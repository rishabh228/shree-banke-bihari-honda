# frozen_string_literal: true

module Public
  class GalleryController < BaseController
    def index
      @media_assets = MediaAsset.images.recent.includes(file_attachment: :blob)
      @gallery_banners = Banner.active_banners.for_section("gallery")
      @news_banners = Banner.active_banners.for_section("news")
    end
  end
end
