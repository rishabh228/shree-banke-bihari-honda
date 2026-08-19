# frozen_string_literal: true

module Public
  class FinanceController < BaseController
    def index
      @settings = current_settings
      @published_bikes = Bike.published_bikes.order(:name)
      @enquiry = Enquiry.new(source: :finance)
    end
  end
end
