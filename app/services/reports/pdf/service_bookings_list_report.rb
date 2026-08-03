# frozen_string_literal: true

module Reports
  module Pdf
    class ServiceBookingsListReport < BaseReport
      private

      def report_title
        "Service Bookings Report"
      end

      def table_headers
        [ "Date", "Customer", "Phone", "Vehicle No.", "Bike Model", "Service Type", "Preferred Date", "Advisor", "Status", "Complaint" ]
      end

      def table_rows
        @records.map do |booking|
          [
            format_datetime(booking.created_at),
            booking.customer_name,
            booking.phone,
            booking.vehicle_number,
            booking.bike_model,
            booking.service_type.humanize.titleize,
            format_date(booking.preferred_date),
            booking.assigned_to&.name || "Unassigned",
            humanize_status(booking.status),
            truncate_text(booking.complaint, 50)
          ]
        end
      end
    end
  end
end
