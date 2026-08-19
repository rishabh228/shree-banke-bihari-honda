# frozen_string_literal: true

# Shree Banke Bihari Honda — Seed Data
puts "Seeding Shree Banke Bihari Honda..."

Setting.instance.update!(
  showroom_name: "Shree Banke Bihari Honda",
  address: "Main Road, Near City Center, Your City - 000000",
  phone: "+91 98765 43210",
  email: "info@shreebankebiharihonda.com",
  whatsapp: "+919876543210",
  google_map_link: "https://maps.google.com/?q=Shree+Banke+Bihari+Honda",
  google_map_embed_url: "https://maps.google.com/maps?q=Honda+Showroom&output=embed",
  contact_page_heading: "Contact Us",
  contact_page_intro: "Visit our showroom, call us, or send a message — we're here to help with sales, service, finance, and insurance.",
  footer_tagline: "Your trusted authorized Honda two-wheeler dealership in the region.",
  gstin: "09AAAAA0000A1Z5",
  pan: "AAAAA0000A",
  state: "Uttar Pradesh",
  state_code: "09",
  invoice_prefix: "SBH",
  legal_name: "Shree Banke Bihari Honda",
  dealer_code: "UP-DEMO-001",
  bank_name: "State Bank of India",
  bank_account_number: "00000000000",
  bank_ifsc: "SBIN0000000",
  upi_id: "sbhhonda@upi",
  handling_hsn: "998599",
  handling_gst_rate: 18,
  vehicle_hsn: "8711",
  accessories_hsn: "871410",
  vehicle_gst_rate: 28,
  accessories_gst_rate: 18,
  facebook: "https://facebook.com/",
  instagram: "https://instagram.com/",
  youtube: "https://youtube.com/",
  business_hours: "Mon - Sat: 9:00 AM - 7:00 PM\nSunday: 10:00 AM - 5:00 PM"
)

admin = User.find_or_create_by!(email: "admin@shreebankebiharihonda.com") do |u|
  u.name = "Super Admin"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :super_admin
end
admin.update!(role: :super_admin, name: "Super Admin")

User.find_or_create_by!(email: "manager@shreebankebiharihonda.com") do |u|
  u.name = "Showroom Manager"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :manager
end

User.find_or_create_by!(email: "sales@shreebankebiharihonda.com") do |u|
  u.name = "Sales Executive"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :sales_executive
end

User.find_or_create_by!(email: "service@shreebankebiharihonda.com") do |u|
  u.name = "Service Advisor"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :service_advisor
end

bikes_data = [
  {
    name: "Honda Activa 6G",
    category: "Scooter",
    engine: "109.51 cc",
    mileage: "60 km/l",
    power: "7.79 PS",
    torque: "8.84 Nm",
    fuel_tank: "5.3 L",
    weight: "107 kg",
    description: "India's most trusted scooter with silent start, external fuel fill, and premium comfort.",
    status: :published,
    variants: [
      { name: "Standard", color: "Pearl Igneous Black", ex_showroom_price: 74_536, insurance: 4_200, rto: 8_500, handling_charge: 1_500, accessories_charge: 3_000, stock_quantity: 8 },
      { name: "DLX", color: "Decent Blue Metallic", ex_showroom_price: 76_536, insurance: 4_300, rto: 8_700, handling_charge: 1_500, accessories_charge: 3_500, stock_quantity: 2 }
    ],
    features: [ "Silent Start", "LED Headlamp", "External Fuel Fill", "Mobile Charging Socket", "Combi Brake System" ],
    specs: [
      [ "Engine Type", "4-Stroke, SI Engine" ],
      [ "Max Power", "7.79 PS @ 8000 rpm" ],
      [ "Seat Height", "764 mm" ],
      [ "Ground Clearance", "171 mm" ]
    ]
  },
  {
    name: "Honda Shine",
    category: "Commuter",
    engine: "123.94 cc",
    mileage: "55 km/l",
    power: "10.59 PS",
    torque: "11 Nm",
    fuel_tank: "10 L",
    weight: "114 kg",
    description: "Perfect commuter bike with refined engine, great mileage, and low maintenance.",
    status: :published,
    variants: [
      { name: "Drum", color: "Athletic Blue Metallic", ex_showroom_price: 69_990, insurance: 3_800, rto: 7_800, handling_charge: 1_500, accessories_charge: 2_500, stock_quantity: 5 },
      { name: "Disc", color: "Black", ex_showroom_price: 72_990, insurance: 4_000, rto: 8_100, handling_charge: 1_500, accessories_charge: 2_800, stock_quantity: 3 }
    ],
    features: [ "LED Headlamp", "Digital-Analog Meter", "Side Stand Engine Cut-off", "5-Step Adjustable Suspension" ],
    specs: [
      [ "Engine Type", "4-Stroke, SI Engine" ],
      [ "Max Power", "10.59 PS @ 7500 rpm" ],
      [ "Wheelbase", "1285 mm" ],
      [ "Ground Clearance", "168 mm" ]
    ]
  },
  {
    name: "Honda SP 125",
    category: "Commuter",
    engine: "123.94 cc",
    mileage: "65 km/l",
    power: "10.72 PS",
    torque: "10.9 Nm",
    fuel_tank: "11 L",
    weight: "116 kg",
    description: "Stylish 125cc commuter with eSP technology and premium features.",
    status: :published,
    variants: [
      { name: "Drum", color: "Matte Axis Gray Metallic", ex_showroom_price: 84_990, insurance: 4_500, rto: 9_200, handling_charge: 1_500, accessories_charge: 3_000, stock_quantity: 6 },
      { name: "Disc", color: "Pearl Spartan Red", ex_showroom_price: 87_990, insurance: 4_700, rto: 9_500, handling_charge: 1_500, accessories_charge: 3_200, stock_quantity: 0, available: false }
    ],
    features: [ "eSP Technology", "LED Headlamp & Taillamp", "Digital Meter", "Silent Start with ACG" ],
    specs: [
      [ "Engine Type", "4-Stroke, SI Engine" ],
      [ "Max Power", "10.72 PS @ 7500 rpm" ],
      [ "Seat Height", "790 mm" ],
      [ "Ground Clearance", "162 mm" ]
    ]
  }
]

bikes_data.each do |data|
  bike = Bike.find_or_initialize_by(name: data[:name])
  bike.assign_attributes(data.except(:variants, :features, :specs))
  bike.published_at = Time.current if bike.published?
  bike.save!

  data[:variants].each do |v|
    variant = bike.bike_variants.find_or_initialize_by(name: v[:name])
    variant.assign_attributes(v)
    variant.save!
  end

  data[:features].each_with_index do |title, i|
    bike.bike_features.find_or_create_by!(title: title) { |f| f.position = i }
  end

  data[:specs].each_with_index do |(label, value), i|
    bike.bike_specifications.find_or_create_by!(label: label) { |s| s.value = value; s.position = i }
  end
end

activa = Bike.find_by!(name: "Honda Activa 6G")
Offer.find_or_create_by!(title: "Activa Festive Offer") do |o|
  o.description = "Special festive discount on Honda Activa 6G. Limited period offer!"
  o.bike = activa
  o.start_date = Date.current
  o.end_date = 3.months.from_now.to_date
  o.active = true
end

Offer.find_or_create_by!(title: "Free Service Camp") do |o|
  o.description = "Free 3rd service on all Honda 2-wheelers purchased from our showroom."
  o.start_date = Date.current
  o.end_date = 2.months.from_now.to_date
  o.active = true
end

accessories = [
  { name: "Full Face Helmet", price: 1_500, stock: 25, description: "ISI certified full face helmet with clear visor." },
  { name: "Riding Gloves", price: 899, stock: 40, description: "Comfortable riding gloves with knuckle protection." },
  { name: "Seat Cover", price: 450, stock: 60, description: "Water-resistant seat cover for all Honda scooters." },
  { name: "Engine Oil (1L)", price: 380, stock: 100, description: "Genuine Honda 4-stroke engine oil." },
  { name: "Body Cover", price: 750, stock: 30, description: "Dust-proof body cover for scooters and bikes." },
  { name: "Crash Guard", price: 1_200, stock: 20, description: "Heavy-duty crash guard for commuter bikes." }
]

accessories.each do |attrs|
  Accessory.find_or_create_by!(name: attrs[:name]) do |a|
    a.assign_attributes(attrs)
    a.status = :active
  end
end

%w[about privacy terms faq contact].each do |slug|
  Page.find_or_create_by!(slug: slug) do |p|
    p.title = slug.titleize
    p.published = true
    p.body = "<h2>#{p.title}</h2><p>Welcome to Shree Banke Bihari Honda. Content editable from admin CMS.</p>"
  end
end

[
  { title: "Ride Your Dreams", subtitle: "Authorized Honda 2-Wheeler Dealer", section: "hero", position: 0 },
  { title: "Premium Service", subtitle: "Expert technicians, genuine parts", section: "hero", position: 1 },
  { title: "Easy Finance", subtitle: "Loan assistance at showroom", section: "hero", position: 2 }
].each do |attrs|
  Banner.find_or_create_by!(title: attrs[:title], section: attrs[:section]) do |b|
    b.assign_attributes(attrs)
    b.active = true
  end
end

sales_exec = User.find_by!(email: "sales@shreebankebiharihonda.com")
shine = Bike.find_by!(name: "Honda Shine")
activa_variant = activa.bike_variants.first
shine_variant = shine.bike_variants.first

[
  {
    customer_name: "Rahul Sharma", phone: "9876543210", email: "rahul@example.com",
    bike: activa, bike_variant: activa_variant, sales_executive: sales_exec,
    status: :delivered, payment_mode: :cash, booking_amount: 5000,
    quoted_on: 10.days.ago.to_date, booked_on: 8.days.ago.to_date, delivery_date: 2.days.ago.to_date,
    chassis_number: "CH123456", engine_number: "EN789012"
  },
  {
    customer_name: "Priya Patel", phone: "9123456780", email: "priya@example.com",
    bike: shine, bike_variant: shine_variant, sales_executive: sales_exec,
    status: :booked, payment_mode: :finance, finance_partner: "HDFC Bank", booking_amount: 3000,
    quoted_on: 3.days.ago.to_date, booked_on: 1.day.ago.to_date
  },
  {
    customer_name: "Amit Kumar", phone: "9988776655",
    bike: activa, bike_variant: activa_variant, sales_executive: sales_exec,
    status: :quoted, payment_mode: :upi, booking_amount: 0,
    quoted_on: Date.current
  }
].each do |attrs|
  variant = attrs.delete(:bike_variant)
  bike = attrs.delete(:bike)
  sale = Sale.find_or_initialize_by(customer_name: attrs[:customer_name], phone: attrs[:phone], bike: bike)
  sale.assign_attributes(attrs)
  sale.bike_variant = variant
  sale.save!
end

Bike.published_bikes.find_each do |bike|
  bike.update!(hsn_code: bike.hsn_code.presence || "8711", gst_rate: bike.gst_rate.presence || 28)
end

[
  [ activa_variant, "ME4TC58A0A0001001", "JF49E1000001" ],
  [ activa_variant, "ME4TC58A0A0001002", "JF49E1000002" ],
  [ shine_variant, "ME4KC21A0A0002001", "HA11E2000001" ]
].each do |variant, chassis, engine|
  VehicleUnit.find_or_create_by!(chassis_number: chassis) do |unit|
    unit.bike_variant = variant
    unit.engine_number = engine
    unit.status = :in_stock
    unit.received_on = Date.current
  end
end

rahul = Sale.find_by(customer_name: "Rahul Sharma", phone: "9876543210")
if rahul
  unit = VehicleUnit.find_or_create_by!(chassis_number: "CH123456") do |record|
    record.bike_variant = activa_variant
    record.engine_number = "EN789012"
    record.status = :delivered
    record.sale = rahul
    record.received_on = 12.days.ago.to_date
  end
  rahul.update_columns(vehicle_unit_id: unit.id, chassis_number: "CH123456", engine_number: "EN789012")
  Billing::IssueInvoiceService.new(rahul).call unless rahul.invoiced?
  if rahul.payment_receipts.none?
    Billing::CreateReceiptService.new(
      rahul,
      { amount: 5_000, payment_mode: :cash, received_on: rahul.booked_on, notes: "Booking token" },
      received_by: sales_exec
    ).call
  end
end

end

enquiry_bike = Bike.published_bikes.first
if enquiry_bike
  Enquiry.find_or_create_by!(phone: "9000000001", source: :bike_enquiry) do |enquiry|
    enquiry.name = "Neha Gupta"
    enquiry.email = "neha@example.com"
    enquiry.message = "Need on-road price for Activa and finance options."
    enquiry.bike = enquiry_bike
    enquiry.status = :new_enquiry
  end

  TestRide.find_or_create_by!(phone: "9000000002", bike: enquiry_bike) do |ride|
    ride.name = "Vikram Singh"
    ride.email = "vikram@example.com"
    ride.preferred_date = Date.current + 1
    ride.preferred_time = "11:00 AM"
    ride.status = :pending
  end
end

service_advisor = User.find_by!(email: "service@shreebankebiharihonda.com")
booking = ServiceBooking.find_or_create_by!(phone: "9000000003", vehicle_number: "UP32AB1234") do |record|
  record.customer_name = "Amit Service"
  record.email = "amit.service@example.com"
  record.bike_model = "Honda Activa 6G"
  record.service_type = "paid"
  record.preferred_date = Date.current
  record.complaint = "Engine noise and free service check."
  record.status = :assigned
  record.assigned_to = service_advisor
end

if booking.job_card.blank?
  Billing::EnsureJobCardService.new(booking).call
end

helmet = Accessory.first
if helmet
  spare = CounterInvoice.find_or_initialize_by(customer_name: "Walk-in helmet", phone: "9000000004", kind: :spare)
  if spare.new_record?
    spare.assign_attributes(status: :draft, buyer_state: "Uttar Pradesh", buyer_state_code: "09")
    spare.save!
    Billing::AddCounterLineService.new(spare, accessory_id: helmet.id, quantity: 1).call
    Billing::IssueCounterInvoiceService.new(spare, issued_by: sales_exec).call
  end
end

Banner.find_or_create_by!(title: "Monsoon service camp", section: "news") do |banner|
  banner.subtitle = "Free 15-point check this weekend at the workshop."
  banner.position = 0
  banner.active = true
end

admin.notifications.find_or_create_by!(title: "New enquiry from website") do |note|
  note.body = "Neha Gupta requested on-road pricing."
  note.notifiable = Enquiry.find_by(phone: "9000000001")
end

puts "Seed complete!"
puts "Admin login: admin@shreebankebiharihonda.com / password123"
