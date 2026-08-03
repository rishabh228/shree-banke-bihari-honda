# frozen_string_literal: true

class BikeFeature < ApplicationRecord
  belongs_to :bike

  validates :title, presence: true

  scope :ordered, -> { order(:position, :id) }

  default_scope { order(:position, :id) }
end
