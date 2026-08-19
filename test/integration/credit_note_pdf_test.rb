# frozen_string_literal: true

require "test_helper"

class CreditNotePdfTest < ActionDispatch::IntegrationTest
  setup do
    setup_billing_context
  end

  test "admin can download a specific vehicle credit note pdf" do
    sale = invoiced_sale
    amount = (sale.tax_invoice.grand_total.to_d / 2).round(2)
    result = Billing::IssueCreditNoteService.new(sale, reason: "Partial return", amount: amount).call
    assert result[:success], result[:error]
    note = result[:credit_note]

    sign_in @user
    host! "localhost"
    get credit_note_pdf_admin_sale_path(sale, credit_note_id: note.id),
        headers: browser_headers

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_equal "%PDF", response.body[0, 4]
    assert_match(/#{Regexp.escape(note.credit_note_number.parameterize)}/, response.headers["Content-Disposition"].to_s)
  end

  test "admin can download a spare credit note pdf" do
    accessory = Accessory.create!(name: "Web Helmet #{SecureRandom.hex(3)}", price: 1_180, stock: 3, status: :active, gst_rate: 18, hsn_code: "871410")
    invoice = CounterInvoice.create!(customer_name: "Walk-in", phone: "9000005555", kind: :spare, status: :draft)
    add = Billing::AddCounterLineService.new(invoice, accessory_id: accessory.id, quantity: 1).call
    raise add[:error] unless add[:success]
    issue = Billing::IssueCounterInvoiceService.new(invoice, issued_by: @user).call
    raise issue[:error] unless issue[:success]
    invoice.reload

    result = Billing::CancelCounterInvoiceService.new(invoice, reason: "Customer return").call
    assert result[:success], result[:error]
    note = result[:credit_note]

    sign_in @user
    host! "localhost"
    get credit_note_pdf_admin_counter_invoice_path(invoice, credit_note_id: note.id),
        headers: browser_headers

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_equal "%PDF", response.body[0, 4]
    assert_match(/#{Regexp.escape(note.credit_note_number.parameterize)}/, response.headers["Content-Disposition"].to_s)
  end

  private

  def invoiced_sale
    sale = Sale.create!(
      customer_name: "Web Buyer",
      phone: "9876500888",
      bike: @bike,
      sales_executive: @user,
      ex_showroom_price: 80_000,
      chassis_number: "CHWEB#{SecureRandom.hex(3).upcase}",
      engine_number: "ENWEB#{SecureRandom.hex(3).upcase}"
    )
    result = Billing::IssueInvoiceService.new(sale).call
    raise result[:error] unless result[:success]
    sale.reload
  end

  def browser_headers
    { "HTTP_USER_AGENT" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" }
  end
end
