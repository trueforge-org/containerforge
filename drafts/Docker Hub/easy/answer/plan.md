# answer — implementation plan
> Source: ./draft.md · Target: apps/answer/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 2.0.3 (latest GitHub release `v2.0.3`, assets dated 2026-10-08). The draft pins 1.2.0 (`answerdev/answer:1.2.0`), which is stale. The project moved to `apache/answer` (`answerdev/answer` redirects there); the draft's asset names `apache-answer-1.2.0-incubating-linux-*.tar.gz` no longer apply, current names have no `-incubating` and use `-bin-linux-`. |
| Renovate | `datasource=github-releases depName=apache/answer versioning=semver` |
| License | Apache-2.0 (repo LICENSE and NOTICE; Apache top-level project) |
| Source URL | https://github.com/apache/answer |
| amd64 | `https://github.com/apache/answer/releases/download/v2.0.3/apache-answer-2.0.3-bin-linux-amd64.tar.gz` |
| arm64 | `https://github.com/apache/answer/releases/download/v2.0.3/apache-answer-2.0.3-bin-linux-arm64.tar.gz` |
| Checksum | Published: `https://github.com/apache/answer/releases/download/v2.0.3/checksums.txt` (sha256 amd64 `a0196013cb2a8805ca75ebb89b45dfbe784483661f6e0b495f15f04d0277fcfa`, arm64 `294b86f31d8b43651b8ac5c8369942f92f3174acc9b490f546c5166af8a700ef`). I recomputed both from the downloaded tarballs and they match. |
| Tarball contents | `apache-answer-2.0.3-bin-linux-<arch>/` with `answer` (about 61 MB), `LICENSE`, `NOTICE`, `licenses/LICENSE-*.txt`. |
| Binary linkage | No ELF interpreter or `NEEDED` entries in either arch (static, pure-Go sqlite via cznic), so no glibc concern; inspected with `readelf`, not executed. |
| Upstream Dockerfile reviewed | https://github.com/apache/answer/blob/v2.0.3/Dockerfile (golang:1.25-alpine builder, alpine runtime, `VOLUME /data`, `EXPOSE 80`, `ENTRYPOINT /entrypoint.sh`). The draft's link is the 1.2.0-era commit. |
| Upstream entrypoint | `script/entrypoint.sh`: `/usr/bin/answer init`, `/usr/bin/answer upgrade`, `/usr/bin/answer run -C /data/`. |
| Config (v2.0.3 `configs/config.yaml`) | `server.http.addr: 0.0.0.0:80`, sqlite at `/data/sqlite3/answer.db`, cache `/data/cache/cache.db`, `i18n.bundle_dir: /data/i18n`. |
| Env vars (docs https://answer.apache.org/docs/env and source) | Install: `INSTALL_PORT` (80), `AUTO_INSTALL` (**any non-empty value**, including `false`, enables env install; `internal/install/install_from_env.go`). Auto-install (needed when enabled): `DB_TYPE` (`sqlite3`, `mysql`, `postgres`), `LANGUAGE`, `SITE_NAME`, `SITE_URL`, `CONTACT_EMAIL`, `ADMIN_NAME`, `ADMIN_PASSWORD` (8-32 chars), `ADMIN_EMAIL`, `EXTERNAL_CONTENT_DISPLAY` (`always_display` or `ask_before_display`). DB: `DB_FILE` (sqlite path), `DB_HOST`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`. Runtime overrides: `SITE_ADDR`, `SWAGGER_HOST`, `SWAGGER_ADDRESS_PORT`, `LOG_LEVEL` (DEBUG/INFO/WARN/ERROR), `LOG_PATH`; also `SKIP_REPLACE_I18N`. No default documented for the runtime overrides. Clash: the ubuntu base sets `LANGUAGE=en_US:en`, which auto-install would read as the site language. |
| Install behaviour (v2.0.3 source) | `init` returns at once when the config file exists and the DB tables exist. Otherwise it serves the install server on `INSTALL_PORT` (with `/healthz`, and `/` redirecting to `/install`). After `base-info` succeeds (wizard or env) the process calls `os.Exit(0)` after 1 s, so the script continues with `upgrade` and `run`. With `-C /config` the config is `/config/conf/config.yaml`, and the installer rewrites cache, i18n and upload paths to `/config/cache/cache.db`, `/config/i18n` and `/config/uploads`; only the DB path comes from the wizard or `DB_FILE`. |
| Ports | 80 upstream (privileged, so remapped). 8080 chosen via `SITE_ADDR` and `INSTALL_PORT`. |

## 2. Target layout

```
apps/answer/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (the app generates its config in the install step). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: prebuilt static Go binary with embedded UI (draft). It is NOT compiled here, so `go-runtime.instructions.md` build rules do not apply (no Go build stage); the instruction file was still read. Closest sibling: `apps/adguardhome-sync` (tarball with per-arch name, `apps/` layout); `apps/postgresql` exists for the optional DB.

## 4. Dockerfile

1. `FROM`; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Install with checksum verification (checksums.txt is the upstream source):
   ```sh
   V="${VERSION#v}" && F="apache-answer-${V}-bin-linux-${TARGETARCH}.tar.gz" && \
   mkdir -p /app /usr/share/licenses/answer && \
   curl -fsSL -o "/tmp/${F}" "https://github.com/apache/answer/releases/download/v${V}/${F}" && \
   curl -fsSL -o /tmp/checksums.txt "https://github.com/apache/answer/releases/download/v${V}/checksums.txt" && \
   (cd /tmp && grep " ${F}\$" checksums.txt | sha256sum -c -) && \
   tar xzf "/tmp/${F}" -C /tmp && \
   install -m 0755 "/tmp/apache-answer-${V}-bin-linux-${TARGETARCH}/answer" /app/answer && \
   cp -r /tmp/apache-answer-${V}-bin-linux-${TARGETARCH}/LICENSE /tmp/apache-answer-${V}-bin-linux-${TARGETARCH}/NOTICE /tmp/apache-answer-${V}-bin-linux-${TARGETARCH}/licenses /usr/share/licenses/answer/ && \
   chown -R root:root /app && rm -rf /tmp/*
   ```
   `TARGETARCH` values `amd64`/`arm64` match the asset names directly, no mapping needed. Do not copy the whole tarball: only the binary goes to `/app`, license files go to `/usr/share/licenses/answer/`.
3. `ENV INSTALL_PORT=8080 SITE_ADDR=0.0.0.0:8080 LANGUAGE=en_US` (`LANGUAGE` overrides the base's `en_US:en`; defaults must match `start.sh` and `settings.yaml`).
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `WORKDIR /config`, `VOLUME /config`. Final `USER apps`.
5. apt: none (`ca-certificates`, `tzdata` are in the base; draft says none).

## 5. docker-bake.hcl

- `APP` = `answer`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=apache/answer versioning=semver
  default = "2.0.3"
  ```
  (Dockerfile strips `v` with `${VERSION#v}` so either form works; confirm the repo's renovate output for `v` tags.)
- `LICENSE` = `Apache-2.0`; `SOURCE` = `https://github.com/apache/answer`
- 4 targets and `default` group copied from `apps/adguardhome-sync/docker-bake.hcl`; `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/apache/answer"`.
- `ports`: `8080` tcp `required: false`.
- `env` (all from section 1; `required: false`, defaults empty unless stated): `SITE_ADDR` "0.0.0.0:8080", `INSTALL_PORT` "8080", `AUTO_INSTALL` "", `DB_TYPE` "", `DB_FILE` "", `DB_HOST` "", `DB_NAME` "", `DB_USERNAME` "", `DB_PASSWORD` "", `LANGUAGE` "en_US", `SITE_NAME` "", `SITE_URL` "", `CONTACT_EMAIL` "", `ADMIN_NAME` "", `ADMIN_PASSWORD` "", `ADMIN_EMAIL` "", `EXTERNAL_CONTENT_DISPLAY` "", `LOG_LEVEL` "", `LOG_PATH` "", `SWAGGER_HOST` "", `SWAGGER_ADDRESS_PORT` "", `TZ` "Etc/UTC".
- `volumes`: `/config` required true.
- `opt_dependencies`: `postgresql` (exists; SQLite is the default and needs no sidecar, so it is not a hard dependency, contrary to the draft's dependency list). `dependencies:` stays absent.

## 7. start.sh

```bash
#!/usr/bin/env bash
export SITE_ADDR="${SITE_ADDR:-0.0.0.0:8080}"
export INSTALL_PORT="${INSTALL_PORT:-8080}"
mkdir -p /config

mkdir -p /config/sqlite3
# sqlite default for auto-install (any non-empty AUTO_INSTALL enables it)
if [[ -n "${AUTO_INSTALL:-}" && "${DB_TYPE:-sqlite3}" == "sqlite3" ]]; then
  export DB_TYPE="${DB_TYPE:-sqlite3}"
  export DB_FILE="${DB_FILE:-/config/sqlite3/answer.db}"
fi

cd /config
/app/answer init -C /config      # first start: install wizard on INSTALL_PORT, or env auto-install
/app/answer upgrade -C /config   # idempotent migration step (upstream does the same)
exec /app/answer run -C /config
```
Mirrors upstream `entrypoint.sh` with `/config` instead of `/data`. With an empty `/config`, `init` serves the install server on 8080 (so the port probe works); once installation succeeds it exits 0 and the `run` step starts the app (section 1). `ADMIN_PASSWORD` and `DB_PASSWORD` stay in the environment (not echoed, not on the command line). In the wizard, a SQLite user must enter `/config/sqlite3/answer.db`; a path under `/data` is not writable on the read-only rootfs (UNVERIFIED: the wizard's pre-filled default). UNVERIFIED, confirm in a real run: signal handling while `init` is the foreground child of the script and after `exec`, and that nothing else writes to the `/data/...` paths of the sample config. If something does, fix its path in the config; do not assume a runtime symlink is possible.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /healthz
  statusCode: 200
filePaths:
- /app/answer
- /usr/share/licenses/answer/LICENSE
- /usr/share/licenses/answer/NOTICE
```
No env is needed: with empty `/config` the install server listens on 8080 and answers `/healthz` with 200 (`internal/install/install_server.go` at v2.0.3). Not a hard DB dependency (SQLite default), so no narrowing exception; the PostgreSQL path is checked manually.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/data` (config, sqlite, cache, uploads, i18n) | `-C /config`; `/config` is the only data volume. |
| Port 80 | `SITE_ADDR=0.0.0.0:8080`, `INSTALL_PORT=8080`. |
| Timezone via `/etc/localtime` (upstream `TIMEZONE`) | Not written; use `TZ` env (tzdata is in the base). |
| Plugin build and `answer build` | Not used (no plugin rebuild at runtime; the rootfs is read-only). |

Draft expectations: chart is non-root UID 568 with read-only rootfs and `/data` volume; image matches (UID 568, read-only), but the persistence path is `/config`, not `/data` (resolves the draft's conflict; `/data` exists in the ubuntu base but is not used). Not privileged.

## 10. Risks, caveats and open questions

- Draft: first run needs the web wizard (or `AUTO_INSTALL=true` plus all auto-install variables) before the instance is usable.
- Draft: Apache Incubator pin 1.2.0 is stale; this plan targets 2.0.3. Major version jump: existing 1.x data may need `answer upgrade`; test a 1.x to 2.x migration before offering it to chart users (UNVERIFIED).
- UNVERIFIED items in section 7 (wizard default DB path, other `/data` writes, signal handling).
- Do not set `AUTO_INSTALL=false`: it still triggers auto-install.
- `SITE_URL` must match the externally visible URL, and `SITE_ADDR` must be set to match the port in `SITE_URL` after install (per docs).
- Swagger UI is shown by default (`swaggerui.show: true` in the sample config); consider the note in the PR.
- The Docker tag of upstream used Asia/Shanghai as default timezone; here `TZ` defaults to `Etc/UTC`.
- Not blockers: static binaries on both arches, no GPU, no privileged.

## 11. Build and test steps

```sh
cd apps/answer
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name answer-probe --read-only --tmpfs /tmp -v answer-probe-config:/config answer:2.0.3
docker logs -f answer-probe       # expect the install service on :8080, no fatal errors; curl http://<ip>:8080/install
docker rm -f answer-probe
# auto-install, sqlite
docker run --rm -d --name answer-probe --read-only --tmpfs /tmp -v answer-probe-config:/config \
  -e AUTO_INSTALL=true -e DB_TYPE=sqlite3 -e LANGUAGE=en_US -e SITE_NAME=test -e SITE_URL=http://localhost:8080 \
  -e CONTACT_EMAIL=a@example.com -e ADMIN_NAME=admin -e ADMIN_PASSWORD=ChangeMe1234 -e ADMIN_EMAIL=a@example.com \
  -e EXTERNAL_CONTENT_DISPLAY=ask_before_display answer:2.0.3
docker restart answer-probe       # must come back up without re-installing
docker rm -f answer-probe; docker volume rm answer-probe-config
forgetool containers test --image answer:2.0.3 --config ./apps/answer/container-test.yaml
```
Success: container stays running, port 8080 serves, post-install restart works and `/config` holds the config, DB and uploads. Max 10 rounds, fresh `/config` volume per round.

## 12. PR checklist

- Branch `feat/add-answer`; commit and title `feat(answer): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes has `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested unless run: both arches, install wizard, env auto-install, PostgreSQL mode with `apps/postgresql`, upgrade from 1.x data, `forgetool` run.
- Standard checklist: minimal scope, instruction files followed, bake and Dockerfile aligned, rootless and read-only, empty `/config` works, no downstream impact, `bake --print` ran.
