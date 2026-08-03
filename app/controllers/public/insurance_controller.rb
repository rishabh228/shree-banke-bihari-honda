# frozen_string_literal: true

module Public
  class InsuranceController < BaseController
    def index
      @settings = current_settings
      @published_bikes = Bike.published_bikes.order(:name)
      @enquiry = Enquiry.new(source: :insurance)
    end
  end
end
