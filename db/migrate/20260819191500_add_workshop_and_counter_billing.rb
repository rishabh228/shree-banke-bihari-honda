# frozen_string_literal: true

class AddWorkshopAndCounterBilling < ActiveRecord::Migration[8.0]
  def change
    change_table :settings, bulk: true do |t|
      t.string :labour_sac, default: "998714"
      t.decimal :labour_gst_rate, precision: 5, scale: 2, default: "18.0"
    end

    change_table :invoices, bulk: true do |t|
      t.string :irn
      t.string :ack_no
      t.date :ack_date
      t.integer :einvoice_status, default: 0, null: false
    end

    create_table :gate_passes do |t|
      t.references :sale, null: false, foreign_key: true, index: { unique: true }
      t.string :gate_pass_number, null: false
      t.datetime :issued_at, null: false
      t.string :driven_by
      t.string :id_proof
      t.text :notes
      t.timestamps
    end
    add_index :gate_passes, :gate_pass_number, unique: true

    create_table :job_cards do |t|
      t.references :service_booking, null: false, foreign_key: true, index: { unique: true }
      t.string :job_card_number, null: false
      t.date :job_card_date, null: false
      t.integer :km_reading
      t.string :chassis_number
      t.string :engine_number
      t.integer :status, default: 0, null: false
      t.timestamps
    end
    add_index :job_cards, :job_card_number, unique: true

    create_table :job_card_lines do |t|
      t.references :job_card, null: false, foreign_key: true
      t.references :accessory, foreign_key: true
      t.string :line_type, null: false
      t.string :description, null: false
      t.string :hsn_code
      t.decimal :quantity, precision: 10, scale: 2, default: "1.0"
      t.string :uqc, default: "NOS"
      t.decimal :gst_rate, precision: 5, scale: 2, default: "18.0"
      t.decimal :unit_price, precision: 12, scale: 2, null: false, default: "0.0"
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :counter_invoices do |t|
      t.integer :kind, null: false, default: 0
      t.references :job_card, foreign_key: true, index: { unique: true }
      t.references :issued_by, foreign_key: { to_table: :users }
      t.string :invoice_number
      t.date :invoice_date
      t.integer :status, default: 0, null: false
      t.string :customer_name, null: false
      t.string :phone
      t.string :email
      t.text :address
      t.string :buyer_gstin
      t.string :buyer_pan
      t.string :buyer_state
      t.string :buyer_state_code
      t.boolean :inter_state, default: false, null: false
      t.boolean :reverse_charge, default: false, null: false
      t.string :place_of_supply
      t.string :place_of_supply_code
      t.decimal :taxable_total, precision: 12, scale: 2, default: "0.0"
      t.decimal :tax_total, precision: 12, scale: 2, default: "0.0"
      t.decimal :grand_total, precision: 12, scale: 2, default: "0.0"
      t.string :irn
      t.string :ack_no
      t.date :ack_date
      t.integer :einvoice_status, default: 0, null: false
      t.text :notes
      t.timestamps
    end
    add_index :counter_invoices, :invoice_number, unique: true
    add_index :counter_invoices, [ :kind, :status ]
    add_index :counter_invoices, :invoice_date

    create_table :counter_invoice_lines do |t|
      t.references :counter_invoice, null: false, foreign_key: true
      t.references :accessory, foreign_key: true
      t.integer :position, default: 0, null: false
      t.string :line_type, null: false
      t.string :description, null: false
      t.string :hsn_code
      t.decimal :quantity, precision: 10, scale: 2, default: "1.0"
      t.string :uqc, default: "NOS"
      t.decimal :gst_rate, precision: 5, scale: 2, default: "0.0"
      t.decimal :taxable_value, precision: 12, scale: 2, default: "0.0"
      t.decimal :cgst_rate, precision: 5, scale: 2, default: "0.0"
      t.decimal :sgst_rate, precision: 5, scale: 2, default: "0.0"
      t.decimal :igst_rate, precision: 5, scale: 2, default: "0.0"
      t.decimal :cgst_amount, precision: 12, scale: 2, default: "0.0"
      t.decimal :sgst_amount, precision: 12, scale: 2, default: "0.0"
      t.decimal :igst_amount, precision: 12, scale: 2, default: "0.0"
      t.decimal :inclusive_amount, precision: 12, scale: 2, default: "0.0"
      t.timestamps
    end
  end
end
