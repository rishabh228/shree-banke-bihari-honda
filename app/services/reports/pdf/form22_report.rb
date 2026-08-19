# frozen_string_literal: true

module Reports
  module Pdf
    class Form22Report < BillingDocument
      def initialize(sale, settings: Setting.instance)
        super(sale, settings: settings, copy_type: nil)
        @sale = sale
      end

      private

      def render_body(pdf)
        render_dealer_header(pdf, "FORM 22 — CERTIFICATE OF ROAD WORTHINESS (DRAFT)")
        pdf.text "Central Motor Vehicles Rules, 1989  |  Draft for RTO filing — verify with the registering authority.",
                 size: 8, color: MUTED, align: :center
        pdf.move_down 12

        pdf.text "Certified that the motor vehicle described below complies with the provisions of the Motor Vehicles Act, 1988 and the Central Motor Vehicles Rules, 1989, including applicable emission and safety norms, and is roadworthy at the time of sale.",
                 size: 9
        pdf.move_down 12

        pdf.table(
          [
            [ "Manufacturer", "Honda Motorcycle and Scooter India Pvt. Ltd." ],
            [ "Dealer (seller)", @settings.legal_showroom_name ],
            [ "Dealer GSTIN / code", [ @settings.gstin, @settings.dealer_code ].compact_blank.join("  |  ").presence || "-" ],
            [ "Invoice No. / Date", [ @sale.tax_invoice&.invoice_number || "Invoice not issued", format_date(@sale.tax_invoice&.invoice_date || Date.current) ].join("  |  ") ],
            [ "Purchaser", @sale.customer_name ],
            [ "Purchaser address", @sale.address.presence || "-" ],
            [ "Class of vehicle", "Two-wheeler (L2)" ],
            [ "Make / model", [ "Honda", @sale.bike.name, @sale.bike_variant&.name, @sale.bike_variant&.color ].compact.join(" / ") ],
            [ "Chassis number", @sale.chassis_number.presence || "NOT ALLOTTED" ],
            [ "Engine number", @sale.engine_number.presence || "NOT ALLOTTED" ],
            [ "Month / year of manufacture", Date.current.strftime("%b %Y") ],
            [ "Sale date", format_date(@sale.delivery_date || @sale.booked_on || Date.current) ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 5, 6, 5, 6 ] }
        ) do
          columns(0).font_style = :bold
          columns(0).width = 160
        end

        pdf.move_down 14
        pdf.text "Declaration", size: 10, style: :bold
        pdf.text "The vehicle has been inspected and is certified as roadworthy. This Form 22 draft is for the RTO file together with Form 21. Official OEM / HiRise stationery remains the source for submission.",
                 size: 8, color: MUTED
        pdf.move_down 28
        pdf.text "Date: #{format_date(Date.current)}", size: 9
        pdf.move_down 28
        pdf.text "Signature of the dealer / authorized signatory", size: 9, align: :right
        pdf.text @settings.legal_showroom_name, size: 8, align: :right, color: MUTED
        pdf.move_down 12
        render_dealer_banner(pdf)
      end
    end
  end
end
