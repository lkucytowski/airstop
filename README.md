# AirStop

AirStop provides an automated, efficient solution for reducing latency and network issues while using GeForce NOW or PS Remote Play on macOS by managing the AWDL (Apple Wireless Direct Link) network interface, ensuring a smoother gaming experience.

## What It Does
- **Disables AWDL**: When GeForce NOW or PS Remote Play starts, it disables AWDL (used by features like AirDrop and Handoff) to prevent network interference.
- **Re-enables AWDL**: Once the streaming app exits, AWDL is re-enabled to restore full functionality of macOS features.
- **Purpose**: AWDL can cause latency and instability during gaming. This tool provides an automated solution to address these issues.

---

## Installation

```bash
git clone https://github.com/lkucytowski/airstop
cd airstop
./install.sh
```

The installer asks for your password once (to add the sudoers rule) and then:
- copies `airstop.sh` to `~/Library/Application Support/airstop/`
- creates `/etc/sudoers.d/airstop`, which lets your user run **only** `ifconfig awdl0 up` and `ifconfig awdl0 down` without a password
- generates `~/Library/LaunchAgents/com.airstop.plist` and loads it, so AirStop runs now and at every login

To update, pull the latest changes and run `./install.sh` again.

---

## How It Works
1. The **Launch Agent** starts the script at login and keeps it running in the background.
2. Every 5 seconds the script checks whether GeForce NOW or PS Remote Play is running. While one is, it keeps AWDL disabled.
3. When the streaming app is closed, the script re-enables AWDL — only if the script itself disabled it.
4. If the script is stopped (e.g. the Launch Agent is unloaded), it re-enables AWDL before exiting.

---

## Uninstalling
```bash
./uninstall.sh
```
This unloads the Launch Agent (re-enabling AWDL if needed) and removes the script, plist, log and sudoers rule.

---

## License

[MIT](LICENSE)
