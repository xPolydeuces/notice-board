# Application Roles for user authorization
class Role < ApplicationRecord
  ADMIN_ID = 1
  GENERAL_ID = 2
  LOCATION_ID = 3

  validates :name, presence: true, uniqueness: true

  def self.admin
    find(ADMIN_ID)
  end

  def self.general
    find(GENERAL_ID)
  end

  def self.location
    find(LOCATION_ID)
  end
end
