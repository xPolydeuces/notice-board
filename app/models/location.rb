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

  # Display name with code
  def full_name
    "#{code} - #{name}"
  end

  # Check if location has any published news posts
  # PERFORMANCE NOTE: When calling this on a collection, use a database query instead:
  #   Location.joins(:news_posts).where(news_posts: { published: true, archived: false }).distinct
  # Or consider adding a counter_cache for better performance with frequent checks
  def has_active_posts?
    news_posts.where(published: true, archived: false).exists?
  end
end
