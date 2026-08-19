# frozen_string_literal: true

module TestRides
  class StatusTransitionService
    ALLOWED = {
      "pending" => %w[confirmed cancelled],
      "confirmed" => %w[completed cancelled],
      "completed" => [],
      "cancelled" => []
    }.freeze

    def initialize(test_ride, new_status)
      @test_ride = test_ride
      @new_status = new_status.to_s
    end

    def call
      return failure("Invalid status transition") unless allowed?

      @test_ride.update!(status: @new_status)
      success(@test_ride)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def allowed?
      ALLOWED[@test_ride.status]&.include?(@new_status)
    end

    def success(data) = { success: true, data: data, error: nil }
    def failure(msg) = { success: false, data: nil, error: msg }
  end
end
