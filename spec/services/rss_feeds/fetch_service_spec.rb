# frozen_string_literal: true

require "rails_helper"

RSpec.describe RssFeeds::FetchService do
  describe "#call" do
    let(:rss_feed) { create(:rss_feed, url: "https://example.com/feed.rss") }
    let(:service) { described_class.new(rss_feed: rss_feed) }

    let(:rss_content) do
      <<~RSS
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Test Feed</title>
            <link>https://example.com</link>
            <description>Test Description</description>
            <item>
              <title>Item 1</title>
              <link>https://example.com/item1</link>
              <description>Description 1</description>
              <pubDate>Mon, 18 Nov 2024 10:00:00 +0000</pubDate>
              <guid>guid-1</guid>
            </item>
            <item>
              <title>Item 2</title>
              <link>https://example.com/item2</link>
              <description>Description 2</description>
              <pubDate>Mon, 18 Nov 2024 11:00:00 +0000</pubDate>
              <guid>guid-2</guid>
            </item>
          </channel>
        </rss>
      RSS
    end

    context "when feed is active" do
      before do
        allow(URI).to receive(:open).and_return(StringIO.new(rss_content))
      end

      it "fetches and parses the feed successfully" do
        result = service.call

        expect(result).to be_success
        expect(result.items_count).to eq(2)
      end

      it "creates RSS feed items" do
        expect { service.call }.to change(RssFeedItem, :count).by(2)
      end

      it "stores correct item attributes" do
        service.call

        item = RssFeedItem.find_by(guid: "guid-1")
        expect(item).to be_present
        expect(item.title).to eq("Item 1")
        expect(item.link).to eq("https://example.com/item1")
        expect(item.description).to eq("Description 1")
      end

      it "does not create duplicate items on subsequent fetches" do
        service.call

        expect { service.call }.not_to change(RssFeedItem, :count)
      end

      it "marks feed as fetched" do
        freeze_time do
          service.call
          expect(rss_feed.reload.last_fetched_at).to be_within(1.second).of(Time.current)
        end
      end
    end

    context "when feed is inactive" do
      let(:rss_feed) { create(:rss_feed, :inactive) }

      it "returns failure" do
        result = service.call

        expect(result).not_to be_success
        expect(result.errors).to include(:feed_inactive)
      end
    end

    context "when fetch fails" do
      before do
        allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new("404 Not Found", nil))
      end

      it "returns failure with error" do
        result = service.call

        expect(result).not_to be_success
        expect(result.errors).to include(:http_error)
      end

      it "marks feed as failed" do
        service.call
        rss_feed.reload

        expect(rss_feed.last_fetched_at).not_to be_nil
        expect(rss_feed.last_successful_fetch_at).to be_nil
        expect(rss_feed.error_count).to eq(1)
        expect(rss_feed.last_error).to be_present
      end
    end

    context "when RSS parsing fails" do
      before do
        allow(URI).to receive(:open).and_return(StringIO.new("invalid xml"))
      end

      it "returns failure" do
        result = service.call

        expect(result).not_to be_success
        expect(result.errors).to include(:rss_parse_error)
      end
    end
  end
end