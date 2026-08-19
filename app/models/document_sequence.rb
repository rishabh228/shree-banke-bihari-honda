# frozen_string_literal: true

class DocumentSequence < ApplicationRecord
  validates :document_type, :financial_year, presence: true
  validates :last_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :document_type, uniqueness: { scope: :financial_year }

  def self.financial_year_for(date = Date.current)
    if date.month >= 4
      "#{date.year}-#{(date.year + 1).to_s.last(2)}"
    else
      "#{date.year - 1}-#{date.year.to_s.last(2)}"
    end
  end
end
