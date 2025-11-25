# Authorization policy for NewsPost model
# Controls access based on user roles and location assignments
class NewsPostPolicy < ApplicationPolicy
  # Define which actions are authorized for the current user

  # Anyone authenticated can view news posts (already handled by BaseController)
  def show?
    true
  end

  # Authorization for modifying actions (edit, update, destroy, publish, etc.)
  def manage?
    admin? || location_match? || general_match?
  end

  alias edit? manage?
  alias update? manage?
  alias destroy? manage?
  alias publish? manage?
  alias unpublish? manage?
  alias archive? manage?
  alias restore? manage?

  # Create authorization is handled differently - check if user can create for a given location
  def create?
    true # All authenticated users can create posts (location assignment handled in params)
  end

  # Check if user can assign a specific location to a post
  def assign_location?
    admin?
  end

  # Scope to filter news posts visible to the user
  scope_for :active_record_relation do |relation|
    if user.location?
      # Location users see only their location's posts
      relation.where(location_id: user.location_id)
    else
      # Admins, superadmins, and general users see all posts
      relation
    end
  end

  private

  def admin?
    user.admin_or_superadmin?
  end

  def location_match?
    user.location? && record.location_id == user.location_id
  end

  def general_match?
    user.general? && record.general?
  end
end
