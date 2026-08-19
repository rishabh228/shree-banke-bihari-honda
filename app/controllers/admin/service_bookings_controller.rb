# frozen_string_literal: true

module Admin
  class ServiceBookingsController < BaseController
    before_action :set_service_booking, only: %i[
      show edit update destroy assign transition
      update_job_card job_card_pdf issue_workshop_invoice workshop_invoice_pdf
    ]

    def index
      authorize ServiceBooking

      @q = policy_scope(ServiceBooking).ransack(ransack_query_for(ServiceBooking))
      @pagy, @service_bookings = pagy(@q.result.includes(:assigned_to).order(created_at: :desc))
    end

    def new
      @service_booking = ServiceBooking.new(preferred_date: Date.current, service_type: "paid")
      authorize @service_booking, :admin_create?
      load_service_advisors
    end

    def create
      @service_booking = ServiceBooking.new(service_booking_params)
      authorize @service_booking, :admin_create?

      result = ServiceBookings::CreateFromAdminService.new(service_booking_params, created_by: current_user).call
      if result[:success]
        redirect_to admin_service_booking_path(result[:service_booking]),
                    notice: "Service booking created. Open the job card when the bike is in the bay, then issue the workshop invoice."
      else
        @service_booking = result[:service_booking]
        load_service_advisors
        flash.now[:alert] = Array(result[:errors]).join(", ").presence
        render :new, status: :unprocessable_entity
      end
    end

    def export_pdf
      authorize ServiceBooking, :index?

      records = export_pdf_scope(ServiceBooking, includes: [ :assigned_to ])
      send_pdf_report(Reports::Pdf::ServiceBookingsListReport, records, "service-bookings-list")
    end

    def show
      authorize @service_booking
      @job_card = @service_booking.job_card
      @job_card_line = JobCardLine.new(quantity: 1, line_type: "part")
      @accessories = Accessory.active.order(:name)
    end

    def edit
      authorize @service_booking
      load_service_advisors
    end

    def update
      authorize @service_booking

      if @service_booking.update(service_booking_params)
        redirect_to admin_service_booking_path(@service_booking), notice: "Service booking was successfully updated."
      else
        load_service_advisors
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

    def update_job_card
      authorize @service_booking, :manage_job_card?

      result = Billing::EnsureJobCardService.new(@service_booking).call
      unless result[:success]
        redirect_to admin_service_booking_path(@service_booking), alert: result[:error]
        return
      end

      if result[:job_card].update(job_card_params)
        redirect_to admin_service_booking_path(@service_booking), notice: "Job card details saved."
      else
        redirect_to admin_service_booking_path(@service_booking), alert: result[:job_card].errors.full_messages.join(", ")
      end
    end

    def job_card_pdf
      authorize @service_booking, :job_card_pdf?
      result = Billing::EnsureJobCardService.new(@service_booking).call
      unless result[:success]
        redirect_to admin_service_booking_path(@service_booking), alert: result[:error]
        return
      end

      send_data Reports::Pdf::JobCardReport.new(result[:job_card]).render,
                filename: "#{result[:job_card].job_card_number.parameterize}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    def issue_workshop_invoice
      authorize @service_booking, :issue_workshop_invoice?

      result = Billing::IssueWorkshopInvoiceService.new(@service_booking, issued_by: current_user).call
      if result[:success]
        redirect_to admin_service_booking_path(@service_booking), notice: "Workshop invoice #{result[:invoice].invoice_number} issued."
      else
        redirect_to admin_service_booking_path(@service_booking), alert: result[:error]
      end
    end

    def workshop_invoice_pdf
      authorize @service_booking, :workshop_invoice_pdf?
      invoice = @service_booking.workshop_invoice
      unless invoice&.issued?
        redirect_to admin_service_booking_path(@service_booking), alert: "Issue the workshop tax invoice first."
        return
      end

      copy_type = params[:copy].presence || "original"
      send_data Reports::Pdf::CounterInvoiceReport.new(invoice, copy_type: copy_type).render,
                filename: "#{invoice.invoice_number.parameterize}-#{copy_type}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    private

    def set_service_booking
      @service_booking = ServiceBooking.find(params[:id])
    end

    def load_service_advisors
      @service_advisors = User.where(role: %i[service_advisor manager super_admin]).order(:name)
    end

    def service_booking_params
      params.require(:service_booking).permit(
        :customer_name, :phone, :email, :vehicle_number, :bike_model, :purchase_year,
        :service_type, :preferred_date, :complaint, :status, :assigned_to_id
      )
    end

    def job_card_params
      params.require(:job_card).permit(:km_reading, :chassis_number, :engine_number)
    end
  end
end
