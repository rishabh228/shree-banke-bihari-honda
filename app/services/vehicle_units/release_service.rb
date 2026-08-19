# frozen_string_literal: true

module VehicleUnits
  class ReleaseService
    def initialize(sale)
      @sale = sale
    end

    def call
      unit = @sale.vehicle_unit
      return { success: true, error: nil } if unit.blank?
      return failure("Delivered chassis cannot be released") if unit.delivered?

      VehicleUnit.transaction do
        unit.with_lock do
          next unless unit.allotted?

          unit.update!(status: :in_stock, sale: nil)
          unit.bike_variant.increment_stock!
        end

        @sale.update_columns(vehicle_unit_id: nil) if @sale.persisted? && !@sale.destroyed?
      end

      { success: true, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def failure(message)
      { success: false, error: message }
    end
  end
end
