# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_08_19_240000) do
  create_table "accessories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 12, scale: 2, default: "0.0"
    t.integer "stock", default: 0
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hsn_code", default: "871410"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "18.0"
    t.index ["status"], name: "index_accessories_on_status"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "banners", force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.string "link"
    t.integer "position", default: 0
    t.string "section", default: "hero", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section", "position"], name: "index_banners_on_section_and_position"
  end

  create_table "bike_features", force: :cascade do |t|
    t.integer "bike_id", null: false
    t.string "title", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_id", "position"], name: "index_bike_features_on_bike_id_and_position"
    t.index ["bike_id"], name: "index_bike_features_on_bike_id"
  end

  create_table "bike_specifications", force: :cascade do |t|
    t.integer "bike_id", null: false
    t.string "label", null: false
    t.string "value", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_id", "position"], name: "index_bike_specifications_on_bike_id_and_position"
    t.index ["bike_id"], name: "index_bike_specifications_on_bike_id"
  end

  create_table "bike_variants", force: :cascade do |t|
    t.integer "bike_id", null: false
    t.string "name", null: false
    t.string "color"
    t.decimal "ex_showroom_price", precision: 12, scale: 2, default: "0.0"
    t.decimal "insurance", precision: 12, scale: 2, default: "0.0"
    t.decimal "rto", precision: 12, scale: 2, default: "0.0"
    t.decimal "handling_charge", precision: 12, scale: 2, default: "0.0"
    t.decimal "accessories_charge", precision: 12, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 12, scale: 2, default: "0.0"
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.index ["bike_id"], name: "index_bike_variants_on_bike_id"
  end

  create_table "bikes", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "category"
    t.string "engine"
    t.string "mileage"
    t.string "power"
    t.string "torque"
    t.string "fuel_tank"
    t.string "weight"
    t.text "description"
    t.integer "status", default: 0, null: false
    t.string "seo_title"
    t.string "seo_description"
    t.text "meta_keywords"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hsn_code", default: "8711"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "28.0"
    t.index ["category"], name: "index_bikes_on_category"
    t.index ["slug"], name: "index_bikes_on_slug", unique: true
    t.index ["status"], name: "index_bikes_on_status"
  end

  create_table "counter_invoice_lines", force: :cascade do |t|
    t.integer "counter_invoice_id", null: false
    t.integer "accessory_id"
    t.integer "position", default: 0, null: false
    t.string "line_type", null: false
    t.string "description", null: false
    t.string "hsn_code"
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0"
    t.string "uqc", default: "NOS"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "taxable_value", precision: 12, scale: 2, default: "0.0"
    t.decimal "cgst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "sgst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "igst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "cgst_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "sgst_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "igst_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "inclusive_amount", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accessory_id"], name: "index_counter_invoice_lines_on_accessory_id"
    t.index ["counter_invoice_id"], name: "index_counter_invoice_lines_on_counter_invoice_id"
  end

  create_table "counter_invoices", force: :cascade do |t|
    t.integer "kind", default: 0, null: false
    t.integer "job_card_id"
    t.integer "issued_by_id"
    t.string "invoice_number"
    t.date "invoice_date"
    t.integer "status", default: 0, null: false
    t.string "customer_name", null: false
    t.string "phone"
    t.string "email"
    t.text "address"
    t.string "buyer_gstin"
    t.string "buyer_pan"
    t.string "buyer_state"
    t.string "buyer_state_code"
    t.boolean "inter_state", default: false, null: false
    t.boolean "reverse_charge", default: false, null: false
    t.string "place_of_supply"
    t.string "place_of_supply_code"
    t.decimal "taxable_total", precision: 12, scale: 2, default: "0.0"
    t.decimal "tax_total", precision: 12, scale: 2, default: "0.0"
    t.decimal "grand_total", precision: 12, scale: 2, default: "0.0"
    t.string "irn"
    t.string "ack_no"
    t.date "ack_date"
    t.integer "einvoice_status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "discount_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "discount_total", precision: 12, scale: 2, default: "0.0", null: false
    t.index ["invoice_date"], name: "index_counter_invoices_on_invoice_date"
    t.index ["invoice_number"], name: "index_counter_invoices_on_invoice_number", unique: true
    t.index ["issued_by_id"], name: "index_counter_invoices_on_issued_by_id"
    t.index ["job_card_id"], name: "index_counter_invoices_on_job_card_id", unique: true
    t.index ["kind", "status"], name: "index_counter_invoices_on_kind_and_status"
  end

  create_table "credit_note_lines", force: :cascade do |t|
    t.integer "credit_note_id", null: false
    t.integer "counter_invoice_line_id"
    t.integer "accessory_id"
    t.decimal "quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "inclusive_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "taxable_value", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "cgst_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "sgst_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "igst_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.index ["counter_invoice_line_id"], name: "index_credit_note_lines_on_counter_invoice_line_id"
    t.index ["credit_note_id"], name: "index_credit_note_lines_on_credit_note_id"
  end

  create_table "credit_notes", force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "sale_id"
    t.string "credit_note_number", null: false
    t.date "credit_note_date", null: false
    t.string "reason"
    t.decimal "grand_total", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "counter_invoice_id"
    t.integer "kind", default: 0, null: false
    t.decimal "taxable_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_total", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "cgst_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "sgst_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "igst_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "collected_total", precision: 12, scale: 2, default: "0.0", null: false
    t.index ["counter_invoice_id"], name: "index_credit_notes_on_counter_invoice_id"
    t.index ["credit_note_number"], name: "index_credit_notes_on_credit_note_number", unique: true
    t.index ["invoice_id"], name: "index_credit_notes_on_invoice_id"
    t.index ["sale_id"], name: "index_credit_notes_on_sale_id"
  end

  create_table "delivery_challans", force: :cascade do |t|
    t.integer "sale_id", null: false
    t.string "challan_number", null: false
    t.date "challan_date", null: false
    t.string "transporter_vehicle_no"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challan_number"], name: "index_delivery_challans_on_challan_number", unique: true
    t.index ["sale_id"], name: "index_delivery_challans_on_sale_id", unique: true
  end

  create_table "document_sequences", force: :cascade do |t|
    t.string "document_type", null: false
    t.string "financial_year", null: false
    t.integer "last_number", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_type", "financial_year"], name: "index_document_sequences_on_type_and_fy", unique: true
  end

  create_table "enquiries", force: :cascade do |t|
    t.integer "source", default: 0, null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.string "email"
    t.text "message"
    t.integer "bike_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_id"], name: "index_enquiries_on_bike_id"
    t.index ["source"], name: "index_enquiries_on_source"
    t.index ["status"], name: "index_enquiries_on_status"
  end

  create_table "gate_passes", force: :cascade do |t|
    t.integer "sale_id", null: false
    t.string "gate_pass_number", null: false
    t.datetime "issued_at", null: false
    t.string "driven_by"
    t.string "id_proof"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gate_pass_number"], name: "index_gate_passes_on_gate_pass_number", unique: true
    t.index ["sale_id"], name: "index_gate_passes_on_sale_id", unique: true
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "position", default: 0, null: false
    t.string "line_type", null: false
    t.string "description", null: false
    t.string "hsn_code"
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0"
    t.string "uqc", default: "NOS"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "taxable_value", precision: 12, scale: 2, default: "0.0"
    t.decimal "cgst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "sgst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "igst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "cgst_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "sgst_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "igst_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "inclusive_amount", precision: 12, scale: 2, default: "0.0"
    t.boolean "collected", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "sale_id", null: false
    t.string "invoice_number", null: false
    t.date "invoice_date", null: false
    t.integer "status", default: 0, null: false
    t.string "place_of_supply"
    t.boolean "inter_state", default: false, null: false
    t.string "hsn_code"
    t.string "accessories_hsn"
    t.decimal "vehicle_gst_rate", precision: 5, scale: 2, default: "28.0"
    t.decimal "accessories_gst_rate", precision: 5, scale: 2, default: "18.0"
    t.decimal "vehicle_inclusive", precision: 12, scale: 2, default: "0.0"
    t.decimal "vehicle_taxable", precision: 12, scale: 2, default: "0.0"
    t.decimal "vehicle_cgst", precision: 12, scale: 2, default: "0.0"
    t.decimal "vehicle_sgst", precision: 12, scale: 2, default: "0.0"
    t.decimal "vehicle_igst", precision: 12, scale: 2, default: "0.0"
    t.decimal "accessories_inclusive", precision: 12, scale: 2, default: "0.0"
    t.decimal "accessories_taxable", precision: 12, scale: 2, default: "0.0"
    t.decimal "accessories_cgst", precision: 12, scale: 2, default: "0.0"
    t.decimal "accessories_sgst", precision: 12, scale: 2, default: "0.0"
    t.decimal "accessories_igst", precision: 12, scale: 2, default: "0.0"
    t.decimal "insurance_collected", precision: 12, scale: 2, default: "0.0"
    t.decimal "rto_collected", precision: 12, scale: 2, default: "0.0"
    t.decimal "taxable_total", precision: 12, scale: 2, default: "0.0"
    t.decimal "tax_total", precision: 12, scale: 2, default: "0.0"
    t.decimal "grand_total", precision: 12, scale: 2, default: "0.0"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reverse_charge", default: false, null: false
    t.string "place_of_supply_code"
    t.string "irn"
    t.string "ack_no"
    t.date "ack_date"
    t.integer "einvoice_status", default: 0, null: false
    t.index ["invoice_date"], name: "index_invoices_on_invoice_date"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["sale_id", "status"], name: "index_invoices_on_sale_id_and_status"
    t.index ["sale_id"], name: "index_invoices_on_sale_id"
  end

  create_table "job_card_lines", force: :cascade do |t|
    t.integer "job_card_id", null: false
    t.integer "accessory_id"
    t.string "line_type", null: false
    t.string "description", null: false
    t.string "hsn_code"
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0"
    t.string "uqc", default: "NOS"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "18.0"
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accessory_id"], name: "index_job_card_lines_on_accessory_id"
    t.index ["job_card_id"], name: "index_job_card_lines_on_job_card_id"
  end

  create_table "job_cards", force: :cascade do |t|
    t.integer "service_booking_id", null: false
    t.string "job_card_number", null: false
    t.date "job_card_date", null: false
    t.integer "km_reading"
    t.string "chassis_number"
    t.string "engine_number"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_card_number"], name: "index_job_cards_on_job_card_number", unique: true
    t.index ["service_booking_id"], name: "index_job_cards_on_service_booking_id", unique: true
  end

  create_table "media_assets", force: :cascade do |t|
    t.string "title", null: false
    t.string "file_type"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.datetime "read_at"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "whatsapp_url"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "offers", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "bike_id"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_offers_on_active"
    t.index ["bike_id"], name: "index_offers_on_bike_id"
    t.index ["start_date", "end_date"], name: "index_offers_on_start_date_and_end_date"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "payment_receipts", force: :cascade do |t|
    t.integer "sale_id", null: false
    t.integer "received_by_id"
    t.string "receipt_number", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.integer "payment_mode", default: 0, null: false
    t.date "received_on", null: false
    t.string "reference_no"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "receipt_head", default: 0, null: false
    t.index ["receipt_number"], name: "index_payment_receipts_on_receipt_number", unique: true
    t.index ["received_by_id"], name: "index_payment_receipts_on_received_by_id"
    t.index ["sale_id"], name: "index_payment_receipts_on_sale_id"
  end

  create_table "sale_add_ons", force: :cascade do |t|
    t.integer "sale_id", null: false
    t.integer "accessory_id"
    t.string "description", null: false
    t.integer "quantity", default: 1, null: false
    t.string "uqc", default: "NOS"
    t.string "hsn_code"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "18.0"
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accessory_id"], name: "index_sale_add_ons_on_accessory_id"
    t.index ["sale_id"], name: "index_sale_add_ons_on_sale_id"
  end

  create_table "sales", force: :cascade do |t|
    t.string "customer_name", null: false
    t.string "phone", null: false
    t.string "email"
    t.text "address"
    t.integer "bike_id", null: false
    t.integer "bike_variant_id"
    t.integer "sales_executive_id", null: false
    t.integer "enquiry_id"
    t.decimal "ex_showroom_price", precision: 12, scale: 2, default: "0.0"
    t.decimal "insurance", precision: 12, scale: 2, default: "0.0"
    t.decimal "rto", precision: 12, scale: 2, default: "0.0"
    t.decimal "other_charges", precision: 12, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 12, scale: 2, default: "0.0"
    t.decimal "booking_amount", precision: 12, scale: 2, default: "0.0"
    t.integer "payment_mode", default: 0, null: false
    t.string "finance_partner"
    t.integer "status", default: 0, null: false
    t.date "quoted_on"
    t.date "booked_on"
    t.date "delivery_date"
    t.string "chassis_number"
    t.string "engine_number"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vehicle_unit_id"
    t.string "buyer_gstin"
    t.string "buyer_state"
    t.string "buyer_pan"
    t.decimal "loan_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "down_payment", precision: 12, scale: 2, default: "0.0"
    t.decimal "handling_charge", precision: 12, scale: 2, default: "0.0"
    t.decimal "accessories_charge", precision: 12, scale: 2, default: "0.0"
    t.string "buyer_state_code"
    t.decimal "discount_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.index ["bike_id"], name: "index_sales_on_bike_id"
    t.index ["bike_variant_id"], name: "index_sales_on_bike_variant_id"
    t.index ["booked_on"], name: "index_sales_on_booked_on"
    t.index ["delivery_date"], name: "index_sales_on_delivery_date"
    t.index ["enquiry_id"], name: "index_sales_on_enquiry_id"
    t.index ["phone"], name: "index_sales_on_phone"
    t.index ["sales_executive_id"], name: "index_sales_on_sales_executive_id"
    t.index ["status"], name: "index_sales_on_status"
    t.index ["vehicle_unit_id"], name: "index_sales_on_vehicle_unit_id"
  end

  create_table "service_bookings", force: :cascade do |t|
    t.string "customer_name", null: false
    t.string "phone", null: false
    t.string "email"
    t.string "vehicle_number", null: false
    t.string "bike_model", null: false
    t.integer "purchase_year"
    t.string "service_type", null: false
    t.date "preferred_date", null: false
    t.text "complaint"
    t.integer "status", default: 0, null: false
    t.integer "assigned_to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_service_bookings_on_assigned_to_id"
    t.index ["preferred_date"], name: "index_service_bookings_on_preferred_date"
    t.index ["status"], name: "index_service_bookings_on_status"
  end

  create_table "settings", force: :cascade do |t|
    t.string "showroom_name", default: "Shree Banke Bihari Honda", null: false
    t.text "address"
    t.string "phone"
    t.string "email"
    t.string "whatsapp"
    t.text "google_map_link"
    t.string "facebook"
    t.string "instagram"
    t.string "youtube"
    t.text "business_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "whatsapp_notifications_enabled", default: true, null: false
    t.string "contact_page_heading", default: "Contact Us"
    t.text "contact_page_intro"
    t.text "google_map_embed_url"
    t.text "footer_tagline"
    t.string "gstin"
    t.string "pan"
    t.string "state"
    t.string "state_code"
    t.string "invoice_prefix", default: "SBH"
    t.decimal "vehicle_gst_rate", precision: 5, scale: 2, default: "28.0"
    t.decimal "accessories_gst_rate", precision: 5, scale: 2, default: "18.0"
    t.string "vehicle_hsn", default: "8711"
    t.string "accessories_hsn", default: "871410"
    t.string "legal_name"
    t.string "dealer_code"
    t.string "bank_name"
    t.string "bank_account_number"
    t.string "bank_ifsc"
    t.string "upi_id"
    t.text "billing_terms"
    t.string "handling_hsn", default: "998599"
    t.decimal "handling_gst_rate", precision: 5, scale: 2, default: "18.0"
    t.string "labour_sac", default: "998714"
    t.decimal "labour_gst_rate", precision: 5, scale: 2, default: "18.0"
  end

  create_table "test_rides", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone", null: false
    t.string "email"
    t.integer "bike_id", null: false
    t.date "preferred_date", null: false
    t.string "preferred_time"
    t.text "remarks"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_id"], name: "index_test_rides_on_bike_id"
    t.index ["preferred_date"], name: "index_test_rides_on_preferred_date"
    t.index ["status"], name: "index_test_rides_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicle_units", force: :cascade do |t|
    t.integer "bike_variant_id", null: false
    t.string "chassis_number", null: false
    t.string "engine_number", null: false
    t.integer "status", default: 0, null: false
    t.integer "sale_id"
    t.date "received_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_variant_id"], name: "index_vehicle_units_on_bike_variant_id"
    t.index ["chassis_number"], name: "index_vehicle_units_on_chassis_number", unique: true
    t.index ["engine_number"], name: "index_vehicle_units_on_engine_number", unique: true
    t.index ["sale_id"], name: "index_vehicle_units_on_sale_id"
    t.index ["status"], name: "index_vehicle_units_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bike_features", "bikes"
  add_foreign_key "bike_specifications", "bikes"
  add_foreign_key "bike_variants", "bikes"
  add_foreign_key "counter_invoice_lines", "accessories"
  add_foreign_key "counter_invoice_lines", "counter_invoices"
  add_foreign_key "counter_invoices", "job_cards"
  add_foreign_key "counter_invoices", "users", column: "issued_by_id"
  add_foreign_key "credit_note_lines", "counter_invoice_lines"
  add_foreign_key "credit_note_lines", "credit_notes"
  add_foreign_key "credit_notes", "counter_invoices"
  add_foreign_key "credit_notes", "invoices"
  add_foreign_key "credit_notes", "sales"
  add_foreign_key "delivery_challans", "sales"
  add_foreign_key "enquiries", "bikes"
  add_foreign_key "gate_passes", "sales"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoices", "sales"
  add_foreign_key "job_card_lines", "accessories"
  add_foreign_key "job_card_lines", "job_cards"
  add_foreign_key "job_cards", "service_bookings"
  add_foreign_key "notifications", "users"
  add_foreign_key "offers", "bikes"
  add_foreign_key "payment_receipts", "sales"
  add_foreign_key "payment_receipts", "users", column: "received_by_id"
  add_foreign_key "sale_add_ons", "accessories"
  add_foreign_key "sale_add_ons", "sales"
  add_foreign_key "sales", "bike_variants"
  add_foreign_key "sales", "bikes"
  add_foreign_key "sales", "enquiries"
  add_foreign_key "sales", "users", column: "sales_executive_id"
  add_foreign_key "sales", "vehicle_units"
  add_foreign_key "service_bookings", "users", column: "assigned_to_id"
  add_foreign_key "test_rides", "bikes"
  add_foreign_key "vehicle_units", "bike_variants"
  add_foreign_key "vehicle_units", "sales", on_delete: :nullify
end
