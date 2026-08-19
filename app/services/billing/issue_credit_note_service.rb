# frozen_string_literal: true

module Billing
  class IssueCreditNoteService
    def initialize(document, reason:, full: false, amount: nil, line_returns: {})
      @document = document
      @reason = reason.to_s.strip
      @full = full
      @amount = amount
      @line_returns = line_returns.to_h
    end

    def call
      return failure("Reason is required to issue a credit note") if @reason.blank?

      if vehicle?
        issue_vehicle
      elsif counter?
        issue_counter
      else
        failure("Unsupported document for a credit note")
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def vehicle?
      @document.is_a?(Sale)
    end

    def counter?
      @document.is_a?(CounterInvoice)
    end

    def issue_vehicle
      invoice = @document.tax_invoice
      return failure("No issued tax invoice to credit") if invoice.blank?
      return failure("This invoice is already cancelled") if invoice.cancelled?

      remaining = remaining_vehicle(invoice)
      return failure("This invoice is already fully credited") if remaining[:value] <= 0

      allocation = allocate_amount(remaining, @full ? remaining[:value] : @amount.to_d)
      return failure(allocation[:error]) if allocation[:error]

      credit_note = nil
      fully_reversed = remaining_is_full?(remaining, allocation)
      Invoice.transaction do
        credit_note = create_note!(
          invoice: invoice,
          sale: @document,
          allocation: allocation,
          kind: fully_reversed ? :full : :partial
        )
        invoice.update!(status: :cancelled) if fully_reversed
      end

      { success: true, credit_note: credit_note, error: nil }
    end

    def issue_counter
      invoice = @document
      return failure("No issued tax invoice to credit") unless invoice.issued?
      return failure("This invoice is already cancelled") if invoice.cancelled?

      remaining = remaining_counter(invoice)
      return failure("This invoice is already fully credited") if remaining[:value] <= 0

      returns = parsed_line_returns(invoice)
      return failure("Enter a return quantity for at least one line, or reverse the remaining bill in full") if returns.empty?

      line_allocation = allocate_counter(returns)
      allocation = if @full
                     remaining.merge(lines: line_allocation[:lines])
      else
                     cap_to_remaining(line_allocation, remaining[:value])
      end
      return failure("Nothing left to credit on these lines") if allocation[:value] <= 0

      credit_note = nil
      fully_reversed = (remaining[:value] - allocation[:value]).round(2) <= 0
      CounterInvoice.transaction do
        restore_stock!(returns)
        credit_note = create_note!(
          counter_invoice: invoice,
          allocation: allocation,
          kind: fully_reversed ? :full : :partial
        )
        allocation[:lines].each { |row| credit_note.lines.create!(row) }
        if fully_reversed
          invoice.update!(status: :cancelled)
          invoice.job_card&.update!(status: :open)
        end
      end

      { success: true, credit_note: credit_note, error: nil }
    end

    def create_note!(allocation:, kind:, invoice: nil, sale: nil, counter_invoice: nil)
      CreditNote.create!(
        invoice: invoice,
        sale: sale,
        counter_invoice: counter_invoice,
        kind: kind,
        credit_note_number: Billing::NumberingService.new(:credit_note).next_number!,
        credit_note_date: Date.current,
        reason: @reason,
        grand_total: allocation[:value],
        taxable_total: allocation[:taxable],
        tax_total: allocation[:tax],
        cgst_amount: allocation[:cgst],
        sgst_amount: allocation[:sgst],
        igst_amount: allocation[:igst],
        collected_total: allocation[:collected]
      )
    end

    def remaining_vehicle(invoice)
      notes = invoice.credit_notes
      gst = remaining_gst(invoice)
      {
        taxable: invoice.taxable_total.to_d - notes.sum(:taxable_total).to_d,
        tax: invoice.tax_total.to_d - notes.sum(:tax_total).to_d,
        collected: vehicle_collected(invoice) - notes.sum(:collected_total).to_d,
        cgst: gst[:cgst],
        sgst: gst[:sgst],
        igst: gst[:igst],
        value: invoice.grand_total.to_d - notes.sum(:grand_total).to_d
      }
    end

    def remaining_counter(invoice)
      notes = invoice.credit_notes
      gst = gst_split(invoice.lines)
      {
        taxable: invoice.taxable_total.to_d - notes.sum(:taxable_total).to_d,
        tax: invoice.tax_total.to_d - notes.sum(:tax_total).to_d,
        collected: 0.to_d,
        cgst: gst[:cgst] - notes.sum(:cgst_amount).to_d,
        sgst: gst[:sgst] - notes.sum(:sgst_amount).to_d,
        igst: gst[:igst] - notes.sum(:igst_amount).to_d,
        value: invoice.grand_total.to_d - notes.sum(:grand_total).to_d
      }
    end

    def remaining_gst(invoice)
      notes = invoice.credit_notes
      split = gst_split(invoice.line_items)
      if split.values.all?(&:zero?)
        split = {
          cgst: invoice.vehicle_cgst.to_d + invoice.accessories_cgst.to_d,
          sgst: invoice.vehicle_sgst.to_d + invoice.accessories_sgst.to_d,
          igst: invoice.vehicle_igst.to_d + invoice.accessories_igst.to_d
        }
      end
      {
        cgst: split[:cgst] - notes.sum(:cgst_amount).to_d,
        sgst: split[:sgst] - notes.sum(:sgst_amount).to_d,
        igst: split[:igst] - notes.sum(:igst_amount).to_d
      }
    end

    def gst_split(lines)
      loaded = lines.respond_to?(:to_a) ? lines.to_a : Array(lines)
      {
        cgst: loaded.sum { |line| line.cgst_amount.to_d },
        sgst: loaded.sum { |line| line.sgst_amount.to_d },
        igst: loaded.sum { |line| line.igst_amount.to_d }
      }
    end

    def vehicle_collected(invoice)
      invoice.insurance_collected.to_d + invoice.rto_collected.to_d
    end

    def allocate_amount(remaining, amount)
      amount = amount.to_d.round(2)
      return { error: "Credit amount must be greater than zero" } if amount <= 0
      return { error: "Credit amount cannot exceed the remaining invoice value (#{format('%.2f', remaining[:value])})" } if amount > remaining[:value] + 0.009

      amount = remaining[:value] if amount >= remaining[:value]
      factor = remaining[:value].positive? ? (amount / remaining[:value]) : 0
      taxable = (remaining[:taxable] * factor).round(2)
      tax = (remaining[:tax] * factor).round(2)
      collected = (remaining[:collected] * factor).round(2)
      cgst = (remaining[:cgst] * factor).round(2)
      sgst = (remaining[:sgst] * factor).round(2)
      igst = (remaining[:igst] * factor).round(2)
      drift = amount - (taxable + tax + collected)
      collected += drift

      {
        value: amount,
        taxable: taxable,
        tax: tax,
        collected: collected,
        cgst: cgst,
        sgst: sgst,
        igst: igst,
        error: nil
      }
    end

    def remaining_is_full?(remaining, allocation)
      (remaining[:value] - allocation[:value]).round(2) <= 0
    end

    def returned_qty(line)
      CreditNoteLine.where(counter_invoice_line_id: line.id).sum(:quantity).to_d
    end

    def parsed_line_returns(invoice)
      if @full
        invoice.lines.filter_map do |line|
          qty = line.quantity.to_d - returned_qty(line)
          next if qty <= 0

          [ line, qty ]
        end
      else
        @line_returns.filter_map do |line_id, qty|
          line = invoice.lines.find_by(id: line_id)
          next if line.blank?

          qty = qty.to_d
          available = line.quantity.to_d - returned_qty(line)
          next if qty <= 0

          qty = [ qty, available ].min
          next if qty <= 0

          [ line, qty ]
        end
      end
    end

    def allocate_counter(returns)
      taxable = tax = cgst = sgst = igst = value = 0.to_d
      rows = returns.filter_map do |line, qty|
        share = share_for_line(line, qty)
        next if share.blank?

        taxable += share[:taxable]
        tax += share[:tax]
        cgst += share[:cgst]
        sgst += share[:sgst]
        igst += share[:igst]
        value += share[:inclusive]
        {
          counter_invoice_line: line,
          accessory_id: line.accessory_id,
          quantity: share[:quantity],
          inclusive_amount: share[:inclusive],
          taxable_value: share[:taxable],
          tax_amount: share[:tax],
          cgst_amount: share[:cgst],
          sgst_amount: share[:sgst],
          igst_amount: share[:igst]
        }
      end

      {
        value: value.round(2),
        taxable: taxable.round(2),
        tax: tax.round(2),
        collected: 0.to_d,
        cgst: cgst.round(2),
        sgst: sgst.round(2),
        igst: igst.round(2),
        lines: rows
      }
    end

    def share_for_line(line, qty)
      credited = credited_on_line(line)
      remaining_qty = line.quantity.to_d - credited[:quantity]
      remaining = {
        inclusive: line.inclusive_amount.to_d - credited[:inclusive],
        taxable: line.taxable_value.to_d - credited[:taxable],
        cgst: line.cgst_amount.to_d - credited[:cgst],
        sgst: line.sgst_amount.to_d - credited[:sgst],
        igst: line.igst_amount.to_d - credited[:igst]
      }
      remaining[:tax] = remaining[:cgst] + remaining[:sgst] + remaining[:igst]
      qty = [ qty.to_d, remaining_qty ].min
      return if qty <= 0 || remaining_qty <= 0

      if qty >= remaining_qty
        remaining.merge(quantity: remaining_qty)
      else
        factor = qty / remaining_qty
        cgst = (remaining[:cgst] * factor).round(2)
        sgst = (remaining[:sgst] * factor).round(2)
        igst = (remaining[:igst] * factor).round(2)
        {
          quantity: qty,
          inclusive: (remaining[:inclusive] * factor).round(2),
          taxable: (remaining[:taxable] * factor).round(2),
          cgst: cgst,
          sgst: sgst,
          igst: igst,
          tax: cgst + sgst + igst
        }
      end
    end

    def credited_on_line(line)
      rows = CreditNoteLine.where(counter_invoice_line_id: line.id)
      {
        quantity: rows.sum(:quantity).to_d,
        inclusive: rows.sum(:inclusive_amount).to_d,
        taxable: rows.sum(:taxable_value).to_d,
        tax: rows.sum(:tax_amount).to_d,
        cgst: rows.sum(:cgst_amount).to_d,
        sgst: rows.sum(:sgst_amount).to_d,
        igst: rows.sum(:igst_amount).to_d
      }
    end

    def cap_to_remaining(allocation, remaining_value)
      return allocation if remaining_value <= 0 || allocation[:value] <= remaining_value

      factor = remaining_value / allocation[:value]
      scaled_lines = allocation[:lines].map do |row|
        row.merge(
          inclusive_amount: (row[:inclusive_amount].to_d * factor).round(2),
          taxable_value: (row[:taxable_value].to_d * factor).round(2),
          tax_amount: (row[:tax_amount].to_d * factor).round(2),
          cgst_amount: (row[:cgst_amount].to_d * factor).round(2),
          sgst_amount: (row[:sgst_amount].to_d * factor).round(2),
          igst_amount: (row[:igst_amount].to_d * factor).round(2)
        )
      end
      {
        value: remaining_value.round(2),
        taxable: (allocation[:taxable] * factor).round(2),
        tax: (allocation[:tax] * factor).round(2),
        collected: 0.to_d,
        cgst: (allocation[:cgst] * factor).round(2),
        sgst: (allocation[:sgst] * factor).round(2),
        igst: (allocation[:igst] * factor).round(2),
        lines: scaled_lines
      }
    end

    def restore_stock!(returns)
      returns.each do |line, qty|
        accessory = line.accessory
        next if accessory.blank?

        increment = qty.to_i.positive? ? qty.to_i : 1
        accessory.lock!
        accessory.increment!(:stock, increment)
      end
    end

    def failure(message)
      { success: false, credit_note: nil, error: message }
    end
  end
end
