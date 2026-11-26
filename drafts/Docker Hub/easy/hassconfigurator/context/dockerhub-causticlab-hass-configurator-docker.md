# Docker Hub: causticlab/hass-configurator-docker

Source URL(s) + fetch date:
- https://hub.docker.com/r/causticlab/hass-configurator-docker (fetched 2026-11-26)

## What it is
- Image description: "Linux x32/64 and ARM (raspberry) builds for the hass-configurator". Publisher causticlab; about 10M+ pulls; 36 stars (as shown on the page).

## Install/build steps
- Pull: `docker pull causticlab/hass-configurator-docker`.
- Example compose service (verbatim from the page):
  - image `causticlab/hass-configurator-docker:latest`, `restart: always`
  - ports `3218:3218/tcp`
  - volumes `./data/configurator-config:/config` and `./data/config:/hass-config`
- Local build uses `HC_BUILD_VERSION` build-arg (example `0.4.0`).

## Runtime deps
- None beyond the image.

## Env vars
- The page says environment variables work since version 0.3.3, but the `/hass-config` folder still must be mapped. No names are listed on the page (names come from upstream source; see the github summary).

## Ports
- `3218/tcp`.

## Volumes/paths and persistent data
- `/config`: configurator settings (`settings.conf`).
- `/hass-config`: Home Assistant config folder to edit.
- Git integration: mount SSH keys to `/root/.ssh/id_rsa`, `/root/.ssh/id_rsa.pub`, `/root/.ssh/known_hosts` (read-write for known_hosts), or use an HTTPS URL with a token.

## User/UID & permissions
- Root in the container (the Dockerfile has no USER; the SSH paths are under `/root`).

## Config files and formats
- Settings file must be named `settings.conf` and `basepath` must be set in it (page text).

## Version/release info
- Tags shown: `latest` (single tag listed in the recent tags view). From 0.4.1 the images are multi-arch and tagged by version or `latest`; ARCH-only tags also exist. Last updated "8 months ago" (no exact date shown).
- The page does not use the label `x86_64`; the TrueCharts chart pins `x86_64@sha256:...` (see truecharts summary).

## Arch support
- Linux x32/64 and ARM (Raspberry Pi) per the description; multi-arch from 0.4.1.

## Gotchas
- The page's `latest` tag and "8 months ago" age contrast with the PyPI release of 0.7.0 on 2026-10-18 (see pypi summary). The Docker Hub image may lag upstream.
- The Docker Hub example uses `latest` (floating). ContainerForge should not use the causticlab image; it builds from PyPI.
