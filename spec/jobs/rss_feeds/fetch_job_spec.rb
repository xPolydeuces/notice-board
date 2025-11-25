require "rails_helper"

RSpec.describe RssFeeds::FetchJob, type: :job do
  describe "#perform" do
    let(:rss_feed) { create(:rss_feed) }
    let(:service) { instance_double(RssFeeds::FetchService) }

    before do
      allow(RssFeeds::FetchService).to receive(:new).with(rss_feed: rss_feed).and_return(service)
    end

    context "when fetch is successful" do
      before do
        allow(service).to receive_messages(call: service, success?: true, items_count: 5)
      end

      it "calls the fetch service" do
        described_class.new.perform(rss_feed.id)

        expect(service).to have_received(:call)
      end

      it "logs success message" do
        allow(Rails.logger).to receive(:info)

        described_class.new.perform(rss_feed.id)

        expect(Rails.logger).to have_received(:info).with(/Successfully fetched 5 items/)
      end
    end

    context "when fetch fails" do
      before do
        allow(service).to receive_messages(call: service, success?: false, errors: [:http_error, "404 Not Found"])
      end

      it "logs error message" do
        allow(Rails.logger).to receive(:error)

        described_class.new.perform(rss_feed.id)

        expect(Rails.logger).to have_received(:error).with(/Failed to fetch RSS feed/)
      end
    end
  end
end
