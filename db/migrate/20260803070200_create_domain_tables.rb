# frozen_string_literal: true

class CreateDomainTables < ActiveRecord::Migration[8.0]
  def change
    create_table :bikes do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :category
      t.string :engine
      t.string :mileage
      t.string :power
      t.string :torque
      t.string :fuel_tank
      t.string :weight
      t.text :description
      t.integer :status, null: false, default: 0
      t.string :seo_title
      t.string :seo_description
      t.text :meta_keywords
      t.datetime :published_at
      t.timestamps
    end
    add_index :bikes, :slug, unique: true
    add_index :bikes, :status
    add_index :bikes, :category

    create_table :bike_variants do |t|
      t.references :bike, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color
      t.decimal :ex_showroom_price, precision: 12, scale: 2, default: 0
      t.decimal :insurance, precision: 12, scale: 2, default: 0
      t.decimal :rto, precision: 12, scale: 2, default: 0
      t.decimal :handling_charge, precision: 12, scale: 2, default: 0
      t.decimal :accessories_charge, precision: 12, scale: 2, default: 0
      t.decimal :total_price, precision: 12, scale: 2, default: 0
      t.boolean :available, null: false, default: true
      t.timestamps
    end

    create_table :bike_features do |t|
      t.references :bike, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :bike_features, [ :bike_id, :position ]

    create_table :bike_specifications do |t|
      t.references :bike, null: false, foreign_key: true
      t.string :label, null: false
      t.string :value, null: false
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :bike_specifications, [ :bike_id, :position ]

    create_table :offers do |t|
      t.string :title, null: false
      t.text :description
      t.references :bike, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :offers, :active
    add_index :offers, [ :start_date, :end_date ]

    create_table :accessories do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 12, scale: 2, default: 0
      t.integer :stock, default: 0
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :accessories, :status

    create_table :test_rides do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.references :bike, null: false, foreign_key: true
      t.date :preferred_date, null: false
      t.string :preferred_time
      t.text :remarks
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :test_rides, :status
    add_index :test_rides, :preferred_date

    create_table :service_bookings do |t|
      t.string :customer_name, null: false
      t.string :phone, null: false
      t.string :email
      t.string :vehicle_number, null: false
      t.string :bike_model, null: false
      t.integer :purchase_year
      t.string :service_type, null: false
      t.date :preferred_date, null: false
      t.text :complaint
      t.integer :status, null: false, default: 0
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :service_bookings, :status
    add_index :service_bookings, :preferred_date

    create_table :enquiries do |t|
      t.integer :source, null: false, default: 0
      t.string :name, null: false
      t.string :phone, null: false
      t.string :email
      t.text :message
      t.references :bike, foreign_key: true
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :enquiries, :source
    add_index :enquiries, :status

    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.boolean :published, null: false, default: false
      t.timestamps
    end
    add_index :pages, :slug, unique: true

    create_table :banners do |t|
      t.string :title
      t.string :subtitle
      t.string :link
      t.integer :position, default: 0
      t.string :section, null: false, default: "hero"
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :banners, [ :section, :position ]

    create_table :settings do |t|
      t.string :showroom_name, null: false, default: "Shree Banke Bihari Honda"
      t.text :address
      t.string :phone
      t.string :email
      t.string :whatsapp
      t.text :google_map_link
      t.string :facebook
      t.string :instagram
      t.string :youtube
      t.text :business_hours
      t.timestamps
    end

    create_table :media_assets do |t|
      t.string :title, null: false
      t.string :file_type
      t.text :description
      t.timestamps
    end

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.datetime :read_at
      t.string :notifiable_type
      t.bigint :notifiable_id
      t.timestamps
    end
    add_index :notifications, [ :notifiable_type, :notifiable_id ]
    add_index :notifications, :read_at
  end
end
