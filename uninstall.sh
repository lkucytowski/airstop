#!/bin/bash
set -uo pipefail

LABEL=com.airstop

launchctl bootout "gui/$(id -u)/$LABEL" 2> /dev/null
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist" "$HOME/Library/Logs/airstop.log"
rm -rf "$HOME/Library/Application Support/airstop"
sudo rm -f /etc/sudoers.d/airstop

echo "AirStop uninstalled."
