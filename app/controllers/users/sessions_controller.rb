# frozen_string_literal: true

module Users
  # Custom Devise Sessions Controller
  class SessionsController < Devise::SessionsController
    layout 'devise'

    # GET /users/sign_in
    # def new
    #   super
    # end

    # POST /users/sign_in
    # def create
    #   super
    # end

    # DELETE /users/sign_out
    # def destroy
    #   super
    # end

    protected

    # Redirect to admin panel after sign in
    def after_sign_in_path_for(resource)
      admin_root_path
    end

    # Redirect to sign in page after sign out
    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    # end
  end
end