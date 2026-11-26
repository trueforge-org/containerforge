# domoticz/domoticz (repository, README, latest release 2026.4)

Source URL(s) + fetch date:
- https://github.com/domoticz/domoticz (README via raw master) · 2026-11-26
- https://github.com/domoticz/domoticz/releases/latest · 2026-11-26

## What it is
Open-source home automation system: monitors and controls lights, switches and sensors (temperature, rain, wind, UV, energy, gas, water). HTML5 web UI for desktop and mobile. 150+ hardware types (Z-Wave, Zigbee, MQTT, RFXCOM, P1 smart meter, Hue, 1-Wire, etc.). Event scripting via dzVents (Lua); Python plugins supported.

## Platforms / build
- Linux, Windows, macOS, FreeBSD, ARM devices (Raspberry Pi). CI badges: Linux x86_64, Windows.
- README gives no build commands; points to wiki "Build Domoticz from source" (https://wiki.domoticz.com/Build_Domoticz_from_source; not fetched).

## Runtime / env (README)
- First run: setup wizard creates admin account. For Docker, env `DOMOTICZ_ADMIN_PASSWORD` provisions admin automatically; `DOMOTICZ_ADMIN_USERNAME` optional. Securing setup: SECURITY_SETUP.md (not fetched).
- Ports and data paths: not stated on README.

## Version/release info
- Latest release `2026.4` ("Stable Release 2026.4"), marked Latest, 01 Oct (year not shown; plan says 2026-10-01). Commit `cc668a12b6ef9334928ae1fec6a7d20876e1f9f8` (signed). 11 assets listed but the asset list did not load. No sha256 values shown on the release page.
- Plan.md's checksum file names (`domoticz_linux_x86_64.tgz.sha256sum`) and sha256 values are NOT confirmed by this fetch.

## License
- Not named on README or site (wiki and site say free and open source). Upstream Dockerfile file header says "GPLv3" (see github-domoticz-domoticz-docker-dockerfile.md). Plan.md's GPL-3.0 is consistent with that; "only" vs "or later" still UNVERIFIED.
