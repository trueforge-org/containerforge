# shaarli — implementation plan
> Source: ./draft.md · Target: apps/shaarli/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.16.11` (tag `v0.16.11`, published 2026-11-23). The draft's `v0.16.10` is stale. Source: https://api.github.com/repos/shaarli/Shaarli/releases/latest. TrueCharts chart pins `v0.16.11@sha256:cbc8595e29a065754e2010c36e7126b1a2f634ec83be3c786602c0783d758e1f` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shaarli/values.yaml). |
| Renovate | `datasource=github-releases depName=shaarli/Shaarli versioning=semver` (VERSION stored without the `v`; Dockerfile prefixes it). |
| License | Zlib/libpng per COPYING (https://raw.githubusercontent.com/shaarli/Shaarli/v0.16.11/COPYING). No LICENSE file in the repo (404). Bake `LICENSE` = `Zlib`. |
| Source URL | https://github.com/shaarli/Shaarli |
| Binary | `shaarli-v0.16.11-full.zip`, https://github.com/shaarli/Shaarli/releases/download/v0.16.11/shaarli-v0.16.11-full.zip. Arch-neutral PHP/JS, same file for amd64 and arm64. Whether the "full" zip already contains `vendor/` and built assets is UNVERIFIED (zip not downloaded); the build must check for them. |
| Checksum source | None published in the release (asset list has only the zip). UNVERIFIED. Plan: compute sha256 on first download and pin it as `ARG SHAARLI_SHA256` in the Dockerfile. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/shaarli/Shaarli/v0.16.11/Dockerfile: four stages (python:3-alpine docs, composer:latest, node:22-alpine with yarn 4.1.0, alpine:3.24.3 runtime). Runtime installs nginx, s6, php84 and extensions (ctype, curl, gd, gettext, iconv, intl, json, ldap, mbstring, openssl, session, xml, simplexml, zlib). `VOLUME /var/www/shaarli/cache`, `VOLUME /var/www/shaarli/data`, `EXPOSE 80`, no `USER` (runs as root). |
| Upstream services | `.docker/services.d/nginx/run` runs `nginx`; `.docker/services.d/php-fpm/run` runs `php-fpm84 -F`. `.docker/nginx.conf`: `listen 80`, `root /var/www/shaarli`, `fastcgi_pass unix:/var/run/php-fpm.sock`. |
| Port | 80/tcp upstream. Chart maps service 8000 to targetPort 80. ContainerForge non-root convention (see `apps/nginx`, `apps/it-tools`) is 8080, so this plan uses 8080 (see section 9). |
| Env vars | None read by the Dockerfile or service scripts. Configuration is done in the web setup wizard. Chart sets none. |
| Data and cache paths | `/var/www/shaarli/data` and `/var/www/shaarli/cache` (Dockerfile VOLUME; chart persistence `data` and `cache`). |
| Arm64 | Yes. GHCR manifest for `ghcr.io/shaarli/shaarli:v0.16.11` lists linux/amd64 and linux/arm64 (https://ghcr.io/v2/shaarli/shaarli/manifests/v0.16.11). |
| Dependencies | None. Flat-file storage, no database. |
| Chart security | `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false` (chart values). Upstream sets no USER. |

## 2. Target layout

- `apps/shaarli/Dockerfile`: build stage fetches and verifies the zip; final stage on ubuntu installs nginx and php-fpm, then copies the app to `/app/shaarli`.
- `apps/shaarli/docker-bake.hcl`
- `apps/shaarli/settings.yaml`
- `apps/shaarli/container-test.yaml`
- `apps/shaarli/start.sh`: creates `/config/data` and `/config/cache` on first run, links them into the app, starts php-fpm, then `exec nginx`.
- `apps/shaarli/defaults/nginx/nginx.conf`: the nginx config, copied to `/etc/nginx/nginx.conf`. Needed because the default config binds port 80 and writes its pid and temp files to root-owned paths. Reason: non-root and read-only rootfs.
- `apps/shaarli/defaults/php-fpm/www.conf`: pool config, listen on `/tmp/php-fpm.sock`, run as `apps`. Reason: upstream pool runs as the nginx user and listens on `/var/run`.

No `root/`, no `etc/`, no `DOWNSTREAM_CHANGES.md` (not used as a FROM base). `defaults/` is allowed by `include/.dockerignore`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build and final stages.

Why: PHP is not a ContainerForge runtime, and `apps/phpmyadmin` and `apps/bookstack` already install `php8.5-*` from apt on this exact base. The `ghcr.io/trueforge-org/nginx` base is an alternative, but nginx alone does not give PHP, so the ubuntu base is simpler. Closest siblings: `apps/phpmyadmin` (php8.5 + web app, php-fpm pool env handling, `/app/www`, `/config` seeding) and `apps/it-tools` (nginx on 8080 with `defaults/default.conf`).

Renovate-compatible: the ubuntu digest is copied as-is from the brief.

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG SHAARLI_SHA256`, `USER root`.
2. `curl -fL -o /tmp/shaarli.zip https://github.com/shaarli/Shaarli/releases/download/v${VERSION}/shaarli-v${VERSION}-full.zip`, then `echo "${SHAARLI_SHA256}  /tmp/shaarli.zip" | sha256sum -c -`. The checksum is pinned on first run because no upstream checksum exists (UNVERIFIED source; recorded in the Dockerfile comment-free ARG only, per repo rules).
3. `unzip -q /tmp/shaarli.zip -d /tmp/src`, then fail the build if `/tmp/src/shaarli/index.php` or `/tmp/src/shaarli/vendor/autoload.php` is missing (confirms the "full" zip assumption).
4. Final stage: `FROM <ubuntu>`, `ARG VERSION`, `USER root`.
5. `apt-get update && apt-get install -y --no-install-recommends nginx php8.5-fpm php8.5-cli php8.5-curl php8.5-gd php8.5-intl php8.5-ldap php8.5-mbstring php8.5-xml php8.5-zip php8.5-gettext` (package list derived from upstream extensions; php8.5-gettext availability and whether ctype/json/iconv/session/openssl/zlib are built into php8.5-common are UNVERIFIED; the build will tell). Clean `/var/lib/apt/lists/*`.
6. Pool and fpm tweaks as in `apps/phpmyadmin`: `clear_env = no`, plus `listen = /tmp/php-fpm.sock` and `user = apps` via `defaults/php-fpm/www.conf` copied to `/etc/php/8.5/fpm/pool.d/www.conf`.
7. `mkdir -p /app/shaarli`, `cp -a /tmp/src/shaarli/. /app/shaarli/`. Remove upstream `data/` and `cache/` directories from the copy, and symlink them: `ln -s /config/data /app/shaarli/data`, `ln -s /config/cache /app/shaarli/cache`. Symlinks are dangling until `start.sh` creates them.
8. License: `install -D /tmp/src/shaarli/COPYING /usr/share/licenses/shaarli/COPYING`.
9. Set `ENV TMPDIR=/tmp`.
10. `chown -R apps:apps /app/shaarli` and `chmod -R 755 /app/shaarli`.
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/shaarli
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "shaarli"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=shaarli/Shaarli versioning=semver
  default = "0.16.11"
}

variable "LICENSE" {
  default = "Zlib"
}

variable "SOURCE" {
  default = "https://github.com/shaarli/Shaarli"
}
```

Then the four standard targets (`image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }`, copied from `apps/bookstack/docker-bake.hcl`. The `image` target passes `args = { VERSION = "${VERSION}" }` and `SHAARLI_SHA256` (set as a bake variable with the pinned value). Validate with `docker buildx bake --print` from `apps/shaarli/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/shaarli/Shaarli"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only `TZ` is read, by the base image. No Shaarli env vars exist upstream, so none are listed (see "Discipline" in the instructions). `dependencies: []` because there is no database.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/cache /tmp/nginx

# Shaarli writes its config and bookmarks under data/ and its template cache under cache/.
# Both are symlinked from /app/shaarli, so nothing is written to /app.

php-fpm8.5 -y /etc/php/8.5/fpm/php-fpm.conf -D

exec nginx -c /etc/nginx/nginx.conf -g "daemon off;"
```

Notes:
- Idempotent: `mkdir -p` only. Existing user state in `/config/data` is never overwritten.
- Empty `/config` works: Shaarli's setup wizard creates `data/config.php` on first visit.
- `php-fpm8.5 -D` daemonizes so `exec nginx` can be PID 1. Risk: a crashed php-fpm is not restarted (see section 10).
- Binds all interfaces through the nginx config (`listen 0.0.0.0:8080` in `defaults/nginx/nginx.conf`, section 2).
- Permissions of `/tmp/nginx` and the socket: all under `/tmp`, writable under `--read-only --tmpfs /tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/shaarli/index.php
- /app/shaarli/vendor/autoload.php
- /usr/share/licenses/shaarli/COPYING
```

Every settings.yaml port (8080) has a tcp probe and an http probe. The first visit redirects to the setup wizard; if `/` does not return 200 in the test, use the path the setup wizard serves (UNVERIFIED which status code the probe sees, to be confirmed in the run). No env-gated code paths exist, so `filePaths` only checks presence.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/www/shaarli/data` (config, bookmarks, user data; Dockerfile VOLUME) | `/app/shaarli/data` symlink to `/config/data` |
| `/var/www/shaarli/cache` (template and HTMLPurifier cache; Dockerfile VOLUME) | `/app/shaarli/cache` symlink to `/config/cache` |
| `/var/run/php-fpm.sock` (upstream nginx to fpm socket) | `/tmp/php-fpm.sock` |
| nginx pid, temp and client body paths (upstream defaults under `/var/lib/nginx` and `/run`) | `/tmp/nginx/*` via `defaults/nginx/nginx.conf` |
| nginx access and error logs (upstream symlinked to stdout/stderr) | keep the stdout/stderr symlinks in the nginx config |
| Upstream runs as root (`runAsUser 0`, chart) | `USER apps`; nginx and php-fpm workers run as `apps` |
| Port 80 (upstream) | 8080 (non-root cannot bind 80; matches `apps/nginx` and `apps/it-tools`) |

Chart values (`readOnlyRootFilesystem false`, `runAsUser 0`) are not carried over: the ContainerForge image must run as `apps` with a read-only rootfs.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: manual setup wizard on first visit (no env-based admin), data and cache must be writable by the PHP worker user (now `apps`, enforced by the symlinks to `/config`).
- Draft expected `php84` on Alpine. The Ubuntu replacement is `php8.5` (UNVERIFIED that every extension in the upstream list exists as a php8.5 package on ubuntu 26.04; the build will confirm).
- Two processes (nginx and php-fpm) without a supervisor. If php-fpm dies, nginx returns 502 and the container keeps running. Open question: accept this, or add a small supervisor (s6 as upstream does) as a separate, reviewed change.
- Checksum: no upstream checksum. Pinned value is only as good as the first download (trust-on-first-use). Documented in the bake file comment only if the repo allows it; otherwise in the PR text.
- Whether the "full" zip includes `vendor/` and built frontend assets is UNVERIFIED until downloaded. If it does not, the Dockerfile must run `composer install --no-dev` and `yarn build` (upstream stages 2 and 3), which adds build tools. Blocker if needed.
- arm64: manifest exists upstream, but this plan builds the same zip for both arches, so no arm64-specific blocker is expected (UNVERIFIED until built).
- Not a blocker: no musl-only dependency, no GPU, no privileged mode.

## 11. Build and test steps

From `apps/shaarli/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe with an empty config volume:
   ```sh
   docker volume create shaarli-probe-config
   docker run --rm -d --name shaarli-probe --read-only --tmpfs /tmp \
     -v shaarli-probe-config:/config shaarli:0.16.11
   docker logs -f shaarli-probe
   ```
   Expected readiness signal: nginx log line about start with no `emerg` or `crit` lines, and `curl -sI http://localhost:8080/` returns a 200 or 302. Clean up with `docker rm -f shaarli-probe; docker volume rm shaarli-probe-config`.
4. `forgetool containers test --image shaarli:0.16.11 --config ./apps/shaarli/container-test.yaml`
5. Repeat step 3 once with the volume kept to confirm a restart does not overwrite `/config/data`.

## 12. PR checklist

- Branch `feat/add-shaarli`, commit `feat(shaarli): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only what was done.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what was not tested: arm64 build and run if not run locally; the checksum trust-on-first-use; the php8.5 extension list.
- Do not check "Built container locally" unless the build and the probe in section 11 actually ran.
- `DOWNSTREAM_CHANGES.md`: not needed (no downstream FROM use).
