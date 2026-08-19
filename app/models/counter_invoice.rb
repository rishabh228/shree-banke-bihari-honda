# frozen_string_literal: true

class CounterInvoice < ApplicationRecord
  include Discountable

  belongs_to :job_card, optional: true
  belongs_to :issued_by, class_name: "User", optional: true
  has_many :lines, -> { order(:position, :id) }, class_name: "CounterInvoiceLine", dependent: :destroy, inverse_of: :counter_invoice
  has_many :credit_notes, dependent: :destroy

  attribute :kind, :integer
  attribute :status, :integer
  attribute :einvoice_status, :integer

  enum :kind, { spare: 0, workshop: 1 }, default: :spare
  enum :status, { draft: 0, issued: 1, cancelled: 2 }, default: :draft
  enum :einvoice_status, { not_applicable: 0, pending: 1, registered: 2, failed: 3 }, default: :not_applicable

  validates :customer_name, presence: true
  validates :invoice_number, uniqueness: true, allow_nil: true
  validates :invoice_number, :invoice_date, presence: true, if: :issued?
  validates :buyer_gstin, format: { with: Setting::GSTIN_FORMAT, message: "must be a valid 15-character GSTIN" },
            allow_blank: true
  validates :phone, format: { with: /\A[0-9+\-\s]{10,15}\z/, message: "must be valid" }, allow_blank: true
  validate :workshop_needs_job_card

  before_validation :normalize_buyer_identifiers
  before_validation :apply_place_of_supply

  scope :recent, -> { order(created_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[customer_name phone invoice_number kind status invoice_date created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def display_kind
    spare? ? "Spare counter" : "Workshop"
  end

  def display_status
    status.humanize.titleize
  end

  def tax_amount
    tax_total.to_d
  end

  def einvoice_applicable?
    buyer_gstin.present?
  end

  def irn_registered?
    irn.present?
  end

  def credit_noted?
    credit_notes.any?
  end

  def credited_total
    credit_notes.sum(:grand_total).to_d
  end

  def remaining_value
    [ grand_total.to_d - credited_total, 0 ].max
  end

  def fully_credited?
    remaining_value <= 0
  end

  def line_subtotal
    if lines.loaded?
      lines.sum { |line| line.inclusive_amount.to_d }
    else
      lines.sum(:inclusive_amount).to_d
    end
  end

  def preview_discount
    issued? || cancelled? ? discount_total.to_d : computed_discount(line_subtotal)
  end

  def preview_grand_total
    issued? || cancelled? ? grand_total.to_d : [ line_subtotal - preview_discount, 0 ].max
  end

  private

  def workshop_needs_job_card
    errors.add(:job_card, "is required for a workshop invoice") if workshop? && job_card_id.blank?
  end

  def normalize_buyer_identifiers
    self.buyer_gstin = buyer_gstin.to_s.gsub(/\s/, "").upcase.presence
    self.buyer_pan = buyer_pan.to_s.gsub(/\s/, "").upcase.presence
    self.phone = phone.to_s.strip.presence
  end

  def apply_place_of_supply
    settings = Setting.instance
    self.buyer_state = buyer_state.presence || settings.state
    self.buyer_state_code = buyer_state_code.presence || settings.state_code
    self.place_of_supply = buyer_state
    self.place_of_supply_code = buyer_state_code
    dealer = settings.state.to_s.strip.downcase
    buyer = buyer_state.to_s.strip.downcase
    self.inter_state = buyer.present? && dealer.present? && buyer != dealer
  end
end
