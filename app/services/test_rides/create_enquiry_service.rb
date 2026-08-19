# frozen_string_literal: true

module TestRides
  class CreateEnquiryService
    def initialize(test_ride)
      @test_ride = test_ride
    end

    def call
      return failure("Cannot convert a cancelled test ride") if @test_ride.cancelled?

      enquiry = Enquiry.new(
        source: :test_ride,
        name: @test_ride.name,
        phone: @test_ride.phone,
        email: @test_ride.email,
        bike: @test_ride.bike,
        status: :new_enquiry,
        message: enquiry_message
      )

      if enquiry.save
        { success: true, enquiry: enquiry, errors: [] }
      else
        failure(enquiry.errors.full_messages.join(", "), enquiry: enquiry)
      end
    end

    private

    def enquiry_message
      parts = [ "Converted from test ride ##{@test_ride.id} (#{@test_ride.bike.name})." ]
      parts << "Preferred slot: #{@test_ride.preferred_date.strftime('%d %b %Y')} #{@test_ride.preferred_time}".strip
      parts << "Remarks: #{@test_ride.remarks}" if @test_ride.remarks.present?
      parts.join("\n")
    end

    def failure(message, enquiry: nil)
      { success: false, enquiry: enquiry, errors: Array(message) }
    end
  end
end
