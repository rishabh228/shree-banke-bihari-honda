# frozen_string_literal: true

module Billing
  class GstLine
    def self.from_inclusive(line_type:, description:, hsn_code:, quantity:, inclusive:, rate:, inter_state:, position:, uqc: "NOS")
      split = InclusiveTax.split(inclusive, rate)
      gst = InclusiveTax.allocate_gst(split[:tax], inter_state: inter_state)
      half_rate = inter_state ? 0.to_d : (rate.to_d / 2).round(2)

      {
        position: position,
        line_type: line_type,
        description: description,
        hsn_code: hsn_code,
        quantity: quantity.to_d,
        uqc: uqc,
        gst_rate: rate.to_d,
        taxable_value: split[:taxable],
        cgst_rate: inter_state ? 0.to_d : half_rate,
        sgst_rate: inter_state ? 0.to_d : (rate.to_d - half_rate).round(2),
        igst_rate: inter_state ? rate.to_d : 0.to_d,
        cgst_amount: gst[:cgst],
        sgst_amount: gst[:sgst],
        igst_amount: gst[:igst],
        inclusive_amount: split[:inclusive]
      }
    end
  end
end
