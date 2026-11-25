# homebox — implementation plan
> Source: ./draft.md · Target: apps/homebox/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.27.1, published 2026-10-23T18:27:49Z. Chart `appVersion` and image tag are also 0.27.1 (`ghcr.io/sysadminsmedia/homebox:0.27.1@sha256:9d0b64776c694f018c0ca06faf52105a33ca376024f46bb58e6ab0e2b728bb61`). Source: https://api.github.com/repos/sysadminsmedia/homebox/releases/latest, https://api.github.com/repos/trueforge-org/truecharts/contents/charts/stable/homebox/Chart.yaml |
| Renovate | `datasource=github-releases depName=sysadminsmedia/homebox versioning=semver` (matches `apps/adguardhome-sync` for a Go binary from GitHub releases). Not checked against a renovate config: UNVERIFIED for the exact `versioning` value. |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`, not "or-later"). Source: https://api.github.com/repos/sysadminsmedia/homebox |
| Source URL | https://github.com/sysadminsmedia/homebox |
| Download amd64 | https://github.com/sysadminsmedia/homebox/releases/download/v0.27.1/homebox_Linux_x86_64.tar.gz (asset confirmed) |
| Download arm64 | https://github.com/sysadminsmedia/homebox/releases/download/v0.27.1/homebox_Linux_arm64.tar.gz (asset confirmed) |
| Checksum source | https://github.com/sysadminsmedia/homebox/releases/download/v0.27.1/checksums.txt (asset confirmed). Contents not fetched: UNVERIFIED for the sha256 values. |
| Binary inside tarball | UNVERIFIED: the member name and layout were not listed. Check with `tar tzf` in step 2 before writing the install line. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/sysadminsmedia/homebox/main/Dockerfile (main branch). The draft's pinned commit `1fd28822634a3d5935c002d569559ef46530d4a0` was not fetched. The main Dockerfile is a Go build on `golang:alpine` and a final `alpine:latest` stage, with `ENTRYPOINT ["/app/api"]`, `CMD ["/data/config.yml"]`, `EXPOSE 7745`, `VOLUME ["/data"]`, no `USER`. |
| Real env vars (upstream ENV) | `HBOX_MODE=production`, `HBOX_STORAGE_CONN_STRING=file:///?no_tmp_dir=true`, `HBOX_STORAGE_PREFIX_PATH=data`, `HBOX_DATABASE_SQLITE_PATH=/data/homebox.db?_pragma=busy_timeout=2000&_pragma=journal_mode=WAL&_fk=1&_time_format=sqlite` |
| Real env vars (chart) | `HBOX_MODE`, `HBOX_WEB_PORT` (chart sets it from port 10603), `HBOX_WEB_HOST=0.0.0.0`, `HBOX_AUTH_API_KEY_PEPPER` (secret), `HBOX_LOG_LEVEL=info`, `HBOX_LOG_FORMAT=text`, `HBOX_OPTIONS_TRUST_PROXY`, `HBOX_DATABASE_DRIVER` (`sqlite3` or `postgres`), `HBOX_DATABASE_HOST/PORT/USERNAME/PASSWORD/DATABASE/SSL_MODE`. Source: https://api.github.com/repos/trueforge-org/truecharts/contents/charts/stable/homebox/values.yaml |
| Port | 7745 (upstream `EXPOSE` and healthcheck). The listen port follows `HBOX_WEB_PORT`, so it is configurable. |
| Healthcheck | Upstream: `wget http://localhost:7745/api/v1/status` every 30 s. |
| Data path | `/data` (upstream VOLUME). SQLite file `/data/homebox.db` with WAL sidecars. `/data/config.yml` is the CMD argument. |
| arm64 | Yes, the `Linux_arm64` tarball is published. |

## 2. Target layout

- `apps/homebox/Dockerfile`
- `apps/homebox/docker-bake.hcl`
- `apps/homebox/settings.yaml`
- `apps/homebox/container-test.yaml`
- `apps/homebox/start.sh`

No `defaults/`, `etc/`, `health/` needed: homebox runs on env vars alone (no config file is shipped). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. A Go binary built with `CGO_ENABLED=0` (upstream) needs no libraries; the release binary's linkage is UNVERIFIED (check with `file` in step 2). Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on the ubuntu base, same `ARG VERSION`/`TARGETARCH` pattern).

## 4. Dockerfile

1. `FROM <ubuntu digest above>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Map the arch: `amd64` to `x86_64`, `arm64` to `arm64`, otherwise `exit 1`. The release asset names use `x86_64`, not `amd64`.
3. Download the tarball and `checksums.txt` from `https://github.com/sysadminsmedia/homebox/releases/download/v${VERSION}/`. Run `grep " homebox_Linux_${arch}.tar.gz$" checksums.txt | sha256sum -c -`. The `v` prefix is added in the URL only (the bake `VERSION` is `0.27.1`).
4. Extract into a `/tmp` directory, `install -m 0755` the `homebox` binary to `/app/homebox`, and copy any LICENSE from the tarball to `/usr/share/licenses/homebox/`. If the tarball ships no LICENSE, copy the repo's `LICENSE` from the source (UNVERIFIED that the tarball has one).
5. `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -rf /tmp/*` for the download and extraction.
6. Tail, same as siblings:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 7745
VOLUME /config
```

`COPY --chmod=0755 . /` brings in `start.sh` and the `.dockerignore` allow-list paths.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "homebox"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sysadminsmedia/homebox versioning=semver
  default = "0.27.1"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/sysadminsmedia/homebox"
}
```

Then the default group (`image-local`), `image`, `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`) and `image-all` (amd64 and arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/homebox`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sysadminsmedia/homebox"
ports:
  - port: 7745
    protocol: tcp
    required: true
env:
  - name: HBOX_MODE
    default: "production"
    required: false
  - name: HBOX_WEB_PORT
    default: "7745"
    required: false
  - name: HBOX_WEB_HOST
    default: "0.0.0.0"
    required: false
  - name: HBOX_LOG_LEVEL
    default: "info"
    required: false
  - name: HBOX_LOG_FORMAT
    default: "text"
    required: false
  - name: HBOX_DATABASE_DRIVER
    default: "sqlite3"
    required: false
  - name: HBOX_DATABASE_SQLITE_PATH
    default: "/config/homebox.db?_pragma=busy_timeout=2000&_pragma=journal_mode=WAL&_fk=1&_time_format=sqlite"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

- Only add `HBOX_AUTH_API_KEY_PEPPER` if upstream proves it required for first start (UNVERIFIED: the chart marks it as a secret but the upstream behavior is not confirmed).
- `HBOX_DATABASE_*` for postgres are optional and only read when `HBOX_DATABASE_DRIVER=postgres`. Listing them is optional. Do not invent them.
- Dependencies: `postgresql` is optional (`opt_dependencies`). `apps/postgresql` exists (exists: yes). No hard dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /config

export HBOX_MODE="${HBOX_MODE:-production}"
export HBOX_WEB_PORT="${HBOX_WEB_PORT:-7745}"
export HBOX_WEB_HOST="${HBOX_WEB_HOST:-0.0.0.0}"
export HBOX_DATABASE_SQLITE_PATH="${HBOX_DATABASE_SQLITE_PATH:-/config/homebox.db?_pragma=busy_timeout=2000&_pragma=journal_mode=WAL&_fk=1&_time_format=sqlite}"
export HBOX_STORAGE_CONN_STRING="${HBOX_STORAGE_CONN_STRING:-file:///config?no_tmp_dir=true}"
export HBOX_STORAGE_PREFIX_PATH="${HBOX_STORAGE_PREFIX_PATH:-data}"

exec /app/homebox
```

- Idempotent: nothing is seeded (SQLite creates `homebox.db` on first run). Writes only go to `/config`.
- Server binds `0.0.0.0` (`HBOX_WEB_HOST`), as the protocol requires.
- Open question (UNVERIFIED): upstream CMD passes `/data/config.yml`. Whether the binary starts with no config argument is not confirmed. If it needs one, the script should pass a generated or absent path, not a path outside `/config`.
- `HBOX_STORAGE_CONN_STRING` `file:///config` is an adaptation of the upstream `file:///` (root): confirm in step 3 that uploads land under `/config/data` and not `/`. UNVERIFIED.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '7745'
http:
- port: '7745'
  path: /api/v1/status
filePaths:
- /app/homebox
- /usr/share/licenses/homebox
```

- Every `settings.yaml` port has a probe (7745 tcp and http).
- The http path `/api/v1/status` is the upstream healthcheck path, so it is the right probe. UNVERIFIED that the status endpoint returns 200 with no setup step (the first-run registration is manual).
- `timeoutSeconds` 60 is a starting value; check it against the sibling of the same family.
- Test runs with no env vars, which the SQLite default covers. The postgres path is not tested here (optional dependency, no db in the single-container suite).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (VOLUME; SQLite, config path, storage prefix) | `/config` via `HBOX_DATABASE_SQLITE_PATH` and `HBOX_STORAGE_CONN_STRING` defaults in `start.sh` |
| `/data/config.yml` (CMD argument, read only) | Not shipped. Unresolved, see section 7 |
| SQLite WAL sidecars (`homebox.db-wal`, `-shm`) | Same directory as the db, so `/config` |
| Scratch and temp | `/tmp` (`--tmpfs /tmp` in the protocol run); `HOME=/config` |

Security expectations from the chart (verify, not guarantees): runs as non-root (common runAsUser 568), readOnlyRootFilesystem true, privileged false. The chart's `/data` pvc is replaced by `/config`. The image runs as `apps` through `USER apps`, which is compatible with read-only rootfs because every write goes to `/config` or `/tmp`.

## 10. Risks, caveats and open questions

- Draft caveats (confirmed as inferred in the draft): SQLite is the default; PostgreSQL is optional and needs an external database; the first user is registered through the web UI, so manual setup is expected.
- Upstream Dockerfile on main is alpine-based. The release tarball is a static Go binary (CGO disabled upstream); linkage UNVERIFIED. If it needs glibc or musl symbols, the ubuntu base covers glibc.
- The tarball member layout and whether the binary needs a config file are UNVERIFIED (sections 4 and 7).
- Source-of-truth mismatch: the draft's Dockerfile link pins commit `1fd2882`, which was not fetched. The plan uses the release tarball, not a source build, so the pinned commit does not change the install.
- Blockers: none found. arm64 is available.

## 11. Build and test steps

From `apps/homebox`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name homebox-probe --read-only --tmpfs /tmp \
  -v homebox-probe-config:/config homebox:0.27.1
docker logs -f homebox-probe
forgetool containers test --image homebox:0.27.1 --config ./apps/homebox/container-test.yaml
docker rm -f homebox-probe; docker volume rm homebox-probe-config
```

- Readiness signal to look for in the log: the server listening on `0.0.0.0:7745` (UNVERIFIED exact line; confirm on first run and use that line).
- Also run once with `tar tzf` on the release tarball and `file` on the binary before writing the Dockerfile install line.
- Run arm64 only if an arm64-specific failure appears.

## 12. PR checklist

- Branch `feat/add-homebox`, commit `feat(homebox): add new container`, PR title matches.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: signing is required at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State in the PR what was not tested: arm64 build, postgres path, first-run registration flow, and any UNVERIFIED item above.
- Do not check "Built container locally" unless the step-11 build and run were actually done.
