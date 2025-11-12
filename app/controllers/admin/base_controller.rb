# frozen_string_literal: true

module Admin
  # Base controller for all admin controllers
  class BaseController < ApplicationController
    include ActionPolicy::Controller
    before_action :authenticate_user!
    before_action :require_admin_access!

    layout 'admin'

    authorize :user, through: :current_user

    private

    # All authenticated users can access admin panel
    # Specific permissions are handled by ActionPolicy in individual controllers
    def require_admin_access!
      return if current_user.present?

      redirect_to new_user_session_path, alert: t('admin.access_denied', default: 'Musisz się zalogować')
    end

    # Use this in controllers that require admin-only access
    def require_admin!
      return if current_user&.admin_or_superadmin?

      redirect_to admin_root_path, alert: t('admin.unauthorized', default: 'Brak uprawnień')
    end

    # Use this in controllers that require location or admin access
    def require_location_or_admin!
      return if current_user&.admin_or_superadmin? || current_user&.location?

      redirect_to admin_root_path, alert: t('admin.unauthorized', default: 'Brak uprawnień')
    end

    # Use this in controllers that require superadmin-only access
    def require_superadmin!
      return if current_user&.superadmin?

      redirect_to admin_root_path, alert: t('admin.unauthorized', default: 'Brak uprawnień')
    end
  end
end