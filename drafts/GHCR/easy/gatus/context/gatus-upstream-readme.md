# Upstream README: TwiN/gatus (Docker and config path)

Source URL(s):
- https://raw.githubusercontent.com/TwiN/gatus/master/README.md (fetched 2026-11-27; grep of Docker, config and port lines)

## Docker usage
- `docker run -p 8080:8080 --name gatus ghcr.io/twin/gatus:stable` (Docker Hub alternative `twinproduction/gatus:stable`).
- Default config file: `config/config.yaml` (relative to the working dir). Override with `GATUS_CONFIG_PATH`.
- If `GATUS_CONFIG_PATH` points to a directory, all `*.yaml` and `*.yml` files in it (and subdirs) are loaded.
- Environment variables can be used inside config files (`${VAR}` expansion; e.g. `${GATUS_DB_URL}` in chart).

## Port
- Web UI and API on `web.port` (default `8080`).

## Config keys referenced
- `web.port` default 8080.
- `ui.dark-mode` default true; `ui.default-sort-by` `name`; `ui.default-filter-by` `none`.
- `announcements[]` for status-page banners.

## Gotchas
- Config file is the only input; no separate include directive (merging is directory-based).
- Image tag `stable` is published on GHCR and Docker Hub.
