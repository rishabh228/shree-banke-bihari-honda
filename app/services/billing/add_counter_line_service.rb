# frozen_string_literal: true

module Billing
  class AddCounterLineService
    def initialize(counter_invoice, attributes)
      @invoice = counter_invoice
      @attributes = attributes.to_h.symbolize_keys
    end

    def call
      return failure("Lines can be added only on a draft invoice") unless @invoice.draft?

      line = nil
      CounterInvoice.transaction do
        accessory = Accessory.find_by(id: @attributes[:accessory_id]) if @attributes[:accessory_id].present?
        quantity = (@attributes[:quantity].presence || 1).to_d
        quantity = 1 if quantity <= 0
        inclusive = (@attributes[:inclusive_amount].presence || @attributes[:unit_price].presence || accessory&.price || 0).to_d * quantity
        description = @attributes[:description].presence || accessory&.name
        return failure("Description is required") if description.blank?
        return failure("Amount must be greater than zero") unless inclusive.positive?

        line_type = @attributes[:line_type].presence || (accessory ? "part" : "part")
        hsn = @attributes[:hsn_code].presence || accessory&.hsn || Setting.instance.accessories_hsn_code
        rate = (@attributes[:gst_rate].presence || accessory&.tax_rate || Setting.instance.accessories_tax_rate).to_d
        uqc = @attributes[:uqc].presence || "NOS"

        attrs = Billing::GstLine.from_inclusive(
          line_type: line_type,
          description: description,
          hsn_code: hsn,
          quantity: quantity,
          inclusive: inclusive,
          rate: rate,
          inter_state: @invoice.inter_state?,
          position: @invoice.lines.count + 1,
          uqc: uqc
        )

        line = @invoice.lines.create!(attrs.merge(accessory: accessory))
        refresh_totals!
      end

      { success: true, line: line, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def refresh_totals!
      @invoice.update!(
        taxable_total: @invoice.lines.sum(:taxable_value),
        tax_total: @invoice.lines.sum(:cgst_amount) + @invoice.lines.sum(:sgst_amount) + @invoice.lines.sum(:igst_amount),
        grand_total: @invoice.lines.sum(:inclusive_amount)
      )
    end

    def failure(message)
      { success: false, line: nil, error: message }
    end
  end
end
