# frozen_string_literal: true

module ServiceBookings
  class StatusTransitionService
    ALLOWED = {
      "pending" => %w[assigned cancelled],
      "assigned" => %w[in_progress cancelled],
      "in_progress" => %w[completed cancelled],
      "completed" => %w[delivered],
      "delivered" => [],
      "cancelled" => []
    }.freeze

    def initialize(booking, new_status)
      @booking = booking
      @new_status = new_status.to_s
    end

    def call
      return failure("Invalid status transition") unless allowed?

      @booking.update!(status: @new_status)
      success(@booking)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def allowed?
      ALLOWED[@booking.status]&.include?(@new_status)
    end

    def success(data) = { success: true, data: data, error: nil }
    def failure(msg) = { success: false, data: nil, error: msg }
  end
end
