# frozen_string_literal: true

require "test_helper"

class TaxCalculatorTest < ActiveSupport::TestCase
  setup do
    setup_billing_context
    @sale = Sale.create!(
      customer_name: "Discount Buyer",
      phone: "9876543210",
      bike: @bike,
      sales_executive: @user,
      ex_showroom_price: 100_000,
      insurance: 2_000,
      rto: 3_000,
      discount_percent: 10,
      discount_amount: 1_000,
      chassis_number: "CHTEST001",
      engine_number: "ENTEST001"
    )
  end

  test "discount reduces ex-showroom before GST split and on-road total" do
    assert_equal 11_000.to_d, @sale.discount_value
    assert_equal 89_000.to_d, @sale.vehicle_inclusive_after_discount
    assert_equal 94_000.to_d, @sale.total_price
  end

  test "tax calculator uses discounted vehicle inclusive" do
    result = Billing::TaxCalculator.new(@sale).result

    assert_equal 89_000.to_d, result[:vehicle_inclusive]
    assert_equal 11_000.to_d, result[:discount_value]
    assert result[:grand_total] < 105_000
  end
end
