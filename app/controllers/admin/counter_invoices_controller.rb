# frozen_string_literal: true

module Admin
  class CounterInvoicesController < BaseController
    before_action :set_counter_invoice, only: %i[show edit update destroy issue invoice_pdf capture_irn cancel_invoice credit_note_pdf]

    def index
      authorize CounterInvoice

      @q = policy_scope(CounterInvoice).ransack(params[:q])
      @pagy, @counter_invoices = pagy(@q.result.recent)
    end

    def show
      authorize @counter_invoice
      @line = CounterInvoiceLine.new(quantity: 1, line_type: "part")
      @accessories = Accessory.active.order(:name)
    end

    def new
      @counter_invoice = CounterInvoice.new(kind: :spare, buyer_state: Setting.instance.state, buyer_state_code: Setting.instance.state_code)
      authorize @counter_invoice
    end

    def create
      @counter_invoice = CounterInvoice.new(counter_invoice_params.merge(kind: :spare, status: :draft))
      authorize @counter_invoice

      if @counter_invoice.save
        redirect_to admin_counter_invoice_path(@counter_invoice), notice: "Spare bill opened. Add parts, then issue the tax invoice."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @counter_invoice
      unless @counter_invoice.draft?
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: "Only draft bills can be edited."
      end
    end

    def update
      authorize @counter_invoice
      unless @counter_invoice.draft?
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: "Only draft bills can be edited."
        return
      end

      if @counter_invoice.update(counter_invoice_params)
        redirect_to admin_counter_invoice_path(@counter_invoice), notice: "Spare bill updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @counter_invoice
      unless @counter_invoice.draft?
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: "Only draft bills can be deleted."
        return
      end

      @counter_invoice.destroy!
      redirect_to admin_counter_invoices_path, notice: "Draft spare bill deleted."
    end

    def issue
      authorize @counter_invoice, :issue?

      result = Billing::IssueCounterInvoiceService.new(@counter_invoice, issued_by: current_user).call
      if result[:success]
        redirect_to admin_counter_invoice_path(@counter_invoice), notice: "Tax invoice #{result[:invoice].invoice_number} issued."
      else
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: result[:error]
      end
    end

    def invoice_pdf
      authorize @counter_invoice, :invoice_pdf?
      unless @counter_invoice.issued? || @counter_invoice.cancelled?
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: "Issue the tax invoice first."
        return
      end

      copy_type = params[:copy].presence || "original"
      send_data Reports::Pdf::CounterInvoiceReport.new(@counter_invoice, copy_type: copy_type).render,
                filename: "#{@counter_invoice.invoice_number.parameterize}-#{copy_type}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    def capture_irn
      authorize @counter_invoice, :capture_irn?

      result = Billing::CaptureIrnService.new(
        @counter_invoice,
        irn: params[:irn],
        ack_no: params[:ack_no],
        ack_date: params[:ack_date]
      ).call
      if result[:success]
        redirect_to admin_counter_invoice_path(@counter_invoice), notice: "e-Invoice IRN recorded."
      else
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: result[:error]
      end
    end

    def cancel_invoice
      authorize @counter_invoice, :cancel_invoice?

      result = Billing::IssueCreditNoteService.new(
        @counter_invoice,
        reason: params[:reason],
        full: params[:full].present?,
        line_returns: params[:line_returns] || {}
      ).call
      if result[:success]
        notice = if result[:credit_note].full?
                   "Credit note #{result[:credit_note].credit_note_number} issued. Invoice cancelled."
        else
                   "Partial credit note #{result[:credit_note].credit_note_number} issued."
        end
        redirect_to admin_counter_invoice_path(@counter_invoice), notice: notice
      else
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: result[:error]
      end
    end

    def credit_note_pdf
      authorize @counter_invoice, :credit_note_pdf?
      credit_note = @counter_invoice.credit_notes.find_by(id: params[:credit_note_id]) || @counter_invoice.credit_notes.order(created_at: :desc).first
      unless credit_note
        redirect_to admin_counter_invoice_path(@counter_invoice), alert: "No credit note on this bill."
        return
      end

      send_data Reports::Pdf::CreditNoteReport.new(credit_note).render,
                filename: "#{credit_note.credit_note_number.parameterize}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    end

    private

    def set_counter_invoice
      @counter_invoice = CounterInvoice.includes(:credit_notes, lines: :accessory).find(params[:id])
    end

    def counter_invoice_params
      params.require(:counter_invoice).permit(
        :customer_name, :phone, :email, :address,
        :buyer_gstin, :buyer_pan, :buyer_state, :buyer_state_code, :notes,
        :discount_percent, :discount_amount
      )
    end
  end
end
