# frozen_string_literal: true

module Admin
  class SalesController < BaseController
    before_action :set_sale, only: %i[
      show edit update destroy transition quotation_pdf
      issue_invoice invoice_pdf cancel_invoice credit_note_pdf
      allot_chassis delivery_challan_pdf form21_pdf form22_pdf gate_pass_pdf capture_irn
    ]
    before_action :load_form_data, only: %i[new edit create update]

    def index
      authorize Sale

      @q = policy_scope(Sale).ransack(ransack_query_for(Sale))
      @pagy, @sales = pagy(@q.result.includes(:bike, :bike_variant, :sales_executive, :tax_invoice).order(created_at: :desc))
    end

    def show
      authorize @sale
      load_billing_context
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
        redirect_to admin_sale_path(@sale), notice: "Sale status updated to #{@sale.display_status}.", status: :see_other
      else
        redirect_to admin_sale_path(@sale), alert: result[:error], status: :see_other
      end
    end

    def export_pdf
      authorize Sale, :export_pdf?

      records = export_pdf_scope(Sale, includes: [ :bike, :bike_variant, :sales_executive ])
      send_pdf_report(Reports::Pdf::SalesListReport, records, "sales-list")
    end

    def quotation_pdf
      authorize @sale, :quotation_pdf?

      send_billing_pdf(
        Reports::Pdf::QuotationReport.new(@sale).render,
        "quotation-#{@sale.customer_name.parameterize}-#{Date.current.iso8601}.pdf"
      )
    end

    def issue_invoice
      authorize @sale, :issue_invoice?

      result = Billing::IssueInvoiceService.new(@sale).call
      if result[:success]
        redirect_to admin_sale_path(@sale), notice: "Tax invoice #{result[:invoice].invoice_number} issued."
      else
        redirect_to admin_sale_path(@sale), alert: result[:error]
      end
    end

    def invoice_pdf
      authorize @sale, :invoice_pdf?
      invoice = @sale.invoices.order(created_at: :desc).first
      unless invoice
        redirect_to admin_sale_path(@sale), alert: "Issue a tax invoice first."
        return
      end

      copy_type = params[:copy].presence || "original"
      send_billing_pdf(
        Reports::Pdf::TaxInvoiceReport.new(invoice, copy_type: copy_type).render,
        "#{invoice.invoice_number.parameterize}-#{copy_type}.pdf"
      )
    end

    def cancel_invoice
      authorize @sale, :cancel_invoice?

      result = Billing::IssueCreditNoteService.new(
        @sale,
        reason: params[:reason],
        full: params[:full].present?,
        amount: params[:amount]
      ).call
      if result[:success]
        redirect_to admin_sale_path(@sale), notice: credit_note_notice(result[:credit_note])
      else
        redirect_to admin_sale_path(@sale), alert: result[:error]
      end
    end

    def credit_note_pdf
      authorize @sale, :credit_note_pdf?
      credit_note = @sale.credit_notes.find_by(id: params[:credit_note_id]) || @sale.credit_notes.order(created_at: :desc).first
      unless credit_note
        redirect_to admin_sale_path(@sale), alert: "No credit note on this sale."
        return
      end

      send_billing_pdf(
        Reports::Pdf::CreditNoteReport.new(credit_note).render,
        "#{credit_note.credit_note_number.parameterize}.pdf"
      )
    end

    def allot_chassis
      authorize @sale, :allot_chassis?

      unit = VehicleUnit.in_stock.find_by(id: params[:vehicle_unit_id])
      result = VehicleUnits::AllotService.new(@sale, unit).call

      if result[:success]
        redirect_to admin_sale_path(@sale), notice: "Chassis #{@sale.chassis_number} allotted.", status: :see_other
      else
        redirect_to admin_sale_path(@sale), alert: result[:error], status: :see_other
      end
    end

    def delivery_challan_pdf
      authorize @sale, :delivery_challan_pdf?

      result = Billing::IssueDeliveryChallanService.new(@sale, transporter_vehicle_no: params[:transporter_vehicle_no]).call
      unless result[:success]
        redirect_to admin_sale_path(@sale), alert: result[:error]
        return
      end

      copy_type = params[:copy].presence || "original"
      send_billing_pdf(
        Reports::Pdf::DeliveryChallanReport.new(result[:challan], copy_type: copy_type).render,
        "#{result[:challan].challan_number.parameterize}-#{copy_type}.pdf"
      )
    end

    def form21_pdf
      authorize @sale, :form21_pdf?
      unless @sale.chassis_allotted?
        redirect_to admin_sale_path(@sale), alert: "Allot chassis and engine number before generating Form 21."
        return
      end

      send_billing_pdf(
        Reports::Pdf::Form21Report.new(@sale).render,
        "form-21-#{@sale.customer_name.parameterize}-#{Date.current.iso8601}.pdf"
      )
    end

    def form22_pdf
      authorize @sale, :form22_pdf?
      unless @sale.chassis_allotted?
        redirect_to admin_sale_path(@sale), alert: "Allot chassis and engine number before generating Form 22."
        return
      end

      send_billing_pdf(
        Reports::Pdf::Form22Report.new(@sale).render,
        "form-22-#{@sale.customer_name.parameterize}-#{Date.current.iso8601}.pdf"
      )
    end

    def gate_pass_pdf
      authorize @sale, :gate_pass_pdf?

      result = Billing::IssueGatePassService.new(
        @sale,
        driven_by: params[:driven_by],
        id_proof: params[:id_proof],
        notes: params[:notes]
      ).call
      unless result[:success]
        redirect_to admin_sale_path(@sale), alert: result[:error]
        return
      end

      send_billing_pdf(
        Reports::Pdf::GatePassReport.new(result[:gate_pass]).render,
        "#{result[:gate_pass].gate_pass_number.parameterize}.pdf"
      )
    end

    def capture_irn
      authorize @sale, :capture_irn?
      invoice = @sale.tax_invoice
      unless invoice
        redirect_to admin_sale_path(@sale), alert: "Issue a tax invoice before recording an IRN."
        return
      end

      result = Billing::CaptureIrnService.new(
        invoice,
        irn: params[:irn],
        ack_no: params[:ack_no],
        ack_date: params[:ack_date]
      ).call
      if result[:success]
        redirect_to admin_sale_path(@sale), notice: "e-Invoice IRN recorded on #{invoice.invoice_number}."
      else
        redirect_to admin_sale_path(@sale), alert: result[:error]
      end
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

    def load_billing_context
      @sale = Sale.includes(:tax_invoice, :invoices, :delivery_challan, :gate_pass, :vehicle_unit, :sale_add_ons, :credit_notes, payment_receipts: :received_by).find(@sale.id)
      @tax_breakdown = Billing::TaxCalculator.new(@sale).result
      @available_units = available_units_for_sale
      @payment_receipt = PaymentReceipt.new(received_on: Date.current, payment_mode: @sale.payment_mode, receipt_head: :vehicle)
      @sale_add_on = SaleAddOn.new(quantity: 1)
      @accessories = Accessory.available.order(:name)
    end

    def available_units_for_sale
      scope = VehicleUnit.in_stock.includes(bike_variant: :bike)
      scope = scope.where(bike_variant_id: @sale.bike_variant_id) if @sale.bike_variant_id.present?
      scope.order(:chassis_number)
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

    def send_billing_pdf(pdf, filename)
      send_data pdf, filename: filename, type: "application/pdf", disposition: "attachment"
    end

    def credit_note_notice(note)
      if note.full?
        "Credit note #{note.credit_note_number} issued. Invoice cancelled."
      else
        "Partial credit note #{note.credit_note_number} issued."
      end
    end

    def sale_params
      params.require(:sale).permit(
        :customer_name, :phone, :email, :address,
        :bike_id, :bike_variant_id, :sales_executive_id, :enquiry_id,
        :ex_showroom_price, :insurance, :rto, :other_charges, :total_price,
        :booking_amount, :payment_mode, :finance_partner, :status,
        :quoted_on, :booked_on, :delivery_date,
        :chassis_number, :engine_number, :notes,
        :buyer_gstin, :buyer_state, :buyer_state_code, :buyer_pan, :loan_amount, :down_payment,
        :handling_charge, :accessories_charge, :discount_percent, :discount_amount
      )
    end
  end
end
