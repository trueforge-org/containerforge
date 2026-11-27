# Traccar documentation: Docker page and configuration file

Source URL(s) + date:
- https://www.traccar.org/docker/
- https://www.traccar.org/configuration-file/
- https://www.traccar.org/documentation (index only, TOC)
- Fetched 2026-11-27

## Docker page (/docker/)
- Official images on Docker Hub. Recommended tags: `6.17.0`, `6.17`, `6`, `6.17.0-alpine`, `6.17-alpine`, `6-alpine`, `latest`; `-debian` and `-ubuntu` variants also listed.
- Multi-platform: alpine, debian, ubuntu each for linux/amd64 and linux/arm64.
- Example run:
  ```
  docker run --name traccar --hostname traccar --detach --restart unless-stopped \
    --publish 80:8082 \
    --publish 5000-5300:5000-5300 --publish 5000-5300:5000-5300/udp \
    traccar/traccar:latest
  ```
  Docs advise publishing only the protocol ports in use (full range starts a docker-proxy per port).
- Volumes recommended: `/opt/traccar/logs` (rw), `/opt/traccar/traccar.xml` -> `/opt/traccar/conf/traccar.xml` (ro), `/opt/traccar/data` (rw). Create the dirs and config file first.
- Default H2 DB is for testing; production: TimescaleDB/PostgreSQL or MySQL (compose examples linked).

## Configuration file (/configuration-file/)
- Config path on Linux: `/opt/traccar/conf/` (`traccar.xml`).
- Env override: set `CONFIG_USE_ENVIRONMENT_VARIABLES=true`; env values take precedence over XML. Key -> env: dots to underscores, uppercase (e.g. `mail.smtp.fromName` -> `MAIL_SMTP_FROM_NAME`).
- Protocol keys: `[protocol].address` (bind; default all interfaces if unset), `[protocol].port`, `[protocol].ssl`, `[protocol].devices`, `[protocol].interval`.

## Gotchas
- Mount `conf/traccar.xml` read-only per docs; the chart only mounts `/opt/traccar/data`.
- Docs say Booleans default to false when unset.
