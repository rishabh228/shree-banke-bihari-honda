# frozen_string_literal: true

module Public
  class AccessoriesController < BaseController
    def index
      accessories = Accessory.available.with_attached_image.order(:name)
      @pagy, @accessories = pagy(accessories)
    end
  end
end
