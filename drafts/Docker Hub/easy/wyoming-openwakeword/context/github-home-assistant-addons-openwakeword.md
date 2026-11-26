# home-assistant/addons: openwakeword (add-on config)

Source URL(s) + fetch date: https://github.com/home-assistant/addons/tree/master/openwakeword (fetched as https://raw.githubusercontent.com/home-assistant/addons/master/openwakeword/config.yaml) · fetched 2026-11-26

## What it is
- Home Assistant add-on packaging of openWakeWord (add-on slug `core_openwakeword`, per the upstream README).

## Config (verbatim facts)
- add-on `version` "2.1.1" (add-on version, not the upstream v2.1.0 tag).
- Image `homeassistant/{arch}-addon-openwakeword`.
- Ports: `10400/tcp`.
- Options: `threshold` 0.5 (float), `trigger_level` 1 (int), `debug_logging` false (bool).
- Map: `share:ro` (read-only share folder). No `config` map.

## Gotchas
- Not a container image for ContainerForge; used only as a reference for defaults (threshold 0.5, trigger_level 1).
- The add-on's version (2.1.1) differs from upstream (2.1.0).
