require "rails_helper"

RSpec.describe Misc::LocaleSelectorComponent, type: :component do
  describe "desktop rendering" do
    it "renders locale selector dropdown with current locale" do
      component = render_inline(described_class.new(current_locale: "pl"))

      expect(component.css(".locale-selector")).to be_present
      expect(component.css("button")).to be_present
      expect(component.text).to include("Polski")
      expect(component.text).to include("🇵🇱")
    end

    it "shows current locale in button and other locales in dropdown" do
      component = render_inline(described_class.new(current_locale: "en"))

      button = component.css("button")
      expect(button.text).to include("English")
      expect(button.text).to include("🇺🇸")

      dropdown_links = component.css(".absolute a")
      expect(dropdown_links.text).to include("Polski")
      expect(dropdown_links.text).to include("🇵🇱")
    end

    it "generates correct URLs for locale switching" do
      component = render_inline(described_class.new(current_locale: "pl"))

      links = component.css("a")
      expect(links.first["href"]).to include("locale=en")
    end

    it "includes Stimulus controller data attributes" do
      component = render_inline(described_class.new(current_locale: "pl"))

      expect(component.css('[data-controller="locale-dropdown"]')).to be_present
      expect(component.css('[data-action="click->locale-dropdown#toggle"]')).to be_present
      expect(component.css('[data-locale-dropdown-target="button"]')).to be_present
      expect(component.css('[data-locale-dropdown-target="menu"]')).to be_present
    end
  end

  describe "mobile rendering" do
    it "renders mobile locale selector with all locales visible" do
      component = described_class.new(current_locale: "pl")
      component.mobile_version = true
      rendered = render_inline(component)

      expect(rendered.css(".locale-selector-mobile")).to be_present
      expect(rendered.text).to include("Polski")
      expect(rendered.text).to include("English")
      expect(rendered.text).to include("🇵🇱")
      expect(rendered.text).to include("🇺🇸")
    end

    it "highlights current locale in mobile version" do
      component = described_class.new(current_locale: "en")
      component.mobile_version = true
      rendered = render_inline(component)

      # Current locale should be highlighted
      highlighted = rendered.css(".bg-gray-100")
      expect(highlighted.text).to include("English")
      expect(highlighted.text).to include("🇺🇸")

      # Other locales should be links
      links = rendered.css("a")
      expect(links.text).to include("Polski")
      expect(links.text).to include("🇵🇱")
    end

    it "does not include dropdown functionality in mobile version" do
      component = described_class.new(current_locale: "pl")
      component.mobile_version = true
      rendered = render_inline(component)

      expect(rendered.css('[data-controller="locale-dropdown"]')).to be_empty
      expect(rendered.css("button")).to be_empty
    end
  end
end
