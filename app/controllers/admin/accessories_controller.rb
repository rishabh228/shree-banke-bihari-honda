# frozen_string_literal: true

module Admin
  class AccessoriesController < BaseController
    before_action :set_accessory, only: %i[show edit update destroy]

    def index
      authorize Accessory

      @q = policy_scope(Accessory).ransack(ransack_query_for(Accessory))
      @pagy, @accessories = pagy(@q.result.order(created_at: :desc))
    end

    def show
      authorize @accessory
    end

    def new
      @accessory = Accessory.new
      authorize @accessory
    end

    def edit
      authorize @accessory
    end

    def create
      @accessory = Accessory.new(accessory_params)
      authorize @accessory

      if @accessory.save
        redirect_to admin_accessory_path(@accessory), notice: "Accessory was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @accessory

      if @accessory.update(accessory_params)
        redirect_to admin_accessory_path(@accessory), notice: "Accessory was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @accessory

      @accessory.destroy!
      redirect_to admin_accessories_path, notice: "Accessory was successfully deleted."
    end

    private

    def set_accessory
      @accessory = Accessory.find(params[:id])
    end

    def accessory_params
      params.require(:accessory).permit(:name, :description, :price, :stock, :status, :image)
    end
  end
end
