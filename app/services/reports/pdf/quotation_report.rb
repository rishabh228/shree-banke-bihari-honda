# frozen_string_literal: true

module Reports
  module Pdf
    class QuotationReport < BaseReport
      def initialize(sale, settings: Setting.instance)
        @sale = sale
        super([ sale ], settings: settings)
      end

      def render
        Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
          render_header(pdf)
          render_customer(pdf)
          render_bike_details(pdf)
          render_pricing(pdf)
          render_terms(pdf)
          render_footer(pdf)
        end.render
      end

      private

      def report_title
        "Quotation / Sale Summary"
      end

      def page_layout
        :portrait
      end

      def render_table(pdf); end

      def render_customer(pdf)
        pdf.text "Customer Details", size: 11, style: :bold
        pdf.move_down 6
        pdf.text "Name: #{@sale.customer_name}"
        pdf.text "Phone: #{@sale.phone}"
        pdf.text "Email: #{@sale.email.presence || '—'}"
        pdf.text "Address: #{@sale.address.presence || '—'}"
        pdf.move_down 12
      end

      def render_bike_details(pdf)
        pdf.text "Vehicle Details", size: 11, style: :bold
        pdf.move_down 6
        pdf.text "Model: #{@sale.bike.name}"
        pdf.text "Variant: #{@sale.bike_variant&.name || 'Standard'}"
        pdf.text "Color: #{@sale.bike_variant&.color || '—'}"
        pdf.text "Sales Executive: #{@sale.sales_executive.name}"
        pdf.text "Status: #{@sale.display_status}"
        pdf.move_down 12
      end

      def render_pricing(pdf)
        rows = [
          [ "Description", "Amount (Rs.)" ],
          [ "Ex-Showroom Price", @sale.ex_showroom_price.to_i.to_s ],
          [ "Insurance", @sale.insurance.to_i.to_s ],
          [ "RTO", @sale.rto.to_i.to_s ],
          [ "Other Charges", @sale.other_charges.to_i.to_s ],
          [ "Total On-Road Price", @sale.total_price.to_i.to_s ],
          [ "Booking Amount Paid", @sale.booking_amount.to_i.to_s ]
        ]

        pdf.table(rows, width: pdf.bounds.width, cell_style: { size: 10, padding: [ 5, 8, 5, 8 ] }) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
          row(-2).font_style = :bold
        end
        pdf.move_down 12
      end

      def render_terms(pdf)
        pdf.text "Terms & Conditions", size: 10, style: :bold
        pdf.move_down 4
        pdf.text "Prices are indicative and subject to change. Booking amount is non-refundable as per showroom policy. " \
                 "Delivery timeline depends on stock availability and RTO processing.",
                 size: 9, color: "666666"
      end
    end
  end
end
