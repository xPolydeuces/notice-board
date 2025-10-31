# Application Configuration
# This file contains branding and configuration settings

module AppConfig
  # Company/Organization Information
  COMPANY_NAME = ENV.fetch("COMPANY_NAME")
  
  # Logo URL (can be overridden via environment variable)
  LOGO_URL = ENV.fetch("LOGO_URL")
  
  # Application Name
  APP_NAME = ENV.fetch("APP_NAME")
  APP_SUBTITLE = ENV.fetch("APP_SUBTITLE")
  
  # Brand Colors (Tailwind CSS classes)
  COLORS = {
    primary: "#FA812F",
    primary_hover: "#E87020",
    secondary: "#FAB12F",
    cream: "#FEF3E2",
    danger: "#DD0303",
    danger_hover: "#BB0202"
  }.freeze
end
