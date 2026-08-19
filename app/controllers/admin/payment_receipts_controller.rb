# frozen_string_literal: true

module Admin
  class PaymentReceiptsController < BaseController
    before_action :set_sale

    def create
      authorize @sale, :create_receipt?

      result = Billing::CreateReceiptService.new(@sale, receipt_params, received_by: current_user).call

      if result[:success]
        redirect_to admin_sale_path(@sale), notice: "Receipt #{result[:receipt].receipt_number} recorded."
      else
        redirect_to admin_sale_path(@sale), alert: result[:error]
      end
    end

    def destroy
      receipt = @sale.payment_receipts.find(params[:id])
      authorize @sale, :destroy_receipt?

      receipt.destroy!
      @sale.update_column(:booking_amount, @sale.payment_receipts.sum(:amount))
      redirect_to admin_sale_path(@sale), notice: "Receipt deleted."
    end

    def pdf
      receipt = @sale.payment_receipts.find(params[:id])
      authorize @sale, :receipt_pdf?

      pdf = Reports::Pdf::PaymentReceiptReport.new(receipt).render
      send_data pdf,
                filename: "#{receipt.receipt_number.parameterize}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    private

    def set_sale
      @sale = Sale.find(params[:sale_id])
    end

    def receipt_params
      params.require(:payment_receipt).permit(:amount, :payment_mode, :received_on, :reference_no, :notes, :receipt_head)
    end
  end
end
