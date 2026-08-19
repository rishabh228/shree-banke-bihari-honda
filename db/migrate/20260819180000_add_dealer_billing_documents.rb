# frozen_string_literal: true

class AddDealerBillingDocuments < ActiveRecord::Migration[8.0]
  def change
    change_table :settings, bulk: true do |t|
      t.string :legal_name
      t.string :dealer_code
      t.string :bank_name
      t.string :bank_account_number
      t.string :bank_ifsc
      t.string :upi_id
      t.text :billing_terms
      t.string :handling_hsn, default: "998599"
      t.decimal :handling_gst_rate, precision: 5, scale: 2, default: "18.0"
    end

    change_table :sales, bulk: true do |t|
      t.decimal :handling_charge, precision: 12, scale: 2, default: "0.0"
      t.decimal :accessories_charge, precision: 12, scale: 2, default: "0.0"
      t.string :buyer_state_code
    end

    change_table :accessories, bulk: true do |t|
      t.string :hsn_code, default: "871410"
      t.decimal :gst_rate, precision: 5, scale: 2, default: "18.0"
    end

    change_table :invoices, bulk: true do |t|
      t.boolean :reverse_charge, null: false, default: false
      t.string :place_of_supply_code
    end

    change_table :payment_receipts, bulk: true do |t|
      t.integer :receipt_head, null: false, default: 0
    end

    create_table :sale_add_ons do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :accessory, foreign_key: true
      t.string :description, null: false
      t.integer :quantity, null: false, default: 1
      t.string :uqc, default: "NOS"
      t.string :hsn_code
      t.decimal :gst_rate, precision: 5, scale: 2, default: "18.0"
      t.decimal :unit_price, precision: 12, scale: 2, null: false, default: "0.0"
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :invoice_line_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
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
      t.boolean :collected, null: false, default: false
      t.timestamps
    end

    create_table :credit_notes do |t|
      t.references :invoice, null: false, foreign_key: true, index: { unique: true }
      t.references :sale, null: false, foreign_key: true
      t.string :credit_note_number, null: false
      t.date :credit_note_date, null: false
      t.string :reason
      t.decimal :grand_total, precision: 12, scale: 2, default: "0.0"
      t.timestamps
    end
    add_index :credit_notes, :credit_note_number, unique: true

    reversible do |dir|
      dir.up do
        execute "UPDATE sales SET handling_charge = other_charges WHERE handling_charge = 0 AND other_charges > 0"
      end
    end
  end
end
