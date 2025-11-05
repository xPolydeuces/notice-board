# frozen_string_literal: true

class User < ApplicationRecord
  # Devise modules - using username instead of email for authentication
  devise :database_authenticatable, :rememberable, :trackable, :timeoutable,
         authentication_keys: [:username]
  
  # Associations
  belongs_to :location, optional: true, inverse_of: :users
  has_many :news_posts, dependent: :nullify, inverse_of: :user

  # Enums
  enum :role, { general: 0, location: 1, admin: 2 }, default: :general

  # Validations
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :username, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "może zawierać tylko litery, cyfry i podkreślenia" }
  validates :username, length: { minimum: 3, maximum: 20 }
  validates :role, presence: true
  validates :location, presence: true, if: :location?
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, allow_blank: true

  # Callbacks
  before_validation :downcase_username

  # Scopes
  scope :alphabetical, -> { order(:username) }
  scope :by_role, ->(role) { where(role: role) }

  # Permission methods
  def can_edit_location?(location)
    admin? || (location? && self.location == location)
  end

  def can_create_general_news?
    admin? || general?
  end

  def can_manage_users?
    admin?
  end

  def can_manage_locations?
    admin?
  end

  def can_manage_rss_feeds?
    admin?
  end

  # Display methods
  def display_name
    username
  end

  def to_s
    display_name
  end

  # Override Devise method to use username for authentication
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  private

  def downcase_username
    self.username = username.to_s.downcase
  end
end
