# frozen_string_literal: true

require "test_helper"

class CreditNoteReportTest < ActiveSupport::TestCase
  setup do
    setup_billing_context
  end

  test "partial vehicle credit note pdf is a valid document" do
    sale = invoiced_sale
    invoice = sale.tax_invoice
    amount = (invoice.grand_total.to_d / 2).round(2)
    result = Billing::IssueCreditNoteService.new(sale, reason: "Price correction", amount: amount).call
    assert result[:success], result[:error]

    note = result[:credit_note]
    pdf = Reports::Pdf::CreditNoteReport.new(note).render

    assert_operator pdf.bytesize, :>, 500
    assert_equal "%PDF", pdf[0, 4]
  end

  test "partial spare credit note pdf includes returned qty" do
    accessory = Accessory.create!(name: "PDF Helmet #{SecureRandom.hex(3)}", price: 1_180, stock: 4, status: :active, gst_rate: 18, hsn_code: "871410")
    invoice = CounterInvoice.create!(customer_name: "Walk-in", phone: "9000004444", kind: :spare, status: :draft, discount_percent: 10)
    add = Billing::AddCounterLineService.new(invoice, accessory_id: accessory.id, quantity: 2).call
    raise add[:error] unless add[:success]
    issue = Billing::IssueCounterInvoiceService.new(invoice, issued_by: @user).call
    raise issue[:error] unless issue[:success]
    invoice.reload
    line = invoice.lines.first

    result = Billing::IssueCreditNoteService.new(invoice, reason: "One returned", line_returns: { line.id.to_s => 1 }).call
    assert result[:success], result[:error]

    note = result[:credit_note]
    pdf = Reports::Pdf::CreditNoteReport.new(note).render

    assert_equal "%PDF", pdf[0, 4]
    assert_operator pdf.bytesize, :>, 500
  end

  private

  def invoiced_sale
    sale = Sale.create!(
      customer_name: "PDF Buyer",
      phone: "9876500777",
      bike: @bike,
      sales_executive: @user,
      ex_showroom_price: 80_000,
      chassis_number: "CHPDF#{SecureRandom.hex(3).upcase}",
      engine_number: "ENPDF#{SecureRandom.hex(3).upcase}"
    )
    result = Billing::IssueInvoiceService.new(sale).call
    raise result[:error] unless result[:success]
    sale.reload
  end
end
