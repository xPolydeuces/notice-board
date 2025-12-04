# config/puma.rb

# Number of threads to use
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

# Port to bind to (Kamal expects this)
port        ENV.fetch("PORT") { 3000 }, "0.0.0.0"

# Environment
environment ENV.fetch("RAILS_ENV") { "production" }

# Workers for clustered mode (optional, comment out if not needed)
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Preload app for faster worker boot
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
