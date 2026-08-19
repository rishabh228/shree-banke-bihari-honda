# frozen_string_literal: true

module Admin
  class SaleAddOnsController < BaseController
    before_action :set_sale

    def create
      authorize @sale, :update?

      add_on = @sale.sale_add_ons.build(add_on_params)
      if add_on.save
        @sale.save!
        redirect_to admin_sale_path(@sale), notice: "Accessory line added to the bill."
      else
        redirect_to admin_sale_path(@sale), alert: add_on.errors.full_messages.join(", ")
      end
    end

    def destroy
      authorize @sale, :update?

      add_on = @sale.sale_add_ons.find(params[:id])
      add_on.destroy!
      @sale.save!
      redirect_to admin_sale_path(@sale), notice: "Accessory line removed."
    end

    private

    def set_sale
      @sale = Sale.find(params[:sale_id])
    end

    def add_on_params
      params.require(:sale_add_on).permit(:accessory_id, :description, :quantity, :unit_price, :hsn_code, :gst_rate)
    end
  end
end
