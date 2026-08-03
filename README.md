# Shree Banke Bihari Honda

A complete **Honda 2-Wheeler Showroom Management System** built with Ruby on Rails 8, Hotwire, Tailwind CSS, Devise, and Pundit.

## Features

- **Public website** — Homepage, bike catalog, offers, accessories, finance, insurance, test ride & service booking
- **Admin panel** — Dashboard, bike management (variants/features/specs), offers, accessories, enquiries, CMS, media library, settings
- **Role-based access** — Super Admin, Manager, Sales Executive, Service Advisor
- **CMS** — Editable pages, banners, homepage sections (no code changes needed)

## Tech Stack

- Ruby on Rails 8
- SQLite (development) — PostgreSQL-ready schema
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Devise · Pundit · Ransack · Pagy · FriendlyId · Chartkick · Active Storage · ActionText

## Setup

```bash
cd shree-banke-bihari-honda
bundle install
rails db:setup    # or: db:create db:migrate db:seed
bin/dev           # starts Rails + Tailwind watcher
```

Visit **http://localhost:3000**

## Login Credentials (after seed)

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@shreebankebiharihonda.com | password123 |
| Manager | manager@shreebankebiharihonda.com | password123 |
| Sales Executive | sales@shreebankebiharihonda.com | password123 |
| Service Advisor | service@shreebankebiharihonda.com | password123 |

Admin panel: **http://localhost:3000/admin**

## Project Structure

```
app/controllers/admin/    # Admin CRUD
app/controllers/public/   # Public website
app/services/             # Business logic
app/policies/             # Pundit authorization
app/views/admin/          # Admin views
app/views/public/         # Public views
```

## User Roles

| Role | Permissions |
|------|-------------|
| Super Admin | Full access |
| Manager | Bikes, offers, accessories, reports |
| Sales Executive | Test rides, enquiries |
| Service Advisor | Service bookings |

## License

Private — Shree Banke Bihari Honda
