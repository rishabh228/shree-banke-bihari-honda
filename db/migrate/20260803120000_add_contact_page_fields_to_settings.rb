# frozen_string_literal: true

class AddContactPageFieldsToSettings < ActiveRecord::Migration[8.0]
  def change
    change_table :settings, bulk: true do |t|
      t.string :contact_page_heading, default: "Contact Us"
      t.text :contact_page_intro
      t.text :google_map_embed_url
      t.text :footer_tagline
    end
  end
end
