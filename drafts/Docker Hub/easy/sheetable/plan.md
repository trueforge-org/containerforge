# sheetable — implementation plan
> Source: ./draft.md · Target: apps/sheetable/ · Difficulty: easy (but see section 10: frontend and release are stale) · Role: main · Verified on 2026-11-23 (re-checked 2026-11-24)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `0.8.1` (tag `v0.8.1`, released 2023-01-14; the latest and only 0.8.x release, the project looks dormant). Draft tag `v0.8.1` is the same. |
| Renovate | `datasource=github-releases depName=SheetAble/SheetAble versioning=semver` (tag has a `v` prefix; use `extractVersion=^v(?<version>.+)$` so `VERSION` stays `0.8.1`) |
| License | AGPL-3.0 (`LICENSE` at the root of tag `v0.8.1` is the AGPL v3 text; the README says only "AGPL License"). SPDX `AGPL-3.0-only` (UNVERIFIED whether "or later" applies: source file headers were not checked) |
| Source URL | https://github.com/SheetAble/SheetAble/ |
| amd64 download | https://github.com/SheetAble/SheetAble/releases/download/v0.8.1/SheetAble_0.8.1_linux_amd64.tar.gz (HTTP 206 checked) |
| arm64 download | https://github.com/SheetAble/SheetAble/releases/download/v0.8.1/SheetAble_0.8.1_linux_arm64.tar.gz (HTTP 206 checked) |
| Checksum source | `SheetAble_0.8.1_checksums.txt` in the same release (sha256). amd64 `7716b39a5dadee7a963e75943a1376939628c73a99f0bce12d3b35f6c4e66dd5`, arm64 `6863eb5c5593a7a92f03ea5b3dfe7bb206167038943a5c795d715c2af8a3424f`. Fetch the file in the Dockerfile and verify with `sha256sum -c` so it follows `VERSION`. |
| Archive content | UNVERIFIED (tarball not unpacked in this check): one file, `sheetable` (24 MB ELF, dynamically linked glibc, CGO sqlite, built by goreleaser per `backend/.goreleaser.yml`), no LICENSE file. |
| Upstream Dockerfile | https://github.com/SheetAble/SheetAble/blob/v0.8.1/backend/Dockerfile reviewed: `golang:alpine` builder with CGO, `alpine:latest` runtime, `COPY --from=builder /app/main .`, `EXPOSE 8000`, `CMD ["./main"]`, no ENV. Alpine/musl, so we use the release tarball (glibc) instead. |
| Env vars (docs https://sheetable.net/docs/configuration, `.env.sample`, `env:` tags in the binary) | `API_SECRET`, `DB_DRIVER` (`mysql`/`postgres`/`sqlite`), `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`, `PORT` (docs say default 8080), `SERVER_URL`, `DEV`, `CONFIG_PATH`, SMTP: `SMTP_ENABLED`, `SMTP_FROM`, `SMTP_SERVER_ADDR`, `SMTP_HOST_SERVER_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` |
| Ports | 8080/http (docs, `docker run -p 8080:8080`). Draft says 8080 (inferred); the Dockerfile says 8000 but `PORT` decides; we set `PORT=8080` explicitly. |
| Paths | Docs example: `CONFIG_PATH=/app/config/`, volume `/app/config` (uploaded sheets, sqlite `database.db`). SQLite file is `database.db` in the config dir (`.env.sample`). |
| Default login | `admin@admin.com` / `sheetable` (docs) unless `ADMIN_EMAIL` / `ADMIN_PASSWORD` set |

## 2. Target layout

```
apps/sheetable/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `scripts/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: a prebuilt glibc Go/CGO binary only needs libc, which the ubuntu base has. `curl`, `tar`, `ca-certificates`, `tzdata` are already in the base (apps/ubuntu/Dockerfile), so no apt packages. Closest sibling: `apps/adguardhome-sync` (tarball from GitHub releases, `/app`, start.sh with `exec`).

## 4. Dockerfile

1. `FROM` line above, `ARG VERSION`, `ARG TARGETARCH` (values `amd64`/`arm64` match upstream file names, no mapping needed).
2. `USER root` only for the download step.
3. `ENV HOME=/config`. The other defaults live only in `start.sh` (section 7).
4. One RUN:
   ```sh
   base="https://github.com/SheetAble/SheetAble/releases/download/v${VERSION}"
   file="SheetAble_${VERSION}_linux_${TARGETARCH}.tar.gz"
   curl -fsSL -o /tmp/${file} "${base}/${file}"
   curl -fsSL -o /tmp/checksums.txt "${base}/SheetAble_${VERSION}_checksums.txt"
   (cd /tmp && grep " ${file}\$" checksums.txt | sha256sum -c -)
   tar xzf /tmp/${file} -C /app sheetable
   mkdir -p /usr/share/licenses/sheetable
   curl -fsSL -o /usr/share/licenses/sheetable/LICENSE https://raw.githubusercontent.com/SheetAble/SheetAble/v${VERSION}/LICENSE
   chown -R apps:apps /app && chmod -R 755 /app
   rm -rf /tmp/*
   ```
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`. Final instruction sequence ends with `USER apps` (put `COPY` before it only if the sibling does; the sibling copies after `USER apps`, follow that).

## 5. docker-bake.hcl

Copy `apps/adguardhome-sync/docker-bake.hcl` and set:
- `APP = "sheetable"`
- `VERSION`, preceded by `// renovate: datasource=github-releases depName=SheetAble/SheetAble versioning=semver extractVersion=^v(?<version>.+)$`, default `"0.8.1"`
- `LICENSE = "AGPL-3.0-only"` (confirm, see section 1)
- `SOURCE = "https://github.com/SheetAble/SheetAble/"`
- targets `docker-metadata-action`, `image` (args.VERSION, OCI source and licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/sheetable && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/SheetAble/SheetAble/"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - {name: PORT, default: "8080", required: false}
  - {name: CONFIG_PATH, default: "/config/", required: false}
  - {name: DB_DRIVER, default: "sqlite", required: false}
  - {name: DB_HOST, default: "", required: false}
  - {name: DB_PORT, default: "5432", required: false}
  - {name: DB_NAME, default: "", required: false}
  - {name: DB_USER, default: "", required: false}
  - {name: DB_PASSWORD, default: "", required: false}
  - {name: API_SECRET, default: "", required: false}   # generated by start.sh and kept in /config when empty
  - {name: ADMIN_EMAIL, default: "admin@admin.com", required: false}
  - {name: ADMIN_PASSWORD, default: "sheetable", required: false}
  - {name: SERVER_URL, default: "", required: false}
  - {name: DEV, default: "", required: false}
  - {name: SMTP_ENABLED, default: "0", required: false}
  - {name: SMTP_FROM, default: "", required: false}
  - {name: SMTP_SERVER_ADDR, default: "", required: false}
  - {name: SMTP_HOST_SERVER_PORT, default: "", required: false}
  - {name: SMTP_USERNAME, default: "", required: false}
  - {name: SMTP_PASSWORD, default: "", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql   # ✅ apps/postgresql exists
```
Write env entries in the multi-line form used by siblings. The draft calls PostgreSQL a hard dependency, but docs and `.env.sample` support `DB_DRIVER=sqlite`, so it is optional; use `opt_dependencies`. `DEV` and the `SMTP_*` entries are listed because the app reads them (`api/config/config.go`); all are optional.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
export PORT="${PORT:-8080}"
export CONFIG_PATH="${CONFIG_PATH:-/config/}"
export DB_DRIVER="${DB_DRIVER:-sqlite}"
export DB_PORT="${DB_PORT:-5432}"   # matches settings.yaml; the app has no port default; set 3306 for mysql
mkdir -p "${CONFIG_PATH}"
# API_SECRET: persist a generated one so JWTs survive restarts
if [ -z "${API_SECRET:-}" ]; then
  [ -s /config/.api_secret ] || (umask 077; head -c 32 /dev/urandom | base64 > /config/.api_secret)
  API_SECRET="$(cat /config/.api_secret)"
fi
export API_SECRET
cd /config
exec /app/sheetable
```
Idempotent, writes only to `/config`, no cache needed. The app binds `0.0.0.0:<PORT>` (`backend/api/server.go`); still confirm from outside the container. Without `API_SECRET` the app falls back to the public value `sheetable` (`api/config/config.go`), so the generated secret is required, not cosmetic. The seeder creates the admin user on every start and only logs `User already exists` if the email is taken (`api/seed/seeder.go`), so changing `ADMIN_PASSWORD` later has no effect; changing `ADMIN_EMAIL` tries to add another user. Document both. The app also reads a `.env` file from its working directory (`/config`); environment variables override it. Keep secrets out of logs and the process list (env only, no flags). The Postgres DSN is built unquoted with `sslmode=disable`, so a `DB_PASSWORD` with spaces or quotes breaks it (upstream limitation).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
filePaths:
- /app/sheetable
```
Runs with no env vars, so the SQLite default path is what is tested. The frontend is embedded in the binary (section 10), so also add an `http` probe on `/health` (returns `{"status":"OK"}`, `api/controllers/routes.go`):

```yaml
http:
- port: '8080'
  path: /health
```
 Pick `timeoutSeconds` from `apps/adguardhome-sync` (default) or 120 if the sqlite migration is slow. DB-narrowing exception does not apply (sqlite works standalone).

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes sheets, thumbnails and `database.db` to `CONFIG_PATH` (code default `./config/`, relative to the working directory). Remapped to `/config` through `CONFIG_PATH=/config/` and `WORKDIR /config`.
- Binary in `/app` is read-only and owned by `apps` (UID 568), matching the draft's common default 568, readOnlyRootFilesystem true.
- Draft extra persistence `/app/config` is replaced by `/config`; document the move in the PR notes (existing TrueCharts users must remount).
- Uploads, thumbnails and composer data go under `CONFIG_PATH` (`sheets/...`, `api/controllers/uploader.go`). Large multipart uploads are buffered by Go in `/tmp`.

## 10. Risks, caveats and open questions

- Draft caveat: needs PostgreSQL. Correction: SQLite also supported; Postgres via `DB_DRIVER=postgres` with `postgresql` from this repo. The postgres database must exist; this repo's `postgresql` image creates `POSTGRES_DB`.
- **UI:** the React build is embedded in the Go source with go.rice (`backend/api/controllers/rice-box.go` lists `index.html` and `static/...`; `routes.go` serves it), so no Node build stage is needed. UNVERIFIED: that the release binary's UI works; request `/` after the first build. How current the embedded UI is relative to `frontend/` was not checked.
- **Blocker, needs a maintainer decision (privacy):** after every upload the app POSTs the user's PDF to the hardcoded third-party URL `https://pdf2png.sheetable.net/createthumbnail` with TLS certificate verification disabled (`InsecureSkipVerify: true`, `api/utils/pdfToImage.go`, called from `uploader.go`). No env var changes or disables it. The draft's note that `pdf2png` is not needed misses this. A network error panics the request (Gin recovery returns an error although the sheet was already saved). Options: ship with a clear warning, patch the source (needs a source build, no longer `easy`), or do not ship. Composer lookups also call `https://api.openopus.org`.
- Stale upstream: last release 2023-01-14, Go 1.19 base. Flag security age in the PR.
- Default admin credentials `admin@admin.com` / `sheetable`: warn in docs; do not make `ADMIN_PASSWORD` required.
- Docs port default 8080 vs Dockerfile `EXPOSE 8000`: we pin `PORT=8080`.
- No arm64 blocker: release publishes `linux_arm64` (glibc).

## 11. Build and test steps

```sh
cd apps/sheetable
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create sheetable-probe-config
docker run --rm -d --name sheetable-probe --read-only --tmpfs /tmp \
  -v sheetable-probe-config:/config sheetable:0.8.1
docker logs -f sheetable-probe
forgetool containers test --image sheetable:0.8.1 --config ./apps/sheetable/container-test.yaml
docker rm -f sheetable-probe; docker volume rm sheetable-probe-config
```
Expected readiness signal: the app's own lines (`Connected to sqlite database /config/database.db...` and `Listening to port 0.0.0.0:8080`) and port 8080 open; no fatal sqlite or permission errors. Also run once with `DB_DRIVER=postgres` against `apps/postgresql` (not covered by the automatic test) and curl from another container.

## 12. PR checklist

- Branch `feat/add-sheetable`, commit and PR title `feat(sheetable): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Only tick boxes that apply. Say honestly what is untested unless run: arm64 build, Postgres mode, the embedded UI, email (SMTP), thumbnails. State the third-party PDF upload (section 10) in the PR Notes.
- Pre-completion: bake print passes, VERSION aligned in Dockerfile ARG and bake, empty `/config` start works, no assertion weakened.
