# frozen_string_literal: true

module Enquiries
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      enquiry = Enquiry.new(@params)
      if enquiry.save
        Notifications::StaffNotifier.new(:enquiry, enquiry).call
        {
          success: true,
          enquiry: enquiry,
          whatsapp_customer_url: Notifications::StaffNotifier.customer_whatsapp_url(:enquiry, enquiry)
        }
      else
        { success: false, enquiry: enquiry, errors: enquiry.errors.full_messages }
      end
    end
  end
end
