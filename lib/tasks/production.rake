# frozen_string_literal: true

namespace :production do
  desc "Create the first live super admin. Set ADMIN_EMAIL, ADMIN_PASSWORD, ADMIN_NAME."
  task create_admin: :environment do
    email = ENV.fetch("ADMIN_EMAIL", "").strip.downcase
    password = ENV.fetch("ADMIN_PASSWORD", "")
    name = ENV.fetch("ADMIN_NAME", "Showroom Admin").strip

    abort "Set ADMIN_EMAIL and ADMIN_PASSWORD" if email.blank? || password.blank?
    abort "Do not use the local dummy password on the live site" if password == "password123"
    abort "ADMIN_PASSWORD must be at least 10 characters" if password.length < 10

    user = User.find_or_initialize_by(email: email)
    user.name = name
    user.password = password
    user.password_confirmation = password
    user.role = :super_admin
    user.save!

    puts "Super admin ready: #{user.email}"
  end
end
