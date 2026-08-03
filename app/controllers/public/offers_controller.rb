# frozen_string_literal: true

module Public
  class OffersController < BaseController
    def index
      offers = Offer.current.includes(:bike).with_attached_banner.order(created_at: :desc)
      @pagy, @offers = pagy(offers)
    end
  end
end
