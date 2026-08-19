# frozen_string_literal: true

class AddPartialCreditNotesGstBackfill < ActiveRecord::Migration[8.0]
  def up
    say_with_time "Backfill credit note GST splits from source invoices" do
      execute <<~SQL.squish
        UPDATE credit_notes
        SET cgst_amount = COALESCE(
              (SELECT SUM(cgst_amount) FROM invoice_line_items WHERE invoice_line_items.invoice_id = credit_notes.invoice_id),
              (SELECT COALESCE(vehicle_cgst, 0) + COALESCE(accessories_cgst, 0) FROM invoices WHERE invoices.id = credit_notes.invoice_id),
              (SELECT SUM(cgst_amount) FROM counter_invoice_lines WHERE counter_invoice_lines.counter_invoice_id = credit_notes.counter_invoice_id),
              0
            ),
            sgst_amount = COALESCE(
              (SELECT SUM(sgst_amount) FROM invoice_line_items WHERE invoice_line_items.invoice_id = credit_notes.invoice_id),
              (SELECT COALESCE(vehicle_sgst, 0) + COALESCE(accessories_sgst, 0) FROM invoices WHERE invoices.id = credit_notes.invoice_id),
              (SELECT SUM(sgst_amount) FROM counter_invoice_lines WHERE counter_invoice_lines.counter_invoice_id = credit_notes.counter_invoice_id),
              0
            ),
            igst_amount = COALESCE(
              (SELECT SUM(igst_amount) FROM invoice_line_items WHERE invoice_line_items.invoice_id = credit_notes.invoice_id),
              (SELECT COALESCE(vehicle_igst, 0) + COALESCE(accessories_igst, 0) FROM invoices WHERE invoices.id = credit_notes.invoice_id),
              (SELECT SUM(igst_amount) FROM counter_invoice_lines WHERE counter_invoice_lines.counter_invoice_id = credit_notes.counter_invoice_id),
              0
            )
        WHERE cgst_amount = 0 AND sgst_amount = 0 AND igst_amount = 0
      SQL
    end
  end

  def down
    # Snapshots for historical full credit notes stay; no reverse needed.
  end
end
