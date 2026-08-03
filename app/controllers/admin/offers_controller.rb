# frozen_string_literal: true

module Admin
  class OffersController < BaseController
    before_action :set_offer, only: %i[show edit update destroy]

    def index
      authorize Offer

      @q = policy_scope(Offer).ransack(ransack_query_for(Offer))
      @pagy, @offers = pagy(@q.result.includes(:bike).order(created_at: :desc))
    end

    def show
      authorize @offer
    end

    def new
      @offer = Offer.new
      authorize @offer
    end

    def edit
      authorize @offer
    end

    def create
      @offer = Offer.new(offer_params)
      authorize @offer

      if @offer.save
        redirect_to admin_offer_path(@offer), notice: "Offer was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @offer

      if @offer.update(offer_params)
        redirect_to admin_offer_path(@offer), notice: "Offer was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @offer

      @offer.destroy!
      redirect_to admin_offers_path, notice: "Offer was successfully deleted."
    end

    private

    def set_offer
      @offer = Offer.find(params[:id])
    end

    def offer_params
      params.require(:offer).permit(
        :title, :description, :bike_id, :start_date, :end_date, :active, :banner
      )
    end
  end
end
