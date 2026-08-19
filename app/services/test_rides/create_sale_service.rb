# frozen_string_literal: true

module TestRides
  class CreateSaleService
    def initialize(test_ride, sales_executive:)
      @test_ride = test_ride
      @sales_executive = sales_executive
    end

    def call
      return failure("Cannot convert a cancelled test ride") if @test_ride.cancelled?
      return failure("Test ride must be linked to a bike") if @test_ride.bike.blank?

      enquiry_result = TestRides::CreateEnquiryService.new(@test_ride).call
      return enquiry_result unless enquiry_result[:success]

      Sales::CreateFromEnquiryService.new(enquiry_result[:enquiry], sales_executive: @sales_executive).call
    end

    private

    def failure(message)
      { success: false, sale: nil, errors: Array(message) }
    end
  end
end
