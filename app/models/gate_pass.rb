# frozen_string_literal: true

class GatePass < ApplicationRecord
  belongs_to :sale

  DRIVEN_BY = %w[customer transporter showroom_staff].freeze

  validates :gate_pass_number, :issued_at, presence: true
  validates :gate_pass_number, uniqueness: true
  validates :sale_id, uniqueness: true
  validates :driven_by, inclusion: { in: DRIVEN_BY }, allow_blank: true

  def display_driven_by
    driven_by.presence&.humanize || "Customer"
  end
end
