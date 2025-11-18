# frozen_string_literal: true

class RssFeed < ApplicationRecord
  # Associations
  has_many :rss_feed_items, dependent: :destroy

  # Callbacks
  before_validation :strip_url_whitespace

  # Validations
  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  # Mark as fetched
  def mark_as_fetched!
    update!(last_fetched_at: Time.current)
  end

  # Check if feed needs refresh (older than 1 hour)
  def needs_refresh?
    return true if last_fetched_at.nil?

    # Use addition to avoid timing precision issues with comparing two 1.hour.ago evaluations
    last_fetched_at.to_i + 1.hour.to_i < Time.current.to_i
  end

  private

  def strip_url_whitespace
    self.url = url&.strip
  end
end