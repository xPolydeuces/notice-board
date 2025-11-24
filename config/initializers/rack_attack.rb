# frozen_string_literal: true

# Skip Rack::Attack configuration in test environment to avoid conflicts with ActionPolicy
unless Rails.env.test?
  module Rack
    class Attack
      # Throttle all requests by IP (60rpm)
      # Allows 60 requests per 1 minute per IP
      throttle("req/ip", limit: 60, period: 1.minute, &:ip)

      # Throttle POST requests to /users/sign_in by IP address
      # Allows 5 requests per 20 seconds
      throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
        req.ip if req.path == "/users/sign_in" && req.post?
      end

      # Throttle POST requests to /users/sign_in by username parameter
      # Allows 5 requests per 20 seconds
      throttle("logins/username", limit: 5, period: 20.seconds) do |req|
        if req.path == "/users/sign_in" && req.post?
          # Return the username if present, otherwise nil
          req.params["user"]&.dig("username")
        end
      end

      # Exponential backoff for repeat offenders
      # Block IPs that hit the limit 10 times in 1 hour
      blocklist("fail2ban") do |req|
        # `filter` returns truthy value if request fails, or if it's from a previously banned IP
        # so request is blocked
        Rack::Attack::Fail2Ban.filter("fail2ban-#{req.ip}", maxretry: 10, findtime: 1.hour, bantime: 24.hours) do
          # The count for the IP is incremented if the return value is truthy
          CGI.unescape(req.query_string).include?("/etc/passwd") ||
            req.path.include?("/etc/passwd") ||
            req.path.include?("..") ||
            req.path.include?("wp-admin") ||
            req.path.include?("wp-login")
        end
      end

      # Custom response for throttled requests
      self.throttled_responder = lambda do |env|
        retry_after = (env["rack.attack.match_data"] || {})[:period]
        [
          429,
          {
            "Content-Type" => "text/plain",
            "Retry-After" => retry_after.to_s
          },
          ["Zbyt wiele żądań. Spróbuj ponownie za #{retry_after} sekund.\n"]
        ]
      end

      # Custom response for blocklisted requests
      self.blocklisted_responder = lambda do |_env|
        [
          403,
          { "Content-Type" => "text/plain" },
          ["Dostęp zablokowany\n"]
        ]
      end

      # Log blocked requests
      ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
        req = payload[:request]
        Rails.logger.warn "[Rack::Attack][Throttled] #{req.ip} #{req.request_method} #{req.fullpath}"
      end

      ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |_name, _start, _finish, _request_id, payload|
        req = payload[:request]
        Rails.logger.warn "[Rack::Attack][Blocked] #{req.ip} #{req.request_method} #{req.fullpath}"
      end
    end
  end
end
