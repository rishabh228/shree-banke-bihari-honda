# frozen_string_literal: true

module Reports
  class DealerRegisterService
    def initialize(from:, to:)
      @from = from
      @to = to
    end

    def vehicle_invoices
      Invoice.issued.includes(:sale).where(invoice_date: @from..@to).order(:invoice_date, :id)
    end

    def counter_invoices
      CounterInvoice.issued.includes(:lines).where(invoice_date: @from..@to).order(:invoice_date, :id)
    end

    def credit_notes
      CreditNote.includes(:invoice, :sale, :counter_invoice).where(credit_note_date: @from..@to).order(:credit_note_date, :id)
    end

    def receipts
      PaymentReceipt.includes(:sale).where(received_on: @from..@to).order(:received_on, :id)
    end

    def outstanding_sales
      Sale.includes(:payment_receipts, :tax_invoice, :bike, :credit_notes)
          .where.not(status: :cancelled)
          .order(created_at: :desc)
          .select { |sale| sale.outstanding_amount.positive? }
    end

    def gst_taxable
      vehicle_invoices.sum { |invoice| invoice.taxable_total.to_d } +
        counter_invoices.sum { |invoice| invoice.taxable_total.to_d } -
        credit_notes.sum { |note| note.taxable_total.to_d }
    end

    def gst_tax
      vehicle_invoices.sum { |invoice| invoice.tax_total.to_d } +
        counter_invoices.sum { |invoice| invoice.tax_total.to_d } -
        credit_notes.sum { |note| note.tax_total.to_d }
    end

    def gst_invoice_value
      vehicle_invoices.sum { |invoice| invoice.grand_total.to_d } +
        counter_invoices.sum { |invoice| invoice.grand_total.to_d } -
        credit_notes.sum { |note| note.grand_total.to_d }
    end
  end
end
