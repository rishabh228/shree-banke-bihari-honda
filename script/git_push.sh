#!/bin/bash
set -e
cd /home/rishabh/WMS_PROJECTS/shree-banke-bihari-honda

# Try rishabh228 first, fallback to logged-in user
if gh repo view rishabh228/shree-banke-bihari-honda &>/dev/null; then
  git remote add origin https://github.com/rishabh228/shree-banke-bihari-honda.git 2>/dev/null || git remote set-url origin https://github.com/rishabh228/shree-banke-bihari-honda.git
elif gh repo create shree-banke-bihari-honda --public --description "Shree Banke Bihari Honda - 2-Wheeler Showroom Management System (Rails 8)" --source=. --remote=origin --push; then
  echo "Repo created and pushed on logged-in account"
  gh repo view --web 2>/dev/null || true
  exit 0
else
  gh repo create rishabh228/shree-banke-bihari-honda --public --description "Shree Banke Bihari Honda - Rails 8 Showroom Management" --source=. --remote=origin --push || {
    git remote add origin https://github.com/rishabhlodhi5/shree-banke-bihari-honda.git 2>/dev/null || true
    gh repo create rishabhlodhi5/shree-banke-bihari-honda --public --source=. --remote=origin --push
  }
fi

git push -u origin main
