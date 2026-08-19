# frozen_string_literal: true

require "test_helper"

class IssueCreditNoteServiceTest < ActiveSupport::TestCase
  setup do
    setup_billing_context
  end

  test "vehicle partial credit keeps the invoice open and stores GST" do
    sale = invoiced_sale
    invoice = sale.tax_invoice
    amount = (invoice.grand_total.to_d / 2).round(2)

    result = Billing::IssueCreditNoteService.new(sale, reason: "Price correction", amount: amount).call
    assert result[:success], result[:error]

    note = result[:credit_note]
    invoice.reload
    assert invoice.issued?
    assert note.partial?
    assert_equal amount, note.grand_total
    assert note.taxable_total.to_d.positive?
    assert note.tax_total.to_d.positive?
    assert_equal invoice.grand_total.to_d - amount, invoice.remaining_value
  end

  test "vehicle remaining full credit cancels the invoice" do
    sale = invoiced_sale
    invoice = sale.tax_invoice
    half = (invoice.grand_total.to_d / 2).round(2)

    first = Billing::IssueCreditNoteService.new(sale, reason: "Partial return", amount: half).call
    assert first[:success], first[:error]

    second = Billing::IssueCreditNoteService.new(sale, reason: "Balance return", full: true).call
    assert second[:success], second[:error]

    invoice.reload
    assert invoice.cancelled?
    assert second[:credit_note].full?
    assert_in_delta invoice.grand_total.to_d, invoice.credit_notes.sum(:grand_total).to_d, 0.01
  end

  test "counter partial return restores only returned stock" do
    accessory = Accessory.create!(name: "Test Helmet #{SecureRandom.hex(3)}", price: 1_180, stock: 5, status: :active, gst_rate: 18, hsn_code: "871410")
    invoice = CounterInvoice.create!(customer_name: "Walk-in", phone: "9000001111", kind: :spare, status: :draft)
    add = Billing::AddCounterLineService.new(invoice, accessory_id: accessory.id, quantity: 2).call
    raise add[:error] unless add[:success]
    issue = Billing::IssueCounterInvoiceService.new(invoice, issued_by: @user).call
    raise issue[:error] unless issue[:success]
    invoice.reload
    accessory.reload
    line = invoice.lines.first

    result = Billing::IssueCreditNoteService.new(
      invoice,
      reason: "One helmet returned",
      line_returns: { line.id.to_s => 1 }
    ).call
    assert result[:success], result[:error]

    invoice.reload
    accessory.reload
    note = result[:credit_note]
    assert invoice.issued?
    assert note.partial?
    assert_equal 4, accessory.stock
    assert_equal 1, note.lines.sum(:quantity)
    assert_equal 1, line.remaining_quantity
  end

  test "counter remaining full credit cancels and restores leftover stock" do
    accessory = Accessory.create!(name: "Test Mirror #{SecureRandom.hex(3)}", price: 590, stock: 3, status: :active, gst_rate: 18, hsn_code: "871410")
    invoice = CounterInvoice.create!(customer_name: "Walk-in", phone: "9000002222", kind: :spare, status: :draft)
    add = Billing::AddCounterLineService.new(invoice, accessory_id: accessory.id, quantity: 2).call
    raise add[:error] unless add[:success]
    issue = Billing::IssueCounterInvoiceService.new(invoice, issued_by: @user).call
    raise issue[:error] unless issue[:success]
    invoice.reload
    line = invoice.lines.first

    Billing::IssueCreditNoteService.new(invoice, reason: "One back", line_returns: { line.id.to_s => 1 }).call
    result = Billing::IssueCreditNoteService.new(invoice, reason: "Rest back", full: true).call
    assert result[:success], result[:error]

    invoice.reload
    accessory.reload
    assert invoice.cancelled?
    assert result[:credit_note].full?
    assert_equal 3, accessory.stock
  end

  test "partial spare credit uses post-discount line value" do
    invoice, line = discounted_spare_bill(quantity: 2, unit_price: 1_180, discount_percent: 10)

    result = Billing::IssueCreditNoteService.new(
      invoice,
      reason: "One helmet returned",
      line_returns: { line.id.to_s => 1 }
    ).call
    assert result[:success], result[:error]

    note = result[:credit_note]
    expected = (invoice.grand_total.to_d / 2).round(2)
    assert_in_delta expected, note.grand_total.to_d, 0.01
    assert note.grand_total.to_d < 1_180
    assert_in_delta expected, note.taxable_total.to_d + note.tax_total.to_d, 0.01
  end

  test "sequential spare credits on a discounted bill sum to the invoice" do
    invoice, line = discounted_spare_bill(quantity: 2, unit_price: 1_180, discount_percent: 10)

    first = Billing::IssueCreditNoteService.new(invoice, reason: "First", line_returns: { line.id.to_s => 1 }).call
    second = Billing::IssueCreditNoteService.new(invoice, reason: "Second", line_returns: { line.id.to_s => 1 }).call
    assert first[:success], first[:error]
    assert second[:success], second[:error]

    invoice.reload
    assert invoice.cancelled?
    assert_equal invoice.grand_total.to_d, invoice.credit_notes.sum(:grand_total).to_d
    assert_equal invoice.taxable_total.to_d, invoice.credit_notes.sum(:taxable_total).to_d
    assert_equal invoice.tax_total.to_d, invoice.credit_notes.sum(:tax_total).to_d
  end

  private

  def invoiced_sale
    sale = Sale.create!(
      customer_name: "CN Buyer",
      phone: "9876500456",
      bike: @bike,
      sales_executive: @user,
      ex_showroom_price: 80_000,
      chassis_number: "CHCN#{SecureRandom.hex(3).upcase}",
      engine_number: "ENCN#{SecureRandom.hex(3).upcase}"
    )
    result = Billing::IssueInvoiceService.new(sale).call
    raise result[:error] unless result[:success]
    sale.reload
  end

  def discounted_spare_bill(quantity:, unit_price:, discount_percent:)
    accessory = Accessory.create!(
      name: "Discounted Part #{SecureRandom.hex(3)}",
      price: unit_price,
      stock: quantity + 2,
      status: :active,
      gst_rate: 18,
      hsn_code: "871410"
    )
    invoice = CounterInvoice.create!(
      customer_name: "Walk-in",
      phone: "9000003333",
      kind: :spare,
      status: :draft,
      discount_percent: discount_percent
    )
    add = Billing::AddCounterLineService.new(invoice, accessory_id: accessory.id, quantity: quantity).call
    raise add[:error] unless add[:success]
    issue = Billing::IssueCounterInvoiceService.new(invoice, issued_by: @user).call
    raise issue[:error] unless issue[:success]
    invoice.reload
    [ invoice, invoice.lines.first ]
  end
end
