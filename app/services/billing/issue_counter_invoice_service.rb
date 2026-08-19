# frozen_string_literal: true

module Billing
  class IssueCounterInvoiceService
    LINE_KEYS = %i[
      position line_type description hsn_code quantity uqc gst_rate
      taxable_value cgst_rate sgst_rate igst_rate
      cgst_amount sgst_amount igst_amount inclusive_amount accessory_id
    ].freeze

    def initialize(counter_invoice, issued_by: nil)
      @invoice = counter_invoice
      @issued_by = issued_by
    end

    def call
      return failure("GSTIN is not set in Settings") unless Setting.instance.billing_ready?
      return failure("This invoice is already issued") if @invoice.issued?
      return failure("This invoice is cancelled") if @invoice.cancelled?
      return failure("Add at least one part or labour line") if @invoice.lines.empty?

      CounterInvoice.transaction do
        recompute_taxes!
        apply_header_discount!
        decrement_stock!
        @invoice.update!(
          invoice_number: Billing::NumberingService.new(numbering_type).next_number!,
          invoice_date: Date.current,
          status: :issued,
          issued_by: @issued_by,
          einvoice_status: @invoice.einvoice_applicable? ? :pending : :not_applicable,
          taxable_total: taxable_total,
          tax_total: tax_total,
          grand_total: grand_total,
          discount_total: @applied_discount
        )
        @invoice.job_card&.update!(status: :billed)
      end

      { success: true, invoice: @invoice, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    rescue StockError => e
      failure(e.message)
    end

    private

    class StockError < StandardError; end

    def numbering_type
      @invoice.workshop? ? :workshop : :spare
    end

    def recompute_taxes!
      @invoice.lines.ordered.each_with_index do |line, index|
        attrs = Billing::GstLine.from_inclusive(
          line_type: line.line_type,
          description: line.description,
          hsn_code: line.hsn_code,
          quantity: line.quantity,
          inclusive: line.inclusive_amount.positive? ? line.inclusive_amount : fallback_inclusive(line),
          rate: line.gst_rate,
          inter_state: @invoice.inter_state?,
          position: index + 1,
          uqc: line.uqc.presence || "NOS"
        )
        line.update!(attrs.slice(*LINE_KEYS.excluding(:accessory_id, :line_type, :description)))
      end
      @invoice.reload
    end

    def apply_header_discount!
      @invoice.reload
      subtotal = @invoice.lines.sum { |line| line.inclusive_amount.to_d }
      @applied_discount = @invoice.computed_discount(subtotal)
      return if @applied_discount <= 0 || subtotal <= 0

      remaining = subtotal - @applied_discount
      allocated = 0.to_d
      lines = @invoice.lines.ordered.to_a
      lines.each_with_index do |line, index|
        scaled = if index == lines.length - 1
                   (remaining - allocated).round(2)
        else
                   value = (line.inclusive_amount.to_d * remaining / subtotal).round(2)
                   allocated += value
                   value
        end

        attrs = Billing::GstLine.from_inclusive(
          line_type: line.line_type,
          description: line.description,
          hsn_code: line.hsn_code,
          quantity: line.quantity,
          inclusive: scaled,
          rate: line.gst_rate,
          inter_state: @invoice.inter_state?,
          position: index + 1,
          uqc: line.uqc.presence || "NOS"
        )
        line.update!(attrs.slice(*LINE_KEYS.excluding(:accessory_id, :line_type, :description)))
      end
      @invoice.reload
    end

    def fallback_inclusive(line)
      line.inclusive_amount.to_d
    end

    def decrement_stock!
      @invoice.lines.includes(:accessory).each do |line|
        accessory = line.accessory
        next if accessory.blank?

        qty = line.quantity.to_d
        qty = 1 if qty <= 0
        accessory.lock!
        if accessory.stock < qty
          raise StockError, "Insufficient stock for #{accessory.name} (available #{accessory.stock})"
        end

        accessory.decrement!(:stock, qty.to_i.positive? ? qty.to_i : 1)
      end
    end

    def taxable_total
      @invoice.lines.sum(&:taxable_value).to_d.round(2)
    end

    def tax_total
      @invoice.lines.sum(&:tax_amount).to_d.round(2)
    end

    def grand_total
      @invoice.lines.sum(&:inclusive_amount).to_d.round(2)
    end

    def failure(message)
      { success: false, invoice: nil, error: message }
    end
  end
end
