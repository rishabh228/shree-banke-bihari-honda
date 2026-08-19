# frozen_string_literal: true

module Sales
  class StatusTransitionService
    ALLOWED = {
      "quoted" => %w[booked cancelled],
      "booked" => %w[rto_processing cancelled],
      "rto_processing" => %w[delivered cancelled],
      "delivered" => [],
      "cancelled" => []
    }.freeze

    def initialize(sale, new_status)
      @sale = sale
      @new_status = new_status.to_s
      @previous_status = sale.status
    end

    def call
      return failure("Invalid status transition") unless allowed?

      @sale.update!(status: @new_status)
      apply_stock_and_chassis
      Notifications::StaffNotifier.new(:sale_status, @sale).call
      success(@sale)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def allowed?
      ALLOWED[@sale.status]&.include?(@new_status)
    end

    def delivered?
      @new_status == "delivered" && @previous_status != "delivered"
    end

    def cancelled?
      @new_status == "cancelled" && @previous_status != "cancelled"
    end

    def apply_stock_and_chassis
      if delivered?
        mark_unit_delivered_or_decrement_stock
      elsif cancelled?
        VehicleUnits::ReleaseService.new(@sale).call
      end
    end

    def mark_unit_delivered_or_decrement_stock
      unit = @sale.vehicle_unit
      if unit.present?
        unit.update!(status: :delivered) unless unit.delivered?
      else
        decrement_variant_stock
      end
    end

    def decrement_variant_stock
      return if @sale.bike_variant.blank?

      @sale.bike_variant.decrement_stock!
    end

    def success(data) = { success: true, data: data, error: nil }
    def failure(msg) = { success: false, data: nil, error: msg }
  end
end
