# frozen_string_literal: true

class CreditNoteLine < ApplicationRecord
  belongs_to :credit_note
  belongs_to :counter_invoice_line, optional: true
  belongs_to :accessory, optional: true
end
