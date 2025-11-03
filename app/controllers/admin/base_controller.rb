# frozen_string_literal: true

module Admin
  # Base controller for all admin controllers
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin_access!
    
    layout 'admin'

    private

    def require_admin_access!
      unless current_user&.admin? || current_user&.general? || current_user&.location_role?
        redirect_to root_path, alert: t('admin.access_denied', default: 'Brak dostępu do panelu administratora')
      end
    end
  end
end
