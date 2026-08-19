# frozen_string_literal: true

module Admin
  class JobCardLinesController < BaseController
    before_action :set_service_booking

    def create
      authorize @service_booking, :manage_job_card?

      result = Billing::EnsureJobCardService.new(@service_booking).call
      unless result[:success]
        redirect_to admin_service_booking_path(@service_booking), alert: result[:error]
        return
      end

      job_card = result[:job_card]
      if job_card.billed?
        redirect_to admin_service_booking_path(@service_booking), alert: "This job card is already billed."
        return
      end

      line = job_card.lines.build(line_params)
      if line.save
        redirect_to admin_service_booking_path(@service_booking), notice: "Job card line added."
      else
        redirect_to admin_service_booking_path(@service_booking), alert: line.errors.full_messages.join(", ")
      end
    end

    def destroy
      authorize @service_booking, :manage_job_card?
      job_card = @service_booking.job_card
      return redirect_to admin_service_booking_path(@service_booking), alert: "No job card yet." if job_card.blank?
      return redirect_to admin_service_booking_path(@service_booking), alert: "Billed job cards cannot be edited." if job_card.billed?

      job_card.lines.find(params[:id]).destroy!
      redirect_to admin_service_booking_path(@service_booking), notice: "Line removed."
    end

    private

    def set_service_booking
      @service_booking = ServiceBooking.find(params[:service_booking_id])
    end

    def line_params
      params.require(:job_card_line).permit(
        :accessory_id, :line_type, :description, :quantity, :unit_price, :hsn_code, :gst_rate, :uqc
      )
    end
  end
end
