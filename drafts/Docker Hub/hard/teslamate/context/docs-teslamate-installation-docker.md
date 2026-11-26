# TeslaMate docs: Docker installation

Source URL: https://docs.teslamate.org/docs/installation/docker (fetched 2026-11-26)

## Compose services
| Service | Image | Ports | Volumes |
| --- | --- | --- | --- |
| teslamate | `teslamate/teslamate:latest` | 4000:4000 | `./import:/opt/app/import` |
| database | `postgres:19-trixie` | none | `teslamate-db:/var/lib/postgresql` |
| grafana | `teslamate/grafana:latest` | 3000:3000 | `teslamate-grafana-data:/var/lib/grafana` |
| mosquitto | `eclipse-mosquitto:2` | 1883 commented out | `mosquitto-conf:/mosquitto/config`, `mosquitto-data:/mosquitto/data` |

- All services restart `always`. teslamate has `cap_drop: all`.
- Mosquitto cmd: `mosquitto -c /mosquitto-no-auth.conf` (no auth).
- Named volumes: teslamate-db, teslamate-grafana-data, mosquitto-conf, mosquitto-data.

## Env (sample values from compose; placeholders to replace)
| Service | Var | Sample |
| --- | --- | --- |
| teslamate | ENCRYPTION_KEY | `secretkey` (encrypts Tesla API tokens) |
| teslamate | DATABASE_USER | `teslamate` |
| teslamate | DATABASE_PASS | `password` |
| teslamate | DATABASE_NAME | `teslamate` |
| teslamate | DATABASE_HOST | `database` |
| teslamate | MQTT_HOST | `mosquitto` |
| database | POSTGRES_USER | `teslamate` |
| database | POSTGRES_PASSWORD | `password` |
| database | POSTGRES_DB | `teslamate` |
| grafana | DATABASE_USER / DATABASE_PASS / DATABASE_NAME / DATABASE_HOST | `teslamate` / `password` / `teslamate` / `database` |

- Page does not mark required vs optional beyond the placeholder instructions; points to a separate env-vars page (not fetched).

## Ports
- 4000: TeslaMate web UI. 3000: Grafana. 1883: MQTT (commented out).

## Requirements
- Docker + Compose; always-on host; >=1 GB RAM to install (2 GB recommended).
- Outbound access to tesla.com.
- Architectures: aarch64 and amd64. armv7 not supported.

## Security notes
- Use a secure ENCRYPTION_KEY and one DB password across teslamate, database and grafana.
- Home-network use recommended; remote access via VPN, Cloudflare Tunnel, Tailscale/ZeroTier, or hardened reverse proxy.
- Grafana default login `admin`/`admin`; change it.
- No MQTT auth by default.

## User / UID
- Not documented on page.

## Post-install
1. `docker compose up` (`-d` for background).
2. Generate Tesla access/refresh tokens; enter in web UI on port 4000.
3. Change Grafana admin password (port 3000).
4. Set Web App and Dashboards URLs under Settings -> URLs.
