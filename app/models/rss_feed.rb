# frozen_string_literal: true

class RssFeed < ApplicationRecord
  # Refresh interval
  REFRESH_INTERVAL = 1.hour

  # Health status thresholds
  ERROR_WARNING_THRESHOLD = 3
  ERROR_CRITICAL_THRESHOLD = 3

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
  scope :healthy, -> { where(error_count: ...ERROR_WARNING_THRESHOLD) }
  scope :unhealthy, -> { where(error_count: ...ERROR_CRITICAL_THRESHOLD) }

  # Mark as fetched successfully
  def mark_as_fetched!
    update!(
      last_fetched_at: Time.current,
      last_successful_fetch_at: Time.current,
      last_error: nil,
      error_count: 0
    )
  end

  # Mark as failed
  def mark_as_failed!(error_message)
    update!(
      last_fetched_at: Time.current,
      last_error: error_message.to_s.truncate(1000),
      error_count: error_count + 1
    )
  end

  # Check if feed needs refresh
  def needs_refresh?
    return true if last_fetched_at.nil?

    last_fetched_at <= REFRESH_INTERVAL.ago
  end

  # Health status
  def health_status
    return :healthy if error_count.zero?
    return :warning if error_count < ERROR_WARNING_THRESHOLD
    return :critical if error_count >= ERROR_CRITICAL_THRESHOLD

    :unknown
  end

  def healthy?
    health_status == :healthy
  end

  def has_errors?
    error_count.positive?
  end

  private

  def strip_url_whitespace
    self.url = url&.strip
  end
end
