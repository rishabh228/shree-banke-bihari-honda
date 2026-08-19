# frozen_string_literal: true

module Admin
  class EnquiriesController < BaseController
    before_action :set_enquiry, only: %i[show edit update destroy convert_to_sale]

    def index
      authorize Enquiry

      @q = policy_scope(Enquiry).ransack(ransack_query_for(Enquiry))
      @pagy, @enquiries = pagy(@q.result.includes(:bike).order(created_at: :desc))
    end

    def export_pdf
      authorize Enquiry, :index?

      records = export_pdf_scope(Enquiry, includes: [ :bike ])
      send_pdf_report(Reports::Pdf::EnquiriesListReport, records, "enquiries-list")
    end

    def show
      authorize @enquiry
    end

    def edit
      authorize @enquiry
    end

    def update
      authorize @enquiry

      if @enquiry.update(enquiry_params)
        redirect_to admin_enquiry_path(@enquiry), notice: "Enquiry was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @enquiry

      @enquiry.destroy!
      redirect_to admin_enquiries_path, notice: "Enquiry was successfully deleted."
    end

    def convert_to_sale
      authorize @enquiry, :update?

      result = Sales::CreateFromEnquiryService.new(@enquiry, sales_executive: current_user).call

      if result[:success]
        redirect_to admin_sale_path(result[:sale]), notice: "Quotation created from enquiry."
      else
        redirect_to admin_enquiry_path(@enquiry), alert: result[:errors].join(", ")
      end
    end

    private

    def set_enquiry
      @enquiry = Enquiry.find(params[:id])
    end

    def enquiry_params
      params.require(:enquiry).permit(:source, :name, :phone, :email, :message, :bike_id, :status)
    end
  end
end
