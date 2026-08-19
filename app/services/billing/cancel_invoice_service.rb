# frozen_string_literal: true

module Billing
  class CancelInvoiceService
    def initialize(sale, reason:)
      @sale = sale
      @reason = reason
    end

    def call
      Billing::IssueCreditNoteService.new(@sale, reason: @reason, full: true).call
    end
  end
end
