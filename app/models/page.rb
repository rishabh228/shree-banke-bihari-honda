# frozen_string_literal: true

class Page < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_rich_text :body

  validates :title, :slug, presence: true
  validates :slug, uniqueness: true

  scope :published_pages, -> { where(published: true) }

  PREDEFINED_SLUGS = %w[about privacy terms faq contact].freeze
end
