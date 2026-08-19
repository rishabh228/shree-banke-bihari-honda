# frozen_string_literal: true

module Admin
  class CounterInvoiceLinesController < BaseController
    before_action :set_invoice

    def create
      authorize @invoice, :update?

      result = Billing::AddCounterLineService.new(@invoice, line_params).call
      if result[:success]
        redirect_to admin_counter_invoice_path(@invoice), notice: "Line added."
      else
        redirect_to admin_counter_invoice_path(@invoice), alert: result[:error]
      end
    end

    def destroy
      authorize @invoice, :update?
      return redirect_to admin_counter_invoice_path(@invoice), alert: "Issued invoices cannot be edited." unless @invoice.draft?

      line = @invoice.lines.find(params[:id])
      line.destroy!
      @invoice.update!(
        taxable_total: @invoice.lines.sum(:taxable_value),
        tax_total: @invoice.lines.sum(:cgst_amount) + @invoice.lines.sum(:sgst_amount) + @invoice.lines.sum(:igst_amount),
        grand_total: @invoice.lines.sum(:inclusive_amount)
      )
      redirect_to admin_counter_invoice_path(@invoice), notice: "Line removed."
    end

    private

    def set_invoice
      @invoice = CounterInvoice.find(params[:counter_invoice_id])
    end

    def line_params
      params.require(:counter_invoice_line).permit(
        :accessory_id, :description, :quantity, :unit_price, :inclusive_amount,
        :hsn_code, :gst_rate, :line_type, :uqc
      )
    end
  end
end
