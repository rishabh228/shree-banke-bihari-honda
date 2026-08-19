# frozen_string_literal: true

class CompleteDealerDmsGaps < ActiveRecord::Migration[8.0]
  def change
    add_column :sales, :discount_percent, :decimal, precision: 5, scale: 2, default: 0, null: false
    add_column :sales, :discount_amount, :decimal, precision: 12, scale: 2, default: 0, null: false

    add_column :counter_invoices, :discount_percent, :decimal, precision: 5, scale: 2, default: 0, null: false
    add_column :counter_invoices, :discount_amount, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :counter_invoices, :discount_total, :decimal, precision: 12, scale: 2, default: 0, null: false

    change_column_null :credit_notes, :invoice_id, true
    change_column_null :credit_notes, :sale_id, true
    add_reference :credit_notes, :counter_invoice, foreign_key: true, index: { unique: true }
  end
end
