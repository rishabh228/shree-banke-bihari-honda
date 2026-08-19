# frozen_string_literal: true

module Reports
  module Pdf
    class Form21Report < BillingDocument
      def initialize(sale, settings: Setting.instance)
        super(sale, settings: settings, copy_type: nil)
        @sale = sale
      end

      private

      def render_body(pdf)
        render_dealer_header(pdf, "FORM 21 — SALE CERTIFICATE (DRAFT)")
        pdf.text "Central Motor Vehicles Rules, 1989  |  Draft for RTO filing — verify with the registering authority.",
                 size: 8, color: MUTED, align: :center
        pdf.move_down 14

        pdf.text "Certified that the vehicle described below has been sold by us to the purchaser named herein.",
                 size: 10
        pdf.move_down 12

        pdf.table(
          [
            [ "Seller (Dealer)", @settings.showroom_name ],
            [ "Seller address", @settings.address.to_s ],
            [ "GSTIN", @settings.gstin.presence || "—" ],
            [ "Invoice No. / Date", [ @sale.tax_invoice&.invoice_number || "Invoice not issued", format_date(@sale.tax_invoice&.invoice_date || @sale.delivery_date) ].join("  |  ") ],
            [ "Purchaser name", @sale.customer_name ],
            [ "Purchaser address", @sale.address.presence || "—" ],
            [ "Purchaser phone", @sale.phone ],
            [ "Purchaser PAN", @sale.buyer_pan.presence || "—" ],
            [ "Class of vehicle", "Two-wheeler" ],
            [ "Maker's name", "Honda Motorcycle and Scooter India Pvt. Ltd." ],
            [ "Model / variant", [ @sale.bike.name, @sale.bike_variant&.name, @sale.bike_variant&.color ].compact.join(" / ") ],
            [ "Chassis number", @sale.chassis_number.presence || "NOT ALLOTTED" ],
            [ "Engine number", @sale.engine_number.presence || "NOT ALLOTTED" ],
            [ "Hypothecated to", @sale.hypothecated? ? (@sale.finance_partner.presence || "Financier (see sale record)") : "Not hypothecated" ],
            [ "Sale date", format_date(@sale.delivery_date || @sale.booked_on || Date.current) ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 5, 6, 5, 6 ] }
        ) do
          columns(0).font_style = :bold
          columns(0).width = 150
        end

        pdf.move_down 16
        pdf.text "This is a dealer-system draft of Form 21. Official Form 21 / Form 22 stationery and Honda HiRise documents remain the source for RTO submission.",
                 size: 8, color: MUTED
        pdf.move_down 36
        pdf.text "Date: #{format_date(Date.current)}", size: 9
        pdf.move_down 28
        pdf.text "Signature of the dealer / authorized signatory", size: 9, align: :right
        pdf.text @settings.showroom_name, size: 8, align: :right, color: MUTED
        pdf.move_down 12
        render_dealer_banner(pdf)
      end
    end
  end
end
