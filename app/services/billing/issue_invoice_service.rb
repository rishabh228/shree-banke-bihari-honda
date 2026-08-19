# frozen_string_literal: true

module Billing
  class IssueInvoiceService
    HEADER_KEYS = %i[
      inter_state reverse_charge place_of_supply place_of_supply_code
      hsn_code accessories_hsn vehicle_gst_rate accessories_gst_rate
      vehicle_inclusive vehicle_taxable vehicle_cgst vehicle_sgst vehicle_igst
      accessories_inclusive accessories_taxable accessories_cgst accessories_sgst accessories_igst
      insurance_collected rto_collected taxable_total tax_total grand_total
    ].freeze

    LINE_KEYS = %i[
      position line_type description hsn_code quantity uqc gst_rate
      taxable_value cgst_rate sgst_rate igst_rate
      cgst_amount sgst_amount igst_amount inclusive_amount collected
    ].freeze

    def initialize(sale)
      @sale = sale
    end

    def call
      return failure("GSTIN is not set in Settings") unless Setting.instance.billing_ready?
      return failure("Allot a chassis and engine number before issuing the tax invoice") unless @sale.chassis_allotted?
      return failure("A tax invoice is already issued for this sale") if @sale.invoiced?
      return failure("Cannot invoice a cancelled sale") if @sale.cancelled?

      invoice = nil
      Invoice.transaction do
        payload = Billing::TaxCalculator.new(@sale).result
        invoice = @sale.invoices.create!(
          payload.slice(*HEADER_KEYS).merge(
            invoice_number: Billing::NumberingService.new(:invoice).next_number!,
            invoice_date: Date.current,
            status: :issued,
            einvoice_status: @sale.buyer_gstin.present? ? :pending : :not_applicable
          )
        )
        payload[:lines].each do |line|
          invoice.line_items.create!(line.slice(*LINE_KEYS))
        end
      end

      { success: true, invoice: invoice, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def failure(message)
      { success: false, invoice: nil, error: message }
    end
  end
end
