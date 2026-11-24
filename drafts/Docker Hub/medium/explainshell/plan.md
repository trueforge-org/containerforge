# explainshell — implementation plan
> Source: ./draft.md · Target: apps/explainshell/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

The plan targets the same upstream commit as the draft (`827ebe3`, which is still `master` HEAD: `827ebe38da9822a10e89946551e377330a9de35e`). Upstream has no version tags (only the moving release tags `db-latest` and `db-dump`), so `VERSION` is the commit SHA. **Two differences from the draft:** the container listens on **8080**, not 80 (the draft's "port 80" is inferred and wrong; the upstream `Caddyfile` and `EXPOSE` use 8080), and this plan **drops Caddy** and runs gunicorn alone (see section 10).

| Item | Value |
| --- | --- |
| Version | commit `827ebe38da9822a10e89946551e377330a9de35e` (no tags) |
| Renovate | `datasource=git-refs depName=idank/explainshell packageName=https://github.com/idank/explainshell currentDigest=827ebe38da9822a10e89946551e377330a9de35e` (pattern copied from the `KASM_NOVNC_VERSION` variable in this repo) |
| License | GPL-3.0 (`LICENSE` is the GNU GPL v3 text). SPDX: `GPL-3.0-only`. UNVERIFIED whether "or later" applies. |
| Source | https://github.com/idank/explainshell |
| Code download | https://github.com/idank/explainshell/archive/827ebe38da9822a10e89946551e377330a9de35e.tar.gz (source archive, arch independent) |
| Database download | https://github.com/idank/explainshell/releases/download/db-latest/explainshell-2026-06-22-063435.db.zst (newest asset visible on the release page; zstd-compressed SQLite DB) |
| Checksums | The release page shows the asset digest `sha256:9c6286d533f7f52e07b2420555b9cff93cf4754380c379747166e1f20374ebc6` for that asset. `tools/download-latest-db.sh` verifies the same digest against the release metadata. UNVERIFIED: that no newer asset has been uploaded since (the page lists assets in upload order and the tail was read). The code archive has no published checksum. |
| Upstream Dockerfile reviewed | https://github.com/idank/explainshell/blob/827ebe3/prod/docker/Dockerfile (multi-stage: `caddy:2-builder` with xcaddy and a local `botshed` plugin, a `python:3.12-slim` DB-download stage, a runtime stage that copies caddy, installs `requirements.txt`, copies the DB, `ENV DEBUG=false DB_PATH=/opt/webapp/explainshell.db`, `EXPOSE 8080`, `CMD ./start.sh`). `prod/docker/start.sh` and `Caddyfile` were also read. |

Facts from the code at that commit:

- `explainshell/config.py`: `DB_PATH` (env `DB_PATH`), `DEBUG` (env `DEBUG`, **defaults to true**; must be set to `false`), `HOST_IP`, `MANDOC_PATH` (only needed to extract manpages, not to serve).
- `explainshell/web/__init__.py`: `create_app()` factory; reads `GIT_SHA` (optional, for cache ETags) and the sidecar file `<DB_PATH>.sha256` if it exists (otherwise "local").
- `explainshell/store.py`: opens the DB with `file:<path>?mode=ro` when `read_only=True`, so the DB can be on a read-only filesystem as long as SQLite needs no `-wal`/`-shm` files (UNVERIFIED for this DB).
- `requirements.txt` (serving only): `Flask>=3.1.3`, `gunicorn>=25.3.0`, `bashlex>=0.18`, `pydantic>=2.0`, `cmarkgfm>=2025.10.22`, `humanize>=4.0`, `cachetools>=5.0`.
- Upstream serves `/static/*` and `/favicon.ico` through Caddy from `explainshell/web`; Flask's default static folder is that same directory, so Flask can serve them itself (UNVERIFIED, test).
- Upstream gunicorn invocation: `gunicorn -w 2 --threads 4 --timeout 15 --graceful-timeout 5 --max-requests 10000 --max-requests-jitter 2000 --preload -b <addr> "explainshell.web:create_app()"`.

## 2. Target layout

```
apps/explainshell/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

A Python web app installed with pip (the draft's choice; ubuntu alone is listed as an alternative but would mean building Python ourselves). Closest siblings: `apps/bazarr` and `apps/apprise-api` (venv in `/app/venv`, app source in `/app`). Follow `python-runtime.instructions.md`.

## 4. Dockerfile

1. `FROM` from section 3, `ARG VERSION`, `ARG TARGETARCH` (omit if unused), `ARG DB_NAME=explainshell-2026-06-22-063435.db.zst`, `ARG DB_SHA256=9c6286d533f7f52e07b2420555b9cff93cf4754380c379747166e1f20374ebc6`.
2. `USER root`.
3. `ENV HOME=/tmp DEBUG=false DB_PATH=/app/explainshell.db GIT_SHA=${VERSION}` (set `GIT_SHA` after the `ARG`).
4. One `RUN` layer:
   - `apt-get update && apt-get install -y --no-install-recommends zstd` (build-time only, purged afterwards; not pinned to the app version because it is not the shipped software). Add `build-essential libffi-dev` only if `cmarkgfm` has no wheel for Python 3.15 and arm64, and purge them too.
   - `mkdir -p /app/explainshell-src /usr/share/licenses/explainshell`
   - `curl -fsSL -o /tmp/src.tar.gz "https://github.com/idank/explainshell/archive/${VERSION}.tar.gz"` and `tar xzf /tmp/src.tar.gz -C /app/explainshell-src --strip-components=1`
   - `/app/venv/bin/pip install --no-cache-dir -r /app/explainshell-src/requirements.txt`
   - `curl -fsSL -o /tmp/db.zst "https://github.com/idank/explainshell/releases/download/db-latest/${DB_NAME}"`, then `echo "${DB_SHA256}  /tmp/db.zst" | sha256sum -c -`, then `zstd -d /tmp/db.zst -o /app/explainshell.db`, then `sha256sum /app/explainshell.db | cut -d' ' -f1 > /app/explainshell.db.sha256` (the app reads `<DB_PATH>.sha256`; upstream writes the sha of the decompressed DB, UNVERIFIED which hash it expects, the app only logs and folds it into the ETag so any value works)
   - `cp /app/explainshell-src/LICENSE /usr/share/licenses/explainshell/LICENSE`
   - `chown -R apps:apps /app && chmod -R 755 /app`, purge build packages, `rm -rf /var/lib/apt/lists/* /tmp/*`
5. `USER apps`
6. `COPY --chmod=0755 . /`
7. `WORKDIR /app/explainshell-src`, `EXPOSE 8080`, `VOLUME /config`.

The DB is baked into the image at build time. This avoids a first-start download (the draft's concern) but the image is large; check the decompressed size during the build and record it in the PR.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "explainshell"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=idank/explainshell packageName=https://github.com/idank/explainshell currentDigest=827ebe38da9822a10e89946551e377330a9de35e
  default = "827ebe38da9822a10e89946551e377330a9de35e"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/idank/explainshell"
}
```

Plus `docker-metadata-action`, `image` (args `VERSION`, labels), `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64, arm64) and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. The DB arguments (`DB_NAME`, `DB_SHA256`) have defaults in the Dockerfile and must be edited by hand when the DB is refreshed (renovate cannot track them). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/idank/explainshell"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: DB_PATH
    default: "/app/explainshell.db"
    required: false
  - name: DEBUG
    default: "false"
    required: false
  - name: GUNICORN_WORKERS
    default: "2"
    required: false
  - name: GUNICORN_THREADS
    default: "4"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```

`DB_PATH` and `DEBUG` are real upstream variables. `GUNICORN_WORKERS` and `GUNICORN_THREADS` are wrapper variables read by `start.sh`. The app persists nothing, so `/config` is declared but optional (reserved for a user-supplied DB, see section 7). Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export DEBUG="${DEBUG:-false}"
export DB_PATH="${DB_PATH:-/app/explainshell.db}"

# Optional override: a user-supplied DB in /config takes precedence over the baked one.
if [ -s /config/explainshell.db ]; then
  export DB_PATH=/config/explainshell.db
fi

cd /app/explainshell-src
exec /app/venv/bin/gunicorn \
  -w "${GUNICORN_WORKERS:-2}" --threads "${GUNICORN_THREADS:-4}" \
  --timeout 15 --graceful-timeout 5 \
  --max-requests 10000 --max-requests-jitter 2000 --preload \
  -b 0.0.0.0:8080 \
  "explainshell.web:create_app()"
```

- Stateless and idempotent. `/config` can be empty; the baked DB is used. The script never writes to `/app` or `/config`.
- Gunicorn's worker temp files go to `/tmp` (gunicorn's default is the system temp dir; add `--worker-tmp-dir /tmp` for clarity).
- Binds `0.0.0.0:8080`. Upstream binds gunicorn to localhost behind Caddy; here it faces the network directly.
- The final command is `exec gunicorn`. No secrets are involved.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120

http:
- port: '8080'
  path: /

filePaths:
- /app/explainshell.db
- /app/venv/bin/gunicorn
- /usr/share/licenses/explainshell/LICENSE
```

The `http` probe covers port 8080 (the index route `@bp.route("/")` exists). A functional check can be added once confirmed: `path: /explain?cmd=tar+xzvf+a.tar.gz` (the query form is UNVERIFIED; check `views.py`). The test sets no env vars, which works because every variable has a default. No DB-dependency narrowing: the DB is local.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/webapp/explainshell.db` (baked into the upstream image) | `/app/explainshell.db`, read-only, opened `mode=ro`. If SQLite needs `-shm` or `-wal` files, copy the DB to `/tmp` in `start.sh` (UNVERIFIED need). |
| Caddy admin and config storage (`admin off`, `persist_config off`) | Not applicable: Caddy is removed. |
| Gunicorn worker heartbeat files | `/tmp`. |
| Python caches | `HOME=/tmp`, venv at build time, base sets `PYTHONDONTWRITEBYTECODE`. |
| Chart runs as root (`runAsUser 0`) with writable rootfs | Runs as `apps` on a read-only rootfs; port 8080 is unprivileged. The chart's port 80 maps to container 8080. |

The draft expects no extra persistence; none is added.

## 10. Risks, caveats and open questions

- **Caddy dropped on purpose.** Upstream runs Caddy (built with xcaddy and a local `botshed` plugin) plus gunicorn, and needs a supervising shell. The draft suggested a "small supervisor" and the repo has `apps/caddy`. The plan avoids two processes: gunicorn serves directly, giving up Caddy's response buffering (protection against slow clients) and the `botshed` bot-shedding. Put a reverse proxy in front for public exposure. If maintainers want parity, a second plan iteration would use the existing `apps/caddy` binary (UNVERIFIED how it would be made to run `botshed`).
- **Image size and DB freshness.** The DB is baked and pinned by hand (`DB_NAME`, `DB_SHA256`). It cannot be tracked by renovate; a new `db-latest` asset needs a manual bump (the `db-latest` tag is a moving release, assets are replaced).
- `DEBUG` defaults to `true` upstream when unset; the Dockerfile `ENV` and `start.sh` both force `false`, because debug mode registers extra routes.
- `cmarkgfm` and `bashlex` wheels for Python 3.15 and arm64 are UNVERIFIED; a compiler may be needed at build time.
- Upstream floor: `gunicorn>=25.3.0` and `Flask>=3.1.3` are unpinned lower bounds, so the image content drifts between builds. Consider freezing the resolved versions in the PR.
- License (GPL-3.0 only vs later) and the exact content of the `.sha256` sidecar are UNVERIFIED.
- The draft's copy-from image (`spaceinvaderone/explainshell`) is not used (amd64 only, third-party).

## 11. Build and test steps

```sh
cd apps/explainshell
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name explainshell-probe --read-only --tmpfs /tmp \
  -v explainshell-probe-config:/config explainshell:827ebe38da9822a10e89946551e377330a9de35e
docker logs -f explainshell-probe

# from the repo root
forgetool containers test \
  --image explainshell:827ebe38da9822a10e89946551e377330a9de35e \
  --config ./apps/explainshell/container-test.yaml

docker rm -f explainshell-probe; docker volume rm explainshell-probe-config
```

Readiness signal: gunicorn logs `Listening at: http://0.0.0.0:8080` and `Booting worker`, the app logs `db sha256: ...`, no traceback. Then `curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/` returns 200 and a `/explain` request returns a rendered page. Also check `/static/` assets load.

## 12. PR checklist

- Branch `feat/add-explainshell`, commit and PR title `feat(explainshell): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Mention in the PR: Caddy removed, port 8080, DB baked and pinned by hand.
- Pre-completion: bake `--print` exits 0, `ARG VERSION` equals the bake default, final `USER apps`, `COPY --chmod=0755 . /`, start on `--read-only --tmpfs /tmp` with an empty `/config`.
- Untested until run: the whole build (DB download, wheel availability), read-only SQLite behaviour, static file serving from Flask, arm64, and the forgetool run. State this in the PR and leave "Built container locally" unchecked if not done.
