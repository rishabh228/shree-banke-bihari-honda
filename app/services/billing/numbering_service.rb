# frozen_string_literal: true

module Billing
  class NumberingService
    PREFIXES = {
      invoice: :invoice_prefix_code,
      receipt: "RCP",
      challan: "DC",
      credit_note: "CN",
      gate_pass: "GP",
      job_card: "JC",
      spare: "SP",
      workshop: "WS"
    }.freeze

    def initialize(document_type, settings: Setting.instance)
      @document_type = document_type.to_s
      @settings = settings
    end

    def next_number!
      financial_year = DocumentSequence.financial_year_for
      sequence = nil

      DocumentSequence.transaction do
        sequence = DocumentSequence.lock.find_or_create_by!(
          document_type: @document_type,
          financial_year: financial_year
        )
        sequence.update!(last_number: sequence.last_number + 1)
      end

      "#{prefix}/#{financial_year}/#{sequence.last_number.to_s.rjust(4, '0')}"
    end

    private

    def prefix
      mapped = PREFIXES.fetch(@document_type.to_sym)
      mapped.is_a?(Symbol) ? @settings.public_send(mapped) : mapped
    end
  end
end
