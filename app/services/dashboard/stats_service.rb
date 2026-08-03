# frozen_string_literal: true

module Dashboard
  class StatsService
    def self.call
      new.call
    end

    def call
      {
        today_enquiries: Enquiry.today.count,
        today_test_rides: TestRide.today.count,
        today_services: ServiceBooking.today.count,
        total_customers: unique_customers_count,
        active_bikes: Bike.published_bikes.count,
        active_offers: Offer.current.count,
        pending_test_rides: TestRide.pending.count,
        pending_services: ServiceBooking.pending.count,
        open_enquiries: Enquiry.open.count
      }
    end

    private

    def unique_customers_count
      phones = Enquiry.pluck(:phone) + TestRide.pluck(:phone) + ServiceBooking.pluck(:phone)
      phones.compact.uniq.size
    end
  end
end
