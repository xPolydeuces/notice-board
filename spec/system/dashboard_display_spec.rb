# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard Display", type: :system do
  let(:user) { create(:user) }
  let(:location) { create(:location) }

  before do
    driven_by(:rack_test)
  end

  describe "viewing the dashboard" do
    context "with general announcements" do
      before do
        create(:news_post, :published, :general, :plain_text,
               user: user,
               title: "General Announcement 1",
               content: "This is a general announcement")
        create(:news_post, :published, :general, :plain_text,
               user: user,
               title: "General Announcement 2",
               content: "Another general announcement")
      end

      it "displays general announcements section" do
        visit root_path

        expect(page).to have_text("Ogłoszenia Ogólne")
        expect(page).to have_text("General Announcement 1")
      end

      it "shows carousel navigation dots" do
        visit root_path

        expect(page).to have_css("[data-dots]")
        expect(page).to have_css("[data-dot]", count: 2)
      end
    end

    context "with location-specific announcements" do
      before do
        create(:news_post, :published, :plain_text,
               user: user,
               location: location,
               title: "Location Announcement",
               content: "This is for a specific location")
      end

      it "displays location announcements when location is specified" do
        visit root_path(location_id: location.id)

        expect(page).to have_text("Ogłoszenia - #{location.name}")
        expect(page).to have_text("Location Announcement")
      end

      it "shows generic location section without location parameter" do
        visit root_path

        expect(page).to have_text("Ogłoszenia Oddziałowe")
        expect(page).to have_text("Wybierz oddział aby zobaczyć ogłoszenia")
      end
    end

    context "with no announcements" do
      it "displays empty message for general announcements" do
        visit root_path

        expect(page).to have_text("Brak ogłoszeń")
      end

      it "does not show navigation dots" do
        visit root_path

        expect(page).not_to have_css("[data-dots]")
      end
    end

    context "with RSS feed items" do
      let(:feed1) { create(:rss_feed, name: "Tech News") }
      let(:feed2) { create(:rss_feed, name: "Weather Updates") }

      before do
        create(:rss_feed_item, rss_feed: feed1, title: "Breaking Tech News")
        create(:rss_feed_item, rss_feed: feed2, title: "Weather Forecast")
      end

      it "displays RSS marquee section" do
        visit root_path

        expect(page).to have_text("Tech News: Breaking Tech News")
        expect(page).to have_text("Weather Updates: Weather Forecast")
      end

      it "shows RSS prefix" do
        visit root_path

        expect(page).to have_text("RSS:")
      end

      it "separates items with bullets" do
        visit root_path

        expect(page).to have_text("•")
      end
    end

    context "with no RSS feed items" do
      it "displays fallback message" do
        visit root_path

        expect(page).to have_text("Bardzo ważne informacje z Warszawy, pobierane z RSS")
      end
    end

    context "with different post types" do
      before do
        create(:news_post, :published, :general, :plain_text,
               user: user,
               title: "Plain Text Post",
               content: "Simple text content")

        create(:news_post, :published, :general, :rich_text,
               user: user,
               title: "Rich Text Post")
      end

      it "renders plain text posts correctly" do
        visit root_path

        expect(page).to have_text("Plain Text Post")
        expect(page).to have_text("Simple text content")
      end

      it "renders rich text posts with formatting" do
        visit root_path

        # Rich text should have prose classes
        expect(page).to have_css(".prose")
      end
    end

    context "layout and styling" do
      before do
        create(:news_post, :published, :general, user: user)
        create(:rss_feed_item)
      end

      it "applies gradient background" do
        visit root_path

        expect(page).to have_css(".notice-board-gradient")
      end

      it "uses flexbox layout" do
        visit root_path

        expect(page).to have_css(".flex.flex-col")
      end

      it "has Stimulus controller attached" do
        visit root_path

        expect(page).to have_css("[data-controller='notice-board']")
      end

      it "sets up carousel targets" do
        visit root_path

        expect(page).to have_css("[data-notice-board-target='carousel']")
      end

      it "sets up marquee targets" do
        visit root_path

        expect(page).to have_css("[data-notice-board-target='marquee']")
        expect(page).to have_css("[data-notice-board-target='marqueeContent']")
      end
    end

    context "with published dates" do
      before do
        travel_to Time.zone.local(2025, 1, 15, 12, 0, 0) do
          create(:news_post, :published, :general, :plain_text,
                 user: user,
                 title: "Recent Post",
                 content: "Content",
                 published_at: Time.current)
        end
      end

      it "displays formatted published date" do
        visit root_path

        # Should show localized date
        expect(page).to have_css(".text-2xl.text-gray-600")
      end
    end

    context "responsive design" do
      it "maintains full screen height" do
        visit root_path

        expect(page).to have_css(".h-screen")
      end

      it "prevents overflow" do
        visit root_path

        expect(page).to have_css(".overflow-hidden")
      end
    end
  end
end