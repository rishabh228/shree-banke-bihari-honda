# frozen_string_literal: true

module Reports
  module Pdf
    class EnquiriesListReport < BaseReport
      private

      def report_title
        "Customer Enquiries Report"
      end

      def table_headers
        [ "Date", "Name", "Phone", "Email", "Source", "Bike", "Status", "Message" ]
      end

      def table_rows
        @records.map do |enquiry|
          [
            format_datetime(enquiry.created_at),
            enquiry.name,
            enquiry.phone,
            enquiry.email.presence || "—",
            enquiry.source_label,
            enquiry.bike&.name || "—",
            humanize_status(enquiry.status),
            truncate_text(enquiry.message, 80)
          ]
        end
      end
    end
  end
end
