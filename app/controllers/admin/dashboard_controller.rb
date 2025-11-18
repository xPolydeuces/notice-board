# frozen_string_literal: true

module Admin
  # Dashboard controller for admin panel home page
  class DashboardController < BaseController
    def index
      @stats = Admin::StatisticsQuery.call
    end
  end
end
