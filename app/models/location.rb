# frozen_string_literal: true

class Location < ApplicationRecord
  # Associations
  has_many :users, dependent: :nullify, inverse_of: :location
  has_many :news_posts, dependent: :nullify, inverse_of: :location

  # Validations
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:code) }

  # Efficiently filter locations that have at least one active post
  # Use this instead of filtering with has_active_posts? in Ruby to avoid N+1 queries
  scope :with_active_posts, lambda {
    joins(:news_posts)
      .where(news_posts: { published: true, archived: false })
      .distinct
  }

  # Display name with code
  def full_name
    "#{code} - #{name}"
  end

  # Check if location has any published, non-archived news posts
  #
  # For single location: location.has_active_posts? (efficient - uses EXISTS query)
  # For collections: Location.with_active_posts (efficient - single JOIN query)
  #
  # Example:
  #   # Bad (N+1 queries)
  #   locations.select { |loc| loc.has_active_posts? }
  #
  #   # Good (single query)
  #   Location.with_active_posts
  def has_active_posts?
    news_posts.where(published: true, archived: false).exists?
  end

  # Check if location can be safely destroyed
  # A location cannot be deleted if it has associated users or news posts
  def destroyable?
    !users.exists? && !news_posts.exists?
  end

  # Return locations available for a given user based on their role
  # Admins/superadmins can see all active locations
  # Location users can only see their own location
  # General users cannot see any locations (create general posts only)
  def self.available_for(user)
    if user.admin_or_superadmin?
      active.ordered
    elsif user.location?
      where(id: user.location_id)
    else
      none
    end
  end
end