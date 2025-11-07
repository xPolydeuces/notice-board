# frozen_string_literal: true

class NewsPost < ApplicationRecord
  # Enums for content type
  enum :post_type, { plain_text: 0, rich_text: 1, image_only: 2 }

  # Associations
  belongs_to :user, inverse_of: :news_posts, counter_cache: true
  belongs_to :location, optional: true, inverse_of: :news_posts, counter_cache: true

  # ActiveStorage and ActionText
  has_rich_text :rich_content  # For rich_text type posts
  has_one_attached :image      # For image_only type posts

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true, if: :plain_text?
  validates :post_type, presence: true
  validate :validate_post_type_content

  private

  def validate_post_type_content
    case post_type.to_sym
    when :plain_text
      errors.add(:content, "can't be blank for text posts") if content.blank?
    when :rich_text
      errors.add(:rich_content, "can't be blank for rich text posts") if rich_content.body.blank?
    when :image_only
      errors.add(:image, "must be attached for image-only posts") unless image.attached?
    end
  end

  public

  # Scopes
  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :archived, -> { where(archived: true) }
  scope :active, -> { where(archived: false) }
  scope :general, -> { where(location_id: nil) }  # Posts for all locations
  scope :for_location, ->(location_id) { where(location_id: location_id) }  # Location-specific
  scope :recent, -> { order(created_at: :desc) }
  scope :by_published_date, -> { order(published_at: :desc, created_at: :desc) }

  # Eager loading associations to avoid N+1 queries
  scope :with_associations, -> { includes(:user, :location) }

  # Combined scope for displaying posts
  scope :for_display, -> { published.active.with_associations.by_published_date }


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