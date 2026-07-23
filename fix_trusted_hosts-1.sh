#!/bin/bash
# Adds trusted_host_patterns to farmOS settings.php for serveo tunnel access
set -e

FARMOS_DIR="/home/kali/farmos"
SETTINGS_FILE="$FARMOS_DIR/www/web/sites/default/settings.php"
DEFAULT_TEMPLATE="$FARMOS_DIR/www/web/sites/default/default.settings.php"

# If settings.php doesn't exist yet, copy it from the template
if [ ! -f "$SETTINGS_FILE" ]; then
  if [ -f "$DEFAULT_TEMPLATE" ]; then
    echo "settings.php not found — copying from default.settings.php"
    cp "$DEFAULT_TEMPLATE" "$SETTINGS_FILE"
  else
    echo "ERROR: Neither settings.php nor default.settings.php found."
    echo "Checked: $SETTINGS_FILE"
    echo "Run 'ls $FARMOS_DIR/www/web/sites/default' to see what's actually there,"
    echo "and 'docker compose logs www --tail 50' to check if the container finished installing."
    exit 1
  fi
fi

# Avoid adding the block twice
if grep -q "trusted_host_patterns" "$SETTINGS_FILE"; then
  echo "trusted_host_patterns already present in settings.php — skipping."
  exit 0
fi

# Backup before editing
cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak.$(date +%s)"

# Append the trusted host config
cat >> "$SETTINGS_FILE" << 'EOF'

$settings['trusted_host_patterns'] = [
  '^farmos\.serveousercontent\.com$',
  '^localhost$',
];
EOF

echo "Done. Added trusted_host_patterns to $SETTINGS_FILE"
echo "Backup saved as: $SETTINGS_FILE.bak.*"
echo "Reload farmOS in your browser to check it worked."
