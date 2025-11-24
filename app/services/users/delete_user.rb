# frozen_string_literal: true

module Users
  # Service to safely delete users with authorization checks
  class DeleteUser
    attr_reader :user, :current_user, :errors

    def initialize(user:, current_user:)
      @user = user
      @current_user = current_user
      @errors = []
    end

    def call
      return failure(:cannot_delete_self) if user == current_user
      return failure(:cannot_delete_admin) if unauthorized_admin_deletion?
      return failure(:cannot_delete_last_superadmin) if last_superadmin?

      if user.destroy
        success
      else
        failure(:destroy_failed)
      end
    end

    def success?
      @success == true
    end

    private

    def unauthorized_admin_deletion?
      user.admin_or_superadmin? && !current_user.superadmin?
    end

    def last_superadmin?
      user.superadmin? && User.where(role: :superadmin).count == 1
    end

    def success
      @success = true
      self
    end

    def failure(reason)
      @success = false
      @errors << reason
      self
    end
  end
end