require "rails_helper"

RSpec.describe Misc::LocaleSelectorComponent, type: :component do
  describe "rendering" do
    it "renders locale selector with available locales" do
      component = render_inline(described_class.new(current_locale: "pl"))

      expect(component.css(".locale-selector")).to be_present
      expect(component.text).to include("Polski")
      expect(component.text).to include("English")
    end

    it "highlights current locale" do
      component = render_inline(described_class.new(current_locale: "en"))

      expect(component.css("span").text).to include("English")
      expect(component.css("a").text).to include("Polski")
    end

    it "generates correct URLs for locale switching" do
      component = render_inline(described_class.new(current_locale: "pl"))

      links = component.css("a")
      expect(links.first["href"]).to include("locale=en")
    end
  end
end
