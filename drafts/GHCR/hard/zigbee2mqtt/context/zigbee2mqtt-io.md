# zigbee2mqtt.io (docs site, incl. Installation and Docker pages)

## Source URL(s) + date
- https://www.zigbee2mqtt.io (main, fetched 2026-11-27)
- https://www.zigbee2mqtt.io/guide/installation/ (follow-up 1)
- https://www.zigbee2mqtt.io/guide/installation/02_docker.html (follow-up 2)

## What it is
- Zigbee to MQTT bridge (Zigbee-herdsman based), GPL-3.0, Node.js.
- Install methods: Linux, Docker, Home Assistant addon, openHABian, Windows, FreeBSD jail, Kubernetes.
- Node.js 22 EOL April 2027; minimum becomes Node v24. 32-bit deprecated.

## Docker (from 02_docker.html)
- Image `ghcr.io/koenkk/zigbee2mqtt`; tags `latest`, `latest-dev`, `2.x.y`, `2.x`, `2`.
- Compose example: `./data:/app/data`, `/run/udev:/run/udev:ro`, port `8080:8080`, env `TZ`, device `/dev/serial/by-id/...:/dev/ttyACM0`, restart `unless-stopped`.
- Data dir in container: `/app/data`; config lives there (`configuration.yaml` implied, not stated explicitly).
- Onboarding runs on port 8080 at first start.

## Ports
| Port | Use |
| --- | --- |
| 8080 | Frontend (default) |

## Volumes/paths
- `/app/data` (config + state). `/run/udev` read-only in compose example.

## User/UID
- Rootless Docker: `--user 1001:1001` plus `--group-add dialout` (example ids). Rootless Compose `user: 1000:1000` + `group_add: dialout`. Rootless Podman `--group-add keep-groups`.
- SELinux may need `:z` on data volume.

## Gotchas
- Serial adapter must be passed through as a device; use `/dev/serial/by-id/` host path.
- Raspberry Pi 1/Zero: pull explicitly with `--platform linux/arm/v6` (Docker bug), arm/v6 dropped from 2.7.2.
- Broker on Docker host reachable via docker0 bridge IP (example 172.17.0.1).
- Installation page links MQTT config (/guide/configuration/mqtt.html) and Frontend config (/guide/configuration/frontend.html); not fetched.
