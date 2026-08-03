# frozen_string_literal: true

module Dashboard
  class ChartsService
    def self.call
      new.call
    end

    def call
      {
        monthly_enquiries: monthly_enquiries,
        popular_bikes: popular_bikes,
        monthly_test_rides: monthly_test_rides,
        service_stats: service_stats
      }
    end

    private

    def monthly_enquiries
      Enquiry.where(created_at: 6.months.ago..).group_by_month(:created_at, format: "%b %Y").count
    end

    def popular_bikes
      TestRide.group(:bike_id).count.transform_keys { |id| Bike.find_by(id: id)&.name || "Unknown" }
    end

    def monthly_test_rides
      TestRide.where(created_at: 6.months.ago..).group_by_month(:created_at, format: "%b %Y").count
    end

    def service_stats
      ServiceBooking.group(:status).count.transform_keys { |k| k.humanize.titleize }
    end
  end
end
