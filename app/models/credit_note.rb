# frozen_string_literal: true

class CreditNote < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :sale, optional: true
  belongs_to :counter_invoice, optional: true
  has_many :lines, class_name: "CreditNoteLine", dependent: :destroy

  enum :kind, { full: 0, partial: 1 }, default: :full

  validates :credit_note_number, :credit_note_date, presence: true
  validates :credit_note_number, uniqueness: true
  validates :grand_total, numericality: { greater_than: 0 }
  validate :source_document_present

  def party_name
    sale&.customer_name || counter_invoice&.customer_name
  end

  def party_phone
    sale&.phone || counter_invoice&.phone
  end

  def party_address
    sale&.address || counter_invoice&.address
  end

  def party_gstin
    sale&.buyer_gstin || counter_invoice&.buyer_gstin
  end

  def against_number
    invoice&.invoice_number || counter_invoice&.invoice_number
  end

  def against_date
    invoice&.invoice_date || counter_invoice&.invoice_date
  end

  def reversed_taxable
    taxable_total.to_d
  end

  def reversed_tax
    tax_total.to_d
  end

  def reversed_collected
    collected_total.to_d
  end

  def vehicle_credit?
    invoice.present?
  end

  def chassis_number
    sale&.chassis_number
  end

  def engine_number
    sale&.engine_number
  end

  def bike_name
    sale&.bike&.name
  end

  def gst_split
    { cgst: cgst_amount.to_d, sgst: sgst_amount.to_d, igst: igst_amount.to_d }
  end

  def display_kind
    full? ? "Full" : "Partial"
  end

  private

  def source_document_present
    vehicle = invoice_id.present? && sale_id.present?
    counter = counter_invoice_id.present?
    return if vehicle ^ counter

    errors.add(:base, "Credit note must reverse either a vehicle invoice or a spare/workshop invoice")
  end
end
