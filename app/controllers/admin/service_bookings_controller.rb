# frozen_string_literal: true

module Admin
  class ServiceBookingsController < BaseController
    before_action :set_service_booking, only: %i[show edit update assign transition]

    def index
      authorize ServiceBooking

      @q = policy_scope(ServiceBooking).ransack(params[:q])
      @pagy, @service_bookings = pagy(@q.result.includes(:assigned_to).order(created_at: :desc))
    end

    def show
      authorize @service_booking
    end

    def edit
      authorize @service_booking
      @service_advisors = User.where(role: %i[service_advisor manager super_admin]).order(:name)
    end

    def update
      authorize @service_booking

      if @service_booking.update(service_booking_params)
        redirect_to admin_service_booking_path(@service_booking), notice: "Service booking was successfully updated."
      else
        @service_advisors = User.where(role: %i[service_advisor manager super_admin]).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def assign
      authorize @service_booking, :update?

      advisor = User.find(params[:assigned_to_id])
      result = ServiceBookings::AssignService.new(@service_booking, advisor).call

      if result[:success]
        redirect_to admin_service_booking_path(@service_booking), notice: "Service booking assigned successfully."
      else
        redirect_to admin_service_booking_path(@service_booking), alert: result[:error]
      end
    end

    def transition
      authorize @service_booking, :update?

      result = ServiceBookings::StatusTransitionService.new(@service_booking, params[:status]).call

      if result[:success]
        redirect_to admin_service_booking_path(@service_booking), notice: "Service booking status updated successfully."
      else
        redirect_to admin_service_booking_path(@service_booking), alert: result[:error]
      end
    end

    private

    def set_service_booking
      @service_booking = ServiceBooking.find(params[:id])
    end

    def service_booking_params
      params.require(:service_booking).permit(
        :customer_name, :phone, :email, :vehicle_number, :bike_model, :purchase_year,
        :service_type, :preferred_date, :complaint, :status, :assigned_to_id
      )
    end
  end
end
