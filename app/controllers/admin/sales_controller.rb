# frozen_string_literal: true

module Admin
  class SalesController < BaseController
    before_action :set_sale, only: %i[show edit update destroy transition quotation_pdf]
    before_action :load_form_data, only: %i[new edit create update]

    def index
      authorize Sale

      @q = policy_scope(Sale).ransack(params[:q])
      @pagy, @sales = pagy(@q.result.includes(:bike, :bike_variant, :sales_executive).order(created_at: :desc))
    end

    def show
      authorize @sale
    end

    def new
      @sale = Sale.new(status: :quoted, quoted_on: Date.current, sales_executive: current_user)
      prefill_from_params
      authorize @sale
    end

    def edit
      authorize @sale
    end

    def create
      @sale = Sale.new(sale_params)
      @sale.sales_executive ||= current_user
      authorize @sale

      if @sale.save
        Notifications::StaffNotifier.new(:sale, @sale).call
        redirect_to admin_sale_path(@sale), notice: "Sale record was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @sale

      if @sale.update(sale_params)
        redirect_to admin_sale_path(@sale), notice: "Sale record was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @sale

      @sale.destroy!
      redirect_to admin_sales_path, notice: "Sale record was successfully deleted."
    end

    def transition
      authorize @sale, :transition?

      result = Sales::StatusTransitionService.new(@sale, params[:status]).call

      if result[:success]
        redirect_to admin_sale_path(@sale), notice: "Sale status updated to #{@sale.display_status}."
      else
        redirect_to admin_sale_path(@sale), alert: result[:error]
      end
    end

    def export_pdf
      authorize Sale, :export_pdf?

      records = export_pdf_scope(Sale, includes: [ :bike, :bike_variant, :sales_executive ])
      send_pdf_report(Reports::Pdf::SalesListReport, records, "sales-list")
    end

    def quotation_pdf
      authorize @sale, :quotation_pdf?

      pdf = Reports::Pdf::QuotationReport.new(@sale).render
      send_data pdf,
                filename: "quotation-#{@sale.customer_name.parameterize}-#{Date.current.iso8601}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    private

    def set_sale
      @sale = Sale.find(params[:id])
    end

    def load_form_data
      @bikes = Bike.published_bikes.order(:name)
      @bike_variants = BikeVariant.joins(:bike).includes(:bike).merge(Bike.published_bikes).ordered
      @sales_executives = User.where(role: %i[sales_executive manager super_admin]).order(:name)
      @enquiries = Enquiry.open.includes(:bike).recent.limit(50)
    end

    def prefill_from_params
      return if params[:enquiry_id].blank?

      enquiry = Enquiry.find_by(id: params[:enquiry_id])
      return unless enquiry

      @sale.assign_attributes(
        customer_name: enquiry.name,
        phone: enquiry.phone,
        email: enquiry.email,
        bike: enquiry.bike,
        bike_variant: enquiry.bike&.bike_variants&.first,
        enquiry: enquiry,
        notes: enquiry.message
      )
    end

    def sale_params
      params.require(:sale).permit(
        :customer_name, :phone, :email, :address,
        :bike_id, :bike_variant_id, :sales_executive_id, :enquiry_id,
        :ex_showroom_price, :insurance, :rto, :other_charges, :total_price,
        :booking_amount, :payment_mode, :finance_partner, :status,
        :quoted_on, :booked_on, :delivery_date,
        :chassis_number, :engine_number, :notes
      )
    end
  end
end
