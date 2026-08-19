# frozen_string_literal: true

module ServiceBookings
  class AssignService
    def initialize(booking, advisor)
      @booking = booking
      @advisor = advisor
    end

    def call
      return { success: false, error: "Advisor must be a service advisor" } unless @advisor.service_advisor? || @advisor.manager? || @advisor.super_admin?

      @booking.update!(assigned_to: @advisor, status: :assigned)
      { success: true, data: @booking }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, error: e.record.errors.full_messages.join(", ") }
    end
  end
end
