# frozen_string_literal: true

module Admin
  class EnquiriesController < BaseController
    before_action :set_enquiry, only: %i[show edit update destroy]

    def index
      authorize Enquiry

      @q = policy_scope(Enquiry).ransack(params[:q])
      @pagy, @enquiries = pagy(@q.result.includes(:bike).order(created_at: :desc))
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

    private

    def set_enquiry
      @enquiry = Enquiry.find(params[:id])
    end

    def enquiry_params
      params.require(:enquiry).permit(:source, :name, :phone, :email, :message, :bike_id, :status)
    end
  end
end
