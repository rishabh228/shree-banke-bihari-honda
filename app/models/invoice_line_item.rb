# frozen_string_literal: true

class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice

  validates :description, :line_type, presence: true

  scope :ordered, -> { order(:position, :id) }
  scope :taxable, -> { where(collected: false) }
  scope :collected, -> { where(collected: true) }

  def tax_amount
    cgst_amount.to_d + sgst_amount.to_d + igst_amount.to_d
  end
end
