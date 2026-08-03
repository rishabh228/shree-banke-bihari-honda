# frozen_string_literal: true

module Enquiries
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      enquiry = Enquiry.new(@params)
      if enquiry.save
        notify_staff(enquiry)
        { success: true, enquiry: enquiry }
      else
        { success: false, enquiry: enquiry, errors: enquiry.errors.full_messages }
      end
    end

    private

    def notify_staff(enquiry)
      User.where(role: [ :super_admin, :manager, :sales_executive ]).find_each do |user|
        Notification.create!(
          user: user,
          title: "New Enquiry from #{enquiry.name}",
          body: enquiry.message,
          notifiable: enquiry
        )
      end
    end
  end
end
