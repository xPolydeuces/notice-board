# Application-wide configuration
module AppConfig
  # Brand colors
  BRAND_COLORS = {
    primary: "#FAB12F",
    secondary: "#FA812F",
    accent: "#DD0303",
    background: "#FEF3E2"
  }.freeze

  # Application name and branding
  APP_NAME = ENV.fetch("APP_NAME", "Tablica Ogłoszeń")
  APP_SUBTITLE = ENV.fetch("APP_SUBTITLE", "Panel Administracyjny")
  COMPANY_NAME = ENV.fetch("COMPANY_NAME", "Your Company")
  LOGO_URL = ENV.fetch("LOGO_URL", "")
  LOCATION = ENV.fetch("LOCATION", "Lokalizacja")

  # Default pagination
  DEFAULT_PER_PAGE = 25

  # News post settings
  NEWS_POST_TITLE_MAX_LENGTH = 200
  NEWS_POST_CONTENT_MAX_LENGTH = 5000

  # RSS feed settings
  RSS_FEED_REFRESH_INTERVAL = 15.minutes
  RSS_FEED_MAX_ITEMS = 10

  # Location settings
  DEFAULT_LOCATION_PREFIX = "R-".freeze
end
