# Load the Rails application.
require_relative "application"

# Add this right above Rails.application.initialize! in config/environment.rb
module Rails
  class Application
    def initialize_with_optional_arg(*args)
      puts "WARNING: initialize! called with args: #{args.inspect}"
      initialize_without_optional_arg # Call the original method
    end
    alias_method :initialize_without_optional_arg, :initialize!
    alias_method :initialize!, :initialize_with_optional_arg
  end
end

# Initialize the Rails application.
Rails.application.initialize!
