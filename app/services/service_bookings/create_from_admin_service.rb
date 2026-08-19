# frozen_string_literal: true

module ServiceBookings
  class CreateFromAdminService
    def initialize(attributes, created_by:)
      @attributes = attributes.to_h.symbolize_keys
      @created_by = created_by
    end

    def call
      advisor = User.find_by(id: @attributes[:assigned_to_id]) if @attributes[:assigned_to_id].present?
      booking_attrs = @attributes.except(:status, :assigned_to_id)
      booking_attrs[:preferred_date] = Date.current if booking_attrs[:preferred_date].blank?
      booking_attrs[:complaint] = prefixed_complaint(booking_attrs[:complaint])

      result = ServiceBookings::CreateService.new(booking_attrs).call
      return result unless result[:success]

      booking = result[:service_booking]
      if advisor.present?
        assign = ServiceBookings::AssignService.new(booking, advisor).call
        return { success: false, service_booking: booking, errors: [ assign[:error] ] } unless assign[:success]
      end

      { success: true, service_booking: booking.reload, errors: [] }
    end

    private

    def prefixed_complaint(complaint)
      source = "Walk-in / phone (entered by #{@created_by&.name.presence || "staff"})"
      [ source, complaint.presence ].compact.join("\n")
    end
  end
end
