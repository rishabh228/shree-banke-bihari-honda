# frozen_string_literal: true

class JobCardLine < ApplicationRecord
  belongs_to :job_card
  belongs_to :accessory, optional: true

  attribute :line_type, :string
  enum :line_type, { part: "part", labour: "labour" }, validate: true

  validates :description, :line_type, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :copy_from_accessory, if: -> { accessory.present? && part? }
  before_validation :apply_labour_defaults, if: :labour?

  def line_total
    quantity.to_d * unit_price.to_d
  end

  private

  def copy_from_accessory
    self.description = accessory.name if description.blank?
    self.unit_price = accessory.price if unit_price.to_d.zero?
    self.hsn_code = accessory.hsn if hsn_code.blank?
    self.gst_rate = accessory.tax_rate
    self.uqc = "NOS" if uqc.blank?
  end

  def apply_labour_defaults
    settings = Setting.instance
    self.hsn_code = settings.labour_sac_code if hsn_code.blank?
    self.gst_rate = settings.labour_tax_rate if gst_rate.blank?
    self.uqc = "HRS" if uqc.blank? || uqc == "NOS"
  end
end
