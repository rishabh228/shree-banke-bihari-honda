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
    "delivered" => "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
    # Enquiry
    "new_enquiry" => "bg-rose-50 text-rose-700 ring-rose-600/20",
    "contacted" => "bg-sky-50 text-sky-700 ring-sky-600/20",
    "follow_up" => "bg-orange-50 text-orange-700 ring-orange-600/20",
    "closed" => "bg-gray-100 text-gray-600 ring-gray-500/20",
    # Sale
    "quoted" => "bg-blue-50 text-blue-700 ring-blue-600/20",
    "booked" => "bg-violet-50 text-violet-700 ring-violet-600/20",
    "rto_processing" => "bg-amber-50 text-amber-700 ring-amber-600/20",
    # Accessory
    "active" => "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
    "inactive" => "bg-gray-100 text-gray-600 ring-gray-500/20",
    # Stock
    "in_stock" => "bg-emerald-50 text-emerald-700 ring-emerald-600/20",
    "low_stock" => "bg-amber-50 text-amber-700 ring-amber-600/20",
    "out_of_stock" => "bg-red-50 text-red-700 ring-red-600/20"
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
    Whatsapp::Link.build(phone, message) || "#"
  end

  def export_ransack_params(*keys)
    query = params[:q]
    return {} unless query.is_a?(ActionController::Parameters)

    query.permit(*keys).to_h
  end

  def export_ransack_params_for(model_class)
    ::SearchQuery::PermittedParams.call(model_class, params[:q]).to_h
  end

  def contact_page_editable?
    ContactPagePolicy.new(current_user, Setting.instance).edit?
  end

  def stock_status_badge(variant)
    label, status_key = if !variant.available? || variant.out_of_stock?
                          [ "Out of Stock", "out_of_stock" ]
                        elsif variant.low_stock?
                          [ "Low Stock (#{variant.stock_quantity})", "low_stock" ]
                        else
                          [ "#{variant.stock_quantity} in stock", "in_stock" ]
                        end

    render partial: "shared/status_badge", locals: { status: status_key, label: label }
  end
end
