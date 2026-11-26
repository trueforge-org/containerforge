# ofsm/ofsm (Docker Hub, "Open Factorio Server Manager")

Source URL(s) + fetch date:
- https://hub.docker.com/r/ofsm/ofsm
- Fetched 2026-11-26

## What it is
- Docker image for the Factorio Server Manager web UI. 100K+ pulls, 12 stars. Last update shown inconsistently ("over 2 years ago" / "over 5 years ago").
- Architectures not listed. Tags: only `latest` (52.1 MB).

## Run method
- No docker run command on the page; Docker Compose: `docker-compose up -d` (HTTPS) or `docker-compose -f docker-compose.simple.yaml up -d` (no HTTPS). `docker pull ofsm/ofsm`.
- Access via configured domain or `http://localhost`.

## Env vars (page)
- `ADMIN_USER`: default `admin` (change it).
- `ADMIN_PASS`: default `factorio` (change it).
- `RCON_PASS`: empty by default -> server generates a random password stored in `fsm-data/conf.json`.
- `COOKIE_ENCRYPTION_KEY`: empty by default -> random key generated and saved in `fsm-data/conf.json`.
- `DOMAIN_NAME`: must be set for Let's Encrypt.
- `EMAIL_ADDRESS`: Let's Encrypt only.
- `FACTORIO_VERSION`: default `latest`; pin in compose.

## Volumes/ports
- Not listed explicitly. `fsm-data/conf.json` holds generated settings.

## Other notes
- Factorio version cannot be changed from the UI; to update, save and stop the server in the UI, then `docker-compose restart`.
- Recommends keeping the UI behind a VPN or internal network.
