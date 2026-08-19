# frozen_string_literal: true

class PaymentReceipt < ApplicationRecord
  belongs_to :sale
  belongs_to :received_by, class_name: "User", optional: true

  attribute :receipt_head, :integer

  enum :payment_mode, {
    cash: 0,
    finance: 1,
    upi: 2,
    mixed: 3,
    cheque: 4,
    bank_transfer: 5
  }, default: :cash

  enum :receipt_head, {
    vehicle: 0,
    insurance: 1,
    rto: 2,
    accessories: 3,
    other: 4
  }, default: :vehicle

  validates :receipt_number, :received_on, :amount, presence: true
  validates :receipt_number, uniqueness: true
  validates :amount, numericality: { greater_than: 0 }

  scope :recent, -> { order(received_on: :desc, created_at: :desc) }

  def display_payment_mode
    payment_mode.humanize.titleize
  end

  def display_head
    receipt_head.humanize.titleize
  end
end
