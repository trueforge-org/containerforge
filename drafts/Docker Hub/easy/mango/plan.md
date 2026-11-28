# mango — implementation plan
> Source: ./draft.md · Target: apps/mango/ · Difficulty: easy for amd64, blocked for arm64 (see section 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.27.0` (tag `v0.27.0`, 2022-07-31), the latest release. The Docker Hub tags `latest` and `v0.27.0` are the same version. The draft's `:latest` is pinned to this. |
| Renovate | `datasource=github-releases depName=getmango/Mango versioning=semver`. The old `hkalexling/mango` repo name redirects to `getmango/Mango`; the repo was archived (last push 2025-03-23). |
| License | `MIT` (`LICENSE`: "Copyright (c) 2020 Alex Ling"). |
| Source (`SOURCE`) | https://github.com/getmango/Mango |
| amd64 download | `https://github.com/getmango/Mango/releases/download/v0.27.0/mango`, a ~35 MB static-pie ELF, with debug info, not stripped (checked with `file`). |
| arm64 download | None usable. The release only has `mango-arm64v8.o` (an object file) and `mango-arm32v7.o`. Upstream's `Dockerfile.arm64v8` links the `.o` on `arm64v8/ubuntu:18.04` after building crystal, libwebp, stbi, myhtml and duktape from source. The Docker Hub image `hkalexling/mango:v0.27.0` is amd64 only. The draft's "arm64: yes" is not correct. |
| Checksum source | Upstream publishes none. sha256 of the amd64 binary, computed locally on 2026-11-23: `e2a90d91927bfbdbe378189fc8342a1dfc186319ebb8196c58db9cc80c11d375`. Pin it as an ARG and bump it with `VERSION`. |
| Port | `9000/tcp` (web UI and OPDS), default `port: 9000`, `host: 0.0.0.0`. |
| Config | `mango -c <file>` (default `~/.config/mango/config.yml`). If the file is missing, Mango writes a default one. From `src/config.cr` (master and the v0.27.0 notes): every option can also come from an environment variable named as the option in upper case; precedence is config file > environment variable > default. Options: `host`, `port`, `base_url`, `session_secret` (default `mango-session-secret`), `library_path`, `library_cache_path`, `db_path`, `queue_db_path`, `scan_interval_minutes`, `thumbnail_generation_interval_hours`, `log_level`, `upload_path`, `plugin_path`, `download_timeout_seconds`, `cache_enabled`, `cache_size_mbs`, `cache_log_enabled`, `disable_login`, `default_username`, `auth_proxy_header_name`, `plugin_update_interval_hours`. Paths starting with `~` expand with `$HOME`. |
| First start | `src/storage.cr`: with no users it creates `admin` with a random password and logs "Initial user created. You can log in with ..." (password in the log). |
| Upstream Dockerfile reviewed | https://github.com/hkalexling/mango/blob/7a7d9eb/Dockerfile (crystal 1.0.0 alpine `make static`, then `FROM alpine`, `COPY` binary to `/usr/local/bin/mango`, `CMD`); the compose file mounts `/root/mango` and `/root/.config/mango`. |

## 2. Target layout

```
apps/mango/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- `start.sh` maps defaults to env, creates dirs and generates a session secret.
- No `defaults/`, `etc/`, `scripts/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.
- Closest sibling: `apps/adguardhome-sync` (single prebuilt binary on ubuntu).

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```

The binary is statically linked (libarchive, sqlite, yaml and so on), so it needs no extra apt packages and runs on glibc Ubuntu without issue. Not a Go app, so the Go rules do not apply.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION`; `ARG TARGETARCH`; `ARG MANGO_SHA256_AMD64=e2a90d91927bfbdbe378189fc8342a1dfc186319ebb8196c58db9cc80c11d375`.
2. `USER root`; `ENV HOME=/config` (needed for `~` in Mango's paths).
3. `RUN set -eux` step:
   - `test "${TARGETARCH}" = "amd64" || { echo "mango publishes no arm64 binary"; exit 1; }`
   - `curl -fsSLo /app/mango "https://github.com/getmango/Mango/releases/download/v${VERSION}/mango"`
   - `echo "${MANGO_SHA256_AMD64}  /app/mango" | sha256sum -c -`
   - `chmod 0755 /app/mango && chown apps:apps /app/mango`
   - `mkdir -p /usr/share/licenses/mango && curl -fsSLo /usr/share/licenses/mango/LICENSE "https://raw.githubusercontent.com/getmango/Mango/v${VERSION}/LICENSE"`
4. `COPY --chmod=0755 . /`
5. `EXPOSE 9000`, `VOLUME /config`, `VOLUME /data`.
6. Final `USER apps`.

No apt packages. `/data` is the manga library mount point; `/data` already exists in the base and is owned by `apps`.

## 5. docker-bake.hcl

- `APP` = `mango`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=getmango/Mango versioning=semver
  default = "0.27.0"
  ```
- `LICENSE` = `MIT`, `SOURCE` = `https://github.com/getmango/Mango`
- Four standard targets and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`, with one deliberate change: `image-all` uses `platforms = ["linux/amd64"]` only, because there is no arm64 binary. This differs from the standard two-platform layout (precedent: `apps/steamcmd` and `apps/deluge` are amd64 only); confirm with maintainers (section 10).
- `docker buildx bake --print` must pass.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/getmango/Mango"
ports:
  - port: 9000
    protocol: tcp
    required: false
env:
  - name: CONFIG_PATH
    default: "/config/config.yml"
    required: false
  - name: LIBRARY_PATH
    default: "/data"
    required: false
  - name: LOG_LEVEL
    default: "info"
    required: false
  - name: PORT
    default: "9000"
    required: false
  - name: SCAN_INTERVAL_MINUTES
    default: "5"
    required: false
  - name: SESSION_SECRET
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
```

`PORT`, `LOG_LEVEL`, `SCAN_INTERVAL_MINUTES`, `LIBRARY_PATH` and `SESSION_SECRET` are the upper-cased option names Mango reads. `CONFIG_PATH` is read by `start.sh` and passed as `-c`. `SESSION_SECRET` is empty by default and is generated on first start (section 7), so `required: false` is correct. No `dependencies:` (draft: none). Config-file values override env after the first start, which should be stated in the PR.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
CONFIG_PATH="${CONFIG_PATH:-/config/config.yml}"

# Defaults for the first start. Mango reads these env vars only when the
# option is missing from the config file (file > env > default).
export HOST="0.0.0.0"
export PORT="${PORT:-9000}"
export LIBRARY_PATH="${LIBRARY_PATH:-/data}"
export DB_PATH="${DB_PATH:-/config/mango.db}"
export QUEUE_DB_PATH="${QUEUE_DB_PATH:-/config/queue.db}"
export LIBRARY_CACHE_PATH="${LIBRARY_CACHE_PATH:-/config/library.yml.gz}"
export UPLOAD_PATH="${UPLOAD_PATH:-/config/uploads}"
export PLUGIN_PATH="${PLUGIN_PATH:-/config/plugins}"
export TMPDIR=/tmp

mkdir -p /config/uploads /config/plugins "$(dirname "${CONFIG_PATH}")"

# Only used while the config file does not exist yet; afterwards the file wins.
if [ ! -f "${CONFIG_PATH}" ] && [ -z "${SESSION_SECRET:-}" ]; then
  SESSION_SECRET="$(head -c 32 /dev/urandom | base64 | tr -d '/+=\n')"
fi
if [ -n "${SESSION_SECRET:-}" ]; then export SESSION_SECRET; fi

exec /app/mango -c "${CONFIG_PATH}"
```

- Idempotent: the config file is written by Mango itself only when missing, and later starts reuse it.
- Nothing writes to `/app`; the only writes are under `/config` (DBs, uploads, plugins) and `/tmp`. The library at `/data` is only read (plugins and uploads write to `/config`).
- `host` is `0.0.0.0`, so the server is reachable from other containers.
- Caveat: Mango dumps the effective options, including the generated `session_secret`, into `/config/config.yml`. That is how upstream stores it, and it is not placed on the command line.
- An empty `SESSION_SECRET` is never exported, because Mango would treat an empty env value as set and use it as the secret.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '9000'
filePaths:
- /app/mango
- /start.sh
- /usr/share/licenses/mango/LICENSE
```

A `tcp` probe is used because the root URL probably redirects to the login page and I could not verify the status code; switch to `http` with `path: /login` if a local run returns 200 (UNVERIFIED). The first run creates the admin user and the config without any env vars, so no required-env path is hidden. `timeoutSeconds` stays at the default (the library scan runs in the background).

## 9. Rootless and read-only-rootfs adaptations

| Upstream path (chart) | Remap |
|---|---|
| `~/.config/mango/config.yml` (`/root/.config/mango`) | `/config/config.yml` via `-c`. |
| DB: code default in v0.27.0 is `~/mango.db` (`src/config.cr`), not under `~/mango/`; an existing `config.yml` may name another path | `/config/mango.db` via `DB_PATH`. |
| `~/mango/queue.db`, `library.yml.gz`, `uploads`, `plugins` (`/root/mango`) | `/config/...` via env defaults. |
| `~/mango/library` | `/data` (read-mostly mount for the manga). |
| temp files | `TMPDIR=/tmp`. |

Draft expectations: the chart ran UID 0 with writable rootfs and two PVCs under `/root`. Ours runs as UID 568, read-only rootfs, not privileged, with `/config` (state) and `/data` (library). To migrate, the operator moves the DB files (wherever the old `config.yml` points) into `/config`. An old `config.yml` stores expanded `/root/...` paths and wins over env, so its path options must be edited too. The library mount must be readable by UID 568.

## 10. Risks, caveats and open questions

- **arm64 is not possible with the prebuilt assets.** Only an object file is published; linking it needs the aarch64 build of several native libraries. Options: ship amd64 only (planned), or add a build stage that mirrors `Dockerfile.arm64v8` (heavy, Crystal 1.0.0 and old Ubuntu 18.04 libs, unverified). Maintainers need to decide; the plan assumes amd64 only and a bake `image-all` limited to amd64.
- The upstream repository is archived; `v0.27.0` (2022) is final.
- The default session secret is a public constant, so `start.sh` generates one at first start. If an operator sets `SESSION_SECRET` only after the first start, it is ignored because the config file takes precedence.
- The initial admin password appears only in the first start's log (check `docker logs`).
- The binary is not stripped (35 MB); that is upstream's choice. I did not check the behaviour with `/data` mounted read-only (UNVERIFIED), though plugins and uploads write to `/config`.
- Scanning a large library takes a while and runs in the background; `scan_interval_minutes` is set to 5 by default.
- `LIBRARY_PATH` is also the name of a GCC build-time variable; it only matters at runtime for this process, which is not a compiler.

## 11. Build and test steps

```sh
cd apps/mango
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create mango-probe-config
docker run --rm -d --name mango-probe --read-only --tmpfs /tmp \
  -v mango-probe-config:/config mango:0.27.0
docker logs -f mango-probe     # expect the Mango banner, "Initial user created. You can log in with ..." and no crash
curl -sI http://<container-ip>:9000/   # reachable from outside, expect a redirect or 200
docker rm -f mango-probe; docker volume rm mango-probe-config
forgetool containers test --image mango:0.27.0 --config ./apps/mango/container-test.yaml
```

Readiness: the initial user line (first run), the process still running and port 9000 open. Restart once on the same volume to check that the existing config and DB are reused and the password line is not repeated.

## 12. PR checklist

- Branch `feat/add-mango` from `main`; commit and PR title `feat(mango): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` with its sections; check only boxes that apply; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` shows status).
- State in the PR: amd64 only and why, the deliberate `image-all` platform change, and where state lives.
- Untested so far: image not built or run; the HTTP status of `/`; first-run behaviour under a read-only rootfs; library scan with a real library; arm64 (not supported).
