# frozen_string_literal: true

module Reports
  module Pdf
    class JobCardReport < BillingDocument
      def initialize(job_card, settings: Setting.instance)
        super(job_card, settings: settings, copy_type: nil)
        @job_card = job_card
        @booking = job_card.service_booking
      end

      private

      def render_body(pdf)
        render_dealer_header(
          pdf,
          "Workshop Job Card",
          folio: [
            [ "Job Card No.", @job_card.job_card_number ],
            [ "Date", format_date(@job_card.job_card_date) ],
            [ "Status", @job_card.status.humanize.titleize ],
            [ "Advisor", @booking.assigned_to&.name || "Unassigned" ]
          ]
        )
        pdf.text "Internal workshop worksheet. Tax invoice is issued separately after jobs are billed.",
                 size: 8, color: MUTED, align: :center
        pdf.move_down 10

        pdf.table(
          [
            [ "Job Card No.", @job_card.job_card_number, "Date", format_date(@job_card.job_card_date) ],
            [ "Service type", @booking.service_type.to_s.humanize.titleize, "Advisor", @booking.assigned_to&.name || "Unassigned" ],
            [ "Status", @job_card.status.humanize.titleize, "KM reading", @job_card.km_reading.present? ? @job_card.km_reading.to_s : "-" ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 8, padding: [ 4, 6, 4, 6 ] }
        ) do
          columns([ 0, 2 ]).font_style = :bold
        end
        pdf.move_down 10

        pdf.table(
          [
            [ { content: "Customer", font_style: :bold }, { content: "Vehicle", font_style: :bold } ],
            [
              [ @booking.customer_name, "Phone: #{@booking.phone}", @booking.email.presence ].compact.join("\n"),
              [
                "Regn: #{@booking.vehicle_number}",
                "Model: #{@booking.bike_model}",
                ("Chassis: #{@job_card.chassis_number}" if @job_card.chassis_number.present?),
                ("Engine: #{@job_card.engine_number}" if @job_card.engine_number.present?)
              ].compact.join("\n")
            ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 8, padding: [ 5, 6, 5, 6 ] }
        )
        pdf.move_down 10

        if @booking.complaint.present?
          pdf.text "Customer complaint / instruction", size: 9, style: :bold
          pdf.text @booking.complaint, size: 8
          pdf.move_down 8
        end

        render_lines(pdf, "Parts", @job_card.parts)
        render_lines(pdf, "Labour", @job_card.labour)

        pdf.table(
          [ [ "Estimated total (GST inclusive)", money(@job_card.estimate_total) ] ],
          width: pdf.bounds.width * 0.5,
          position: :right,
          cell_style: { size: 9, padding: [ 4, 6, 4, 6 ] }
        ) do
          row(0).font_style = :bold
          columns(1).align = :right
        end

        pdf.move_down 24
        pdf.table(
          [ [ "Technician", "Service advisor", "Customer" ] ],
          width: pdf.bounds.width,
          cell_style: { size: 9, padding: [ 32, 8, 8, 8 ], borders: [ :top ] }
        )
        pdf.move_down 12
        render_authorized_signatory(pdf)
      end

      def render_lines(pdf, heading, lines)
        pdf.text heading, size: 9, style: :bold
        pdf.move_down 3
        if lines.empty?
          pdf.text "None", size: 8, color: MUTED
          pdf.move_down 8
          return
        end

        rows = [ [ "Description", "HSN/SAC", "Qty", "UQC", "Amount" ] ]
        lines.each do |line|
          rows << [ line.description, line.hsn_code.to_s, format("%.2f", line.quantity), line.uqc.to_s, money(line.line_total) ]
        end
        pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 8, padding: [ 3, 4, 3, 4 ] }) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
          columns(2..4).align = :right
        end
        pdf.move_down 8
      end
    end
  end
end
