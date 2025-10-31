# frozen_string_literal: true

class Location < ApplicationRecord
  # Associations
  has_many :users, dependent: :nullify
  has_many :news_posts, dependent: :nullify

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
  def has_active_posts?
    news_posts.where(published: true, archived: false).exists?
  end
end
