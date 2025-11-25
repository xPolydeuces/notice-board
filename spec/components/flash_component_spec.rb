require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  describe "rendering" do
    context "with no flash messages" do
      it "does not render" do
        render_inline(described_class.new(flash: {}))
        expect(page).to have_no_css(".flash-message")
      end
    end

    context "with a notice flash message" do
      it "renders the notice message" do
        render_inline(described_class.new(flash: { notice: "Success!" }))

        expect(page).to have_text("Success!")
        expect(page).to have_css(".bg-green-100")
        expect(page).to have_css(".text-green-800")
      end
    end

    context "with an alert flash message" do
      it "renders the alert message" do
        render_inline(described_class.new(flash: { alert: "Error occurred!" }))

        expect(page).to have_text("Error occurred!")
        expect(page).to have_css(".bg-red-100")
        expect(page).to have_css(".text-red-800")
      end
    end

    context "with a warning flash message" do
      it "renders the warning message" do
        render_inline(described_class.new(flash: { warning: "Be careful!" }))

        expect(page).to have_text("Be careful!")
        expect(page).to have_css(".bg-yellow-100")
        expect(page).to have_css(".text-yellow-800")
      end
    end

    context "with an info flash message" do
      it "renders the info message" do
        render_inline(described_class.new(flash: { info: "Just so you know" }))

        expect(page).to have_text("Just so you know")
        expect(page).to have_css(".bg-blue-100")
        expect(page).to have_css(".text-blue-800")
      end
    end

    context "with multiple flash messages" do
      it "renders all messages" do
        render_inline(described_class.new(flash: {
                                            notice: "Success!",
                                            alert: "Error!",
                                            warning: "Warning!"
                                          }))

        expect(page).to have_text("Success!")
        expect(page).to have_text("Error!")
        expect(page).to have_text("Warning!")
      end
    end

    context "with dismissible option" do
      it "renders dismiss button when dismissible is true" do
        render_inline(described_class.new(flash: { notice: "Success!" }, dismissible: true))

        expect(page).to have_css("button[data-action*='click']")
      end

      it "does not render dismiss button when dismissible is false" do
        render_inline(described_class.new(flash: { notice: "Success!" }, dismissible: false))

        expect(page).to have_no_css("button[data-action*='click']")
      end
    end

    context "with unknown flash type" do
      it "uses info styling as default" do
        render_inline(described_class.new(flash: { unknown: "Unknown type" }))

        # Should not render unknown types that aren't in FLASH_TYPES
        expect(page).to have_no_text("Unknown type")
      end
    end
  end

  describe "#flash_messages" do
    it "filters only valid flash types" do
      component = described_class.new(flash: {
                                        notice: "Valid",
                                        unknown: "Invalid",
                                        alert: "Also valid"
                                      })

      messages = component.flash_messages
      expect(messages.keys).to contain_exactly("notice", "alert")
    end
  end

  describe "#flash_config" do
    subject(:component) { described_class.new }

    it "returns correct config for notice" do
      config = component.flash_config(:notice)
      expect(config[:icon]).to eq("check-circle")
      expect(config[:bg]).to eq("bg-green-100")
    end

    it "returns correct config for alert" do
      config = component.flash_config(:alert)
      expect(config[:icon]).to eq("alert-circle")
      expect(config[:bg]).to eq("bg-red-100")
    end

    it "returns info config for unknown types" do
      config = component.flash_config(:unknown)
      expect(config[:icon]).to eq("info")
      expect(config[:bg]).to eq("bg-blue-100")
    end
  end

  describe "#render?" do
    it "returns true when flash messages exist" do
      component = described_class.new(flash: { notice: "Success!" })
      expect(component.render?).to be true
    end

    it "returns false when no flash messages exist" do
      component = described_class.new(flash: {})
      expect(component.render?).to be false
    end

    it "returns false when only invalid flash types exist" do
      component = described_class.new(flash: { unknown: "Invalid" })
      expect(component.render?).to be false
    end
  end
end
