# frozen_string_literal: true

module Billing
  class CaptureIrnService
    def initialize(record, irn:, ack_no: nil, ack_date: nil)
      @record = record
      @irn = irn
      @ack_no = ack_no
      @ack_date = ack_date
    end

    def call
      irn = @irn.to_s.gsub(/\s/, "").upcase
      return failure("IRN is required") if irn.blank?
      return failure("IRN must be at least 8 characters") if irn.length < 8
      return failure("IRN is too long") if irn.length > 64
      return failure("Issue the tax invoice before recording an IRN") unless issued?

      @record.update!(
        irn: irn,
        ack_no: @ack_no.to_s.strip.presence,
        ack_date: parse_date,
        einvoice_status: :registered
      )

      { success: true, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def issued?
      @record.respond_to?(:issued?) ? @record.issued? : true
    end

    def parse_date
      value = @ack_date
      return Date.current if value.blank?
      return value if value.is_a?(Date)

      Date.parse(value.to_s)
    rescue ArgumentError
      Date.current
    end

    def failure(message)
      { success: false, error: message }
    end
  end
end
