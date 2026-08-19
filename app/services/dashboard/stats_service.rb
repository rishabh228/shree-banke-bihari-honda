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
        open_enquiries: Enquiry.open.count,
        bikes_sold_this_month: Sale.delivered_this_month.count,
        sales_revenue_this_month: Sale.delivered_this_month.sum(:total_price),
        pending_sales: Sale.pipeline.count,
        bookings_this_month: Sale.where(booked_on: Time.zone.today.all_month).where.not(status: :cancelled).count,
        low_stock_variants: BikeVariant.low_stock.count,
        out_of_stock_variants: BikeVariant.out_of_stock.count
      }
    end

    private

    def unique_customers_count
      phones = Enquiry.pluck(:phone) + TestRide.pluck(:phone) + ServiceBooking.pluck(:phone) + Sale.pluck(:phone)
      phones.compact.uniq.size
    end
  end
end
