# Third-party Dockerfile: geek-cookbook/containers apps/zurg @ 69a4d32

Source URL(s) + date: https://raw.githubusercontent.com/geek-cookbook/containers/69a4d32bdba580ccb4e6578ea4e95507d55684b3/apps/zurg/Dockerfile (fetched 2026-11-27)

## Build
- `ARG VERSION`
- Stage `upstream`: `FROM ghcr.io/debridmediamanager/zurg-testing:${VERSION}` (upstream binary image).
- Final: `FROM ghcr.io/geek-cookbook/alpine:3.17.6@sha256:8f7b9f66375192ab91b1315eab93469e14c4e7724196e9bf31267ac164c00b87`.
  - WORKDIR /config.
  - RUN apk add --no-cache python3 libxml2-utils (for plex update script).
  - COPY --from=upstream /app/zurg /app/ ; COPY --from=upstream /app/config.yml /config/.
  - COPY ./apps/zurg/entrypoint.sh /entrypoint.sh (not fetched).
  - CMD ["/entrypoint.sh"]. No USER, EXPOSE, HEALTHCHECK, VOLUME.

## Runtime
- Binary at /app/zurg; default config at /config/config.yml copied from upstream image.

## Gotchas
- Base alpine 3.17.6 (EOL-era pin, unverified status).
- Upstream image name is zurg-testing (old name; README says it is the same build as zurg-public).
- Entrypoint behaviour not verified (file not fetched).
