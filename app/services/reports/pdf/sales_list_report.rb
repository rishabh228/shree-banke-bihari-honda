# frozen_string_literal: true

module Reports
  module Pdf
    class SalesListReport < BaseReport
      private

      def report_title
        "Sales & Bookings Report"
      end

      def table_headers
        [ "Date", "Customer", "Phone", "Bike", "Variant", "Total Price", "Booking Amt", "Payment", "Executive", "Status", "Delivery" ]
      end

      def table_rows
        @records.map do |sale|
          [
            format_date(sale.booked_on || sale.quoted_on || sale.created_at.to_date),
            sale.customer_name,
            sale.phone,
            sale.bike.name,
            sale.bike_variant&.name || "—",
            format_currency(sale.total_price),
            format_currency(sale.booking_amount),
            sale.display_payment_mode,
            sale.sales_executive.name,
            humanize_status(sale.status),
            format_date(sale.delivery_date)
          ]
        end
      end
    end
  end
end
