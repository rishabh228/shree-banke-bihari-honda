# frozen_string_literal: true

class TestRide < ApplicationRecord
  belongs_to :bike

  enum :status, {
    pending: 0,
    confirmed: 1,
    completed: 2,
    cancelled: 3
  }, default: :pending

  validates :name, :phone, :preferred_date, presence: true
  validates :phone, format: { with: /\A[0-9+\-\s]{10,15}\z/, message: "must be valid" }

  scope :upcoming, -> { where(preferred_date: Date.current..).where.not(status: :cancelled).order(:preferred_date) }
  scope :today, -> { where(preferred_date: Date.current) }
  scope :recent, -> { order(created_at: :desc) }

  def transition_to!(new_status)
    update!(status: new_status)
  end
end
