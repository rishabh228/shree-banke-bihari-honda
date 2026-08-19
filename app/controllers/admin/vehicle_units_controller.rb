# frozen_string_literal: true

module Admin
  class VehicleUnitsController < BaseController
    before_action :set_vehicle_unit, only: %i[show edit update destroy]

    def index
      authorize VehicleUnit

      @q = policy_scope(VehicleUnit).ransack(ransack_query_for(VehicleUnit))
      @pagy, @vehicle_units = pagy(
        @q.result.includes(bike_variant: :bike, sale: {}).order(created_at: :desc)
      )
    end

    def show
      authorize @vehicle_unit
    end

    def new
      @vehicle_unit = VehicleUnit.new(received_on: Date.current, status: :in_stock)
      authorize @vehicle_unit
      load_form_data
    end

    def edit
      authorize @vehicle_unit
      load_form_data
    end

    def create
      @vehicle_unit = VehicleUnit.new(vehicle_unit_params)
      authorize @vehicle_unit

      if @vehicle_unit.save
        redirect_to admin_vehicle_unit_path(@vehicle_unit), notice: "Chassis unit was added to stock."
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @vehicle_unit

      if @vehicle_unit.update(vehicle_unit_params)
        redirect_to admin_vehicle_unit_path(@vehicle_unit), notice: "Chassis unit was updated."
      else
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @vehicle_unit

      if @vehicle_unit.allotted? || @vehicle_unit.delivered?
        redirect_to admin_vehicle_unit_path(@vehicle_unit), alert: "Cannot delete an allotted or delivered chassis."
        return
      end

      @vehicle_unit.destroy!
      redirect_to admin_vehicle_units_path, notice: "Chassis unit was deleted."
    end

    private

    def set_vehicle_unit
      @vehicle_unit = VehicleUnit.find(params[:id])
    end

    def load_form_data
      @bike_variants = BikeVariant.includes(:bike).ordered
    end

    def vehicle_unit_params
      params.require(:vehicle_unit).permit(:bike_variant_id, :chassis_number, :engine_number, :received_on, :notes)
    end
  end
end
