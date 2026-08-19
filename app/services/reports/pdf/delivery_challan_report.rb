# frozen_string_literal: true

module Reports
  module Pdf
    class DeliveryChallanReport < BillingDocument
      CHALLAN_COPY_LABELS = {
        "original" => "ORIGINAL FOR CONSIGNEE",
        "duplicate" => "DUPLICATE FOR TRANSPORTER",
        "triplicate" => "TRIPLICATE FOR CONSIGNER"
      }.freeze

      def initialize(challan, settings: Setting.instance, copy_type: "original")
        super(challan, settings: settings, copy_type: copy_type)
        @challan = challan
        @sale = challan.sale
      end

      private

      def copy_labels
        CHALLAN_COPY_LABELS
      end

      def footer_copy_label
        {
          "original" => "CONSIGNEE",
          "duplicate" => "TRANSPORTER",
          "triplicate" => "CONSIGNER"
        }[@copy_type]
      end

      def render_body(pdf)
        render_dealer_header(pdf, "DELIVERY CHALLAN")
        pdf.text "GST Rule 55 movement document. Gate pass is issued separately for yard security.",
                 size: 8, color: MUTED, align: :center
        pdf.move_down 10

        pdf.table(
          [
            [ "Challan No.", @challan.challan_number, "Challan Date", format_date(@challan.challan_date) ],
            [ "Linked invoice", @sale.tax_invoice&.invoice_number || "Not issued", "Transporter vehicle", @challan.transporter_vehicle_no.presence || "-" ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 4, 6, 4, 6 ] }
        ) do
          columns([ 0, 2 ]).font_style = :bold
        end
        pdf.move_down 14

        pdf.text "Consignee", size: 11, style: :bold
        pdf.text @sale.customer_name, size: 11
        pdf.text [ @sale.address.presence, "Phone: #{@sale.phone}" ].compact.join("\n"), size: 9
        pdf.move_down 12

        pdf.table(
          [
            [ "Description", "HSN", "Qty", "Chassis No.", "Engine No." ],
            [
              "#{@sale.bike.name} — #{[ @sale.bike_variant&.name, @sale.bike_variant&.color ].compact.join(' / ')}",
              @sale.bike.hsn,
              "1 NOS",
              @sale.chassis_number.presence || "-",
              @sale.engine_number.presence || "-"
            ]
          ],
          header: true,
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 5, 6, 5, 6 ] }
        ) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
        end
        pdf.move_down 12
        pdf.text "This challan is for delivery of the vehicle from the showroom. It is not a tax invoice.",
                 size: 8, color: MUTED
        pdf.move_down 32
        pdf.table(
          [ [ "Customer signature", "Store / yard in-charge" ] ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 28, 8, 8, 8 ], borders: [ :top ] }
        )
        pdf.move_down 12
        render_dealer_banner(pdf)
      end
    end
  end
end
