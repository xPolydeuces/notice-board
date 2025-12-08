source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.1"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails", "~> 1.3"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.3"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails", "~> 1.4"
# Authorization framework
gem "action_policy", "~> 0.7.5"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", "~> 2.9", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1", require: false

# Background job processing
gem "sidekiq", "~> 8.0"
gem "sidekiq-cron", "~> 2.0"

# Redis for caching and Sidekiq
gem "redis", ">= 5.0"

# Pin connection_pool to 2.x for Rails 8.1 compatibility
gem "connection_pool", "~> 2.4"

# RSS feed parsing
gem "rss"

# Authentication framework
gem "devise", "~> 4.9"
gem "devise-i18n", "~> 1.15"

# A framework for creating reusable, testable & encapsulated view components
gem "view_component", "~> 4.1"

# Dry family
gem "dry-initializer", "~> 3.2" # A simple way to create initializer methods
gem "dry-types", "~> 1.8" # Type system for Ruby

# Lograge for 1 line logging
gem "lograge", "~> 0.14"

# Haml for HTML templates
gem "haml-rails", "~> 3.0"

# Catch unsafe migrations in development
gem "strong_migrations", "~> 2.5"

# Internationalization for Rails
gem "rails-i18n", "~> 8.0"

# Find N+1 queries
gem "pg_query", "~> 6.1"
gem "prosopite", "~> 2.1"

# PGHero for database monitoring
gem "pghero", "~> 3.7"

# Lucide Icons for Rails
gem "lucide-rails", "~> 0.7"

# Rack middleware for rate limiting
gem "rack-attack", "~> 6.7"

# Pagination
gem "kaminari", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Audit gem vulnerabilities [https://github.com/rubysec/bundler-audit]
  gem "bundler-audit", require: false

  # Load environment variables from .env file
  gem "dotenv-rails"

  # Rubocop for code style
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false

  # Avoid various issues due to inconsistencies and inefficiencies between a database schema and application models
  gem "database_consistency", require: false

  # Detect inconsistencies between a database schema and application models
  gem "active_record_doctor"

  # Rspec as testing framework
  gem "rspec-rails"

  # Capybara for feature and system tests
  gem "capybara"

  # HTML to Haml converter
  gem "html2haml"

  # Factories for database seeding
  gem "factory_bot_rails"

  # Faker for generating fake data
  gem "faker"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # Manage Procfile-based applications
  gem "foreman"
end

group :test do
  # Sidekiq testing helpers
  gem "rspec-sidekiq"

  # Code coverage for tests
  gem "simplecov", require: false

  # one-liners to test common Rails functionality that
  gem "shoulda-matchers"

  # Clean up the database between tests
  gem "database_cleaner-active_record"
end
