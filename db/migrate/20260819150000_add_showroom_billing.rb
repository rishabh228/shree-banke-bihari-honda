# frozen_string_literal: true

class AddShowroomBilling < ActiveRecord::Migration[8.0]
  def change
    change_table :settings, bulk: true do |t|
      t.string :gstin
      t.string :pan
      t.string :state
      t.string :state_code
      t.string :invoice_prefix, default: "SBH"
      t.decimal :vehicle_gst_rate, precision: 5, scale: 2, default: "28.0"
      t.decimal :accessories_gst_rate, precision: 5, scale: 2, default: "18.0"
      t.string :vehicle_hsn, default: "8711"
      t.string :accessories_hsn, default: "871410"
    end

    change_table :bikes, bulk: true do |t|
      t.string :hsn_code, default: "8711"
      t.decimal :gst_rate, precision: 5, scale: 2, default: "28.0"
    end

    create_table :vehicle_units do |t|
      t.references :bike_variant, null: false, foreign_key: true
      t.string :chassis_number, null: false
      t.string :engine_number, null: false
      t.integer :status, null: false, default: 0
      t.references :sale, foreign_key: { on_delete: :nullify }
      t.date :received_on
      t.text :notes
      t.timestamps
    end
    add_index :vehicle_units, :chassis_number, unique: true
    add_index :vehicle_units, :engine_number, unique: true
    add_index :vehicle_units, :status

    change_table :sales, bulk: true do |t|
      t.references :vehicle_unit, foreign_key: true
      t.string :buyer_gstin
      t.string :buyer_state
      t.string :buyer_pan
      t.decimal :loan_amount, precision: 12, scale: 2, default: "0.0"
      t.decimal :down_payment, precision: 12, scale: 2, default: "0.0"
    end

    create_table :document_sequences do |t|
      t.string :document_type, null: false
      t.string :financial_year, null: false
      t.integer :last_number, null: false, default: 0
      t.timestamps
    end
    add_index :document_sequences, [ :document_type, :financial_year ], unique: true, name: "index_document_sequences_on_type_and_fy"

    create_table :invoices do |t|
      t.references :sale, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.date :invoice_date, null: false
      t.integer :status, null: false, default: 0
      t.string :place_of_supply
      t.boolean :inter_state, null: false, default: false
      t.string :hsn_code
      t.string :accessories_hsn
      t.decimal :vehicle_gst_rate, precision: 5, scale: 2, default: "28.0"
      t.decimal :accessories_gst_rate, precision: 5, scale: 2, default: "18.0"
      t.decimal :vehicle_inclusive, precision: 12, scale: 2, default: "0.0"
      t.decimal :vehicle_taxable, precision: 12, scale: 2, default: "0.0"
      t.decimal :vehicle_cgst, precision: 12, scale: 2, default: "0.0"
      t.decimal :vehicle_sgst, precision: 12, scale: 2, default: "0.0"
      t.decimal :vehicle_igst, precision: 12, scale: 2, default: "0.0"
      t.decimal :accessories_inclusive, precision: 12, scale: 2, default: "0.0"
      t.decimal :accessories_taxable, precision: 12, scale: 2, default: "0.0"
      t.decimal :accessories_cgst, precision: 12, scale: 2, default: "0.0"
      t.decimal :accessories_sgst, precision: 12, scale: 2, default: "0.0"
      t.decimal :accessories_igst, precision: 12, scale: 2, default: "0.0"
      t.decimal :insurance_collected, precision: 12, scale: 2, default: "0.0"
      t.decimal :rto_collected, precision: 12, scale: 2, default: "0.0"
      t.decimal :taxable_total, precision: 12, scale: 2, default: "0.0"
      t.decimal :tax_total, precision: 12, scale: 2, default: "0.0"
      t.decimal :grand_total, precision: 12, scale: 2, default: "0.0"
      t.text :notes
      t.timestamps
    end
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :invoice_date
    add_index :invoices, [ :sale_id, :status ]

    create_table :payment_receipts do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :received_by, foreign_key: { to_table: :users }
      t.string :receipt_number, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :payment_mode, null: false, default: 0
      t.date :received_on, null: false
      t.string :reference_no
      t.text :notes
      t.timestamps
    end
    add_index :payment_receipts, :receipt_number, unique: true

    create_table :delivery_challans do |t|
      t.references :sale, null: false, foreign_key: true, index: { unique: true }
      t.string :challan_number, null: false
      t.date :challan_date, null: false
      t.string :transporter_vehicle_no
      t.text :notes
      t.timestamps
    end
    add_index :delivery_challans, :challan_number, unique: true
  end
end
