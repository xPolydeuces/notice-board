# Header visible on every page
class HeaderComponent < ApplicationViewComponent
  option :current_user, Types::Instance(User).optional

  private

  attr_reader :current_user

  def user_signed_in?
    current_user.present?
  end
end
