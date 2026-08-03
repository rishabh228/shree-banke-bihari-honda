# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    super_admin: 0,
    manager: 1,
    sales_executive: 2,
    service_advisor: 3
  }, default: :sales_executive

  has_many :assigned_service_bookings, class_name: "ServiceBooking", foreign_key: :assigned_to_id, dependent: :nullify
  has_many :notifications, dependent: :destroy
  has_many :sales, class_name: "Sale", foreign_key: :sales_executive_id, dependent: :nullify

  validates :name, presence: true
  validates :role, presence: true

  scope :staff, -> { where.not(role: roles[:super_admin]) }

  def display_role
    role.humanize.titleize
  end
end
