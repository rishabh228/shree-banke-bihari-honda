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
      decrement_variant_stock if delivered?
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

    def decrement_variant_stock
      return if @sale.bike_variant.blank?

      @sale.bike_variant.decrement_stock!
    end

    def success(data) = { success: true, data: data, error: nil }
    def failure(msg) = { success: false, data: nil, error: msg }
  end
end
