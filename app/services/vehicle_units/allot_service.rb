# frozen_string_literal: true

module VehicleUnits
  class AllotService
    def initialize(sale, vehicle_unit)
      @sale = sale
      @vehicle_unit = vehicle_unit
    end

    def call
      return failure("Select a chassis unit") if @vehicle_unit.blank?
      return failure("This chassis is not in stock") unless @vehicle_unit.in_stock?
      return failure("Chassis does not match the selected variant") unless variant_matches?
      return failure("This sale already has a chassis allotted") if @sale.vehicle_unit.present?
      return failure("Cannot allot chassis to a cancelled sale") if @sale.cancelled?

      VehicleUnit.transaction do
        @vehicle_unit.with_lock do
          return failure("This chassis is not in stock") unless @vehicle_unit.in_stock?

          @vehicle_unit.update!(status: :allotted, sale: @sale)
        end

        @sale.update!(
          vehicle_unit: @vehicle_unit,
          chassis_number: @vehicle_unit.chassis_number,
          engine_number: @vehicle_unit.engine_number,
          bike_variant: @vehicle_unit.bike_variant,
          bike: @vehicle_unit.bike_variant.bike
        )
        @vehicle_unit.bike_variant.decrement_stock!
      end

      { success: true, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def variant_matches?
      return true if @sale.bike_variant_id.blank?

      @sale.bike_variant_id == @vehicle_unit.bike_variant_id
    end

    def failure(message)
      { success: false, error: message }
    end
  end
end
