# discordgsm — implementation plan
> Source: ./draft.md · Target: apps/discordgsm/ · Difficulty: easy (draft) / easy-medium (verified) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `2.20.1` (GitHub release and tag, published 2026-01-09, no `v` prefix). Same as the draft tag. |
| Renovate | `datasource=github-releases depName=DiscordGSM/GameServerMonitor versioning=semver` |
| License | MIT (`LICENSE` at repo root; GitHub SPDX `MIT`) |
| Source | https://github.com/DiscordGSM/GameServerMonitor |
| Artifact | Interpreted app, no binary. Source tarball `https://github.com/DiscordGSM/GameServerMonitor/archive/refs/tags/2.20.1.tar.gz` (arch independent), plus `pip install -r requirements.txt` (arch-specific wheels from PyPI) |
| Checksum | Upstream publishes none for the source archive. UNVERIFIED: use the git tag as the integrity anchor. `requirements.txt` pins exact versions. |
| Upstream Dockerfile | Reviewed (`DiscordGSM/GameServerMonitor` Dockerfile at the commit the draft links): `python:3.13-alpine`, user `dgsm`, `WORKDIR /usr/src/app`, `PYTHONDONTWRITEBYTECODE=1`, `PYTHONUNBUFFERED=1`, `pip install -r requirements.txt`, `mkdir /usr/src/app/data`, `CMD ["python","main.py"]`. No `EXPOSE`, no `VOLUME`. |
| `requirements.txt` | aiohttp 3.13.5, audioop-lts 0.2.2 (python>=3.13), discord.py 2.7.1, flask[async] 3.1.3, gunicorn 26.0.0, opengsq 3.6.2, psycopg2-binary 2.9.12, pymongo 4.17.0, python-dotenv 1.2.2, typing-extensions 4.15.0, tzdata 2026.2 (+ pywin32 on Windows only) |
| Python | `.python-version` is `3.13`. PyPI has `cp314` wheels but NO `cp315` wheels for psycopg2-binary 2.9.12, aiohttp 3.13.5, pymongo 4.17.0, audioop-lts 0.2.2 (checked 2026-11-23). So use the Python 3.14 base, not 3.15 (same reasoning as `apps/changedetection`). |
| Runtime env vars (from `discordgsm/environment.py`, `discordgsm/database.py`, `discordgsm/main.py`, `discordgsm/service.py`) | `APP_TOKEN` (required), `WHITELIST_GUILDS` (required unless `APP_PUBLIC=true`), `APP_PUBLIC`, `APP_DEBUG`, `APP_ACTIVITY_TYPE` (3), `APP_ACTIVITY_NAME`, `APP_ADVERTISE_TYPE` (0), `APP_SHARD_IDS`, `APP_SHARD_COUNT` (1), `APP_PUBLIC_WEBHOOK_URL`, `TASK_QUERY_SERVER` (60), `TASK_QUERY_SERVER_TIMEOUT` (15), `TASK_QUERY_CHUNK_SIZE` (50), `TASK_EDIT_MESSAGE_TIMEOUT` (3), `DB_CONNECTION` (`sqlite` default; `pgsql`, `mongodb`), `DATABASE_URL`, `COMMAND_QUERY_PUBLIC` (false), `COMMAND_QUERY_COOLDOWN` (5), `WEB_API_ENABLE` (false), `HEROKU_APP_NAME`, `FACTORIO_USERNAME`, `FACTORIO_TOKEN`. Upstream docker-compose also sets `POSTGRES_SSL_MODE` (UNVERIFIED where it is read). |
| Ports | None needed by the bot (it connects out to Discord). Optional Flask web UI/API (`app.py`) is served by `gunicorn --bind 0.0.0.0:8000 app:app` in upstream `docker-compose.yml` and `Procfile`. Upstream Dockerfile has no EXPOSE. |
| Writable paths | `discordgsm/logger.py` writes `<repo>/data/logs/discordgsm.log`; `discordgsm/database.py` writes SQLite `<repo>/data/servers.db` (path is `dirname(discordgsm/)/../data`). So with the source at `/app`, writes go to `/app/data`. Upstream chart persistence: `/app/data`. |
| Startup behavior | `main.py` exits with code 1 when `APP_TOKEN` does not have 3 dot-separated parts. `discordgsm/service.py` (imported by `app.py`/gunicorn) does `os.environ["APP_TOKEN"]` and raises `KeyError` without it. |
| Hard dependency | The draft says PostgreSQL is a hard dependency. Verified: false. `DB_CONNECTION` defaults to `sqlite`, so PostgreSQL (or MongoDB) is optional. |

## 2. Target layout

```
apps/discordgsm/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `scripts/` or `health/` needed. Never `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

```
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232
```

Why: Python bot, needs `/app/venv` from the python base. The brief lists 3.15.2, but the dependency wheels (psycopg2-binary, aiohttp, pymongo, audioop-lts) have no cp315 wheels yet, and eight apps in the repo already use 3.14.8. Add a comment line above `FROM` like `apps/changedetection` ("stay on python 3.14 until all pinned wheels ship cp315"). Closest sibling: `apps/changedetection` (pip into `/app/venv`, source under `/app`), plus `apps/bazarr`. Re-check at implementation time and switch to the 3.15.2 digest from the brief if wheels appeared.

## 4. Dockerfile

1. Comment about 3.14, then `FROM` above. `ARG VERSION`.
2. No extra `ENV` needed: the python base already sets `PYTHONUNBUFFERED`, `PYTHONDONTWRITEBYTECODE` and `PIP_NO_CACHE_DIR` (UNVERIFIED for the 3.14.8 digest, so re-check with `docker inspect`; add them if missing). The ubuntu base sets `HOME=/config`; the bot does not write to `$HOME`.
3. `USER root`. No apt packages needed (all dependencies ship manylinux wheels; `curl`, `tar` are in the ubuntu base). Check at build time: if a wheel is missing and pip falls back to a source build, add `build-essential libpq-dev` in a purge-after step as `apps/bazarr` does.
4. One `RUN`:
   - `curl -fsSL -o /tmp/discordgsm.tar.gz "https://github.com/DiscordGSM/GameServerMonitor/archive/refs/tags/${VERSION}.tar.gz"`
   - `tar xzf /tmp/discordgsm.tar.gz -C /app --strip-components=1` (puts `main.py`, `app.py`, `discordgsm/`, `public/` in `/app`, next to the base's `/app/venv`).
   - `/app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt` (cache stays out of the image; `PIP_NO_CACHE_DIR=1` is already set).
   - Replace the upstream data dir with a symlink to persistent storage: `rm -rf /app/data && ln -s /config/data /app/data`. This is a plain file symlink, not a venv, so the python-runtime "no symlink for /config/venv" rule is not touched.
   - License: `mkdir -p /usr/share/licenses/discordgsm && cp /app/LICENSE /usr/share/licenses/discordgsm/LICENSE` (the app is installed whole, but keeping the license in the standard path costs nothing).
   - `chown -R apps:apps /app && chmod -R 755 /app`, `rm -rf /tmp/* /root/.cache`.
5. `COPY --chmod=0755 . /` then `USER apps` (the base's own `COPY . /` and `/start.sh` are overridden by this app's `start.sh`).
6. No `EXPOSE` (no port needed by default). `VOLUME /config`.

Do not set `PYTHONPATH`; `start.sh` does `cd /app`.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "discordgsm" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=DiscordGSM/GameServerMonitor versioning=semver
  default = "2.20.1"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/DiscordGSM/GameServerMonitor" }
```

Then copy the standard blocks from `apps/bazarr/docker-bake.hcl`: `target "docker-metadata-action" {}`, `group "default" { targets = ["image-local"] }`, `target "image"` (args `VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `target "image-local"` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `target "image-all"` (`linux/amd64`, `linux/arm64`). Write them in the multi-line style of the siblings. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/DiscordGSM/GameServerMonitor"
ports: []   # or omit; the bot needs no inbound port
env:
  - APP_TOKEN            default "" required true   # handled in start.sh: clear error + exit 1
  - WHITELIST_GUILDS     default "" required false  # needed unless APP_PUBLIC=true
  - APP_PUBLIC           default "false"
  - APP_DEBUG            default "false"
  - DB_CONNECTION        default "sqlite"  (sqlite | pgsql | mongodb)
  - DATABASE_URL         default ""
  - TASK_QUERY_SERVER    default "60"
  - TASK_QUERY_SERVER_TIMEOUT default "15"
  - COMMAND_QUERY_PUBLIC default "false"
  - TZ                   default "Etc/UTC"
volumes:
  - path: /config  required: true
dependencies: none
opt_dependencies:
  - postgresql ✅   # only when DB_CONNECTION=pgsql
```

Write it in the real list-of-maps form of `apps/bazarr/settings.yaml` (name/default/required per entry). Optional extras (`APP_ACTIVITY_*`, `APP_ADVERTISE_TYPE`, `APP_SHARD_*`) may be added; each is verified above. Correct the draft: PostgreSQL is optional, so list it under `opt_dependencies`, not `dependencies`. Since `required: true` for `APP_TOKEN` cannot have a meaningful default, `start.sh` handles it (see 7).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# persistent data dir behind the /app/data symlink (sqlite DB + logs)
mkdir -p /config/data/logs

if [ "$(printf '%s' "${APP_TOKEN:-}" | awk -F. '{print NF}')" != "3" ]; then
  echo "ERROR: APP_TOKEN is missing or malformed (expected a Discord bot token). See https://discordgsm.com/guide/how-to-get-a-discord-bot-token" >&2
  exit 1
fi

cd /app
exec /app/venv/bin/python -u /app/main.py
```

Rules applied: idempotent (`mkdir -p` only), no writes to `/app` (symlink target is `/config/data`), no secrets in files or the process list (token only in the environment, not echoed), final `exec`. The check mirrors upstream `main.py` so the message is clear; do not echo the token. No DB seeding or passwords: the bot is a DB client only; `DATABASE_URL` is passed straight through the environment (it may contain special characters, never interpolate it into a command).

## 8. container-test.yaml

The test runs without env vars, and the bot exits at once without a token (and gunicorn also fails on `os.environ["APP_TOKEN"]`). So a TCP/HTTP probe cannot pass and no port is declared; use file and runner checks that do not need the bot to be running:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/main.py
- /app/discordgsm/main.py
- /app/venv/bin/python
- /usr/share/licenses/discordgsm/LICENSE
runners:
- entrypoint: /app/venv/bin/python
  cmd: "-c __import__('discord');__import__('flask');__import__('psycopg2');__import__('pymongo');__import__('opengsq');print('deps'+'-ok')"
  expectedOutput: deps-ok
```

Runner: forgetool splits `cmd` on whitespace (see `apps/python/container-test.yaml`), so the one-liner above is space-free and the expected string is built at runtime. Do not import `discordgsm.service` (needs `APP_TOKEN`). Confirm that `entrypoint` overrides the image start script like in the python sibling. Run the real-token path manually in step 11. Not weakened: nothing existing; this is new, and the reason (token required) is commented in the file.

The DB-dependency narrowing exception does not apply (SQLite works without a DB container).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/usr/src/app/data/servers.db`, `data/logs/discordgsm.log` (resolved to `<repo>/data`) | `/app/data` is a build-time symlink to `/config/data`; `start.sh` creates `/config/data/logs`. |
| Python bytecode | `PYTHONDONTWRITEBYTECODE=1` from the base. |
| pip cache | `PIP_NO_CACHE_DIR=1`, nothing at runtime. |
| `.env` loading (`python-dotenv`) | Reads `/app/.env` if present; not shipped, harmless. |

Draft expectations reconciled: chart runs as UID 0 and writable rootfs. This image runs as `apps` (568), `readOnlyRootFilesystem` works, not privileged. Extra persistence `/app/data` becomes `/config/data`, so users migrating from the chart must move their volume content (document in the PR). No `/data` volume.

## 10. Risks, caveats and open questions

- Needs a Discord bot token and a developer portal app; without `APP_TOKEN` the container exits 1 by design (matches upstream). Alternative: also run gunicorn with a dummy token for tests. Rejected as it would fake readiness.
- No cp315 wheels, so the base is 3.14.8; re-verify before the PR.
- The optional web UI/API on 8000 is not started. If wanted, add `WEB_API_ENABLE` handling and gunicorn in `start.sh` plus a port entry and probe. Open question for the maintainer.
- Bot must reach monitored game servers over UDP/TCP; network policy is the user's concern (draft caveat).
- No checksum for the source tarball (see section 1).
- Chart ran as root; data volume ownership must allow UID 568 on `/config`.

## 11. Build and test steps

```sh
cd apps/discordgsm
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
# negative check (no token): expect the APP_TOKEN error and exit 1
docker run --rm --read-only --tmpfs /tmp -v discordgsm-probe-config:/config discordgsm:2.20.1
# positive check needs a real token (user supplies it): expect "Started Discord Game Server Monitor 2.20.1" then "Logged on as ..."
docker run --rm -d --name discordgsm-probe --read-only --tmpfs /tmp -e APP_TOKEN=... -e WHITELIST_GUILDS=... -v discordgsm-probe-config:/config discordgsm:2.20.1
docker logs -f discordgsm-probe
forgetool containers test --image discordgsm:2.20.1 --config ./apps/discordgsm/container-test.yaml
docker rm -f discordgsm-probe; docker volume rm discordgsm-probe-config
```

Check `/config/data/servers.db` appears and the second start with the same volume keeps it. Empty `/config` must work.

## 12. PR checklist

- Branch `feat/add-discordgsm`; commit `feat(discordgsm): add new container`; PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; check only boxes that apply; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- Honest untested list: the live Discord connection needs a real token (untested unless the user provides one), arm64 build and run, PostgreSQL and MongoDB modes, the web UI on 8000.
- Run the pre-completion checklist: bake print passes, VERSION aligned in Dockerfile and bake, rootless, empty `/config`, no `DOWNSTREAM_CHANGES.md` needed.
