# frozen_string_literal: true

require "test_helper"

class CancelCounterInvoiceServiceTest < ActiveSupport::TestCase
  setup do
    setup_billing_context
    @accessory = Accessory.create!(name: "Test Helmet #{SecureRandom.hex(3)}", price: 1_180, stock: 5, status: :active, gst_rate: 18, hsn_code: "871410")
    @invoice = CounterInvoice.create!(customer_name: "Walk-in", phone: "9000001111", kind: :spare, status: :draft)
    result = Billing::AddCounterLineService.new(@invoice, accessory_id: @accessory.id, quantity: 1).call
    raise result[:error] unless result[:success]

    issue = Billing::IssueCounterInvoiceService.new(@invoice, issued_by: @user).call
    raise issue[:error] unless issue[:success]
    @invoice.reload
    @accessory.reload
  end

  test "issues a credit note, cancels the bill, and restores stock" do
    assert @invoice.issued?
    assert_equal 4, @accessory.stock

    result = Billing::CancelCounterInvoiceService.new(@invoice, reason: "Customer return").call
    assert result[:success], result[:error]

    @invoice.reload
    @accessory.reload
    assert @invoice.cancelled?
    assert @invoice.credit_notes.any?
    assert_equal 5, @accessory.stock
    assert_equal @invoice.grand_total, @invoice.credit_notes.first.grand_total
  end
end
