# frozen_string_literal: true

module Public
  class BikesController < BaseController
    def index
      @q = Bike.published_bikes.ransack(ransack_params)
      bikes = @q.result(distinct: true).with_attached_thumbnail.order(:name)
      @pagy, @bikes = pagy(bikes)
      @categories = Bike.published_bikes.where.not(category: [ nil, "" ]).distinct.pluck(:category).sort
    end

    def show
      @bike = Bike.published_bikes
                  .includes(:bike_variants, :bike_features, :bike_specifications)
                  .friendly
                  .find(params[:slug])
      @variants = @bike.bike_variants.available_variants.ordered
      @features = @bike.bike_features.ordered
      @specifications = @bike.bike_specifications.ordered
      @related_offers = Offer.current.where(bike: @bike).limit(3)
    end

    private

    def ransack_params
      params.fetch(:q, {}).permit(:category_eq, :name_cont, :engine_cont)
    end
  end
end
