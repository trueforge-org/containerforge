# etherpad — implementation plan
> Source: ./draft.md · Target: apps/etherpad/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v3.3.22`, published 2026-11-22 (https://api.github.com/repos/ether/etherpad/releases/latest, via `gh`). Draft says `3.3.20` (stale). Chart image: `ghcr.io/ether/etherpad:3.3.22@sha256:a6c5adbdf315beac5062e01059fd3021f2f790bfaf1669372a72bb300527b323` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/etherpad/values.yaml). |
| Renovate | `datasource=github-releases depName=ether/etherpad versioning=semver` |
| License | Apache-2.0 (GitHub API `license.spdx_id` for ether/etherpad; deb control file `License: Apache-2.0`). |
| Source URL | https://github.com/ether/etherpad (default branch `develop`). The draft's `etherpad-lite` repo link is UNVERIFIED as current. |
| Download (confirmed on the release page) | amd64: `https://github.com/ether/etherpad/releases/download/v3.3.22/etherpad-latest_amd64.deb` sha256 `6cd390d346e8ca255f700f2ec99657b148002eff287262c6a553762d175718fd`. arm64: `https://github.com/ether/etherpad/releases/download/v3.3.22/etherpad-latest_arm64.deb` sha256 `5e5e976e6c7dc630d4a45fc25f4a03a99e6e56f6eda02215e7fed1ee7dc02575`. Versioned names `etherpad_3.3.22-1_{amd64,arm64}.deb` carry the same digests. |
| Checksum source | GitHub release asset digest (API). The amd64 `.deb` was downloaded and its sha256 recomputed locally: it matches. The arm64 `.deb` was not downloaded (UNVERIFIED locally). |
| Package contents (amd64 `.deb`, inspected, not installed) | Control: `Package: etherpad`, `Version: 3.3.22-1`, `Pre-Depends: adduser`, `Depends: nodejs (>= 24), ca-certificates`, `Recommends: libreoffice, curl`. Ships `/opt/etherpad/` (with `bin/node_modules` containing `ep_etherpad-lite`, `log4js`, `tsx`, `ueberdb2`, and 22,842 files in `node_modules`), `/etc/etherpad/`, `/etc/default/etherpad`, `/lib/systemd/system/etherpad.service`, `/usr/share/etherpad/settings.json.dist`. postinst creates `/var/lib/etherpad` and `/var/log/etherpad`, and uses `etherpad` user and `/var/lib/etherpad/etherpad.db` for sqlite. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ether/etherpad/844729c6b9e68d593da9928141e6e2daced53ec9/Dockerfile: `ARG PnpmVersion=12.4.2`; `node:24-alpine` stages (`adminbuild`, `build`, `production`); `EP_UID=5001`, `EP_GID=0`, `EP_DIR=/opt/etherpad-lite`; `USER etherpad`; `EXPOSE 9001`; runs `node` directly. Alpine (musl) base, so `copy-from` is not usable. |
| Port | 9001/http (`settings.json.docker` `port` `${PORT:9001}`; Dockerfile `EXPOSE 9001`). Chart maps 10060 to 9001. |
| Env vars (real, from settings.json.docker and doc/docker.md) | `IP` (default `0.0.0.0`), `PORT` (default `9001`), `DB_TYPE` (default `dirty`), `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`, `DB_CHARSET`, `DB_FILENAME` (default `var/dirty.db`; sqlite example `var/etherpad.sq3`), `DB_COLLECTION`, `DB_URL`, `SOCIAL_META_DESCRIPTION`, `PAD_SHORTCUTS_ENABLED_CMD_SHIFT_C`, `MINIFY`, `SKIN_NAME`. Build args: `TIMEZONE`, `SETTINGS`, `ETHERPAD_PLUGINS`, `INSTALL_SOFFICE`, `EP_UID`, `EP_GID`. |
| Admin and user passwords | The chart sets `ADMIN_PASSWORD` and `USER_PASSWORD` (chart values.yaml, secret `env-secrets`). Whether `settings.json` reads them is UNVERIFIED: no such name was found in the reviewed `settings.json.docker` lines. Admin UI needs an admin password set in settings before it is usable (draft caveat). |
| Data / config paths | `/opt/etherpad-lite/var` (docs/docker.md: needs writable `/tmp` and `/opt/etherpad-lite/var`; chart persists there). Settings come from `EP_DIR/settings.json`. DB file default `var/dirty.db` (relative to EP_DIR). |
| Dependencies | PostgreSQL optional (chart `dependencies.postgresql.enabled: true`, `DB_TYPE: postgres`, `DB_PORT: 5432`). `apps/postgresql` exists. |
| arm64 | arm64 `.deb` published on the same release (see above). Upstream image arm64 not checked (UNVERIFIED). |

## 2. Target layout

- `apps/etherpad/Dockerfile`
- `apps/etherpad/docker-bake.hcl`
- `apps/etherpad/settings.yaml`
- `apps/etherpad/container-test.yaml`
- `apps/etherpad/start.sh` (`exec node` with `settings.json` generated from env)
- `apps/etherpad/defaults/settings.json` only if a seeded settings file is needed on first run (see section 7); otherwise use the one shipped in the `.deb` (`/usr/share/etherpad/settings.json.dist`).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The `.deb` is downloaded in the build stage, so no repo file holds the app code.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage. Reason: the `.deb` is the app, so a plain Ubuntu userland is enough. The `.deb` needs `nodejs (>= 24)` (see section 4 for how to satisfy it). Closest sibling for a Node server on the Ubuntu base: `apps/budge` (node on python-node). If the Node runtime comes from python-node instead, use `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (Node 24 per budge comment, UNVERIFIED for the exact version). Decide after step 1 of section 11.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download the matching `.deb` by arch: `ARCH=$(case ${TARGETARCH} in amd64) echo amd64;; arm64) echo arm64;; esac)`; `curl -fL -o /tmp/etherpad.deb https://github.com/ether/etherpad/releases/download/v${VERSION}/etherpad-latest_${ARCH}.deb`.
3. Verify sha256 against the release digest for the arch. Keep the two digests in the Dockerfile as `ARG`s or a small case table, and fail the build on mismatch (`echo "<sha>  /tmp/etherpad.deb" | sha256sum -c -`). Do not use the `latest` name in the check, use the arch-specific file and digest.
4. Extract without installing (no systemd, no postinst): `dpkg-deb -x /tmp/etherpad.deb /tmp/root`. Keep `dpkg-deb -e` out; the postinst is not needed because the image does its own setup.
5. Node runtime: install Node 24 in the final stage (exact method UNVERIFIED for ubuntu 26.04; `nodesource` is a new vendor URL and needs a checksum, so prefer the base's Node if python-node is used). The `.deb` declares `nodejs (>= 24)`, so do not install the `.deb`'s dependency tree with apt.
6. Final stage `FROM <base>`, `USER root`: `COPY --from=build /tmp/root/opt/etherpad/ /app/etherpad/` (the final stage is a separate image, so the extracted tree must come from the build stage), then `COPY --from=build /tmp/root/usr/share/etherpad/settings.json.dist /app/etherpad/settings.json` (only if not generated by start.sh). `install -D` the Apache LICENSE to `/usr/share/licenses/etherpad/LICENSE`.
7. Move writable state to `/config` through `ENV` only: `ENV NODE_ENV=production ETHERPAD_PRODUCTION=true DB_TYPE=sqlite DB_FILENAME=/config/etherpad.sq3` (the sqlite value needs a driver check, UNVERIFIED for `ueberdb2`). `HOME=/tmp`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 9001
VOLUME /config
WORKDIR /app/etherpad
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "etherpad"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ether/etherpad versioning=semver
  default = "3.3.22"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/ether/etherpad"
}
```

Then the four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. Validate with `docker buildx bake --print`. The Dockerfile `ARG VERSION` must be `3.3.22`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ether/etherpad"
ports:
  - port: 9001
    protocol: tcp
    required: true
env:
  - name: IP
    default: "0.0.0.0"
    required: false
  - name: PORT
    default: "9001"
    required: false
  - name: DB_TYPE
    default: "sqlite"
    required: false
  - name: DB_FILENAME
    default: "/config/etherpad.sq3"
    required: false
  - name: DB_HOST
    default: ""
    required: false
  - name: DB_PORT
    default: ""
    required: false
  - name: DB_NAME
    default: ""
    required: false
  - name: DB_USER
    default: ""
    required: false
  - name: DB_PASS
    default: ""
    required: false
  - name: ADMIN_PASSWORD
    default: ""
    required: false
  - name: USER_PASSWORD
    default: ""
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

Notes: PostgreSQL is optional (draft), so it is under `opt_dependencies` using the `- name:` form of `apps/babybuddy/settings.yaml` and `apps/bookstack/settings.yaml`; `apps/postgresql` exists. `ADMIN_PASSWORD` and `USER_PASSWORD` are listed because the chart passes them, but the settings file must read them for them to count (UNVERIFIED, section 1). Remove them from `env` if not read by `settings.json`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/etherpad
cd /app/etherpad

# seed settings.json only when missing (never overwrite user state)
if [ ! -s /config/settings.json ]; then
  cp /app/etherpad/settings.json /config/settings.json
fi

exec node --require tsx/cjs src/node/server.js -- --settings /config/settings.json
```

Nothing is written to `/app`. The `--settings` argument and the entry file are UNVERIFIED (check `bin/run.sh` in the package). If the server does not support `--settings`, generate `/tmp/etherpad/settings.json` from the env at start and point the server at it. `DB_*` values are applied on every start. Use `exec` so PID 1 gets signals. Confirm the server entry point and the `node` invocation from `/app/etherpad/bin/` (UNVERIFIED exact entry file for 3.3.22). Escape `DB_PASS` and admin values before substitution (start-script rule).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '9001'
http:
- port: '9001'
  path: /
filePaths:
- /app/etherpad/src/node/server.js
- /app/etherpad/settings.json
- /usr/share/licenses/etherpad/LICENSE
```

The test runs without env vars, so the default embedded DB (sqlite) path is what is tested. The PostgreSQL path needs a sidecar and is not tested here; no DB-dependency narrowing applies, because the app starts without a DB. Paths above are the expected layout and are UNVERIFIED until the image is built (adjust them to the real files).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Change |
| --- | --- |
| `/opt/etherpad-lite/var` (`dirty.db`, sessions, `js` minified cache, `installed_plugins.json`) | `/config` via `DB_FILENAME` and a settings path under `/config`; minified assets to `/tmp` (UNVERIFIED which dirs the server writes at runtime). |
| `HOME`, npm and pnpm caches | `/tmp` only. |
| Upstream `USER etherpad` (UID 5001) | `USER apps`. The app files are read-only at runtime. |
| Chart runs as UID 0 and `readOnlyRootFilesystem: false` | Not copied. Target: `--read-only --tmpfs /tmp` with `/config`. Verify in section 11. |
| postinst paths `/var/lib/etherpad`, `/var/log/etherpad`, `/etc/etherpad` | Not used. Not run in the image. |

Draft expectations reconciled: UID 0 in the chart is a chart default, not needed. Read-only rootfs is possible if the `/tmp` and `/config` writes above are correct. Privileged not needed. Extra persistence: only `/config`.

## 10. Risks, caveats and open questions

- Node 24: the `.deb` needs `nodejs >= 24`. The base's Node version is UNVERIFIED. If the base Node is older, install Node 24 with a pinned, checksummed tarball.
- The `.deb` ships `node_modules` for the server, so the image should not run `pnpm install`. The `.deb` is compiled for amd64 and arm64 separately, so both need a build check.
- `ADMIN_PASSWORD` and `USER_PASSWORD` may not be read by `settings.json` (UNVERIFIED). If not, the admin UI has no password setup via env and the chart values are misleading.
- `DB_TYPE=sqlite` and `DB_FILENAME` pointing to `/config` need the `ueberdb2` sqlite driver to be present in the `.deb` (UNVERIFIED).
- Admin UI build is in the `.deb` (the draft mentioned a build cost; the image does not build it).
- The chart image is `3.3.22`, the draft is `3.3.20`. Bump the plan to `3.3.22` (done here).
- Blockers: none found. Not musl-only (the `.deb` is glibc Ubuntu), no GPU, no privileged. `libreoffice` is only a recommended package; leave it out (`--no-install-recommends`) unless the user needs office conversion.

## 11. Build and test steps

```sh
cd apps/etherpad
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name etherpad-probe --read-only --tmpfs /tmp \
  -v etherpad-probe-config:/config etherpad:3.3.22
docker logs -f etherpad-probe
forgetool containers test --image etherpad:3.3.22 --config ./apps/etherpad/container-test.yaml
docker rm -f etherpad-probe; docker volume rm etherpad-probe-config
```

Expected readiness signal: the Etherpad startup banner and `listening` on port 9001 (UNVERIFIED exact string, read it from the first run). Check that `/config` holds the sqlite file after start. Also test with `-p 9001:9001` from the host. Optional: run a PostgreSQL sidecar (`apps/postgresql`) and check `DB_TYPE=postgres` connects (not part of the single-container suite).

## 12. PR checklist

- Branch `feat/add-etherpad`, commit and PR title `feat(etherpad): add new container`, target `main`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` shows the status).
- PR Notes section includes `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Say what is untested: the arm64 `.deb` runtime, the Node 24 choice, PostgreSQL, the admin password variables, `--read-only` startup.
- `docker buildx bake --print` must pass; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
