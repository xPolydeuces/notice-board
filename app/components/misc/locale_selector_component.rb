module Misc
  class LocaleSelectorComponent < ApplicationViewComponent
    AVAILABLE_LOCALES = %w[pl en].freeze

    def initialize(current_locale: I18n.locale)
      @current_locale = current_locale.to_s
    end

    private

    attr_reader :current_locale

    def available_locales
      AVAILABLE_LOCALES
    end

    def locale_name(locale)
      case locale
      when 'pl' then 'Polski'
      when 'en' then 'English'
      else locale.upcase
      end
    end

    def locale_url(locale)
      url_for(locale: locale)
    end
  end
end
