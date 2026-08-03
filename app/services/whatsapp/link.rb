# frozen_string_literal: true

module Whatsapp
  module Link
    module_function

    def build(phone, message = nil)
      return nil if phone.blank?

      digits = phone.gsub(/\D/, "")
      digits = "91#{digits}" if digits.length == 10
      base = "https://wa.me/#{digits}"
      message.present? ? "#{base}?text=#{ERB::Util.url_encode(message)}" : base
    end
  end
end
