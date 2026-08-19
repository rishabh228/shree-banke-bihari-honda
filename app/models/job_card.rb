# frozen_string_literal: true

class JobCard < ApplicationRecord
  belongs_to :service_booking
  has_many :lines, -> { order(:position, :id) }, class_name: "JobCardLine", dependent: :destroy, inverse_of: :job_card
  has_one :counter_invoice, dependent: :restrict_with_error

  attribute :status, :integer
  enum :status, { open: 0, billed: 1, closed: 2 }, default: :open

  validates :job_card_number, :job_card_date, presence: true
  validates :job_card_number, uniqueness: true
  validates :service_booking_id, uniqueness: true
  validates :km_reading, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def parts
    lines.select(&:part?)
  end

  def labour
    lines.select(&:labour?)
  end

  def estimate_total
    lines.sum(&:line_total)
  end
end
