# frozen_string_literal: true

class NewsPost < ApplicationRecord
  # File size limits (in bytes)
  MAX_IMAGE_SIZE = 10.megabytes
  MAX_PDF_SIZE = 20.megabytes

  # Enums for content type
  enum :post_type, { plain_text: "plain_text", rich_text: "rich_text", image_only: "image_only", pdf_only: "pdf_only" }

  # Associations
  belongs_to :user, inverse_of: :news_posts, counter_cache: true
  belongs_to :location, optional: true, inverse_of: :news_posts, counter_cache: true

  # ActiveStorage and ActionText
  has_rich_text :rich_content  # For rich_text type posts
  has_one_attached :image      # For image_only type posts
  has_one_attached :pdf        # For pdf_only type posts

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true, if: :plain_text?
  validates :post_type, presence: true
  validate :validate_post_type_content
  validate :validate_image_format_and_size
  validate :validate_pdf_format_and_size

  private

  def validate_post_type_content
    case post_type
    when "plain_text"
      errors.add(:content, "can't be blank for text posts") if content.blank?
    when "rich_text"
      errors.add(:rich_content, "can't be blank for rich text posts") if rich_content.body.blank?
    when "image_only"
      errors.add(:image, "must be attached for image-only posts") unless image.attached?
    when "pdf_only"
      errors.add(:pdf, "must be attached for PDF posts") unless pdf.attached?
    end
  end

  def validate_image_format_and_size
    return unless image.attached?

    # Validate content type
    unless image.content_type.in?(%w[image/png image/jpg image/jpeg image/gif image/webp])
      errors.add(:image, "must be a PNG, JPG, GIF, or WebP image")
    end

    # Validate file size
    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "must be less than #{MAX_IMAGE_SIZE / 1.megabyte}MB (current size: #{(image.byte_size / 1.megabyte.to_f).round(2)}MB)")
    end
  end

  def validate_pdf_format_and_size
    return unless pdf.attached?

    # Validate content type
    unless pdf.content_type == "application/pdf"
      errors.add(:pdf, "must be a PDF file")
    end

    # Validate file size
    if pdf.byte_size > MAX_PDF_SIZE
      errors.add(:pdf, "must be less than #{MAX_PDF_SIZE / 1.megabyte}MB (current size: #{(pdf.byte_size / 1.megabyte.to_f).round(2)}MB)")
    end
  end

  public

  # Scopes
  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false, archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :active, -> { where(archived: false) }
  scope :general, -> { where(location_id: nil) }  # Posts for all locations
  scope :for_location, ->(location_id) { where(location_id: location_id) }  # Location-specific
  scope :recent, -> { order(created_at: :desc) }
  scope :by_published_date, -> { order(Arel.sql("published_at DESC NULLS LAST, created_at DESC")) }

  # Eager loading associations to avoid N+1 queries
  scope :with_associations, -> { includes(:user, :location).with_rich_text_rich_content.with_attached_image.with_attached_pdf }

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

  # Serialization helpers for JSON/API
  def image_url
    return nil unless image_only? && image.attached?

    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end

  def pdf_url
    return nil unless pdf_only? && pdf.attached?

    Rails.application.routes.url_helpers.rails_blob_path(pdf, only_path: true)
  end

  def rich_content_html
    return nil unless rich_text?

    rich_content.to_s
  end
end