# frozen_string_literal: true

class Offers::ExpireInactiveJob < ApplicationJob
  queue_as :default

  def perform
    Offer.where(active: true).where("end_date < ?", Date.current).find_each(&:deactivate!)
  end
end
