# frozen_string_literal: true

class Bike < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  enum :status, { draft: 0, published: 1, hidden: 2 }, default: :draft

  has_many :bike_variants, dependent: :destroy
  has_many :bike_features, dependent: :destroy
  has_many :bike_specifications, dependent: :destroy
  has_many :offers, dependent: :nullify
  has_many :test_rides, dependent: :destroy
  has_many :enquiries, dependent: :nullify

  has_many_attached :images
  has_one_attached :thumbnail
  has_one_attached :brochure

  accepts_nested_attributes_for :bike_variants, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :bike_features, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :bike_specifications, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true

  scope :published_bikes, -> { where(status: :published) }
  scope :featured, -> { published_bikes.order(created_at: :desc).limit(6) }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  def self.ransackable_attributes(_auth_object = nil)
    %w[category name engine mileage power status slug]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  before_validation :set_published_at, if: -> { published? && published_at.blank? }

  def starting_price
    bike_variants.available_variants.minimum(:total_price) || bike_variants.minimum(:total_price)
  end

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def hide!
    update!(status: :hidden)
  end

  private

  def set_published_at
    self.published_at = Time.current
  end
end
