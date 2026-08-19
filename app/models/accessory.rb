# frozen_string_literal: true

class Accessory < ApplicationRecord
  enum :status, { active: 0, inactive: 1 }, default: :active

  has_one_attached :image

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :gst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :available, -> { where(status: :active).where("stock > 0") }
  scope :in_stock, -> { where("stock > 0") }

  def hsn
    hsn_code.presence || Setting.instance.accessories_hsn_code
  end

  def tax_rate
    (gst_rate.presence || Setting.instance.accessories_tax_rate).to_d
  end
end
