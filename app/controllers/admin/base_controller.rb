# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin_access!
    
    layout "admin"

    private

    def authorize_admin_access!
      unless current_user.admin? || current_user.general? || current_user.location_role?
        redirect_to root_path, alert: "Nie masz dostępu do panelu administracyjnego."
      end
    end
  end
end
