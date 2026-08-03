# frozen_string_literal: true

class BikeSpecification < ApplicationRecord
  belongs_to :bike

  validates :label, :value, presence: true

  scope :ordered, -> { order(:position, :id) }

  default_scope { order(:position, :id) }
end
