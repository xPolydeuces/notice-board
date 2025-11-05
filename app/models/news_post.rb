# frozen_string_literal: true

class NewsPost < ApplicationRecord
  # Enums for content type
  enum :post_type, { text: 0, rich_text: 1, image_only: 2 }

  # Associations
  belongs_to :user, inverse_of: :news_posts
  belongs_to :location, optional: true, inverse_of: :news_posts

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :post_type, presence: true

  # Scopes
  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :archived, -> { where(archived: true) }
  scope :active, -> { where(archived: false) }
  scope :general, -> { where(location_id: nil) }  # Posts for all locations
  scope :for_location, ->(location_id) { where(location_id: location_id) }  # Location-specific
  scope :recent, -> { order(created_at: :desc) }
  scope :by_published_date, -> { order(published_at: :desc, created_at: :desc) }

  # Type helpers - check if post is general (no location) or location-specific
  def general?
    location_id.nil?
  end

  def location_specific?
    location_id.present?
  end

  # Publishing
  def publish!
    update!(published: true, published_at: Time.current)
  end

  def unpublish!
    update!(published: false)
  end

  # Archiving
  def archive!
    update!(archived: true, published: false)
  end

  def restore!
    update!(archived: false)
  end

  # Display helpers
  def status_badge
    return "Archived" if archived?
    return "Published" if published?

    "Draft"
  end

  def scope_badge
    general? ? "General" : "Location: #{location.code}"
  end
end
