# frozen_string_literal: true

class Sale < ApplicationRecord
  belongs_to :bike
  belongs_to :bike_variant, optional: true
  belongs_to :sales_executive, class_name: "User"
  belongs_to :enquiry, optional: true

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
  validates :total_price, :booking_amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :apply_variant_pricing, if: -> { bike_variant.present? }
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
    %w[customer_name phone status payment_mode booked_on delivery_date created_at bike_id sales_executive_id]
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

  private

  def sync_bike_from_variant
    self.bike = bike_variant.bike if bike_variant.present?
  end

  def apply_variant_pricing
    self.ex_showroom_price = bike_variant.ex_showroom_price
    self.insurance = bike_variant.insurance
    self.rto = bike_variant.rto
    self.other_charges = bike_variant.handling_charge.to_d + bike_variant.accessories_charge.to_d
  end

  def calculate_total_price
    self.total_price = ex_showroom_price.to_d + insurance.to_d + rto.to_d + other_charges.to_d
  end

  def sync_status_dates
    self.quoted_on ||= Date.current if quoted? && quoted_on.blank?
    self.booked_on ||= Date.current if booked? && booked_on.blank?
    self.delivery_date ||= Date.current if delivered? && delivery_date.blank?
  end
end
