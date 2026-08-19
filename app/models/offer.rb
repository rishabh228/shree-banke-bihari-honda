# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :bike, optional: true

  has_one_attached :banner

  validates :title, presence: true

  scope :active_offers, -> { where(active: true).where("end_date IS NULL OR end_date >= ?", Date.current) }
  scope :current, -> { active_offers.where("start_date IS NULL OR start_date <= ?", Date.current) }
  scope :expired, -> { where("end_date < ?", Date.current) }

  before_save :sync_active_status

  def expired?
    end_date.present? && end_date < Date.current
  end

  def deactivate!
    update!(active: false)
  end

  private

  def sync_active_status
    self.active = false if expired?
  end
end
