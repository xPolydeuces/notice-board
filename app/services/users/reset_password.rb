module Users
  class ResetPassword < ApplicationService
    attr_reader :user, :current_user

    def initialize(user:, current_user:)
      super()
      @user = user
      @current_user = current_user
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

    # Expose the temporary password for flash message
    def temporary_password
      @temp_password
    end

    private

    def success(temp_password = nil)
      @temp_password = temp_password
      super()
    end
  end
end
