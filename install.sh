#!/bin/bash
set -euo pipefail

LABEL=com.airstop
INSTALL_DIR="$HOME/Library/Application Support/airstop"
SCRIPT="$INSTALL_DIR/airstop.sh"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/airstop.log"
SUDOERS=/etc/sudoers.d/airstop
DOMAIN="gui/$(id -u)"
USER_NAME="$(id -un)"

cd "$(dirname "$0")"

echo "Installing airstop.sh to $INSTALL_DIR"
mkdir -p "$INSTALL_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
install -m 0755 airstop.sh "$SCRIPT"

echo "Adding sudoers rule $SUDOERS (sudo password required)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
cat > "$tmp" << EOF
$USER_NAME ALL=(root) NOPASSWD: /sbin/ifconfig awdl0 down
$USER_NAME ALL=(root) NOPASSWD: /sbin/ifconfig awdl0 up
EOF

/usr/sbin/visudo -cqf "$tmp"
sudo install -m 0440 -o root -g wheel "$tmp" "$SUDOERS"

echo "Writing LaunchAgent $PLIST"
cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$LOG</string>
    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
EOF
plutil -lint -s "$PLIST"

echo "Loading LaunchAgent"

launchctl bootout "$DOMAIN/$LABEL" 2> /dev/null || true
launchctl bootstrap "$DOMAIN" "$PLIST"

echo "Done. AirStop is running; logs: $LOG"
