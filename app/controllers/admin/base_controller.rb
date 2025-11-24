# frozen_string_literal: true

module Admin
  # Base controller for all admin controllers
  class BaseController < ApplicationController
    include ActionPolicy::Controller

    before_action :authenticate_user!
    before_action :check_force_password_change!

    layout "admin"

    authorize :user, through: :current_user

    private

    # Check if user needs to change password
    def check_force_password_change!
      return unless current_user&.force_password_change?
      return if controller_name == "passwords" && action_name.in?(%w[edit update])

      redirect_to edit_admin_password_path,
                  alert: t("admin.passwords.must_change", default: "You must change your password before continuing.")
    end

    # Use this in controllers that require admin-only access
    def require_admin!
      return if current_user&.admin_or_superadmin?

      redirect_to admin_root_path, alert: t("admin.unauthorized", default: "Brak uprawnień")
    end

    # Use this in controllers that require location or admin access
    def require_location_or_admin!
      return if current_user&.admin_or_superadmin? || current_user&.location?

      redirect_to admin_root_path, alert: t("admin.unauthorized", default: "Brak uprawnień")
    end

    # Use this in controllers that require superadmin-only access
    def require_superadmin!
      return if current_user&.superadmin?

      redirect_to admin_root_path, alert: t("admin.unauthorized", default: "Brak uprawnień")
    end
  end
end
