# paperless-ngx — implementation plan
> Source: ./draft.md · Target: apps/paperless-ngx/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v3.5.1, published 2026-11-18, not a prerelease. Chart pins `ghcr.io/paperless-ngx/paperless-ngx:3.5.1`. Source: https://api.github.com/repos/paperless-ngx/paperless-ngx/releases/latest (read via `gh api`). |
| Renovate | `datasource=github-releases depName=paperless-ngx/paperless-ngx versioning=semver` for the tarball. UNVERIFIED: renovate config not read; confirm `versioning` against sibling `apps/bazarr`. |
| License | GPL-3.0 (repo license metadata, https://api.github.com/repos/paperless-ngx/paperless-ngx) |
| Source URL | https://github.com/paperless-ngx/paperless-ngx |
| Download | `https://github.com/paperless-ngx/paperless-ngx/releases/download/v3.5.1/paperless-ngx-v3.5.1.tar.xz` (only release asset; the URL resolves via a 302 redirect). Architecture-neutral source tarball. |
| Per-arch | Tarball is arch-neutral. Upstream handles arm64 with `TARGETARCH` (jbig2enc `.deb` choice, s6 arch mapping `amd64`→`x86_64`, `arm64`→`aarch64`). |
| Checksum source | UNVERIFIED: no `.sha256` or checksum asset is published on the release. Compute the SHA-256 of the downloaded tarball, pin it in the Dockerfile, and state in the PR that it is self-computed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/v3.5.1/Dockerfile (read via WebFetch summary, not verbatim). Stages: `compile-frontend` (`node:24-trixie-slim`, pnpm, `ng build --configuration production`), `s6-overlay-base` (uv image, s6-overlay v3.2.2.0 with SHA-256 check), `main-app` (apt packages, `uv pip install --system`, `collectstatic`, `compilemessages`). `ENTRYPOINT ["/init"]`, no `USER` (s6 runs as root and drops to `paperless`, UID/GID 1000), `EXPOSE 8000`, `VOLUME` for data, media, consume, export. |
| Upstream apt packages (runtime) | curl, gosu, tzdata, fonts-liberation, gettext, ghostscript, gnupg, icc-profiles-free, postgresql-client, mariadb-client, tesseract-ocr (eng, deu, fra, ita, spa), unpaper, pngquant, jbig2dec, libxml2, libxslt1.1, qpdf, file, libmagic1, media-types, zlib1g, poppler-utils. |
| Not in upstream list | `imagemagick` is in the draft's inferred list but NOT in the upstream runtime package list. Do not add it without a reason. |
| Env (real, upstream image) | `PNGX_CONTAINERIZED=1`, `PYTHONDONTWRITEBYTECODE=1`, `PYTHONUNBUFFERED=1`, `UV_LINK_MODE=copy`, `S6_*` vars. App config (docs/configuration.md, https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/v3.5.1/docs/configuration.md): `PAPERLESS_DATA_DIR` (default `../data/` relative to `src`), `PAPERLESS_MEDIA_ROOT` (default `../media/`), `PAPERLESS_CONSUMPTION_DIR` (default `../consume/`), `PAPERLESS_EXPORT_DIR` (default not stated in the fetched text), `PAPERLESS_BIND_ADDR` (default `::`), `PAPERLESS_PORT` (default `8000`, docs say do not change in Docker), `PAPERLESS_DBENGINE` (default `sqlite`; `postgresql`, `mariadb`), `PAPERLESS_DBHOST`, `PAPERLESS_DBPORT` (5432/3306), `PAPERLESS_DBNAME`/`DBUSER`/`DBPASS` (defaults `paperless`), `PAPERLESS_REDIS` (default `redis://localhost:6379`; Valkey works), `USERMAP_UID`/`USERMAP_GID` (default 1000). |
| Port | 8000/tcp (EXPOSE, configuration.md). |
| Data paths | Upstream: `/usr/src/paperless/data`, `media`, `consume`, `export` (VOLUME). ContainerForge: remap to `/config` (see section 9). |
| arm64 | Upstream build path supports arm64 via TARGETARCH. UNVERIFIED: manifest list of `ghcr.io/paperless-ngx/paperless-ngx:3.5.1` not queried. |
| Dependencies | `apps/valkey` ✅ and `apps/postgresql` ✅ exist. `gotenberg` ❌ and `tika` ❌ have no app (optional; Office conversion disabled without them). |
| Frontend in tarball | UNVERIFIED: unknown whether `paperless-ngx-v3.5.1.tar.xz` already contains the built frontend (`documents/static/frontend/`). Check the tarball contents first (section 11, step 0). If it does not, build the frontend in a separate node stage. |

## 2. Target layout

- `apps/paperless-ngx/Dockerfile`
- `apps/paperless-ngx/docker-bake.hcl`
- `apps/paperless-ngx/settings.yaml`
- `apps/paperless-ngx/container-test.yaml`
- `apps/paperless-ngx/start.sh` (replaces upstream s6 `/init`; see section 7)
- `apps/paperless-ngx/defaults/` only if a default `paperless.conf`-style file is needed (not planned: all config through env)
- `apps/paperless-ngx/etc/` not needed unless a Celery or Granian config must be shipped

Never `root/`. `DOWNSTREAM_CHANGES.md` not applicable: this app is not a `FROM` base for another container.

## 3. Base image

- Runtime: `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (digest copied from the brief). Fits a Django app on Python with `uv` available. Closest sibling: `apps/bazarr` (Python app, `uv pip install --requirement`, `USER apps`, `COPY --chmod=0755 . /`, `CMD [""]`).
- Frontend build stage (only if the tarball lacks the frontend): `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, used as `AS frontend`, then `COPY --from=frontend`. This keeps Node out of the runtime image. Node version in python-node: UNVERIFIED (upstream uses `node:24`).
- Do not use `ghcr.io/trueforge-org/ubuntu` for the final stage: Python is needed and `python` already provides it.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Pin `VERSION` to `3.5.1` in bake (see section 5).
2. Frontend stage (conditional on section 1 check): `FROM python-node AS frontend`, `USER root`, copy the extracted source, `corepack enable`, `pnpm install --frozen-lockfile` in `src-ui`, then `./node_modules/.bin/ng build --configuration production`. Output goes to `documents/static/frontend/`. Set `ENV HOME=/tmp PNPM_HOME=/tmp/pnpm` so no cache is written to `/config`.
3. Runtime stage, `USER root` for installs only:
   - `apt-get update && apt-get install -y --no-install-recommends <upstream runtime list minus gosu>` (gosu is not needed, `USER apps` replaces the s6 drop). Pin nothing from apt here: the base is not pinned to an upstream apt version, but record the resolved versions in the PR. Remove `/var/lib/apt/lists/*`.
   - jbig2enc: download the `.deb` for `${TARGETARCH}` from the upstream builder release (URL UNVERIFIED: not fetched; confirm exact asset name `jbig2enc_0.30-*_${arch}.deb` on https://github.com/paperless-ngx/builder/releases before pinning). Verify its checksum (UNVERIFIED source) and `dpkg -i`.
   - Extract the tarball to `/app` (`ARG VERSION`-based URL, SHA-256 checked against the value pinned in the Dockerfile, see section 1). Include the license: `/usr/share/licenses/paperless-ngx/LICENSE` (GPL-3.0; the tarball's license file path is UNVERIFIED).
   - Copy the frontend output (step 2) into `/app/documents/static/frontend/`.
   - Install Python deps with `uv pip install --system --requirement <exported requirements>`, where requirements come from the tarball's `uv.lock` via `uv export --no-dev --no-hashes` (mirrors upstream). Set `UV_LINK_MODE=copy`, `UV_CACHE_DIR=/tmp/uv`. Remove `/tmp/*` after.
   - Run `python manage.py collectstatic --no-input` and `compilemessages` with a build-only dummy `PAPERLESS_SECRET_KEY` and `PAPERLESS_DATA_DIR=/tmp/build-data`. Remove the build data afterwards. Do not write to `/app` at runtime.
   - Keep `/app` owned by root and world-readable (`chmod -R 755 /app`).
4. `ENV PNGX_CONTAINERIZED=1 PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 UV_LINK_MODE=copy PAPERLESS_DATA_DIR=/config/data PAPERLESS_MEDIA_ROOT=/config/media PAPERLESS_CONSUMPTION_DIR=/config/consume PAPERLESS_EXPORT_DIR=/config/export PAPERLESS_BIND_ADDR=0.0.0.0 PAPERLESS_PORT=8000` (paths are ContainerForge decisions, see section 9).
5. `COPY --chmod=0755 . /`, `USER apps`.
6. `EXPOSE 8000`, `VOLUME /config`, `CMD ["/start.sh"]`.

Keep the `COPY --from=` for jbig2enc out of the image: it is an apt `.deb`, not a `COPY --from` image.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "paperless-ngx"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=paperless-ngx/paperless-ngx versioning=semver
  default = "3.5.1"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/paperless-ngx/paperless-ngx"
}
```

Use the SPDX id from the upstream LICENSE file, not the GitHub summary. The repository reports `GPL-3.0`; confirm `GPL-3.0-only` vs `GPL-3.0-or-later` by reading the file header before committing. Then the four standard targets and the default group exactly as in `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/paperless-ngx/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/paperless-ngx/paperless-ngx"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: PAPERLESS_SECRET_KEY
    default: ""
    required: true
  - name: PAPERLESS_URL
    default: "http://localhost:8000"
    required: false
  - name: PAPERLESS_TIME_ZONE
    default: "Etc/UTC"
    required: false
  - name: PAPERLESS_OCR_LANGUAGE
    default: "eng"
    required: false
  - name: PAPERLESS_REDIS
    default: "redis://valkey:6379"
    required: false
  - name: PAPERLESS_DBENGINE
    default: "sqlite"
    required: false
  - name: PAPERLESS_DBHOST
    default: ""
    required: false
  - name: PAPERLESS_DBPORT
    default: ""
    required: false
  - name: PAPERLESS_DBNAME
    default: "paperless"
    required: false
  - name: PAPERLESS_DBUSER
    default: "paperless"
    required: false
  - name: PAPERLESS_DBPASS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - valkey
  - postgresql
```

- `PAPERLESS_SECRET_KEY` is `required: true` with an empty default, so `start.sh` must generate and persist one under `/config` on first run (see section 7). The schema rule requires a non-empty default or start.sh handling; start.sh handling is the plan.
- Only include env names the app reads. `PAPERLESS_OCR_LANGUAGE`, `PAPERLESS_URL` and `PAPERLESS_TIME_ZONE` are standard Paperless settings but are NOT in the fetched configuration page (only the data-path, bind, DB, Redis and USERMAP sections were fetched). Mark them UNVERIFIED and check against `docs/configuration.md` before committing, or drop them.
- `PAPERLESS_DBPASS` default is empty (no baked password; upstream default `paperless` is not carried over, the user sets it with postgresql).
- `dependencies: valkey, postgresql` are soft: SQLite works without postgresql, Valkey is needed for the Celery broker. Decide hard vs optional (`opt_dependencies`) with the user; the database-dependent exception in the protocol only applies if the DB is a hard dependency.

## 7. start.sh

Idempotent, runs with empty `/config`, never writes to `/app`:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /config/media /config/consume /config/export

secret_file="/config/data/secret_key"
if [ -z "${PAPERLESS_SECRET_KEY:-}" ]; then
  if [ ! -s "${secret_file}" ]; then
    head -c 48 /dev/urandom | base64 > "${secret_file}"   # seed only when missing
  fi
  export PAPERLESS_SECRET_KEY="$(cat "${secret_file}")"
fi

cd /app/src   # UNVERIFIED: the backend root inside the tarball (src/ or repo root); confirm in section 11 step 0
exec granian --interface wsgi --host 0.0.0.0 --port "${PAPERLESS_PORT:-8000}" paperless.wsgi:application
```

Open points (section 10):
- Upstream runs three processes under s6: web (Granian), Celery worker and the consumer. The plan above runs only the web process. A working Paperless needs the worker for consumption. Options: (a) run `celery -A paperless worker` and the web server in one `start.sh` with a supervisor or background process plus `wait`; (b) split into a second app. Do not ship web-only as "ready".
- `PAPERLESS_BIND_ADDR` default `::` is set to `0.0.0.0` in the Dockerfile (section 4) for IPv4 reachability from other containers.
- Confirm the Granian command and entry module against the tarball (UNVERIFIED: not read; the fetched text only names Granian via `GRANIAN_HOST`/`GRANIAN_PORT`).
- DB passwords (`PAPERLESS_DBPASS`) are read from env on every start (no DB-side setup here: SQLite by default).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
```

- Timeout 180s: first start runs migrations and index creation. Compare with `apps/bazarr` before finalising.
- The test runs with no env vars: `PAPERLESS_SECRET_KEY` is generated by start.sh, so the default path is tested. A user-supplied key path goes in `filePaths` if added.
- UNVERIFIED: the health endpoint. `/` is the safest assumption (returns login or redirect). Do not claim a success endpoint without reading the upstream source.
- Narrowing for the DB dependency is NOT needed with the SQLite default. Do not add a narrowed assertion without the three-criteria check in the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in ContainerForge | Reason |
| --- | --- | --- |
| `/usr/src/paperless/data` | `/config/data` (`PAPERLESS_DATA_DIR`) | Persistent state (SQLite db, index, classifier, secret key). |
| `/usr/src/paperless/media` | `/config/media` (`PAPERLESS_MEDIA_ROOT`) | Persistent documents. |
| `/usr/src/paperless/consume` | `/config/consume` (`PAPERLESS_CONSUMPTION_DIR`) | Drop folder; mount point for the user to populate. |
| `/usr/src/paperless/export` | `/config/export` (`PAPERLESS_EXPORT_DIR`, UNVERIFIED env name) | Export target. |
| `/tmp` (build) | `/tmp` only | Caches (`UV_CACHE_DIR`, `PNPM_HOME`, `HOME=/tmp` at build) never in `/config`. |
| `/run`, `/var/cache/fontconfig` (upstream chmod 1777) | Not needed | s6 and fontconfig are dropped; fontconfig cache is UNVERIFIED for ghostscript/tesseract, check the warnings in the run step. |

- The chart's `runAsUser 0` and `USERMAP_UID`/`USERMAP_GID` remapping are NOT carried over. The container runs as `apps` (`USER apps`). The draft's non-root expectation is a "no" in the chart; ContainerForge makes it "yes" by design.
- `readOnlyRootFilesystem`: the image stays read-only at runtime (writes only to `/config` and `/tmp`). Test with `--read-only --tmpfs /tmp`.
- No `privileged`, no extra capabilities.
- Upstream s6 supervision (`/init`) is removed; the process model is in section 7.

## 10. Risks, caveats and open questions

- Heavy stack: web + Celery worker + consumer. Choose the process model in section 7 before building. Blocker until decided.
- Frontend: the draft says the frontend is built at build time. Confirm from the tarball whether the built frontend is included (section 1). If not, the `python-node` build stage in section 3 is required.
- OCR packages (tesseract, ghostscript, poppler, unpaper) and first-run indexing are CPU and RAM heavy. Set expectations in the PR.
- Gotenberg and Tika: no ContainerForge apps (`❌` in the draft). Office conversion is disabled without them. Not a blocker for the app, a limitation to state.
- `PAPERLESS_DBENGINE`: SQLite default. Postgresql/MariaDB support is present upstream, but the app here will use SQLite unless `dependencies` is hard-wired.
- Secret key handling (section 7): generated on first start and stored in `/config/data/secret_key`. Changing it invalidates sessions. Document.
- Renovate and the frontend node version drift: both need renovate coverage once the frontend build stage exists.
- jbig2enc `.deb`: exact asset name and checksum UNVERIFIED (section 4).
- arm64: upstream claims multi-arch via TARGETARCH, but the image manifest was not checked. Do not claim arm64 is tested.
- Blockers: none confirmed beyond the open process-model decision and the frontend question.

## 11. Build and test steps

Step 0 (before writing the Dockerfile): download `https://github.com/paperless-ngx/paperless-ngx/releases/download/v3.5.1/paperless-ngx-v3.5.1.tar.xz` into a scratch directory outside the repo, record its SHA-256, list its top-level entries and check for the frontend output and the backend root. Record the results in the PR.

From `apps/paperless-ngx/` (protocol order, one app only):

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe run with an empty config volume:
   ```sh
   docker volume create paperless-ngx-probe-config
   docker run --rm -d --name paperless-ngx-probe --read-only --tmpfs /tmp \
     -v paperless-ngx-probe-config:/config paperless-ngx:3.5.1
   docker logs -f paperless-ngx-probe
   ```
   Pass signal: Granian reports it is listening on `0.0.0.0:8000` (exact text UNVERIFIED until the run), process still running, no stack trace. Cleanup: `docker rm -f paperless-ngx-probe; docker volume rm paperless-ngx-probe-config`.
4. `forgetool containers test --image paperless-ngx:3.5.1 --config ./container-test.yaml` (if forgetool is unavailable locally, check the same assertions by hand with curl against `localhost:8000`).

Run via `haiku-triage` for the test command per the repo rules, not in the main shell. Round limit: 10.

## 12. PR checklist

- Branch: `feat/add-paperless-ngx` from `main`.
- Commit: `feat(paperless-ngx): add new container`.
- PR title matches the commit.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- Say what was not tested: arm64 image, Gotenberg/Tika integration, OCR quality, multi-process behaviour under `--read-only` if not run.
- `docker buildx bake --print` result stated.
- Not applicable: DOWNSTREAM_CHANGES.md (not a `FROM` base).
