#!/bin/bash
cd /home/rishabh/WMS_PROJECTS/shree-banke-bihari-honda
git add Gemfile Gemfile.lock README.md Rakefile config.ru Procfile.dev Dockerfile .gitignore .gitattributes .ruby-version .rubocop.yml .dockerignore .github .kamal bin config db lib public script vendor app
git commit -F - <<'MSG'
Initial Rails 8 Honda showroom app with admin panel and public website

Shree Banke Bihari Honda dealership management system with Devise, Pundit,
Hotwire, Tailwind, bike catalog, bookings, enquiries, and CMS.

Co-Authored-By: Composer <noreply@anthropic.com>
MSG
