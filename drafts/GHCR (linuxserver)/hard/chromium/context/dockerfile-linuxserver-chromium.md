# linuxserver/docker-chromium Dockerfile
Source URL: https://raw.githubusercontent.com/linuxserver/docker-chromium/4ec00555069627093b9110daff841d363f9a95f8/Dockerfile (fetched 2026-11-27)

## Build
- Single stage. `FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie`
- ARG BUILD_DATE, VERSION; LABEL build_version, maintainer thelamer
- ENV `TITLE=Chromium`, `PIXELFLUX_WAYLAND=true`
- RUN: curl icon to `/usr/share/selkies/www/icon.png` (from linuxserver docker-templates); apt-get install `chromium chromium-l10n` (--no-install-recommends); autoclean; rm `/config/.cache`, apt lists, /var/tmp, /tmp
- COPY /root /  (s6 service files, from repo root/)
- EXPOSE 3001
- VOLUME /config

## Not in Dockerfile
- No ENTRYPOINT/CMD/HEALTHCHECK here; inherited from baseimage-selkies.
- Web UI port 3001 per EXPOSE; TrueCharts chart uses 8080 (CUSTOM_PORT) -- mismatch to verify in plan.

## Gotchas
- Icon fetched at build time from GitHub raw (network needed at build).
- /config/.cache removed at build; chart mounts emptyDir at /config/.cache.
