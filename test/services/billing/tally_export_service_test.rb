# frozen_string_literal: true

require "test_helper"

class TallyExportServiceTest < ActiveSupport::TestCase
  setup do
    setup_billing_context
  end

  test "xml envelope is valid Tally import data" do
    xml = Billing::TallyExportService.new(from: Date.current.beginning_of_month, to: Date.current).to_xml

    assert_includes xml, "<ENVELOPE>"
    assert_includes xml, "<TALLYREQUEST>Import Data</TALLYREQUEST>"
    assert_includes xml, "<REPORTNAME>Vouchers</REPORTNAME>"
    assert_includes xml, "<SVCURRENTCOMPANY>"
  end

  test "sales invoice appears as a Tally Sales voucher" do
    sale = Sale.create!(
      customer_name: "Tally Buyer",
      phone: "9876500123",
      bike: @bike,
      sales_executive: @user,
      ex_showroom_price: 80_000,
      chassis_number: "CHTALLY01",
      engine_number: "ENTALLY01"
    )
    result = Billing::IssueInvoiceService.new(sale).call
    assert result[:success], result[:error]

    xml = Billing::TallyExportService.new(from: Date.current, to: Date.current).to_xml
    invoice = result[:invoice]

    assert_includes xml, "<VOUCHERTYPENAME>Sales</VOUCHERTYPENAME>"
    assert_includes xml, "<VOUCHERNUMBER>#{invoice.invoice_number}</VOUCHERNUMBER>"
    assert_includes xml, "Tally Buyer"
    assert_includes xml, "<LEDGERNAME>Sales</LEDGERNAME>"
  end
end
