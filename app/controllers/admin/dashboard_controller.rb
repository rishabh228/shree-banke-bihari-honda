# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      authorize :dashboard, :index?

      @stats = Dashboard::StatsService.call
      @charts = Dashboard::ChartsService.call
      @upcoming_test_rides = TestRide.upcoming.includes(:bike).limit(10)
    end
  end
end
