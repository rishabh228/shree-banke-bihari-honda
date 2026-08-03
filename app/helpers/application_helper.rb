# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def format_price(amount)
    return "—" if amount.blank?

    number_to_currency(amount, unit: "₹", precision: 0, format: "%u %n")
  end

  def status_color(status)
    key = status.to_s.downcase

    STATUS_COLORS.fetch(key, "bg-gray-100 text-gray-700 ring-gray-600/20")
  end

  STATUS_COLORS = {
    # Bike
    "draft" => "bg-gray-100 text-gray-700 ring-gray-600/20",
    "published" => "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
    "hidden" => "bg-amber-50 text-amber-700 ring-amber-600/20",
    # Test ride
    "pending" => "bg-amber-50 text-amber-700 ring-amber-600/20",
    "confirmed" => "bg-sky-50 text-sky-700 ring-sky-600/20",
    "completed" => "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
    "cancelled" => "bg-red-50 text-red-700 ring-red-600/20",
    # Service booking
    "assigned" => "bg-violet-50 text-violet-700 ring-violet-600/20",
    "in_progress" => "bg-blue-50 text-blue-700 ring-blue-600/20",
    "delivered" => "bg-teal-50 text-teal-700 ring-teal-600/20",
    # Enquiry
    "new_enquiry" => "bg-rose-50 text-rose-700 ring-rose-600/20",
    "contacted" => "bg-sky-50 text-sky-700 ring-sky-600/20",
    "follow_up" => "bg-orange-50 text-orange-700 ring-orange-600/20",
    "closed" => "bg-gray-100 text-gray-600 ring-gray-500/20",
    # Accessory
    "active" => "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
    "inactive" => "bg-gray-100 text-gray-600 ring-gray-500/20"
  }.freeze
  private_constant :STATUS_COLORS

  def admin_nav_active?(controller_name, action_name = nil)
    return controller_name == params[:controller].split("/").last if action_name.nil?

    controller_name == params[:controller].split("/").last && action_name == params[:action]
  end

  def public_nav_active?(path)
    current_page?(path)
  end

  def whatsapp_url(phone, message = nil)
    return "#" if phone.blank?

    digits = phone.gsub(/\D/, "")
    digits = "91#{digits}" if digits.length == 10
    base = "https://wa.me/#{digits}"
    message.present? ? "#{base}?text=#{ERB::Util.url_encode(message)}" : base
  end
end
