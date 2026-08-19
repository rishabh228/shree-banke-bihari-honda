# frozen_string_literal: true

module ServiceBookings
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      service_booking = ServiceBooking.new(@params)
      if service_booking.save
        Notifications::StaffNotifier.new(:service_booking, service_booking).call
        {
          success: true,
          service_booking: service_booking,
          whatsapp_customer_url: Notifications::StaffNotifier.customer_whatsapp_url(:service_booking, service_booking)
        }
      else
        { success: false, service_booking: service_booking, errors: service_booking.errors.full_messages }
      end
    end
  end
end
