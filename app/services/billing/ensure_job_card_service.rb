# frozen_string_literal: true

module Billing
  class EnsureJobCardService
    def initialize(service_booking)
      @service_booking = service_booking
    end

    def call
      return failure("Cannot open a job card on a cancelled booking") if @service_booking.cancelled?

      job_card = @service_booking.job_card
      if job_card.blank?
        job_card = @service_booking.create_job_card!(
          job_card_number: Billing::NumberingService.new(:job_card).next_number!,
          job_card_date: Date.current,
          status: :open
        )
      end

      { success: true, job_card: job_card, error: nil }
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages.join(", "))
    end

    private

    def failure(message)
      { success: false, job_card: nil, error: message }
    end
  end
end
