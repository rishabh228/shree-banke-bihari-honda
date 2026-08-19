# frozen_string_literal: true

module Billing
  class StartCounterInvoiceFromAccessoryService
    def initialize(accessory, attributes = {})
      @accessory = accessory
      @attributes = attributes.to_h.symbolize_keys
    end

    def call
      return failure("Set a selling price on this accessory first") unless @accessory.price.to_d.positive?

      invoice = CounterInvoice.new(
        kind: :spare,
        status: :draft,
        customer_name: @attributes[:customer_name].to_s.strip.presence || "Walk-in customer",
        phone: @attributes[:phone],
        buyer_state: Setting.instance.state,
        buyer_state_code: Setting.instance.state_code
      )
      return failure(invoice.errors.full_messages.join(", ")) unless invoice.save

      result = Billing::AddCounterLineService.new(
        invoice,
        accessory_id: @accessory.id,
        quantity: @attributes[:quantity].presence || 1
      ).call

      unless result[:success]
        invoice.destroy
        return failure(result[:error])
      end

      { success: true, invoice: invoice, error: nil }
    end

    private

    def failure(message)
      { success: false, invoice: nil, error: message }
    end
  end
end
