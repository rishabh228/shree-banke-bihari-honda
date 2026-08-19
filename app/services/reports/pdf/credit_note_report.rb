# frozen_string_literal: true

module Reports
  module Pdf
    class CreditNoteReport < BillingDocument
      def initialize(credit_note, settings: Setting.instance, copy_type: "original")
        super(credit_note, settings: settings, copy_type: copy_type)
        @credit_note = credit_note
      end

      private

      def render_body(pdf)
        render_dealer_header(pdf, "Credit Note", folio: folio_fields)
        render_boxed_parties(
          pdf,
          [
            @settings.legal_showroom_name,
            @settings.address,
            ("GSTIN: #{@settings.gstin}" if @settings.gstin.present?)
          ].compact.join("\n"),
          [ @credit_note.party_name, ("Phone: #{@credit_note.party_phone}" if @credit_note.party_phone.present?), @credit_note.party_address.presence ].compact.join("\n")
        )
        if @credit_note.vehicle_credit? && (@credit_note.chassis_number.present? || @credit_note.engine_number.present?)
          render_vehicle_strip(pdf, model: @credit_note.bike_name, engine: @credit_note.engine_number, serial: @credit_note.chassis_number)
        end

        pdf.text reversal_sentence, size: 9
        if @credit_note.counter_invoice&.discount_total.to_d.positive?
          pdf.move_down 4
          pdf.text "Returned amounts follow the original bill after dealer discount.", size: 8, color: MUTED
        end
        pdf.move_down 8
        render_return_lines(pdf)
        rows = [
          [ "Taxable value reversed", money(@credit_note.reversed_taxable) ],
          [ "GST reversed", money(@credit_note.reversed_tax) ]
        ]
        rows << [ "CGST", money(@credit_note.cgst_amount) ] if @credit_note.cgst_amount.to_d.positive?
        rows << [ "SGST", money(@credit_note.sgst_amount) ] if @credit_note.sgst_amount.to_d.positive?
        rows << [ "IGST", money(@credit_note.igst_amount) ] if @credit_note.igst_amount.to_d.positive?
        if @credit_note.reversed_collected.positive?
          rows << [ "Collected amounts reversed", money(@credit_note.reversed_collected) ]
        end
        rows << [ "Credit note total", money(@credit_note.grand_total) ]
        pdf.table(
          rows,
          width: pdf.bounds.width * 0.6,
          cell_style: { size: 9, padding: [ 4, 6, 4, 6 ] }
        ) do
          row(-1).font_style = :bold
          columns(1).align = :right
        end
        pdf.move_down 8
        pdf.text "Amount in words: #{Billing::AmountInWords.rupees(@credit_note.grand_total)}", size: 8, style: :italic
        pdf.move_down 12
        if @credit_note.reason.present?
          pdf.text "Reason: #{@credit_note.reason}", size: 8
          pdf.move_down 6
        end
        pdf.text footer_sentence, size: 8, color: MUTED
        render_authorized_signatory(pdf)
      end

      def reversal_sentence
        kind = @credit_note.full? ? "in full" : "in part"
        "This credit note reverses Tax Invoice #{@credit_note.against_number} #{kind}."
      end

      def footer_sentence
        source = @credit_note.invoice || @credit_note.counter_invoice
        if source&.cancelled?
          "Original tax invoice #{@credit_note.against_number} stands cancelled."
        else
          remaining = source&.remaining_value
          "This is a partial credit note. Remaining invoice value: #{money(remaining)}."
        end
      end

      def render_return_lines(pdf)
        lines = @credit_note.lines.to_a
        return if lines.empty?

        table_rows = [ [ "Returned item", "Qty", "Amount" ] ] +
                     lines.map do |line|
                       description = line.counter_invoice_line&.description || "Part return"
                       [ description, line.quantity.to_s, money(line.inclusive_amount) ]
                     end
        pdf.table(table_rows, width: pdf.bounds.width, cell_style: { size: 8, padding: [ 3, 5, 3, 5 ] }) do
          row(0).font_style = :bold
          columns(1..2).align = :right
        end
        pdf.move_down 8
      end

      def folio_fields
        [
          [ "Credit Note", @credit_note.credit_note_number ],
          [ "Kind", @credit_note.display_kind ],
          [ "Date", format_date(@credit_note.credit_note_date) ],
          [ "Against", @credit_note.against_number ],
          [ "Invoice date", format_date(@credit_note.against_date) ]
        ]
      end
    end
  end
end
