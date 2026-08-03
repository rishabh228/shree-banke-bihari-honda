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

ActiveRecord::Schema[8.0].define(version: 2026_08_03_120000) do
  create_table "accessories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 12, scale: 2, default: "0.0"
    t.integer "stock", default: 0
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["category"], name: "index_bikes_on_category"
    t.index ["slug"], name: "index_bikes_on_slug", unique: true
    t.index ["status"], name: "index_bikes_on_status"
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
    t.index ["bike_id"], name: "index_sales_on_bike_id"
    t.index ["bike_variant_id"], name: "index_sales_on_bike_variant_id"
    t.index ["booked_on"], name: "index_sales_on_booked_on"
    t.index ["delivery_date"], name: "index_sales_on_delivery_date"
    t.index ["enquiry_id"], name: "index_sales_on_enquiry_id"
    t.index ["phone"], name: "index_sales_on_phone"
    t.index ["sales_executive_id"], name: "index_sales_on_sales_executive_id"
    t.index ["status"], name: "index_sales_on_status"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bike_features", "bikes"
  add_foreign_key "bike_specifications", "bikes"
  add_foreign_key "bike_variants", "bikes"
  add_foreign_key "enquiries", "bikes"
  add_foreign_key "notifications", "users"
  add_foreign_key "offers", "bikes"
  add_foreign_key "sales", "bike_variants"
  add_foreign_key "sales", "bikes"
  add_foreign_key "sales", "enquiries"
  add_foreign_key "sales", "users", column: "sales_executive_id"
  add_foreign_key "service_bookings", "users", column: "assigned_to_id"
  add_foreign_key "test_rides", "bikes"
end
