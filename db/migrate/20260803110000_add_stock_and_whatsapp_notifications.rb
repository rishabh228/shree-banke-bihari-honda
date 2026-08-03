# frozen_string_literal: true

class AddStockAndWhatsappNotifications < ActiveRecord::Migration[8.0]
  def change
    change_table :bike_variants, bulk: true do |t|
      t.integer :stock_quantity, null: false, default: 0
    end

    change_table :settings, bulk: true do |t|
      t.boolean :whatsapp_notifications_enabled, null: false, default: true
    end

    change_table :notifications, bulk: true do |t|
      t.string :whatsapp_url
    end
  end
end
