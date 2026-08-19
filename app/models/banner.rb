# frozen_string_literal: true

class Banner < ApplicationRecord
  has_one_attached :image

  SECTIONS = %w[hero gallery testimonial news].freeze

  validates :section, presence: true, inclusion: { in: SECTIONS }

  scope :active_banners, -> { where(active: true) }
  scope :for_section, ->(section) { where(section: section) }
  scope :ordered, -> { order(:position, :id) }

  default_scope { order(:position, :id) }
end
