# frozen_string_literal: true

module Reports
  module Pdf
    class GatePassReport < BillingDocument
      def initialize(gate_pass, settings: Setting.instance)
        super(gate_pass, settings: settings, copy_type: nil)
        @gate_pass = gate_pass
        @sale = gate_pass.sale
      end

      private

      def render_body(pdf)
        render_dealer_header(pdf, "GATE PASS / VEHICLE EXIT")
        pdf.text "Security document for vehicle leaving dealer premises. This is not a tax invoice or delivery challan.",
                 size: 8, color: MUTED, align: :center
        pdf.move_down 12

        pdf.table(
          [
            [ "Gate Pass No.", @gate_pass.gate_pass_number, "Issued", format_datetime(@gate_pass.issued_at) ],
            [ "Tax invoice", @sale.tax_invoice&.invoice_number || "Not issued", "Delivery challan", @sale.delivery_challan&.challan_number || "-" ],
            [ "Driven by", @gate_pass.display_driven_by, "ID proof", @gate_pass.id_proof.presence || "-" ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 4, 6, 4, 6 ] }
        ) do
          columns([ 0, 2 ]).font_style = :bold
        end
        pdf.move_down 12

        pdf.text "Customer / consignee", size: 10, style: :bold
        pdf.text @sale.customer_name, size: 11
        pdf.text [ @sale.address.presence, "Phone: #{@sale.phone}" ].compact.join("\n"), size: 9
        pdf.move_down 12

        pdf.table(
          [
            [ "Model", "Colour", "Chassis No.", "Engine No." ],
            [
              [ @sale.bike.name, @sale.bike_variant&.name ].compact.join(" / "),
              @sale.bike_variant&.color.presence || "-",
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

        if @gate_pass.notes.present?
          pdf.move_down 10
          pdf.text "Remarks: #{@gate_pass.notes}", size: 9
        end

        pdf.move_down 28
        pdf.table(
          [ [ "Yard / store in-charge", "Security (exit)", "Customer / driver" ] ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 36, 8, 8, 8 ], borders: [ :top ] }
        )
        pdf.move_down 12
        render_dealer_banner(pdf)
      end

      def format_datetime(time)
        time.present? ? time.in_time_zone.strftime("%d %b %Y %I:%M %p") : "-"
      end
    end
  end
end
