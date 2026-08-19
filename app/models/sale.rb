# frozen_string_literal: true

class Sale < ApplicationRecord
  include Discountable

  belongs_to :bike
  belongs_to :bike_variant, optional: true
  belongs_to :sales_executive, class_name: "User"
  belongs_to :enquiry, optional: true
  belongs_to :vehicle_unit, optional: true

  has_many :invoices, dependent: :destroy
  has_one :tax_invoice, -> { where(status: :issued) }, class_name: "Invoice", inverse_of: :sale
  has_many :payment_receipts, dependent: :destroy
  has_one :delivery_challan, dependent: :destroy
  has_one :gate_pass, dependent: :destroy
  has_many :sale_add_ons, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :sale
  has_many :credit_notes, dependent: :destroy

  accepts_nested_attributes_for :sale_add_ons, allow_destroy: true, reject_if: :all_blank

  enum :status, {
    quoted: 0,
    booked: 1,
    rto_processing: 2,
    delivered: 3,
    cancelled: 4
  }, default: :quoted

  enum :payment_mode, {
    cash: 0,
    finance: 1,
    upi: 2,
    mixed: 3
  }, default: :cash

  PAYMENT_MODES = payment_modes.keys.freeze

  validates :customer_name, :phone, presence: true
  validates :phone, format: { with: /\A[0-9+\-\s]{10,15}\z/, message: "must be valid" }
  validates :total_price, :booking_amount, :loan_amount, :down_payment, :handling_charge, :accessories_charge,
            numericality: { greater_than_or_equal_to: 0 }
  validates :buyer_gstin, format: { with: Setting::GSTIN_FORMAT, message: "must be a valid 15-character GSTIN" },
            allow_blank: true
  validates :buyer_pan, format: { with: Setting::PAN_FORMAT, message: "must be a valid PAN" }, allow_blank: true

  before_destroy :release_vehicle_unit_on_destroy
  before_validation :normalize_buyer_identifiers

  before_validation :apply_variant_pricing, if: -> { bike_variant.present? && (new_record? || bike_variant_id_changed?) }
  before_validation :sync_bike_from_variant
  before_validation :calculate_total_price
  before_save :sync_status_dates

  scope :active, -> { where.not(status: :cancelled) }
  scope :closed_won, -> { where(status: :delivered) }
  scope :pipeline, -> { where(status: %i[quoted booked rto_processing]) }
  scope :this_month, -> { where(created_at: Time.zone.today.all_month) }
  scope :delivered_this_month, -> { closed_won.where(delivery_date: Time.zone.today.all_month) }
  scope :recent, -> { order(created_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[customer_name phone status payment_mode booked_on delivery_date created_at bike_id sales_executive_id chassis_number]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[bike bike_variant sales_executive]
  end

  def display_status
    status.humanize.titleize
  end

  def display_payment_mode
    payment_mode.humanize.titleize
  end

  def chassis_allotted?
    vehicle_unit_id.present? || chassis_number.present?
  end

  def invoiced?
    tax_invoice.present?
  end

  def credit_noted?
    credit_notes.any?
  end

  def amount_received
    receipts_total = receipt_total_amount
    receipts_total.positive? ? receipts_total : booking_amount.to_d
  end

  def outstanding_amount
    credited = if credit_notes.loaded?
      credit_notes.sum { |note| note.grand_total.to_d }
    else
      credit_notes.sum(:grand_total).to_d
    end
    [ total_price.to_d - amount_received - credited, 0 ].max
  end

  def hypothecated?
    finance? || finance_partner.present? || loan_amount.to_d.positive?
  end

  def discount_value
    computed_discount(ex_showroom_price)
  end

  def vehicle_inclusive_after_discount
    [ ex_showroom_price.to_d - discount_value, 0 ].max
  end

  private

  def receipt_total_amount
    if payment_receipts.loaded?
      payment_receipts.sum { |receipt| receipt.amount.to_d }
    else
      payment_receipts.sum(:amount).to_d
    end
  end

  def normalize_buyer_identifiers
    self.buyer_gstin = buyer_gstin.to_s.gsub(/\s/, "").upcase.presence
    self.buyer_pan = buyer_pan.to_s.gsub(/\s/, "").upcase.presence
    self.chassis_number = chassis_number.to_s.strip.upcase.presence
    self.engine_number = engine_number.to_s.strip.upcase.presence
  end

  def release_vehicle_unit_on_destroy
    return if vehicle_unit.blank? || vehicle_unit.delivered?

    VehicleUnits::ReleaseService.new(self).call
  end

  def sync_bike_from_variant
    self.bike = bike_variant.bike if bike_variant.present?
  end

  def apply_variant_pricing
    self.ex_showroom_price = bike_variant.ex_showroom_price
    self.insurance = bike_variant.insurance
    self.rto = bike_variant.rto
    self.handling_charge = bike_variant.handling_charge
    self.accessories_charge = bike_variant.accessories_charge
  end

  def calculate_total_price
    add_ons_total = sale_add_ons.reject(&:marked_for_destruction?).sum(&:line_total)
    self.other_charges = handling_charge.to_d + accessories_charge.to_d + add_ons_total
    self.total_price = vehicle_inclusive_after_discount + insurance.to_d + rto.to_d + other_charges.to_d
  end

  def sync_status_dates
    self.quoted_on ||= Date.current if quoted? && quoted_on.blank?
    self.booked_on ||= Date.current if booked? && booked_on.blank?
    self.delivery_date ||= Date.current if delivered? && delivery_date.blank?
  end
end
