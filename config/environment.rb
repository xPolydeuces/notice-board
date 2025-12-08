# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
lambda { |*args| Rails.application.initialize! }.call