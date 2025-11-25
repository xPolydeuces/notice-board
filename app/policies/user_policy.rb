# Authorization policy for User model
# Controls user management based on roles and permissions
class UserPolicy < ApplicationPolicy
  # Index and viewing user list
  def index?
    user.admin_or_superadmin?
  end

  # Creating new users
  def create?
    user.admin_or_superadmin?
  end

  alias new? create?

  # Editing and updating users
  def update?
    user.admin_or_superadmin? && can_modify?
  end

  alias edit? update?

  # Deleting users
  def destroy?
    user.admin_or_superadmin? && can_modify?
  end

  # Resetting passwords
  def reset_password?
    user.admin_or_superadmin? && record != user
  end

  # Assigning superadmin role
  def assign_superadmin_role?
    user.superadmin?
  end

  # Check if user can modify locations
  def manage_locations?
    user.admin_or_superadmin?
  end

  # Check if user can manage RSS feeds
  def manage_rss_feeds?
    user.admin_or_superadmin?
  end

  private

  # Only superadmins can modify other superadmin accounts
  def can_modify?
    return true unless record.superadmin?

    user.superadmin?
  end
end
