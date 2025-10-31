# frozen_string_literal: true

class RssFeed < ApplicationRecord
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
    last_fetched_at.nil? || last_fetched_at < 1.hour.ago
  end
end
