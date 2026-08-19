# frozen_string_literal: true

class CounterInvoiceLine < ApplicationRecord
  belongs_to :counter_invoice
  belongs_to :accessory, optional: true

  validates :description, :line_type, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  scope :ordered, -> { order(:position, :id) }

  def tax_amount
    cgst_amount.to_d + sgst_amount.to_d + igst_amount.to_d
  end

  def part?
    line_type == "part" || line_type == "accessory"
  end

  def labour?
    line_type == "labour"
  end

  def returned_quantity
    CreditNoteLine.where(counter_invoice_line_id: id).sum(:quantity).to_d
  end

  def remaining_quantity
    [ quantity.to_d - returned_quantity, 0 ].max
  end
end
