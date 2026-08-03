# frozen_string_literal: true

module Admin
  class BannersController < BaseController
    before_action :set_banner, only: %i[show edit update destroy]

    def index
      authorize Banner

      @q = policy_scope(Banner).ransack(ransack_query_for(Banner))
      @pagy, @banners = pagy(@q.result.order(:position, :id))
    end

    def show
      authorize @banner
    end

    def new
      @banner = Banner.new
      authorize @banner
    end

    def edit
      authorize @banner
    end

    def create
      @banner = Banner.new(banner_params)
      authorize @banner

      if @banner.save
        redirect_to admin_banner_path(@banner), notice: "Banner was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @banner

      if @banner.update(banner_params)
        redirect_to admin_banner_path(@banner), notice: "Banner was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @banner

      @banner.destroy!
      redirect_to admin_banners_path, notice: "Banner was successfully deleted."
    end

    private

    def set_banner
      @banner = Banner.unscoped.find(params[:id])
    end

    def banner_params
      params.require(:banner).permit(:title, :subtitle, :link, :position, :section, :active, :image)
    end
  end
end
