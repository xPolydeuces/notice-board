# Represents an individual item from an RSS feed
class RssFeedItem < ApplicationRecord
  belongs_to :rss_feed

  validates :title, presence: true
  validates :guid, presence: true, uniqueness: { scope: :rss_feed_id }

  after_destroy :clear_dashboard_cache
  # Callbacks
  after_save :clear_dashboard_cache

  scope :ordered, -> { order(published_at: :desc, created_at: :desc) }
  scope :recent, ->(limit = 50) { ordered.limit(limit) }

  # Returns the display text for this feed item
  def display_text
    title
  end

  private

  # Clear dashboard RSS cache when feed items change
  def clear_dashboard_cache
    Rails.cache.delete("dashboard/rss_feed_items")
  end
end
