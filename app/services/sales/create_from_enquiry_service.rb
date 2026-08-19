# frozen_string_literal: true

module Sales
  class CreateFromEnquiryService
    def initialize(enquiry, sales_executive:)
      @enquiry = enquiry
      @sales_executive = sales_executive
    end

    def call
      return { success: false, errors: [ "Enquiry must be linked to a bike" ] } if @enquiry.bike.blank?

      sale = Sale.new(
        customer_name: @enquiry.name,
        phone: @enquiry.phone,
        email: @enquiry.email,
        bike: @enquiry.bike,
        bike_variant: @enquiry.bike&.bike_variants&.first,
        sales_executive: @sales_executive,
        enquiry: @enquiry,
        status: :quoted,
        quoted_on: Date.current,
        notes: @enquiry.message
      )

      if sale.save
        { success: true, sale: sale }
      else
        { success: false, sale: sale, errors: sale.errors.full_messages }
      end
    end
  end
end
