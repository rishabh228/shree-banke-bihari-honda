# frozen_string_literal: true

module Reports
  module Pdf
    class BikesListReport < BaseReport
      private

      def report_title
        "Bike Catalog Report"
      end

      def table_headers
        [ "Name", "Category", "Engine", "Mileage", "Starting Price", "Variants", "Status" ]
      end

      def table_rows
        @records.map do |bike|
          [
            bike.name,
            bike.category.presence || "—",
            bike.engine.presence || "—",
            bike.mileage.presence || "—",
            format_currency(bike.starting_price),
            bike.bike_variants.size.to_s,
            humanize_status(bike.status)
          ]
        end
      end
    end
  end
end
