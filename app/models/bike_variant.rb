# frozen_string_literal: true

class BikeVariant < ApplicationRecord
  belongs_to :bike

  validates :name, presence: true
  validates :ex_showroom_price, :insurance, :rto, :handling_charge, :accessories_charge, :total_price,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :available_variants, -> { where(available: true) }
  scope :ordered, -> { order(:name) }

  before_save :calculate_total_price

  def calculate_total_price
    self.total_price = ex_showroom_price.to_d + insurance.to_d + rto.to_d +
                       handling_charge.to_d + accessories_charge.to_d
  end
end
