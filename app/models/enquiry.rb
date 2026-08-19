# frozen_string_literal: true

class Enquiry < ApplicationRecord
  belongs_to :bike, optional: true

  has_many :sales, dependent: :nullify

  enum :source, {
    contact_form: 0,
    bike_enquiry: 1,
    finance: 2,
    insurance: 3,
    accessories: 4,
    general: 5,
    test_ride: 6
  }, default: :general

  enum :status, {
    new_enquiry: 0,
    contacted: 1,
    follow_up: 2,
    closed: 3
  }, default: :new_enquiry

  validates :name, :phone, presence: true
  validates :phone, format: { with: /\A[0-9+\-\s]{10,15}\z/, message: "must be valid" }

  scope :today, -> { where(created_at: Time.zone.today.all_day) }
  scope :recent, -> { order(created_at: :desc) }
  scope :open, -> { where.not(status: :closed) }

  def source_label
    source.humanize.titleize
  end
end
