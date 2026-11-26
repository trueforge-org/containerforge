# Home Assistant: AndroidTV integration

Source URL(s) + fetch date:
- https://www.home-assistant.io/integrations/androidtv/
- Fetched 2026-11-26

## What it is
Home Assistant's built-in Android TV / Fire TV integration. Two connection methods.

## Connection methods
- Built-in Python implementation (recommended), using the `adb-shell` package.
- ADB server: enabled by the `adb_server_ip` option. Use `127.0.0.1` when the server runs on the same machine as Home Assistant.

## Relevant to the adb-hass-androidtv container
- The page names only `adb_server_ip` for the server. It does not name a server port option, and the page does not confirm the default 5037. The container README is the source for port 5037 (see github-blburgess-adb-hass-androidtv.md).
- ADB key: with the Python implementation, Home Assistant generates a key when none is given in the `ADB Key` option (as of version 0.101). No key requirements are described for the ADB server method.
- Device prep: enable ADB debugging, use the device IP. No separate pairing step. On first connection the device prompts for approval; tick "always allow".
- Only one ADB client can be connected to a device at a time. Disconnect others, restart the device, then restart Home Assistant.
- Some devices accept the first authorization only over Wi-Fi.
- If the Python implementation has problems with newer devices, switch to the ADB server.
- Devices that drop off Wi-Fi may need a wake lock app. Some devices need "Voice Commands When TV Screen is Off" set on.
