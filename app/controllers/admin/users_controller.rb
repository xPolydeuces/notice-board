# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :require_admin!
    before_action :set_user, only: [:edit, :update, :destroy, :reset_password]
    before_action :prevent_superadmin_modification, only: [:edit, :update, :destroy]

    def index
      @users = User.includes(:location).alphabetical.all
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path, notice: t('admin.users.created')
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      # Remove password from params if blank (user doesn't want to change it)
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user.update(user_params)
        redirect_to admin_users_path, notice: t('admin.users.updated')
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      result = Users::DeleteUser.new(user: @user, current_user: current_user).call

      if result.success?
        redirect_to admin_users_path, notice: t('admin.users.deleted')
      else
        error_key = result.errors.first
        redirect_to admin_users_path, alert: t("admin.users.#{error_key}")
      end
    end

    def reset_password
      result = Users::ResetPassword.new(user: @user, current_user: current_user).call

      if result.success?
        flash[:notice] = t('admin.users.password_reset_success', username: @user.username,
                           default: "Password reset for %{username}.")
        flash[:temp_password] = result.temporary_password
        redirect_to admin_users_path
      else
        error_key = result.errors.first
        redirect_to admin_users_path, alert: t("admin.users.#{error_key}",
                                                default: 'Failed to reset password.')
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def prevent_superadmin_modification
      # Only superadmins can modify other superadmin accounts
      if @user.superadmin? && !current_user.superadmin?
        redirect_to admin_users_path, alert: t('admin.users.cannot_modify_superadmin')
      end
    end

    def user_params
      permitted = [:username, :role, :location_id, :password, :password_confirmation]

      # Prevent assignment of superadmin role through form (superadmin is set only via seeds/console)
      if params[:user][:role] == 'superadmin'
        params[:user].delete(:role)
      end

      if @user&.superadmin? && params[:user][:role].present?
        params[:user].delete(:role)
      end
      
      params.require(:user).permit(*permitted)
    end
  end
end