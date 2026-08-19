# frozen_string_literal: true

module Bikes
  class PublishService
    def initialize(bike)
      @bike = bike
    end

    def call
      @bike.publish!
      Result.success(@bike)
    rescue ActiveRecord::RecordInvalid => e
      Result.failure(e.record.errors.full_messages)
    end

    Result = Struct.new(:success, :data, :errors, keyword_init: true) do
      def self.success(data) = new(success: true, data: data, errors: [])
      def self.failure(errors) = new(success: false, data: nil, errors: Array(errors))
      def success? = success
    end
  end
end
