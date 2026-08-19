# frozen_string_literal: true

class AddGstSplitToCreditNoteLines < ActiveRecord::Migration[8.0]
  def up
    add_column :credit_note_lines, :cgst_amount, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :credit_note_lines, :sgst_amount, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :credit_note_lines, :igst_amount, :decimal, precision: 12, scale: 2, default: 0, null: false

    say_with_time "Backfill credit note line GST from original invoice lines" do
      execute <<~SQL.squish
        UPDATE credit_note_lines
        SET cgst_amount = ROUND(COALESCE(
              (SELECT counter_invoice_lines.cgst_amount * credit_note_lines.quantity
                      / NULLIF(counter_invoice_lines.quantity, 0)
               FROM counter_invoice_lines
               WHERE counter_invoice_lines.id = credit_note_lines.counter_invoice_line_id),
              0
            ), 2),
            sgst_amount = ROUND(COALESCE(
              (SELECT counter_invoice_lines.sgst_amount * credit_note_lines.quantity
                      / NULLIF(counter_invoice_lines.quantity, 0)
               FROM counter_invoice_lines
               WHERE counter_invoice_lines.id = credit_note_lines.counter_invoice_line_id),
              0
            ), 2),
            igst_amount = ROUND(COALESCE(
              (SELECT counter_invoice_lines.igst_amount * credit_note_lines.quantity
                      / NULLIF(counter_invoice_lines.quantity, 0)
               FROM counter_invoice_lines
               WHERE counter_invoice_lines.id = credit_note_lines.counter_invoice_line_id),
              0
            ), 2)
      SQL
    end
  end

  def down
    remove_column :credit_note_lines, :cgst_amount
    remove_column :credit_note_lines, :sgst_amount
    remove_column :credit_note_lines, :igst_amount
  end
end
