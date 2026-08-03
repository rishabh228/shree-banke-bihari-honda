# frozen_string_literal: true

class ServiceBooking < ApplicationRecord
  belongs_to :assigned_to, class_name: "User", optional: true

  enum :status, {
    pending: 0,
    assigned: 1,
    in_progress: 2,
    completed: 3,
    delivered: 4,
    cancelled: 5
  }, default: :pending

  SERVICE_TYPES = %w[free paid warranty general].freeze

  validates :customer_name, :phone, :vehicle_number, :bike_model, :service_type, :preferred_date, presence: true
  validates :service_type, inclusion: { in: SERVICE_TYPES }
  validates :phone, format: { with: /\A[0-9+\-\s]{10,15}\z/, message: "must be valid" }

  scope :upcoming, -> { where(preferred_date: Date.current..).where.not(status: :cancelled).order(:preferred_date) }
  scope :today, -> { where(preferred_date: Date.current) }
  scope :recent, -> { order(created_at: :desc) }
end
