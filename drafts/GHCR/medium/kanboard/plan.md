# kanboard — implementation plan
> Source: ./draft.md · Target: apps/kanboard/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v1.2.58` (latest stable, published 2026-11-21, https://api.github.com/repos/kanboard/kanboard/releases/tags/v1.2.58). Draft pins `v1.2.57` (published 2026-10-31); use `v1.2.58`, which carries security fixes. |
| Renovate | `datasource=github-releases depName=kanboard/kanboard versioning=semver` (standard form; not confirmed against a fetched page for this app). |
| License | MIT (GitHub SPDX, https://api.github.com/repos/kanboard/kanboard). Upstream Dockerfile also labels `org.opencontainers.image.licenses="MIT"`. |
| Source URL | https://github.com/kanboard/kanboard |
| Download | Source tarball `https://github.com/kanboard/kanboard/archive/refs/tags/${VERSION}.tar.gz`. No release assets exist for this tag. |
| Checksum source | None published by upstream for the tarball. GitHub archive tarballs are tag-addressed; record the SHA-256 of the downloaded tarball in the Dockerfile (`ARCHIVE_SHA256`) and verify on every build. UNVERIFIED: that the archive is byte-stable over time. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/kanboard/kanboard/v1.2.57/Dockerfile (v1.2.57; re-check at v1.2.58 before porting). |
| Upstream base | `FROM alpine:3.24`, single stage. Installs nginx, s6, php85 (php-fpm, phar, curl) plus extensions: json, zlib, xml, dom, ctype, zip, iconv, pdo, pdo_mysql, pdo_sqlite, pdo_pgsql, mbstring, session, bcmath, gd, openssl, sockets, posix, ldap, simplexml, xmlwriter. |
| Upstream runtime | EXPOSE 80 443. VOLUME `/var/www/app/data`, `/var/www/app/plugins`, `/etc/nginx/ssl`. ENTRYPOINT `/usr/local/bin/entrypoint.sh`, CMD []. No USER, no WORKDIR, no ENV. HEALTHCHECK `curl -f http://localhost/healthcheck.php`. |
| Ports | 80/tcp (web UI). 443 is listed by upstream EXPOSE but this plan serves HTTP only; see section 10. |
| Dependency | Optional PostgreSQL (or SQLite by default). The chart lists `postgresql` as a dependency (ContainerForge `apps/postgresql` exists). |
| Env vars | UNVERIFIED: upstream Dockerfile sets none. Config-level env names (e.g. database settings) were not confirmed on a fetched page; do not list any in settings.yaml until confirmed in `config.default.php` or the docs. |
| Default admin | Default `admin`/`admin` on first login (draft; UNVERIFIED against docs). Must be changed on first login. |

## 2. Target layout

- `apps/kanboard/Dockerfile`
- `apps/kanboard/docker-bake.hcl`
- `apps/kanboard/settings.yaml`
- `apps/kanboard/container-test.yaml`
- `apps/kanboard/start.sh`
- `apps/kanboard/etc/nginx/` (nginx site config listening on 8080, reason: non-root cannot bind 80; the file lives under `etc/` so `.dockerignore` allows it)
- `apps/kanboard/defaults/` only if a default `config.php` override is needed (reason: data/config seeding); otherwise none.
- No `root/`, no `DOWNSTREAM_CHANGES.md` (not used as `FROM`).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Fits because PHP 8.5 is in the Ubuntu 26.04 archive and the same family is already used by `apps/bookstack` (`php8.5-*` packages from apt, nginx/php-fpm style). The draft suggested the `nginx` sibling as runtime; the plan does not use it, because PHP must be installed alongside nginx, and the ubuntu base is simpler. Closest sibling: `apps/bookstack` (PHP stack on ubuntu, `/config` for data).

## 4. Dockerfile

1. `ARG VERSION`, `ARG ARCHIVE_SHA256`, `ARG TARGETARCH`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends nginx php8.5-fpm php8.5-cli php8.5-gd php8.5-mbstring php8.5-xml php8.5-zip php8.5-curl php8.5-intl php8.5-sqlite3 php8.5-pgsql php8.5-ldap php8.5-bcmath` (`unzip` is not needed; the ubuntu base has it). Pin the PHP version in the `apt-get` lines to the one in the 26.04 archive; check it matches the `php8.5` used in `apps/bookstack`. Clean `/var/lib/apt/lists/*`.
3. Download and verify:
   `curl -fsSL -o /tmp/kanboard.tar.gz "https://github.com/kanboard/kanboard/archive/refs/tags/${VERSION}.tar.gz"`, then `echo "${ARCHIVE_SHA256}  /tmp/kanboard.tar.gz" | sha256sum -c -`.
4. `mkdir -p /app/www && tar xzf /tmp/kanboard.tar.gz -C /app/www --strip-components=1`.
5. Remove unneeded: `rm -rf /app/www/docker /app/www/tests`.
6. Data path: upstream writes `data/` and `plugins/` inside the app. Symlink them to `/config`, as bookstack does: `rm -rf /app/www/data /app/www/plugins` first (the tarball ships both folders), then `ln -s /config/data /app/www/data` and `ln -s /config/plugins /app/www/plugins` (dangling until start.sh creates the targets). Create `/defaults` before step 7.
7. Config: `cp /app/www/config.default.php /defaults/config.php` (seed only when missing; see section 7).
8. License: `install -D /app/www/LICENSE /usr/share/licenses/kanboard/LICENSE`.
9. Write nothing else to `/app`. `chown -R root:root /app && chmod -R 755 /app`.
10. Clean `/tmp/*`, `$HOME/.cache`, apt lists.
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME ["/config"]
WORKDIR /config
```

Note: `EXPOSE 8080` differs from upstream port 80 because the image runs non-root (section 9). The upstream `443` is not exposed; TLS is out of scope unless the user asks.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kanboard"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kanboard/kanboard versioning=semver
  default = "v1.2.58"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/kanboard/kanboard"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

`ARCHIVE_SHA256` is passed as a build arg, which needs a bake variable too: add `variable "ARCHIVE_SHA256" { default = "<sha256 of v1.2.58 tarball>" }` and set it in `image` args. The sha256 is UNVERIFIED until the tarball is downloaded once. `docker buildx bake --print` after that.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/kanboard/kanboard"
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
opt_dependencies:
  - name: postgresql
```

Only `TZ` is listed: no upstream env names are confirmed (section 1). Add database env vars only after confirming them in the Kanboard docs, with the defaults that `start.sh` uses. `opt_dependencies` lists PostgreSQL because the draft marks it optional and `apps/postgresql` exists.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /config/plugins /config/nginx /tmp/nginx /tmp/php

# seed config.php only when missing
if [[ ! -f /config/config.php ]]; then
    cp /defaults/config.php /config/config.php
fi
ln -sfn /config/config.php /app/www/config.php

# php-fpm with its own config (socket and pid in /tmp), shipped under etc/php/
php-fpm8.5 -D -y /etc/php/8.5/fpm/kanboard-fpm.conf

exec nginx -g 'daemon off;'
```

Notes: `/app/www/config.php` symlink is needed only if Kanboard reads its config from its own directory (UNVERIFIED for this version). Confirm with the first run. `/etc/php/8.5/fpm/kanboard-fpm.conf` is a new file shipped from `etc/php/8.5/fpm/` (add it to section 2) with `listen = /tmp/php/php-fpm.sock`, `pid` and `error_log` under `/tmp`, and the `user`/`group` lines omitted because it runs as `apps`; editing `/etc/php/.../www.conf` with `sed` at runtime is not possible as non-root. UNVERIFIED: the exact config content. nginx's `pid` and temp paths must point at `/tmp` (section 9); the nginx site file in `etc/nginx/` sets these and `listen 8080`. Do not chown `/config` as root; the UID is `apps`.

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
- /app/www/index.php
- /app/www/app
- /usr/share/licenses/kanboard/LICENSE
```

Every port in settings.yaml has a probe (8080). The HTTP path `/` returns a redirect to the login page; confirm the status code on the first run and keep the probe only if it is 200 (UNVERIFIED). If Kanboard returns a redirect, use `/healthcheck.php` (upstream HEALTHCHECK uses it) and confirm the status on first run. No env vars are needed to start, so no required-env paths exist.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/www/app/data` (upstream VOLUME; SQLite DB, uploads) | `/config/data` via symlink created at build time |
| `/var/www/app/plugins` (upstream VOLUME) | `/config/plugins` via symlink |
| `/etc/nginx/ssl` (draft extra-persistence) | Not used: HTTP only. If TLS is added later, use `/config/ssl`. |
| nginx pid, temp, logs | `/tmp` (pid, client_body_temp_path, proxy_temp_path, fastcgi_temp_path in `etc/nginx`) |
| php-fpm socket, session | `/tmp/php` |
| Port 80 | 8080 (non-root cannot bind 80 with rootless UID) |

Draft expectations reconciled: the chart runs as root (`runAsUser: 0`, `runAsNonRoot: false`). This image runs as `apps` (UID 568), so the chart values must be adjusted for `runAsUser: 568`. The chart's `readOnlyRootFilesystem: false` can become `true` if all writes above are remapped; test with `--read-only --tmpfs /tmp`. Not privileged.

## 10. Risks, caveats and open questions

- Kanboard config keys and env names are unconfirmed. Do not invent any; start with the default `config.php` seeded to `/config`.
- The default `admin`/`admin` account is set in the app, not in this image. The PR must say that the first login needs a password change (manual, UNVERIFIED wording).
- Upstream image is Alpine; the apt PHP extension set must be checked against what Kanboard requires at v1.2.58 (UNVERIFIED: the list in section 1 is from v1.2.57's Alpine image).
- Using nginx and php-fpm from apt means two processes; `start.sh` backgrounds php-fpm and `exec`s nginx. If the process model needs supervision, add `tini` (not in the base); note this in the PR.
- Kanboard v1.2.58 security notes (SSRF hardening) make it the required version; do not pin v1.2.57.
- Optional PostgreSQL: the default SQLite path works without any dependency. PostgreSQL wiring is not in this plan.
- Blockers: none confirmed. No musl-only build (source app), no GPU, no privileged need. arm64: PHP runs natively on arm64 via apt; UNVERIFIED until built.

## 11. Build and test steps

```sh
cd apps/kanboard
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name kanboard-probe --read-only --tmpfs /tmp \
  -v kanboard-probe-config:/config kanboard:v1.2.58
docker logs -f kanboard-probe
forgetool containers test --image kanboard:v1.2.58 --config ./apps/kanboard/container-test.yaml
docker rm -f kanboard-probe; docker volume rm kanboard-probe-config
```

Expected readiness signal: nginx starts (`nginx: ... start worker process` in logs) and php-fpm reports `ready to handle connections`; the process stays alive. Confirm `/config/data` exists after start and survives a restart. Check from outside the container with `-p 8080:8080` that the web UI answers.

## 12. PR checklist

- Branch `feat/add-kanboard`, commit and PR title `feat(kanboard): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the PHP extension set on Ubuntu 26.04 against v1.2.58, the HTTP probe status code, arm64, PostgreSQL wiring, and the default admin change flow.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
