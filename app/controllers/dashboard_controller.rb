# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    # Get location from params (optional - for location-specific displays)
    @location = Location.find_by(id: params[:location_id]) if params[:location_id].present?

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

    # Fetch active RSS feeds
    @rss_feeds = RssFeed.active.order(:name).to_a
  end
end