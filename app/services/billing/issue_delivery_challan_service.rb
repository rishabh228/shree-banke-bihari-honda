# frozen_string_literal: true

module Billing
  class IssueDeliveryChallanService
    def initialize(sale, attributes = {})
      @sale = sale
      @attributes = attributes
    end

    def call
      return { success: true, challan: @sale.delivery_challan, error: nil } if @sale.delivery_challan.present?
      return failure("Allot chassis and engine number before generating a delivery challan") unless @sale.chassis_allotted?
      return failure("Cannot generate a delivery challan for a cancelled sale") if @sale.cancelled?

      challan = @sale.create_delivery_challan!(
        challan_number: Billing::NumberingService.new(:challan).next_number!,
        challan_date: Date.current,
        transporter_vehicle_no: @attributes[:transporter_vehicle_no],
        notes: @attributes[:notes]
      )

      { success: true, challan: challan, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def failure(message)
      { success: false, challan: nil, error: message }
    end
  end
end
