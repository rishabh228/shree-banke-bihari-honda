# frozen_string_literal: true

class Setting < ApplicationRecord
  has_one_attached :logo

  validates :showroom_name, presence: true

  def self.instance
    first || create!(showroom_name: "Shree Banke Bihari Honda")
  end
end
