# frozen_string_literal: true

class NewsPost < ApplicationRecord
  # Constants for post types
  POST_TYPES = %w[general location].freeze

  # Associations
  belongs_to :user
  belongs_to :location, optional: true

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :post_type, presence: true, inclusion: { in: POST_TYPES }
  validates :location, presence: true, if: :location_post?

  # Ensure general posts don't have a location
  validate :general_posts_cannot_have_location

  # Scopes
  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :archived, -> { where(archived: true) }
  scope :active, -> { where(archived: false) }
  scope :general, -> { where(post_type: "general") }
  scope :for_location, ->(location_id) { where(post_type: "location", location_id: location_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_published_date, -> { order(published_at: :desc, created_at: :desc) }

  # Type helpers
  def general?
    post_type == "general"
  end

  def location_post?
    post_type == "location"
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

  private

  def general_posts_cannot_have_location
    return unless general? && location_id.present?

    errors.add(:location, "cannot be set for general posts")
  end
end
