# frozen_string_literal: true

class SaleAddOn < ApplicationRecord
  belongs_to :sale
  belongs_to :accessory, optional: true

  validates :description, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :copy_from_accessory, if: -> { accessory.present? }

  def line_total
    quantity.to_i * unit_price.to_d
  end

  private

  def copy_from_accessory
    self.description = accessory.name if description.blank?
    self.unit_price = accessory.price if unit_price.to_d.zero?
    self.hsn_code = accessory.hsn if hsn_code.blank?
    self.gst_rate = accessory.tax_rate
  end
end
