# frozen_string_literal: true

class BikeVariant < ApplicationRecord
  LOW_STOCK_THRESHOLD = 3

  belongs_to :bike

  has_many :sales, dependent: :nullify

  validates :name, presence: true
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :ex_showroom_price, :insurance, :rto, :handling_charge, :accessories_charge, :total_price,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :available_variants, -> { where(available: true).where("stock_quantity > 0") }
  scope :ordered, -> { order(:name) }
  scope :low_stock, -> { where("stock_quantity > 0 AND stock_quantity <= ?", LOW_STOCK_THRESHOLD) }
  scope :out_of_stock, -> { where(stock_quantity: 0) }

  before_save :calculate_total_price

  def calculate_total_price
    self.total_price = ex_showroom_price.to_d + insurance.to_d + rto.to_d +
                       handling_charge.to_d + accessories_charge.to_d
  end

  def in_stock?
    available? && stock_quantity.positive?
  end

  def low_stock?
    in_stock? && stock_quantity <= LOW_STOCK_THRESHOLD
  end

  def out_of_stock?
    stock_quantity.zero?
  end

  def stock_label
    return "Out of Stock" if out_of_stock? || !available?
    return "Only #{stock_quantity} left" if low_stock?

    "#{stock_quantity} units available"
  end

  def decrement_stock!(quantity = 1)
    with_lock do
      new_quantity = [ stock_quantity - quantity, 0 ].max
      attrs = { stock_quantity: new_quantity }
      attrs[:available] = false if new_quantity.zero?
      update!(attrs)
    end
  end
end
