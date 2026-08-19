# frozen_string_literal: true

module Public
  class HomeController < BaseController
    def index
      @featured_bikes = Bike.featured.with_attached_thumbnail
      @offers = Offer.current.includes(:bike).limit(4)
      @banners = Banner.active_banners.for_section("hero")
      @news_banners = Banner.active_banners.for_section("news")
      @accessories = Accessory.available.limit(8)
      @settings = current_settings
    end
  end
end
