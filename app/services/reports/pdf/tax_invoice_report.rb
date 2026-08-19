# frozen_string_literal: true

module Reports
  module Pdf
    class TaxInvoiceReport < BillingDocument
      def initialize(invoice, settings: Setting.instance, copy_type: "original")
        super(invoice, settings: settings, copy_type: copy_type)
        @invoice = invoice
        @sale = invoice.sale
      end

      private

      def render_body(pdf)
        render_dealer_header(pdf, @invoice.cancelled? ? "Tax Invoice (Cancelled)" : "Tax Invoice", folio: folio_fields)
        render_einvoice_block(pdf, @invoice)
        render_boxed_parties(pdf, supplier_text, recipient_text)
        render_vehicle_strip(
          pdf,
          model: [ @sale.bike.name, @sale.bike_variant&.name ].compact.join(" / "),
          engine: @sale.engine_number,
          serial: @sale.chassis_number
        )
        render_specifications(pdf)
        render_tax_meta(pdf)
        render_taxable_lines(pdf)
        render_collected_lines(pdf)
        render_hsn_summary(pdf)
        render_totals(pdf)
        render_bank_details(pdf)
        render_authorized_signatory(pdf, terms: default_terms)
      end

      def folio_fields
        [
          [ "Invoice No.", @invoice.invoice_number ],
          [ "Date", format_date(@invoice.invoice_date) ],
          [ "Payment", @sale.display_payment_mode ],
          [ "Executive", @sale.sales_executive&.name.presence || "—" ]
        ]
      end

      def supplier_text
        [
          @settings.legal_showroom_name,
          @settings.address,
          ("GSTIN: #{@settings.gstin}" if @settings.gstin.present?),
          ("PAN: #{@settings.pan}" if @settings.pan.present?),
          ("State: #{@settings.place_of_supply_label}" if @settings.state.present? || @settings.state_code.present?)
        ].compact.join("\n")
      end

      def recipient_text
        [
          @sale.customer_name,
          @sale.address.presence,
          "Phone: #{@sale.phone}",
          ("GSTIN: #{@sale.buyer_gstin}" if @sale.buyer_gstin.present?),
          ("PAN: #{@sale.buyer_pan}" if @sale.buyer_pan.present?),
          ("State: #{[ @sale.buyer_state, @sale.buyer_state_code ].compact_blank.join(' / ')}" if @sale.buyer_state.present? || @sale.buyer_state_code.present?)
        ].compact.join("\n")
      end

      def render_specifications(pdf)
        specs = specification_lines
        return if specs.empty?

        pdf.table(
          [ [ { content: "Vehicle description / specifications", font_style: :bold, background_color: "F5F5F5" } ], [ specs ] ],
          width: pdf.bounds.width,
          cell_style: { size: 7, padding: [ 4, 6, 4, 6 ], borders: [ :top, :bottom, :left, :right ], border_color: LINE, border_width: 0.5 }
        )
        pdf.move_down 8
      end

      def specification_lines
        bike = @sale.bike
        lines = [ "Brand: Honda", "Model: #{bike.name}" ]
        lines << "Variant: #{@sale.bike_variant.name}" if @sale.bike_variant&.name.present?
        lines << "Colour: #{@sale.bike_variant.color}" if @sale.bike_variant&.color.present?
        lines << "Category: #{bike.category}" if bike.category.present?
        lines << "Engine: #{bike.engine}" if bike.engine.present?
        lines << "Power: #{bike.power}" if bike.power.present?
        lines << "Mileage: #{bike.mileage}" if bike.mileage.present?
        lines << "Fuel tank: #{bike.fuel_tank}" if bike.fuel_tank.present?
        bike.bike_specifications.limit(8).each do |spec|
          next if spec.label.blank? || spec.value.blank?

          lines << "#{spec.label}: #{spec.value}"
        end
        lines << "Hypothecation: #{hypothecation_label}"
        lines.uniq.join("   |   ")
      end

      def render_tax_meta(pdf)
        pdf.table(
          [
            [
              "Place of Supply",
              [ @invoice.place_of_supply, @invoice.place_of_supply_code ].compact_blank.join(" / "),
              "Reverse Charge",
              @invoice.reverse_charge? ? "Yes" : "No"
            ],
            [
              "Supply Type",
              @invoice.inter_state? ? "Inter-State (IGST)" : "Intra-State (CGST/SGST)",
              "Sale Type",
              @sale.hypothecated? ? "Financed / Retail" : "Retail"
            ]
          ],
          width: pdf.bounds.width,
          cell_style: { size: 8, padding: [ 3, 5, 3, 5 ], borders: [ :top, :bottom, :left, :right ], border_color: LINE, border_width: 0.5 }
        ) do
          columns([ 0, 2 ]).font_style = :bold
        end
        pdf.move_down 8
      end

      def hypothecation_label
        return "Not hypothecated" unless @sale.hypothecated?

        [ @sale.finance_partner.presence, ("Loan #{money(@sale.loan_amount)}" if @sale.loan_amount.to_d.positive?) ].compact.join(" / ").presence || "Financed"
      end

      def render_taxable_lines(pdf)
        pdf.text "Taxable Supplies", size: 9, style: :bold
        pdf.move_down 3
        rows = [ taxable_headers ] + taxable_rows
        pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 7, padding: [ 3, 3, 3, 3 ] }) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
          columns(2..9).align = :right
        end
        pdf.move_down 8
      end

      def taxable_headers
        [ "Description", "HSN", "Qty", "UQC", "Taxable", "GST %", "CGST", "SGST", "IGST", "Amount" ]
      end

      def taxable_rows
        taxable_items.map do |item|
          [
            item[:description],
            item[:hsn_code].to_s,
            format("%.0f", item[:quantity]),
            item[:uqc].to_s,
            money(item[:taxable_value]),
            format("%.2f", item[:gst_rate]),
            money(item[:cgst_amount]),
            money(item[:sgst_amount]),
            money(item[:igst_amount]),
            money(item[:inclusive_amount])
          ]
        end
      end

      def render_collected_lines(pdf)
        return if collected_items.empty?

        pdf.text "Amounts collected on behalf (not a supply under GST)", size: 9, style: :bold
        pdf.move_down 3
        rows = [ [ "Description", "Amount" ] ] + collected_items.map { |item| [ item[:description], money(item[:inclusive_amount]) ] }
        pdf.table(rows, header: true, width: pdf.bounds.width, cell_style: { size: 8, padding: [ 3, 5, 3, 5 ] }) do
          row(0).font_style = :bold
          row(0).background_color = HEADER_BG
          row(0).text_color = "FFFFFF"
          columns(1).align = :right
        end
        pdf.move_down 8
      end

      def render_hsn_summary(pdf)
        summary = grouped_hsn
        return if summary.empty?

        pdf.text "HSN-wise tax summary", size: 9, style: :bold
        pdf.move_down 3
        rows = [ [ "HSN", "GST %", "Taxable Value", "CGST", "SGST", "IGST" ] ]
        summary.each do |row|
          rows << [
            row[:hsn_code].to_s,
            format("%.2f", row[:gst_rate]),
            money(row[:taxable_value]),
            money(row[:cgst_amount]),
            money(row[:sgst_amount]),
            money(row[:igst_amount])
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
        collected_total = collected_items.sum { |item| item[:inclusive_amount].to_d }
        pdf.table(
          [
            [ "Taxable value", money(@invoice.taxable_total) ],
            [ "Total GST (CGST + SGST / IGST)", money(@invoice.tax_total) ],
            [ "Insurance + RTO (collected)", money(collected_total) ],
            [ "Invoice total (on-road)", money(@invoice.grand_total) ]
          ],
          width: pdf.bounds.width * 0.55,
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

      def taxable_items
        persisted_items.reject { |item| item[:collected] }
      end

      def collected_items
        persisted_items.select { |item| item[:collected] }
      end

      def persisted_items
        @persisted_items ||= begin
          if @invoice.line_items.any?
            @invoice.line_items.ordered.map { |item| item_hash(item) }
          else
            legacy_items
          end
        end
      end

      def item_hash(item)
        {
          description: item.description,
          hsn_code: item.hsn_code,
          quantity: item.quantity,
          uqc: item.uqc,
          gst_rate: item.gst_rate,
          taxable_value: item.taxable_value,
          cgst_amount: item.cgst_amount,
          sgst_amount: item.sgst_amount,
          igst_amount: item.igst_amount,
          inclusive_amount: item.inclusive_amount,
          collected: item.collected?
        }
      end

      def grouped_hsn
        taxable_items.group_by { |item| [ item[:hsn_code], item[:gst_rate] ] }.map do |(hsn, rate), grouped|
          {
            hsn_code: hsn,
            gst_rate: rate,
            taxable_value: grouped.sum { |item| item[:taxable_value].to_d },
            cgst_amount: grouped.sum { |item| item[:cgst_amount].to_d },
            sgst_amount: grouped.sum { |item| item[:sgst_amount].to_d },
            igst_amount: grouped.sum { |item| item[:igst_amount].to_d }
          }
        end
      end

      def legacy_items
        items = []
        items << {
          description: "#{@sale.bike.name} (GST inclusive)", hsn_code: @invoice.hsn_code, quantity: 1, uqc: "NOS",
          gst_rate: @invoice.vehicle_gst_rate, taxable_value: @invoice.vehicle_taxable,
          cgst_amount: @invoice.vehicle_cgst, sgst_amount: @invoice.vehicle_sgst, igst_amount: @invoice.vehicle_igst,
          inclusive_amount: @invoice.vehicle_inclusive, collected: false
        }
        if @invoice.accessories_inclusive.to_d.positive?
          items << {
            description: "Handling / accessories (GST inclusive)", hsn_code: @invoice.accessories_hsn, quantity: 1, uqc: "NOS",
            gst_rate: @invoice.accessories_gst_rate, taxable_value: @invoice.accessories_taxable,
            cgst_amount: @invoice.accessories_cgst, sgst_amount: @invoice.accessories_sgst, igst_amount: @invoice.accessories_igst,
            inclusive_amount: @invoice.accessories_inclusive, collected: false
          }
        end
        if @invoice.insurance_collected.to_d.positive?
          items << { description: "Insurance (collected for insurer)", hsn_code: nil, quantity: 1, uqc: "NOS", gst_rate: 0,
                     taxable_value: 0, cgst_amount: 0, sgst_amount: 0, igst_amount: 0,
                     inclusive_amount: @invoice.insurance_collected, collected: true }
        end
        if @invoice.rto_collected.to_d.positive?
          items << { description: "RTO / registration (collected for RTO)", hsn_code: nil, quantity: 1, uqc: "NOS", gst_rate: 0,
                     taxable_value: 0, cgst_amount: 0, sgst_amount: 0, igst_amount: 0,
                     inclusive_amount: @invoice.rto_collected, collected: true }
        end
        items
      end
    end
  end
end
