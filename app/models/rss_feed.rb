# Represents an RSS feed source that can be fetched and displayed
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
  scope :healthy, -> { where(error_count: ...3) }
  scope :unhealthy, -> { where(error_count: 3..) }

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

  # Check if feed needs refresh (older than 1 hour)
  def needs_refresh?
    return true if last_fetched_at.nil?

    # Use addition to avoid timing precision issues with comparing two 1.hour.ago evaluations
    last_fetched_at.to_i + 1.hour.to_i < Time.current.to_i
  end

  # Health status
  def health_status
    return :healthy if error_count.zero?
    return :warning if error_count < 3
    return :critical if error_count >= 3

    :unknown
  end

  def healthy?
    health_status == :healthy
  end

  def errors?
    error_count.positive?
  end

  private

  def strip_url_whitespace
    self.url = url&.strip
  end
end
