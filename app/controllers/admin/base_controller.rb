# frozen_string_literal: true

module Admin
  # Base controller for all admin controllers
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin_access!
    
    layout 'admin'

    private

    # All authenticated users can access admin panel
    # Specific permissions are handled by ActionPolicy in individual controllers
    def require_admin_access!
      return if current_user.present?

      redirect_to new_user_session_path, alert: t('admin.access_denied', default: 'Musisz się zalogować')
    end

    # Use this in controllers that require admin-only access
    def require_admin!
      return if current_user&.admin?

      redirect_to admin_root_path, alert: t('admin.unauthorized', default: 'Brak uprawnień')
    end

    # Use this in controllers that require location or admin access
    def require_location_or_admin!
      return if current_user&.admin? || current_user&.location?

      redirect_to admin_root_path, alert: t('admin.unauthorized', default: 'Brak uprawnień')
    end
  end
end