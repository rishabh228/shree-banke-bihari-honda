# frozen_string_literal: true

module Billing
  class IssueGatePassService
    def initialize(sale, attributes = {})
      @sale = sale
      @attributes = attributes.to_h.symbolize_keys
    end

    def call
      return { success: true, gate_pass: @sale.gate_pass, error: nil } if @sale.gate_pass.present?
      return failure("Allot chassis and engine number before generating a gate pass") unless @sale.chassis_allotted?
      return failure("Cannot generate a gate pass for a cancelled sale") if @sale.cancelled?

      gate_pass = @sale.create_gate_pass!(
        gate_pass_number: Billing::NumberingService.new(:gate_pass).next_number!,
        issued_at: Time.current,
        driven_by: @attributes[:driven_by].presence || "customer",
        id_proof: @attributes[:id_proof],
        notes: @attributes[:notes]
      )

      { success: true, gate_pass: gate_pass, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def failure(message)
      { success: false, gate_pass: nil, error: message }
    end
  end
end
