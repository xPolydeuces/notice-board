# frozen_string_literal: true

module Admin
  # Controller for managing user passwords in the admin panel
  class PasswordsController < BaseController
    def edit
      # User can change their own password
    end

    def update
      if current_user.update_with_password(password_params)
        current_user.update_column(:force_password_change, false) if current_user.force_password_change?

        bypass_sign_in(current_user)
        redirect_to admin_root_path, notice: t("admin.passwords.updated", default: "Password successfully updated.")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def password_params
      params.expect(user: %i[current_password password password_confirmation])
    end
  end
end
