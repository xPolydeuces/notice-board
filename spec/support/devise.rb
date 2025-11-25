RSpec.configure do |config|
  # Include Devise test helpers for request specs
  config.include Devise::Test::IntegrationHelpers, type: :request
  # Ensure Devise mappings are loaded before running specs
  config.before(:suite) do
    Rails.application.reload_routes!
  end
end
