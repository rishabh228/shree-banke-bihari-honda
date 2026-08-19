# frozen_string_literal: true

module TestRides
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      test_ride = TestRide.new(@params)
      if test_ride.save
        Notifications::StaffNotifier.new(:test_ride, test_ride).call
        {
          success: true,
          test_ride: test_ride,
          whatsapp_customer_url: Notifications::StaffNotifier.customer_whatsapp_url(:test_ride, test_ride)
        }
      else
        { success: false, test_ride: test_ride, errors: test_ride.errors.full_messages }
      end
    end
  end
end
