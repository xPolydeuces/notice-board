module Admin
  # User info component for admin sidebar
  # PERFORMANCE NOTE: When rendering this component in a list, ensure you preload :location
  # Example: User.includes(:location).all
  class UserInfoComponent < ApplicationViewComponent
    option :user, Types.Instance(User)

    def role_badge_class
      if user.admin?
        "bg-red-100 text-red-800"
      elsif user.general?
        "bg-blue-100 text-blue-800"
      elsif user.location_role?
        "bg-green-100 text-green-800"
      else
        "bg-gray-100 text-gray-800"
      end
    end

    def role_name
      return t(".admin") if user.admin?
      return t(".general") if user.general?
      return t(".location", location: user.location&.name) if user.location_role?

      t(".user")
    end
  end
end
