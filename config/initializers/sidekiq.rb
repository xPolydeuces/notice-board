# frozen_string_literal: true

require "sidekiq/cron/job"

Sidekiq.configure_server do |config|
  # Catch N+1 queries in Sidekiq using Prosopite
  unless Rails.env.production?
    config.server_middleware do |chain|
      require "prosopite/middleware/sidekiq"
      chain.add(Prosopite::Middleware::Sidekiq)
    end
  end

  # Configure recurring jobs
  schedule_file = Rails.root.join("config/sidekiq_schedule.yml")

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
    Rails.logger.info("Sidekiq schedule loaded successfully")
  else
    Rails.logger.warn("Sidekiq schedule file not found: #{schedule_file}")
  end
end
