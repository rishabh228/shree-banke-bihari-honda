# frozen_string_literal: true

module Notifications
  class WhatsappMessageBuilder
    def self.staff_message(event_type, record)
      new(event_type, record).staff_message
    end

    def self.customer_message(event_type, record)
      new(event_type, record).customer_message
    end

    def initialize(event_type, record)
      @event_type = event_type.to_sym
      @record = record
      @showroom = Setting.instance
    end

    def staff_message
      case @event_type
      when :enquiry then enquiry_staff_message
      when :test_ride then test_ride_staff_message
      when :service_booking then service_booking_staff_message
      when :sale then sale_staff_message
      when :sale_status then sale_status_staff_message
      else "New activity at #{@showroom.showroom_name}"
      end
    end

    def customer_message
      case @event_type
      when :enquiry then enquiry_customer_message
      when :test_ride then test_ride_customer_message
      when :service_booking then service_booking_customer_message
      else "Hi #{@showroom.showroom_name}, I would like to get in touch regarding Honda bikes."
      end
    end

    private

    def enquiry_staff_message
      bike = @record.bike&.name || "General"
      <<~MSG.squish
        *New Enquiry* — #{@showroom.showroom_name}
        Name: #{@record.name}
        Phone: #{@record.phone}
        Email: #{@record.email.presence || "—"}
        Bike: #{bike}
        Source: #{@record.source_label}
        Message: #{@record.message.presence || "—"}
      MSG
    end

    def enquiry_customer_message
      bike = @record.bike&.name
      base = "Hi #{@showroom.showroom_name}, I submitted an enquiry"
      bike.present? ? "#{base} for #{bike}." : "#{base}."
    end

    def test_ride_staff_message
      <<~MSG.squish
        *New Test Ride Request* — #{@showroom.showroom_name}
        Name: #{@record.name}
        Phone: #{@record.phone}
        Bike: #{@record.bike.name}
        Date: #{@record.preferred_date.strftime("%d %b %Y")}
        Time: #{@record.preferred_time.presence || "Flexible"}
        Remarks: #{@record.remarks.presence || "—"}
      MSG
    end

    def test_ride_customer_message
      "Hi #{@showroom.showroom_name}, I booked a test ride for #{@record.bike.name} on #{@record.preferred_date.strftime("%d %b %Y")}."
    end

    def service_booking_staff_message
      <<~MSG.squish
        *New Service Booking* — #{@showroom.showroom_name}
        Customer: #{@record.customer_name}
        Phone: #{@record.phone}
        Vehicle: #{@record.vehicle_number} (#{@record.bike_model})
        Service: #{@record.service_type.titleize}
        Date: #{@record.preferred_date.strftime("%d %b %Y")}
        Complaint: #{@record.complaint.presence || "—"}
      MSG
    end

    def service_booking_customer_message
      "Hi #{@showroom.showroom_name}, I booked a #{@record.service_type} service for my #{@record.bike_model} (#{@record.vehicle_number}) on #{@record.preferred_date.strftime("%d %b %Y")}."
    end

    def sale_staff_message
      variant = @record.bike_variant&.name
      bike_label = [ @record.bike.name, variant ].compact.join(" — ")
      <<~MSG.squish
        *New Sale* — #{@showroom.showroom_name}
        Customer: #{@record.customer_name}
        Phone: #{@record.phone}
        Bike: #{bike_label}
        Status: #{@record.display_status}
        Total: ₹#{@record.total_price.to_i}
      MSG
    end

    def sale_status_staff_message
      variant = @record.bike_variant&.name
      bike_label = [ @record.bike.name, variant ].compact.join(" — ")
      <<~MSG.squish
        *Sale Updated* — #{@showroom.showroom_name}
        Customer: #{@record.customer_name}
        Phone: #{@record.phone}
        Bike: #{bike_label}
        New Status: #{@record.display_status}
      MSG
    end
  end
end
