# frozen_string_literal: true

module Admin
  class MediaAssetsController < BaseController
    before_action :set_media_asset, only: %i[show edit update destroy]

    def index
      authorize MediaAsset

      @q = policy_scope(MediaAsset).ransack(params[:q])
      @pagy, @media_assets = pagy(@q.result.order(created_at: :desc))
    end

    def show
      authorize @media_asset
    end

    def new
      @media_asset = MediaAsset.new
      authorize @media_asset
    end

    def edit
      authorize @media_asset
    end

    def create
      @media_asset = MediaAsset.new(media_asset_params)
      authorize @media_asset

      if @media_asset.save
        redirect_to admin_media_asset_path(@media_asset), notice: "Media asset was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @media_asset

      if @media_asset.update(media_asset_params)
        redirect_to admin_media_asset_path(@media_asset), notice: "Media asset was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @media_asset

      @media_asset.destroy!
      redirect_to admin_media_assets_path, notice: "Media asset was successfully deleted."
    end

    private

    def set_media_asset
      @media_asset = MediaAsset.find(params[:id])
    end

    def media_asset_params
      params.require(:media_asset).permit(:title, :description, :file)
    end
  end
end
