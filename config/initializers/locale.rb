# Configure I18n (internationalization) settings
Rails.application.configure do
  # Set default locale to Polish
  config.i18n.default_locale = :pl

  # Set available locales (Polish and English)
  config.i18n.available_locales = %i[pl en]

  # Raise errors on missing translations in development/test
  config.i18n.raise_on_missing_translations = true if Rails.env.local?

  # Fall back to default locale if translation is missing
  config.i18n.fallbacks = true
end
