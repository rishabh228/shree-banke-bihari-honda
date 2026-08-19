# frozen_string_literal: true

class AddPartialCreditNotes < ActiveRecord::Migration[8.0]
  def up
    add_column :credit_notes, :kind, :integer, default: 0, null: false
    add_column :credit_notes, :taxable_total, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :credit_notes, :tax_total, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :credit_notes, :cgst_amount, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :credit_notes, :sgst_amount, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :credit_notes, :igst_amount, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :credit_notes, :collected_total, :decimal, precision: 12, scale: 2, default: 0, null: false

    remove_index :credit_notes, :invoice_id
    add_index :credit_notes, :invoice_id
    remove_index :credit_notes, :counter_invoice_id
    add_index :credit_notes, :counter_invoice_id

    create_table :credit_note_lines do |t|
      t.references :credit_note, null: false, foreign_key: true
      t.references :counter_invoice_line, foreign_key: true
      t.integer :accessory_id
      t.decimal :quantity, precision: 10, scale: 2, default: 0, null: false
      t.decimal :inclusive_amount, precision: 12, scale: 2, default: 0, null: false
      t.decimal :taxable_value, precision: 12, scale: 2, default: 0, null: false
      t.decimal :tax_amount, precision: 12, scale: 2, default: 0, null: false
      t.timestamps
    end

    say_with_time "Backfill credit note GST snapshots" do
      execute <<~SQL.squish
        UPDATE credit_notes
        SET kind = 0,
            taxable_total = COALESCE((SELECT taxable_total FROM invoices WHERE invoices.id = credit_notes.invoice_id),
                                     (SELECT taxable_total FROM counter_invoices WHERE counter_invoices.id = credit_notes.counter_invoice_id),
                                     0),
            tax_total = COALESCE((SELECT tax_total FROM invoices WHERE invoices.id = credit_notes.invoice_id),
                                 (SELECT tax_total FROM counter_invoices WHERE counter_invoices.id = credit_notes.counter_invoice_id),
                                 0),
            collected_total = COALESCE(
              (SELECT COALESCE(insurance_collected, 0) + COALESCE(rto_collected, 0) FROM invoices WHERE invoices.id = credit_notes.invoice_id),
              0
            )
      SQL
    end
  end

  def down
    drop_table :credit_note_lines
    remove_index :credit_notes, :invoice_id
    add_index :credit_notes, :invoice_id, unique: true
    remove_index :credit_notes, :counter_invoice_id
    add_index :credit_notes, :counter_invoice_id, unique: true
    remove_column :credit_notes, :kind
    remove_column :credit_notes, :taxable_total
    remove_column :credit_notes, :tax_total
    remove_column :credit_notes, :cgst_amount
    remove_column :credit_notes, :sgst_amount
    remove_column :credit_notes, :igst_amount
    remove_column :credit_notes, :collected_total
  end
end
