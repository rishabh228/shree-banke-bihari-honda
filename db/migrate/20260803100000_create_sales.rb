# frozen_string_literal: true

class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.string :customer_name, null: false
      t.string :phone, null: false
      t.string :email
      t.text :address
      t.references :bike, null: false, foreign_key: true
      t.references :bike_variant, foreign_key: true
      t.references :sales_executive, null: false, foreign_key: { to_table: :users }
      t.references :enquiry, foreign_key: true
      t.decimal :ex_showroom_price, precision: 12, scale: 2, default: 0
      t.decimal :insurance, precision: 12, scale: 2, default: 0
      t.decimal :rto, precision: 12, scale: 2, default: 0
      t.decimal :other_charges, precision: 12, scale: 2, default: 0
      t.decimal :total_price, precision: 12, scale: 2, default: 0
      t.decimal :booking_amount, precision: 12, scale: 2, default: 0
      t.integer :payment_mode, null: false, default: 0
      t.string :finance_partner
      t.integer :status, null: false, default: 0
      t.date :quoted_on
      t.date :booked_on
      t.date :delivery_date
      t.string :chassis_number
      t.string :engine_number
      t.text :notes
      t.timestamps
    end

    add_index :sales, :status
    add_index :sales, :booked_on
    add_index :sales, :delivery_date
    add_index :sales, :phone
  end
end
