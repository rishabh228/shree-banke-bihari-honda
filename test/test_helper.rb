# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    def setup_billing_context
      Setting.instance.update!(
        showroom_name: "Shree Banke Bihari Honda",
        gstin: "09AAAAA0000A1Z5",
        pan: "AAAAA0000A",
        state: "Uttar Pradesh",
        state_code: "09",
        invoice_prefix: "SBH",
        vehicle_gst_rate: 28,
        accessories_gst_rate: 18,
        vehicle_hsn: "8711",
        accessories_hsn: "871410"
      )

      @user = User.create!(
        name: "Test Admin",
        email: "billing-test-#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: :super_admin
      )

      @bike = Bike.create!(
        name: "Test Activa #{SecureRandom.hex(3)}",
        category: "Scooter",
        status: :published,
        hsn_code: "8711",
        gst_rate: 28
      )
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
