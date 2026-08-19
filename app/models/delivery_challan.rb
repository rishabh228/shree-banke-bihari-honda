# frozen_string_literal: true

class DeliveryChallan < ApplicationRecord
  belongs_to :sale

  validates :challan_number, :challan_date, presence: true
  validates :challan_number, uniqueness: true
  validates :sale_id, uniqueness: true
end
