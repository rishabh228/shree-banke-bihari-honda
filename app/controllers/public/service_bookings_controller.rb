# frozen_string_literal: true

module Public
  class ServiceBookingsController < BaseController
    def new
      @service_booking = ServiceBooking.new
      authorize @service_booking
    end

    def create
      @service_booking = ServiceBooking.new(service_booking_params)
      authorize @service_booking

      result = ServiceBookings::CreateService.new(service_booking_params).call

      if result[:success]
        redirect_to root_path,
                    status: :see_other,
                    flash: {
                      notice: "Your service booking has been submitted. Our team will confirm your appointment soon.",
                      whatsapp_customer_url: result[:whatsapp_customer_url]
                    }
      else
        @service_booking = result[:service_booking]
        flash.now[:alert] = result[:errors]&.to_sentence.presence ||
                            "Unable to submit your service booking. Please check the form and try again."
        render :new, status: :unprocessable_entity
      end
    end

    private

    def service_booking_params
      params.require(:service_booking).permit(
        :customer_name, :phone, :email, :vehicle_number, :bike_model,
        :purchase_year, :service_type, :preferred_date, :complaint
      )
    end
  end
end
