# frozen_string_literal: true

module Billing
  module AmountInWords
    ONES = %w[
      zero one two three four five six seven eight nine ten eleven twelve
      thirteen fourteen fifteen sixteen seventeen eighteen nineteen
    ].freeze
    TENS = %w[zero ten twenty thirty forty fifty sixty seventy eighty ninety].freeze

    module_function

    def rupees(amount)
      rupees_part, paise_part = split_amount(amount)
      words = "#{segment_words(rupees_part)} rupees"
      words += " and #{segment_words(paise_part)} paise" if paise_part.positive?
      "#{words} only".upcase
    end

    def split_amount(amount)
      value = amount.to_d.round(2)
      rupees_part = value.to_i
      paise_part = ((value - rupees_part) * 100).round
      [ rupees_part, paise_part ]
    end

    def segment_words(number)
      return ONES[0] if number.zero?
      return scale_words(number, 10_000_000, "crore") if number >= 10_000_000
      return scale_words(number, 100_000, "lakh") if number >= 100_000
      return scale_words(number, 1_000, "thousand") if number >= 1_000
      return scale_words(number, 100, "hundred") if number >= 100
      return "#{TENS[number / 10]}#{(number % 10).zero? ? '' : " #{ONES[number % 10]}"}".strip if number >= 20

      ONES[number]
    end

    def scale_words(number, divisor, label)
      quotient, remainder = number.divmod(divisor)
      [ "#{segment_words(quotient)} #{label}", remainder.positive? ? segment_words(remainder) : nil ].compact.join(" ")
    end
  end
end
