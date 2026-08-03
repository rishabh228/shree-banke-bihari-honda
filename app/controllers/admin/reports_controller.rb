# frozen_string_literal: true

module Admin
  class ReportsController < BaseController
    def index
      authorize :report, :index?

      @charts = Dashboard::ChartsService.call
      @stats = Dashboard::StatsService.call
    end
  end
end
