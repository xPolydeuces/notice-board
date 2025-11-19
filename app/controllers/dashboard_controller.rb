# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    # Get location from params (optional - for location-specific displays)
    @location = Location.find_by(id: params[:location_id]) if params[:location_id].present?

    # Fetch all active locations for the selector
    @locations = Location.active.ordered.to_a

    # Fetch general announcements (visible everywhere)
    @general_posts = NewsPost.published
                             .active
                             .general
                             .with_associations
                             .by_published_date
                             .limit(10)
                             .to_a

    # Fetch location-specific announcements
    if @location
      @location_posts = NewsPost.published
                                .active
                                .for_location(@location.id)
                                .with_associations
                                .by_published_date
                                .limit(10)
                                .to_a
    else
      @location_posts = []
    end

    # Fetch recent RSS feed items from active feeds
    active_feed_ids = RssFeed.active.pluck(:id)
    @rss_feed_items = RssFeedItem.where(rss_feed_id: active_feed_ids)
                                  .includes(:rss_feed)
                                  .recent(50)
                                  .to_a
  end
end