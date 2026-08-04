# frozen_string_literal: true

module Admin
  class ServiceBookingsController < BaseController
    before_action :set_service_booking, only: %i[show edit update destroy assign transition]

    def index
      authorize ServiceBooking

      @q = policy_scope(ServiceBooking).ransack(ransack_query_for(ServiceBooking))
      @pagy, @service_bookings = pagy(@q.result.includes(:assigned_to).order(created_at: :desc))
    end

    def export_pdf
      authorize ServiceBooking, :index?

      records = export_pdf_scope(ServiceBooking, includes: [ :assigned_to ])
      send_pdf_report(Reports::Pdf::ServiceBookingsListReport, records, "service-bookings-list")
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
        redirect_to admin_service_booking_path(@service_booking), notice: "Service booking status updated successfully.", status: :see_other
      else
        redirect_to admin_service_booking_path(@service_booking), alert: result[:error], status: :see_other
      end
    end

    def destroy
      authorize @service_booking

      @service_booking.destroy!
      redirect_to admin_service_bookings_path, notice: "Service booking was successfully deleted."
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
