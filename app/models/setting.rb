# frozen_string_literal: true

class Setting < ApplicationRecord
  has_one_attached :logo

  validates :showroom_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def self.instance
    first || create!(showroom_name: "Shree Banke Bihari Honda")
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

  def social_links
    {
      facebook: facebook,
      instagram: instagram,
      youtube: youtube,
      whatsapp: whatsapp
    }.compact_blank
  end
end
