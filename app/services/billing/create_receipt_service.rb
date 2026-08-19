# frozen_string_literal: true

module Billing
  class CreateReceiptService
    def initialize(sale, attributes, received_by:)
      @sale = sale
      @attributes = attributes
      @received_by = received_by
    end

    def call
      amount = @attributes[:amount].presence || @attributes["amount"]
      amount = amount.to_d
      return failure("Amount must be greater than zero") unless amount.positive?
      return failure("Amount exceeds outstanding balance of ₹ #{format('%.2f', @sale.outstanding_amount)}") if amount > @sale.outstanding_amount
      return failure("Cannot collect payment on a cancelled sale") if @sale.cancelled?

      receipt = nil
      PaymentReceipt.transaction do
        receipt = @sale.payment_receipts.create!(
          permitted_attributes.merge(
            receipt_number: Billing::NumberingService.new(:receipt).next_number!,
            received_by: @received_by,
            received_on: (permitted_attributes[:received_on].presence || Date.current),
            amount: amount
          )
        )
        @sale.update_column(:booking_amount, @sale.payment_receipts.sum(:amount))
      end

      { success: true, receipt: receipt, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def failure(message)
      { success: false, receipt: nil, error: message }
    end

    def permitted_attributes
      attrs = @attributes.respond_to?(:to_unsafe_h) ? @attributes.to_unsafe_h : @attributes.to_h
      attrs.symbolize_keys
    end
  end
end
