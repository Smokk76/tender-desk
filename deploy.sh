#!/bin/bash
# One-shot deploy: Tender Desk landing page -> GitHub Pages
# Run from anywhere: bash /Users/igorkaminski/.code/tender-desk-site/deploy.sh
set -e
DIR=/Users/igorkaminski/.code/tender-desk-site

if [ ! -d "$DIR/.git" ]; then
  git -C "$DIR" init -b main
fi
git -C "$DIR" add -A
git -C "$DIR" -c user.name="Smokk76" -c user.email="igor.kaminski@gmail.com" \
  commit -m "Tender Desk landing page v3" || echo "nothing to commit"

if ! git -C "$DIR" remote get-url origin >/dev/null 2>&1; then
  gh repo create Smokk76/tender-desk --public 2>/dev/null || echo "repo may already exist"
  git -C "$DIR" remote add origin https://github.com/Smokk76/tender-desk.git
fi
git -C "$DIR" push -u origin main

# Enable GitHub Pages (201 on create; error text if already enabled is fine)
gh api -X POST repos/Smokk76/tender-desk/pages \
  -f "source[branch]=main" -f "source[path]=/" 2>/dev/null || echo "pages may already be enabled"

echo "Waiting for Pages build..."
for i in $(seq 1 20); do
  status=$(gh api repos/Smokk76/tender-desk/pages --jq .status 2>/dev/null || echo pending)
  echo "  status: $status"
  [ "$status" = "built" ] && break
  sleep 15
done

curl -sI https://smokk76.github.io/tender-desk/ | head -1
echo "Live URL: https://smokk76.github.io/tender-desk/"
