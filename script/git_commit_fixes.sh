#!/bin/bash
cd /home/rishabh/WMS_PROJECTS/shree-banke-bihari-honda
git add \
  app/controllers/application_controller.rb \
  app/models/bike.rb \
  app/models/user.rb \
  app/views/devise \
  app/views/layouts/devise.html.erb \
  script/git_push.sh \
  script/git_commit_fixes.sh
git commit -F - <<'MSG'
Fix Devise sign-in and admin bike search filters

Remove registerable from User to match skipped registration routes and add
branded Devise login views. Allow status in Bike ransackable attributes so
admin status filter works with Ransack 4.

Co-Authored-By: Composer <noreply@anthropic.com>
MSG
