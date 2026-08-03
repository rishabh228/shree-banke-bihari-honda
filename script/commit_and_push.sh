#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="$ROOT/tmp/commit_push.log"
mkdir -p "$ROOT/tmp"

{
  echo "=== git status ==="
  git status --short
  echo "=== staging ==="
  git add Gemfile Gemfile.lock app config/routes.rb db/schema.rb db/seeds.rb db/migrate script/commit_and_push.sh

  if git diff --staged --quiet; then
    echo "Nothing to commit"
  else
    git commit -F - <<'EOF'
Add sales module, stock tracking, and WhatsApp notifications

Add full sales pipeline with PDF exports, variant stock_quantity with
low-stock dashboard alerts and auto-decrement on delivery, and WhatsApp
wa.me staff/customer alerts for enquiries, test rides, service bookings,
and sales. Fix WhatsappMessageBuilder Zeitwerk constant naming.
EOF
    echo "Committed: $(git rev-parse HEAD)"
  fi

  echo "=== pushing ==="
  git push origin main
  echo "PUSH_OK"
  echo "BRANCH=$(git branch --show-current)"
  echo "HEAD=$(git rev-parse HEAD)"
  git status --short
} >"$OUT" 2>&1

cat "$OUT"
