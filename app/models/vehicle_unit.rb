# frozen_string_literal: true

class VehicleUnit < ApplicationRecord
  belongs_to :bike_variant
  belongs_to :sale, optional: true

  enum :status, { in_stock: 0, allotted: 1, delivered: 2 }, default: :in_stock

  validates :chassis_number, :engine_number, presence: true
  validates :chassis_number, uniqueness: { case_sensitive: false }
  validates :engine_number, uniqueness: { case_sensitive: false }

  before_validation :normalize_identifiers

  scope :recent, -> { order(created_at: :desc) }
  scope :for_variant, ->(variant_id) { where(bike_variant_id: variant_id) if variant_id.present? }

  def self.ransackable_attributes(_auth_object = nil)
    %w[chassis_number engine_number status bike_variant_id received_on]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[bike_variant sale]
  end

  def display_label
    variant = bike_variant
    bike_name = variant&.bike&.name
    [ chassis_number, engine_number, [ bike_name, variant&.name, variant&.color ].compact.join(" ") ].compact.join(" · ")
  end

  def display_status
    status.humanize.titleize
  end

  private

  def normalize_identifiers
    self.chassis_number = chassis_number.to_s.strip.upcase.presence
    self.engine_number = engine_number.to_s.strip.upcase.presence
  end
end
