# frozen_string_literal: true

class User < ApplicationRecord
  # Devise modules - removed :registerable since admins create users
  devise :database_authenticatable, :rememberable, :validatable,
         authentication_keys: [:username]

  # Associations
  belongs_to :location, optional: true
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :news_posts, dependent: :nullify

  # Validations
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :location, presence: true, if: :location_role?

  # Make email optional for Devise
  def email_required?
    false
  end

  def email_changed?
    false
  end

  # Role helper methods
  def admin?
    roles.exists?(id: Role::ADMIN_ID)
  end

  def general?
    roles.exists?(id: Role::GENERAL_ID)
  end

  def location_role?
    roles.exists?(id: Role::LOCATION_ID)
  end

  # For display purposes
  def role
    return "admin" if admin?
    return "general" if general?
    return "location" if location_role?

    "none"
  end

  # Check if user can manage posts for a specific location
  def can_manage_location?(location_id)
    return true if admin? || general?
    return false unless location_role?

    self.location_id == location_id
  end
end
