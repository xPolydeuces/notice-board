# frozen_string_literal: true

# Main dashboard controller that displays news posts and RSS feeds
# Handles both general announcements and location-specific content
class DashboardController < ApplicationController
  def index
    @location = find_location
    @locations = fetch_active_locations
    @general_posts = fetch_general_posts
    @location_posts = fetch_location_posts
    @rss_feed_items = fetch_rss_feed_items
  end

  private

  def find_location
    return nil unless params[:location_id].present?

    Location.find_by(id: params[:location_id])
  end

  def fetch_active_locations
    Location.active.ordered.to_a
  end

  def fetch_general_posts
    NewsPost.published
            .active
            .general
            .with_associations
            .by_published_date
            .limit(10)
            .to_a
  end

  def fetch_location_posts
    return [] unless @location

    NewsPost.published
            .active
            .for_location(@location.id)
            .with_associations
            .by_published_date
            .limit(10)
            .to_a
  end

  def fetch_rss_feed_items
    active_feed_ids = RssFeed.active.pluck(:id)
    RssFeedItem.where(rss_feed_id: active_feed_ids)
               .includes(:rss_feed)
               .recent(50)
               .to_a
  end
end