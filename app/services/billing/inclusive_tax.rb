# frozen_string_literal: true

module Billing
  module InclusiveTax
    module_function

    def split(inclusive_amount, rate)
      inclusive = inclusive_amount.to_d
      tax_rate = rate.to_d

      if inclusive.zero? || tax_rate.zero?
        return { inclusive: inclusive.round(2), taxable: inclusive.round(2), tax: 0.to_d }
      end

      taxable = (inclusive * 100 / (100 + tax_rate)).round(2)
      tax = (inclusive - taxable).round(2)

      { inclusive: inclusive.round(2), taxable: taxable, tax: tax }
    end

    def allocate_gst(tax, inter_state:)
      tax_amount = tax.to_d.round(2)

      if inter_state
        { cgst: 0.to_d, sgst: 0.to_d, igst: tax_amount }
      else
        cgst = (tax_amount / 2).round(2)
        { cgst: cgst, sgst: (tax_amount - cgst).round(2), igst: 0.to_d }
      end
    end
  end
end
