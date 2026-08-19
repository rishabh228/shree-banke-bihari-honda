# frozen_string_literal: true

module Billing
  class CancelCounterInvoiceService
    def initialize(counter_invoice, reason:)
      @invoice = counter_invoice
      @reason = reason
    end

    def call
      Billing::IssueCreditNoteService.new(@invoice, reason: @reason, full: true).call
    end
  end
end
