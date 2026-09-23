#!/bin/bash

IFCONFIG=/sbin/ifconfig
IFACE=awdl0
APPS=("GeForceNOW" "GeForceNOWStreamer" "RemotePlay")
POLL_INTERVAL=5

disabled_by_us=false

is_streaming_app_running() {
    local app
    for app in "${APPS[@]}"; do
        pgrep -f "/Contents/MacOS/${app}( |$)" > /dev/null && return 0
    done
    return 1
}

is_awdl_up() {
    "$IFCONFIG" "$IFACE" 2> /dev/null | head -n 1 | grep -q '[<,]UP[,>]'
}

disable_awdl() {
    sudo -n "$IFCONFIG" "$IFACE" down && disabled_by_us=true
}

enable_awdl() {
    sudo -n "$IFCONFIG" "$IFACE" up && disabled_by_us=false
}

restore_awdl() {
    if $disabled_by_us; then
        enable_awdl
    fi
}

trap restore_awdl EXIT
trap 'exit 0' TERM INT HUP

while true; do
    if is_streaming_app_running; then
        is_awdl_up && disable_awdl
    elif $disabled_by_us; then
        enable_awdl
    fi
    sleep "$POLL_INTERVAL" &
    wait $!
done
