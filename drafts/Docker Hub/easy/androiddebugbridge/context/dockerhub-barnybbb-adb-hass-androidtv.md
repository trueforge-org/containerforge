# barnybbb/adb-hass-androidtv (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/barnybbb/adb-hass-androidtv
- Fetched 2026-11-26

## What it is
Docker Hub listing for the adb-hass-androidtv image (upstream project: see github-blburgess-adb-hass-androidtv.md). Alpine-based, runs an ADB server and links Android TV / Fire TV / Google TV devices for Home Assistant's AndroidTV integration. MIT.

## Tags and architectures
- Only `latest` is listed.
- Version history: 1.1.0 (2026-01-29, Alpine 3.23.3, ADB 36.0.2-14143358), 1.0.0 (2020-12-22, Alpine 3.22.0, ADB 29.0.6-6198805).
- Architectures: not shown on the page. Image size about 20.7 MB; last updated about 10 months before the fetch.

## Run instructions (from listing)
- Config file: `docker run -it -v /tmp:/opt/androidtv-connect barnybbb/adb-hass-androidtv:latest`
- Env vars: `docker run -it -e devicelist=192.168.1.100,192.168.1.101::739264:44556 -e bootwait=10 -e checkfreq=60 barnybbb/adb-hass-androidtv:latest`
- Compose: port `5037:5037`, `restart: unless-stopped`, env or volume.

## Ports
5037 (ADB server).

## Volumes
`/opt/androidtv-connect` holds `config.yml`.

## Env vars
`devicelist` (required; `<host>[:<port>][:<auth_code>:<auth_port>]`, port default 5555, auth_port requires auth_code), `bootwait` (10), `checkfreq` (300), `enable_adb_usb` (no). Config file values override env.

## Gotchas
- Home Assistant setup: add each device by host and port, plus the container's IP and ADB server port (default 5037).
- UnRAID community template exists (not fetched).
