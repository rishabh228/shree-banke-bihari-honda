# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :sale

  has_many :line_items, -> { ordered }, class_name: "InvoiceLineItem", dependent: :destroy, inverse_of: :invoice
  has_many :credit_notes, dependent: :destroy

  attribute :einvoice_status, :integer

  enum :status, { issued: 0, cancelled: 1 }, default: :issued
  enum :einvoice_status, { not_applicable: 0, pending: 1, registered: 2, failed: 3 }, default: :not_applicable

  validates :invoice_number, :invoice_date, presence: true
  validates :invoice_number, uniqueness: true
  validate :only_one_issued_invoice, if: :issued?

  scope :recent, -> { order(invoice_date: :desc, created_at: :desc) }

  def display_status
    status.humanize.titleize
  end

  def vehicle_tax
    vehicle_cgst.to_d + vehicle_sgst.to_d + vehicle_igst.to_d
  end

  def accessories_tax
    accessories_cgst.to_d + accessories_sgst.to_d + accessories_igst.to_d
  end

  def irn_registered?
    irn.present?
  end

  def einvoice_applicable?
    sale&.buyer_gstin.present?
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

  private

  def only_one_issued_invoice
    return if sale.blank?

    existing = sale.invoices.issued
    existing = existing.where.not(id: id) if persisted?
    errors.add(:base, "This sale already has an issued tax invoice") if existing.exists?
  end
end
