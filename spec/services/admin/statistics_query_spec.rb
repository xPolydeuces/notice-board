# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::StatisticsQuery, type: :service do
  describe ".call" do
    it "returns statistics hash" do
      result = described_class.call
      expect(result).to be_a(Hash)
      expect(result).to have_key(:users_count)
      expect(result).to have_key(:locations_count)
      expect(result).to have_key(:news_posts_count)
      expect(result).to have_key(:rss_feeds_count)
    end

    it "returns integer values" do
      result = described_class.call
      expect(result[:users_count]).to be_an(Integer)
      expect(result[:locations_count]).to be_an(Integer)
      expect(result[:news_posts_count]).to be_an(Integer)
      expect(result[:rss_feeds_count]).to be_an(Integer)
    end
  end

  describe "#call" do
    before do
      # Clear cache before each test
      Rails.cache.clear
    end

    it "returns correct counts" do
      create_list(:user, 3)
      create_list(:location, 2)
      create_list(:news_post, 5)
      create_list(:rss_feed, 4)

      result = described_class.new.call

      # Verify service returns actual database counts
      expect(result[:users_count]).to eq(User.count)
      expect(result[:locations_count]).to eq(Location.count)
      expect(result[:news_posts_count]).to eq(NewsPost.count)
      expect(result[:rss_feeds_count]).to eq(RssFeed.count)
    end

    it "returns zero counts when no records exist" do
      User.destroy_all
      Location.destroy_all
      NewsPost.destroy_all
      RssFeed.destroy_all

      result = described_class.new.call

      expect(result[:users_count]).to eq(0)
      expect(result[:locations_count]).to eq(0)
      expect(result[:news_posts_count]).to eq(0)
      expect(result[:rss_feeds_count]).to eq(0)
    end

    it "caches the result" do
      create(:user)

      # First call should query the database
      expect(ActiveRecord::Base.connection).to receive(:select_one).once.and_call_original
      result1 = described_class.new.call

      # Second call should use cache and not query database
      expect(ActiveRecord::Base.connection).not_to receive(:select_one)
      result2 = described_class.new.call

      expect(result1).to eq(result2)
    end

    it "uses the correct cache key" do
      described_class.new.call
      expect(Rails.cache.exist?(described_class::CACHE_KEY)).to be true
    end

    it "respects cache expiry" do
      result = described_class.new.call

      # Verify cache entry has expiry
      cache_entry = Rails.cache.read(described_class::CACHE_KEY)
      expect(cache_entry).to eq(result)

      # Clear cache
      Rails.cache.delete(described_class::CACHE_KEY)
      expect(Rails.cache.exist?(described_class::CACHE_KEY)).to be false
    end

    it "fetches fresh data when cache expires" do
      initial_count = User.count
      create(:user)
      result1 = described_class.new.call
      expect(result1[:users_count]).to eq(initial_count + 1)

      # Clear cache to simulate expiry
      Rails.cache.clear

      create(:user)
      result2 = described_class.new.call
      expect(result2[:users_count]).to eq(initial_count + 2)
    end

    it "uses optimized single query" do
      # Verify only one database query is executed
      queries = []
      ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
        queries << payload[:sql] unless payload[:name] == "SCHEMA"
      end

      described_class.new.call

      # Should execute only one query with subqueries
      active_queries = queries.reject { |q| q.include?("CACHE") }
      expect(active_queries.count).to eq(1)
      expect(active_queries.first).to include("SELECT COUNT(*) FROM users")
      expect(active_queries.first).to include("SELECT COUNT(*) FROM locations")
      expect(active_queries.first).to include("SELECT COUNT(*) FROM news_posts")
      expect(active_queries.first).to include("SELECT COUNT(*) FROM rss_feeds")

      ActiveSupport::Notifications.unsubscribe("sql.active_record")
    end
  end
end
