# frozen_string_literal: true

class Setting < ApplicationRecord
  has_one_attached :logo

  GSTIN_FORMAT = /\A[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}\z/
  PAN_FORMAT = /\A[A-Z]{5}[0-9]{4}[A-Z]{1}\z/

  validates :showroom_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :gstin, format: { with: GSTIN_FORMAT, message: "must be a valid 15-character GSTIN" }, allow_blank: true
  validates :pan, format: { with: PAN_FORMAT, message: "must be a valid PAN" }, allow_blank: true
  validates :invoice_prefix, length: { maximum: 10 }, allow_blank: true
  validates :vehicle_gst_rate, :accessories_gst_rate, :handling_gst_rate, :labour_gst_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  before_validation :normalize_tax_identifiers

  def self.instance
    with_attached_logo.first || create!(showroom_name: "Shree Banke Bihari Honda")
  end

  def whatsapp_notifications_enabled?
    whatsapp_notifications_enabled != false
  end

  def contact_heading
    contact_page_heading.presence || "Contact Us"
  end

  def contact_intro
    contact_page_intro.presence ||
      "Visit our showroom, call us, or send a message — we're here to help with sales, service, finance, and insurance."
  end

  def map_embed_url
    google_map_embed_url.presence || google_map_link
  end

  def map_directions_url
    google_map_link.presence || google_map_embed_url
  end

  def billing_ready?
    gstin.present?
  end

  def place_of_supply_label
    [ state.presence, state_code.presence ].compact.join(" / ").presence || "—"
  end

  def invoice_prefix_code
    invoice_prefix.presence || "SBH"
  end

  def vehicle_hsn_code
    vehicle_hsn.presence || "8711"
  end

  def accessories_hsn_code
    accessories_hsn.presence || "871410"
  end

  def handling_hsn_code
    handling_hsn.presence || "998599"
  end

  def handling_tax_rate
    (handling_gst_rate.presence || 18).to_d
  end

  def legal_showroom_name
    legal_name.presence || showroom_name
  end

  def labour_sac_code
    labour_sac.presence || "998714"
  end

  def labour_tax_rate
    (labour_gst_rate.presence || 18).to_d
  end

  def vehicle_tax_rate
    (vehicle_gst_rate.presence || 28).to_d
  end

  def accessories_tax_rate
    (accessories_gst_rate.presence || 18).to_d
  end

  def social_links
    {
      facebook: facebook,
      instagram: instagram,
      youtube: youtube,
      whatsapp: whatsapp
    }.compact_blank
  end

  private

  def normalize_tax_identifiers
    self.gstin = gstin.to_s.gsub(/\s/, "").upcase.presence
    self.pan = pan.to_s.gsub(/\s/, "").upcase.presence
    self.invoice_prefix = invoice_prefix.to_s.strip.upcase.presence
  end
end
