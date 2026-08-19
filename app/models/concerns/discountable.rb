# frozen_string_literal: true

module Discountable
  extend ActiveSupport::Concern

  included do
    validates :discount_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
    validates :discount_amount, numericality: { greater_than_or_equal_to: 0 }
  end

  def computed_discount(base)
    value = (base.to_d * discount_percent.to_d / 100) + discount_amount.to_d
    [ value.round(2), [ base.to_d, 0 ].max ].min
  end

  def discount_given?
    discount_percent.to_d.positive? || discount_amount.to_d.positive?
  end
end
