# frozen_string_literal: true

module Admin
  # Base controller for all admin controllers
  class BaseController < ApplicationController
    include ActionPolicy::Controller
    before_action :authenticate_user!
    before_action :require_admin_access!
    before_action :check_force_password_change!

    layout 'admin'

    authorize :user, through: :current_user

    private

    # All authenticated users can access admin panel
    # Specific permissions are handled by ActionPolicy in individual controllers
    def require_admin_access!
      return if current_user.present?

      redirect_to new_user_session_path, alert: t('admin.access_denied', default: 'Musisz się zalogować')
    end

    # Check if user needs to change password
    def check_force_password_change!
      return unless current_user&.force_password_change?
      return if controller_name == 'passwords' && action_name.in?(['edit', 'update'])

      redirect_to edit_admin_password_path, alert: t('admin.passwords.must_change', default: 'You must change your password before continuing.')
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

    # Helper methods for common redirect and render patterns
    def redirect_with_notice(path, message_key)
      redirect_to path, notice: t(message_key)
    end

    def redirect_with_alert(path, message_key)
      redirect_to path, alert: t(message_key)
    end

    def render_error(template)
      render template, status: :unprocessable_content
    end
  end
end