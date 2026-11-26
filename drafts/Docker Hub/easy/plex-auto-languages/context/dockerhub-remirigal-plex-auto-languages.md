# remirigal/plex-auto-languages (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/remirigal/plex-auto-languages (fetched 2026-11-26)

**What it is**
- "Automated language selection for Plex TV Shows !" Language tracked per show and per user (managed and shared users included).

**Version/release info**
- Only tag: `latest` (digest begins `sha256:54bd9cf5d...`, size 31.2 MB). The Hub page shows the repo updated "12 months ago" and the tag "over 3 years ago".
- Chart pins `latest@sha256:54bd9cf5d399514b8ed3052ce1d01a14375825a429653cb06da129685740889e`, same digest prefix as the Hub page. `latest` is therefore not the v1.2.3 release (plan.md: built from master).

**Install/run**
- `docker pull remirigal/plex-auto-languages`
- Compose: image `remirigal/plex-auto-languages:latest`, env `PLEX_URL=http://plex:32400`, `PLEX_TOKEN=...`, `TZ=Europe/Paris`, volume `./config:/config`.
- Alternative: mount a `config.yaml` into `/config`. Kubernetes and bare Python (3.8+, `python3 main.py -c ./config.yaml`) also documented.

**Ports and volumes**
- No ports exposed or published. `/config` holds the optional `config.yaml`.

**Env vars (Hub text, master)**
- `PLEX_URL` (required), `PLEX_TOKEN` (required), `PLEX_TOKEN_FILE` (default `/run/secrets/plex_token`), `TZ`. Any config key via env, e.g. `NOTIFICATIONS_ENABLE`.
- Key defaults listed: `update_level: show`, `update_strategy: all` (or next), `trigger_on_play`/`trigger_on_scan`: true, `trigger_on_activity`: false, `refresh_library_on_scan`: true, `ignore_labels: PAL_IGNORE` (master name), `scheduler.enable: true`, `scheduler.schedule_time: 02:00`, `notifications.enable: false`, `debug: false`.

**Arch support**
- Not stated on the page.

**Gotchas**
- The Hub text uses `ignore_labels` (master); the v1.2.3 release uses `ignore_tags`. The Hub text's `update_strategy` default (`all`) disagrees with v1.2.3 `default.yaml` (`next`).
