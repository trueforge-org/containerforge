# RemiRigal/Plex-Auto-Languages

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/RemiRigal/Plex-Auto-Languages/v1.2.3/Dockerfile
- https://raw.githubusercontent.com/RemiRigal/Plex-Auto-Languages/v1.2.3/README.md
- https://raw.githubusercontent.com/RemiRigal/Plex-Auto-Languages/v1.2.3/config/default.yaml
- https://raw.githubusercontent.com/RemiRigal/Plex-Auto-Languages/v1.2.3/requirements.txt
- https://api.github.com/repos/RemiRigal/Plex-Auto-Languages/releases/tags/v1.2.3
- Fetched 2026-11-26. The draft's `:latest` image and Dockerfile blob `104ead7...` (master, 2025-11-30) were not fetched; the release tag `v1.2.3` (commit `7c8e9366...`) was read instead, per plan.md.
- `github.com/remirigal/plex-auto-languages` (lowercase, from the draft) is the same repository.

**What it is**
- Python service that sets audio and subtitle language per Plex TV show and per user, based on what was watched. Scheduler runs a deeper pass. Optional Apprise notifications. Also runs an internal health server (plan.md: port 9880). MIT license.

**Install/build steps and build deps**
- Upstream Dockerfile (v1.2.3), verbatim:
  ```
  FROM python:3.8-alpine
  ENV LANG C.UTF-8
  ENV LC_ALL C.UTF-8
  ENV CONTAINERIZED True
  RUN apk add --update curl tini && rm -rf /var/cache/apk/*
  COPY ./requirements.txt /app/requirements.txt
  RUN python3 -m pip install --no-cache-dir -r /app/requirements.txt
  COPY . /app/
  WORKDIR /app
  VOLUME /config
  HEALTHCHECK CMD curl --silent --fail http://localhost:9880/ || exit 1
  ENTRYPOINT ["/sbin/tini", "-s", "python3", "main.py", "-c", "/config/config.yaml"]
  ```
- No EXPOSE, USER or CMD upstream.
- Build deps: none beyond pip. Upstream needs `curl` and `tini` (base already has `curl`; PID 1 handled by base per plan.md).
- Requirements (v1.2.3, all lower bounds only):
  ```
  plexapi>=4.13.2
  websocket-client>=1.5.1
  apprise>=1.2.1
  PyYAML>=6.0
  schedule>=1.1.0
  Flask>=2.2.3
  python-dateutil>=2.8.2
  tqdm>=4.64.1
  requests>=2.28.2
  ```

**Runtime deps**
- Python 3 (upstream tested 3.8+ per README); pip deps above. Reaches Plex over HTTP at `PLEX_URL`.

**Binaries/entrypoint/CLI flags**
- `python3 main.py -c /config/config.yaml` (upstream ENTRYPOINT under tini). Bare install: `python3 main.py -c ./config.yaml`. `-c` file is optional.

**Env vars**
- Any config key can be set by env: path uppercased with `_` (e.g. `PLEX_URL` -> `plex.url`, `NOTIFICATIONS_ENABLE` -> `notifications.enable`). Source is plan.md's reading of `main.py`/config loader (not re-verified in this pass). README lists `PLEX_URL`, `PLEX_TOKEN` (required), `PLEX_TOKEN_FILE` (default `/run/secrets/plex_token`), `TZ`.

| Env var | v1.2.3 default (`config/default.yaml`) | Notes |
| --- | --- | --- |
| `PLEX_URL` | `""` | required, e.g. `http://plex:32400` |
| `PLEX_TOKEN` | `""` | required (or `PLEX_TOKEN_FILE`) |
| `PLEX_TOKEN_FILE` | `/run/secrets/plex_token` | Docker secret path |
| `UPDATE_LEVEL` | `show` | `show` or `season` |
| `UPDATE_STRATEGY` | `next` | README lists `all` as the default (conflict; see Gotchas) |
| `TRIGGER_ON_PLAY` | `true` | |
| `TRIGGER_ON_SCAN` | `true` | |
| `TRIGGER_ON_ACTIVITY` | `false` | Plex web client and Plex for Windows only; more resource use |
| `REFRESH_LIBRARY_ON_SCAN` | `true` | disabling suggested for libraries over 10k episodes |
| `IGNORE_TAGS` | `[PAL_IGNORE]` | list; README example `PAL_IGNORE` |
| `SCHEDULER_ENABLE` | `true` | |
| `SCHEDULER_SCHEDULE_TIME` | `"02:00"` | HH:MM |
| `NOTIFICATIONS_ENABLE` | `false` | Apprise |
| `NOTIFICATIONS_APPRISE_CONFIGS` | `[]` | list |
| `DEBUG` | `false` | large log volume when true |
| `TZ` | - | timezone (README) |

- Config file keys live under `plexautolanguages:` in `default.yaml` (the key is the top-level section; `plex.url`, `scheduler.schedule_time`, etc. nested under it).

**Ports**
- No ports exposed or published (README). Upstream HEALTHCHECK probes `http://localhost:9880/` (health server; plan.md reads it from source).

**Volumes/paths and persistent data**
- `/config` (upstream `VOLUME /config`): holds optional `config.yaml`. README "Volumes: /config". Cache location `/config/cache/<server id>` per plan.md (source not fetched here).

**User/UID & permissions**
- Upstream image has no USER (root).

**Config files and formats**
- YAML `config.yaml` (optional, at `/config/config.yaml`); `config/default.yaml` shipped in the app (verbatim):
  ```yaml
  plexautolanguages:
    update_level: "show"
    update_strategy: "next"
    trigger_on_play: true
    trigger_on_scan: true
    trigger_on_activity: false
    refresh_library_on_scan: true
    ignore_tags:
      - PAL_IGNORE

    plex:
      url: ""
      token: ""

    scheduler:
      enable: true
      schedule_time: "02:00"

    notifications:
      enable: false
      apprise_configs: []

    debug: false
  ```

**Healthcheck/readiness endpoints**
- Upstream HEALTHCHECK: `curl --silent --fail http://localhost:9880/`. Other endpoints (`/health`, `/ready`) per plan.md source reading; not verified here.

**Version/release info and asset naming**
- Release `v1.2.3`, published 2023-08-11T08:31:37Z, not prerelease. One release asset: `README.md` (8,427 bytes). No binary assets. Release body references commit `7c8e936` (PR #85, skip shows by Plex tags).
- Source archive pattern: `https://github.com/RemiRigal/Plex-Auto-Languages/archive/refs/tags/v<version>.tar.gz` (plan.md).

**Arch support**
- Not stated; pure Python (plan.md says arch independent).

**Gotchas**
- README and Docker Hub say `update_strategy` default is `all`; `default.yaml` at v1.2.3 says `"next"`. Source wins for ContainerForge defaults (plan uses `next`).
- Docker Hub (`latest`, master) uses `ignore_labels`; v1.2.3 uses `ignore_tags`. The plan pins v1.2.3 and so uses `IGNORE_TAGS`.
- README gives no warning about testing on a copy (draft caveat is inferred).
- Tracks are set per show, per user (managed and shared users).
- `trigger_on_scan` sets new episodes based on the most recently watched episode, or the first if never watched.
- Plan check: Dockerfile base, requirements, default.yaml values, env var mapping, `/config` volume, health port 9880 (from upstream HEALTHCHECK), and MIT license all match. Release is 2023; master is newer (per plan.md).
