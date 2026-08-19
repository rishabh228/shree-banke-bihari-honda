# frozen_string_literal: true

module Reports
  module Pdf
    class CounterInvoiceReport < BillingDocument
      def initialize(invoice, settings: Setting.instance, copy_type: "original")
        super(invoice, settings: settings, copy_type: copy_type)
        @invoice = invoice
      end

      private

      def render_body(pdf)
        title = @invoice.workshop? ? "Tax Invoice — Workshop" : "Tax Invoice — Spare Counter"
        title = "#{title} (Cancelled)" if @invoice.cancelled?
        render_dealer_header(pdf, title, folio: folio_fields)
        render_einvoice_block(pdf, @invoice)
        render_boxed_parties(pdf, supplier_text, recipient_text)
        render_tax_meta(pdf)
        render_workshop_vehicle(pdf)
        render_lines(pdf)
        render_hsn_summary(pdf)
        render_totals(pdf)
        render_bank_details(pdf)
        render_authorized_signatory(pdf, terms: @invoice.workshop? ? workshop_terms : spare_terms)
      end

      def folio_fields
        [
          [ "Invoice No.", @invoice.invoice_number ],
          [ "Date", format_date(@invoice.invoice_date) ],
          [ "Document", @invoice.display_kind ],
          [ "Issued by", @invoice.issued_by&.name.presence || "—" ]
        ]
      end

      def supplier_text
        [
          @settings.legal_showroom_name,
          @settings.address,
          ("GSTIN: #{@settings.gstin}" if @settings.gstin.present?),
          ("PAN: #{@settings.pan}" if @settings.pan.present?)
        ].compact.join("\n")
      end

      def recipient_text
        [
          @invoice.customer_name,
          @invoice.address.presence,
          ("Phone: #{@invoice.phone}" if @invoice.phone.present?),
          ("GSTIN: #{@invoice.buyer_gstin}" if @invoice.buyer_gstin.present?),
          ("PAN: #{@invoice.buyer_pan}" if @invoice.buyer_pan.present?),
          ("State: #{[ @invoice.buyer_state, @invoice.buyer_state_code ].compact_blank.join(' / ')}" if @invoice.buyer_state.present? || @invoice.buyer_state_code.present?)
        ].compact.join("\n")
      end

      def render_tax_meta(pdf)
        rows = [
          [
            "Place of Supply",
            [ @invoice.place_of_supply, @invoice.place_of_supply_code ].compact_blank.join(" / "),
            "Reverse Charge",
            @invoice.reverse_charge? ? "Yes" : "No"
          ],
          [
            "Supply Type",
            @invoice.inter_state? ? "Inter-State (IGST)" : "Intra-State (CGST/SGST)",
            @invoice.workshop? ? "Job Card" : "Document",
            @invoice.workshop? ? (@invoice.job_card&.job_card_number.presence || "—") : @invoice.display_kind
          ]
        ]
        pdf.table(
          rows,
          width: pdf.bounds.width,
          cell_style: { size: 8, padding: [ 3, 5, 3, 5 ], borders: [ :top, :bottom, :left, :right ], border_color: LINE, border_width: 0.5 }
        ) do
          columns([ 0, 2 ]).font_style = :bold
        end
        pdf.move_down 8
      end

      def render_workshop_vehicle(pdf)
        job = @invoice.job_card
        return if job.blank?

        booking = job.service_booking
        render_vehicle_strip(
          pdf,
          model: booking&.bike_model.presence || "—",
          engine: job.engine_number,
          serial: job.chassis_number.presence || booking&.vehicle_number
        )
      end

      def render_bank_details(pdf)
        bank = [
          ("Bank: #{@settings.bank_name}" if @settings.bank_name.present?),
          ("A/c: #{@settings.bank_account_number}" if @settings.bank_account_number.present?),
          ("IFSC: #{@settings.bank_ifsc}" if @settings.bank_ifsc.present?),
          ("UPI: #{@settings.upi_id}" if @settings.upi_id.present?)
        ].compact
        return if bank.empty?

        pdf.text "Bank details", size: 9, style: :bold
        pdf.text bank.join("  |  "), size: 8
        pdf.move_down 6
      end

      def render_lines(pdf)
        pdf.text "Taxable supplies", size: 9, style: :bold
        pdf.move_down 3
        rows = [ [ "Description", "HSN/SAC", "Qty", "UQC", "Taxable", "GST %", "CGST", "SGST", "IGST", "Amount" ] ]
        @invoice.lines.ordered.each do |item|
          rows << [
            item.description,
            item.hsn_code.to_s,
            format("%.2f", item.quantity),
            item.uqc.to_s,
            money(item.taxable_value),
            format("%.2f", item.gst_rate),
            money(item.cgst_amount),
            money(item.sgst_amount),
            money(item.igst_amount),
            money(item.inclusive_amount)
          ]
        end
        pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 7, padding: [ 3, 3, 3, 3 ] }) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
          columns(2..9).align = :right
        end
        pdf.move_down 8
      end

      def render_hsn_summary(pdf)
        grouped = @invoice.lines.ordered.group_by { |item| [ item.hsn_code, item.gst_rate ] }
        return if grouped.empty?

        pdf.text "HSN / SAC-wise tax summary", size: 9, style: :bold
        pdf.move_down 3
        rows = [ [ "HSN/SAC", "GST %", "Taxable Value", "CGST", "SGST", "IGST" ] ]
        grouped.each do |(hsn, rate), items|
          rows << [
            hsn.to_s,
            format("%.2f", rate),
            money(items.sum { |item| item.taxable_value.to_d }),
            money(items.sum { |item| item.cgst_amount.to_d }),
            money(items.sum { |item| item.sgst_amount.to_d }),
            money(items.sum { |item| item.igst_amount.to_d })
          ]
        end
        pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 7, padding: [ 3, 4, 3, 4 ] }) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
          columns(1..5).align = :right
        end
        pdf.move_down 8
      end

      def render_totals(pdf)
        pdf.table(
          [
            [ "Taxable value", money(@invoice.taxable_total) ],
            [ "Total GST", money(@invoice.tax_total) ],
            [ "Invoice total", money(@invoice.grand_total) ]
          ],
          width: pdf.bounds.width * 0.5,
          position: :right,
          cell_style: { size: 8, padding: [ 3, 5, 3, 5 ] }
        ) do
          row(-1).font_style = :bold
          columns(1).align = :right
        end
        pdf.move_down 6
        pdf.text "Amount in words: #{Billing::AmountInWords.rupees(@invoice.grand_total)}", size: 8, style: :italic
        pdf.move_down 8
      end

      def spare_terms
        "Genuine Honda spare parts / accessories. Prices are GST-inclusive. No warranty on electrical items unless stated. Subject to showroom jurisdiction."
      end

      def workshop_terms
        "Labour SAC 998714 (repair of motor vehicles) unless shown otherwise. Parts are GST-inclusive. Old parts returned only if requested at job-card opening. Subject to showroom jurisdiction."
      end
    end
  end
end
