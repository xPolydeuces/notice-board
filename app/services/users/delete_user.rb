module Users
  class DeleteUser < ApplicationService
    attr_reader :user, :current_user

    def initialize(user:, current_user:)
      super()
      @user = user
      @current_user = current_user
    end

    def call
      return failure(:cannot_delete_self) if user == current_user
      return failure(:cannot_delete_admin) if unauthorized_admin_deletion?

      # Use transaction with lock to prevent race condition when checking last superadmin
      ActiveRecord::Base.transaction do
        return failure(:cannot_delete_last_superadmin) if last_superadmin_with_lock?

        if user.destroy
          success
        else
          failure(:destroy_failed)
        end
      end
    end

    private

    def unauthorized_admin_deletion?
      user.admin_or_superadmin? && !current_user.superadmin?
    end

    def last_superadmin_with_lock?
      user.superadmin? && User.lock.where(role: :superadmin).one?
    end
  end
end