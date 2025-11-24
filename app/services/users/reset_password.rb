# frozen_string_literal: true

module Users
  # Service to reset user passwords and generate temporary credentials
  class ResetPassword
    attr_reader :user, :current_user, :errors

    def initialize(user:, current_user:)
      @user = user
      @current_user = current_user
      @errors = []
    end

    def call
      return failure(:cannot_reset_own) if user == current_user

      temp_password = user.generate_temporary_password

      if user.save
        success(temp_password)
      else
        failure(:save_failed)
      end
    end

    def success?
      @success == true
    end

    # Expose the temporary password for flash message
    def temporary_password
      @temp_password
    end

    private

    def success(temp_password)
      @success = true
      @temp_password = temp_password
      self
    end

    def failure(reason)
      @success = false
      @errors << reason
      self
    end
  end
end