# frozen_string_literal: true

module Billing
  class IssueWorkshopInvoiceService
    def initialize(service_booking, issued_by:)
      @booking = service_booking
      @issued_by = issued_by
    end

    def call
      job_card = @booking.job_card
      return failure("Open a job card and add parts / labour first") if job_card.blank? || job_card.lines.empty?
      return failure("A workshop invoice is already issued for this job card") if job_card.counter_invoice&.issued?
      return failure("Cannot invoice a cancelled booking") if @booking.cancelled?

      invoice = nil
      CounterInvoice.transaction do
        invoice = job_card.counter_invoice || job_card.create_counter_invoice!(
          kind: :workshop,
          status: :draft,
          customer_name: @booking.customer_name,
          phone: @booking.phone,
          email: @booking.email,
          notes: @booking.complaint
        )
        invoice.lines.destroy_all
        job_card.lines.each_with_index do |source, index|
          attrs = Billing::GstLine.from_inclusive(
            line_type: source.line_type,
            description: source.description,
            hsn_code: source.hsn_code,
            quantity: source.quantity,
            inclusive: source.line_total,
            rate: source.gst_rate,
            inter_state: invoice.inter_state?,
            position: index + 1,
            uqc: source.uqc.presence || (source.labour? ? "HRS" : "NOS")
          )
          invoice.lines.create!(attrs.merge(accessory_id: source.accessory_id))
        end
      end

      Billing::IssueCounterInvoiceService.new(invoice.reload, issued_by: @issued_by).call
    end

    private

    def failure(message)
      { success: false, invoice: nil, error: message }
    end
  end
end
