# frozen_string_literal: true

module Notifications
  class StaffNotifier
    ROLE_MAP = {
      enquiry: %i[super_admin manager sales_executive],
      test_ride: %i[super_admin manager sales_executive],
      service_booking: %i[super_admin manager service_advisor],
      sale: %i[super_admin manager sales_executive],
      sale_status: %i[super_admin manager sales_executive]
    }.freeze

    TITLE_MAP = {
      enquiry: ->(record) { "New enquiry from #{record.name}" },
      test_ride: ->(record) { "Test ride request — #{record.name}" },
      service_booking: ->(record) { "Service booking — #{record.customer_name}" },
      sale: ->(record) { "New sale — #{record.customer_name}" },
      sale_status: ->(record) { "Sale #{record.display_status} — #{record.customer_name}" }
    }.freeze

    def initialize(event_type, record)
      @event_type = event_type.to_sym
      @record = record
    end

    def call
      return nil unless enabled?

      message = Notifications::WhatsappMessageBuilder.staff_message(@event_type, @record)
      whatsapp_url = Whatsapp::Link.build(Setting.instance.whatsapp, message)

      users_for_event.find_each do |user|
        Notification.create!(
          user: user,
          title: TITLE_MAP.fetch(@event_type).call(@record),
          body: message,
          whatsapp_url: whatsapp_url,
          notifiable: @record
        )
      end

      whatsapp_url
    end

    def self.customer_whatsapp_url(event_type, record)
      return nil if Setting.instance.whatsapp.blank?

      message = Notifications::WhatsappMessageBuilder.customer_message(event_type, record)
      Whatsapp::Link.build(Setting.instance.whatsapp, message)
    end

    private

    def enabled?
      Setting.instance.whatsapp_notifications_enabled? && Setting.instance.whatsapp.present?
    end

    def users_for_event
      roles = ROLE_MAP.fetch(@event_type)
      User.where(role: roles)
    end
  end
end
