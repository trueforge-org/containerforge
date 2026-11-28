# flashpaper — implementation plan
> Source: ./draft.md · Target: apps/flashpaper/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.6.1, published 2026-11-23 (https://api.github.com/repos/AndrewPaglusch/FlashPaper/releases/latest). The draft names v2.6.0, which is stale. The release has no uploaded assets. |
| Renovate | `datasource=github-releases depName=AndrewPaglusch/FlashPaper versioning=semver` |
| License | MIT (GitHub license API, `spdx_id` MIT) |
| Source URL | https://github.com/AndrewPaglusch/FlashPaper |
| Download | Source archive of the tag, `https://github.com/AndrewPaglusch/FlashPaper/archive/refs/tags/v${VERSION}.tar.gz` (tag is `v2.6.1`, bake `VERSION` has no `v`). UNVERIFIED: the exact archive URL pattern was not fetched; it is the standard GitHub tag archive form. |
| Per-arch binary | None. FlashPaper is PHP source, so the same tree runs on amd64 and arm64. |
| Checksum source | None published on the release. Pin the tag's commit SHA in the Dockerfile and verify it after download (UNVERIFIED: the SHA of v2.6.1 was not read). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/Dockerfile. This is the commit the draft cites. It is not the v2.6.1 tree. |
| Upstream base | `php:8.5-fpm-alpine` (musl). Not usable on ubuntu, so the runtime has to be rebuilt from apt. |
| Upstream steps | `apk add curl nginx`; `COPY . /var/www/html`; `chown -R nginx:nginx`; copies `php.ini-production` to `php.ini`; writes `conf.d/upload-progress.ini` with `session.upload_progress.enabled = Off` (GHSA-6wmf-4rv5-p3rp); copies `docker/php-fpm.conf`, `docker/nginx.conf`, `docker/entrypoint.sh`, `docker/settings.php`; `VOLUME /var/www/html/data`; `ENTRYPOINT ["/bin/ash", "/entrypoint.sh"]`. |
| Entrypoint | https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/entrypoint.sh: `chown -R nginx: /var/www/html/data/`, `touch data/index.php`, starts `php-fpm` then `nginx -c /etc/nginx/nginx.conf`, then a readiness loop on `localhost` that greps for `AndrewPaglusch/FlashPaper`, then `tail -f` of the nginx and php error logs. |
| Port | 80 in the upstream container. UNVERIFIED: the `listen` directive in `docker/nginx.conf` was not read. The ContainerForge rootless port is 8080 (see section 9). |
| Env vars | UNVERIFIED: none read. The upstream Dockerfile sets none, and the entrypoint reads none. |
| Data path | `/var/www/html/data` (upstream `VOLUME`). Pastes are stored there per the draft (UNVERIFIED against app code). |
| Dependencies | None: the data path implies file storage (UNVERIFIED against app code). |

## 2. Target layout

Exact file list for `apps/flashpaper/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required; replaces upstream `entrypoint.sh`)
- `etc/nginx/nginx.conf` (required reason: the web server must listen on 8080 and write to `/tmp`; the upstream config is not read yet, so the file is a rewrite of it; `etc/` is on the `.dockerignore` allow-list)
- `etc/php/php-fpm.conf` (required reason: the pool runs as `apps` on a `/tmp` socket; upstream `docker/php-fpm.conf` is the source)
- `etc/php/conf.d/upload-progress.ini` (required reason: the security setting from upstream, kept as a file so it is visible)

Not used: `defaults/` (no seed files), `health/` (no health probe script), `root/` (never used), `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Final stage and build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The ubuntu base is the default for a non-Python, non-Java runtime (the porter table, and the draft's own rule that PHP comes from apt on ubuntu).
- Closest sibling: `apps/bookstack` (PHP stack on the same ubuntu 26.04 digest, `USER apps`, `VOLUME /config`).
- Alternative `apps/nginx` (nginx on ubuntu 26.04) was considered. It is not used, because the PHP-FPM part still has to be installed, and the sibling PHP pattern is ubuntu.
- No `python` or `python-node` base: no Python or Node in the upstream runtime.

## 4. Dockerfile

Keep the `ARG VERSION` and `ARG TARGETARCH` pattern from `apps/bookstack`. The `VERSION` default lives in `docker-bake.hcl`.

1. `ARG VERSION` and `ARG TARGETARCH`. `USER root` for installs only.
2. Install php and nginx with pinned apt versions where the version is taken from apt. The ubuntu 26.04 package names and versions are UNVERIFIED for this plan (php-fpm, php-curl, php-cli, nginx). Check them against `apt-cache policy` in the build and record the pinned values in the Dockerfile. The PHP runtime has to match the PHP version the FlashPaper source needs (UNVERIFIED: minimum PHP version in the FlashPaper `composer.json` was not read).
3. Remove `composer` from the plan. The upstream Dockerfile does not use it, and the draft's "composer (inferred)" is not confirmed.
4. Download and extract the source:
   ```dockerfile
   RUN curl -fsSL "https://github.com/AndrewPaglusch/FlashPaper/archive/refs/tags/v${VERSION}.tar.gz" -o /tmp/flashpaper.tar.gz \
    && mkdir -p /tmp/flashpaper-src \
    && tar -xzf /tmp/flashpaper.tar.gz -C /tmp/flashpaper-src --strip-components=1
   ```
   Verify the archive against the pinned commit SHA before extracting (UNVERIFIED: the SHA for v2.6.1 was not read; set it when verified).
5. Copy the app to `/app/flashpaper` (the rootfs is read-only at runtime, so the web root cannot be `/var/www/html`). Remove the upstream `docker/` directory from the copy.
6. Build-time data symlink: `ln -s /config/data /app/flashpaper/data`. The symlink dangles until `start.sh` creates `/config/data`. This is the same pattern as the fenrus plan.
7. Ship the license: `COPY` the upstream `LICENSE` to `/usr/share/licenses/flashpaper/LICENSE`.
8. Set file ownership to `apps` for `/config` only, not for `/app`.
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   ```
   Keep `COPY --chmod=0755 . /` so the test can see the files.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "flashpaper"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=AndrewPaglusch/FlashPaper versioning=semver
  default = "2.6.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/AndrewPaglusch/FlashPaper"
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

Validate with `docker buildx bake --print` from `apps/flashpaper`. Note the `VERSION` value is without the `v` prefix; the Dockerfile builds the tag URL as `v${VERSION}` (the tag is `v2.6.1`, confirmed by the releases API).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/AndrewPaglusch/FlashPaper"
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

- `ports`: 8080 only, because nginx binds 8080 in the rootless build. Port 80 is the upstream port and is not used.
- `env`: no upstream env vars were confirmed, so only `TZ` (the standard entry) is listed. Do not add env names that the app does not read.
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /tmp/php /tmp/nginx /tmp/php-sessions
[ -f /config/data/index.php ] || touch /config/data/index.php

php-fpm -y /etc/php/php-fpm.conf -D
exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
```

- Idempotent: the data folder and the `index.php` guard are created only when missing. No seeding of user state.
- No writes to `/app`. The only persistent write is to `/config/data`.
- Caches, pid and socket files, and temp paths go to `/tmp` (nginx `client_body_temp` and friends in `etc/nginx/nginx.conf`).
- `php-fpm -D` daemonises the FPM master. Upstream used `tail -f` on the logs; that is dropped, because the `log` paths are under `/tmp` and the container should exit if nginx exits. Risk: if PHP-FPM dies, nginx keeps running. Section 10 lists this.
- The readiness loop from upstream is not kept. The test in section 8 covers it.
- Final long-running process is `nginx` via `exec`, so signals reach it.

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
  - /app/flashpaper/index.php
  - /usr/share/licenses/flashpaper/LICENSE
  - /etc/nginx/nginx.conf
  - /etc/php/php-fpm.conf
```

- Every port in `settings.yaml` has a `tcp` probe (8080). The `http` probe checks the response on `/`.
- UNVERIFIED: the exact file names under `/app/flashpaper` were not listed. `index.php` is the expected entry point; confirm it exists before the test is accepted.
- No env-gated code paths: FlashPaper needs no env to start, so the test covers the start path.
- Do not weaken any assertion. If the `http` probe does not return a 200 on `/`, fix the nginx config, not the test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or bind | ContainerForge remap |
| --- | --- |
| `/var/www/html` (web root, written by `chown` at build) | `/app/flashpaper`, read-only at runtime, no writes |
| `/var/www/html/data` (`VOLUME`, pastes) | symlink to `/config/data`, created at build |
| `chown -R nginx:nginx` | not used. The pool and the web root run as `apps` |
| `/var/run/nginx`, `/var/run/php-fpm`, `/var/log/php` | `/tmp/nginx`, `/tmp/php`; logs to `/tmp` |
| `session.save_path` (PHP default) | `/tmp/php-sessions`, set in `etc/php/php-fpm.conf` |
| nginx `listen 80` | `listen 8080` in `etc/nginx/nginx.conf` (rootless cannot bind 80). UNVERIFIED: current upstream listen directive was not read. |
| `/usr/local/etc/php-fpm.d` (removed upstream) | Not used: pool config is supplied by `etc/php/php-fpm.conf` |
| `/etc/nginx/nginx.conf` (upstream copy) | `etc/nginx/nginx.conf` in the image, read-only |

Security expectations from the draft (non-root no, read-only no, privileged no) are the chart's defaults, not the app's. The target is: non-root (`USER apps`), read-only rootfs (passes with `--read-only --tmpfs /tmp`), no privileged mode. Those are the ContainerForge rules, not the chart values.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: the chart pins `master`, but the release is v2.6.1. The plan uses the tag, not `master`, so the app version does not drift.
- Draft caveat: "the upstream project is small" was not tested. It does not change the plan.
- Draft's "two processes need a supervisor": confirmed. This plan runs php-fpm as a daemon and nginx in the foreground. If PHP-FPM dies, nginx keeps serving errors. A proper supervisor was not chosen; check this during the run test.
- Draft's arm64 claim: UNVERIFIED for the ubuntu 26.04 apt packages on arm64. The source is arch-independent, so the risk is apt availability only.
- Blockers: none found that stop the build. The main work is the nginx and php-fpm config rewrite (section 9).
- Open questions: confirm the php-fpm and php-curl apt package names and versions on ubuntu 26.04; confirm the PHP version minimum; confirm `docker/nginx.conf` listen directive and its temp paths; confirm `settings.php` writes nothing at runtime.

## 11. Build and test steps

Run from `apps/flashpaper`. These follow `.github/instructions/build-test-protocol.instructions.md`, one app at a time.

```sh
cd apps/flashpaper
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name flashpaper-probe --read-only --tmpfs /tmp \
  -v flashpaper-probe-config:/config flashpaper:2.6.1
docker logs -f flashpaper-probe
forgetool containers test --image flashpaper:2.6.1 --config ./container-test.yaml
docker rm -f flashpaper-probe; docker volume rm flashpaper-probe-config
```

- Expected readiness signal: nginx starts with no error and the probe on 8080 returns 200 for `/`. Log lines from php-fpm (`fpm is running`, `ready to handle connections`) are the second signal.
- Empty `/config`: use a fresh named volume each round.
- If `forgetool` is unavailable, run the probe by hand: `curl -fsS http://localhost:8080/` and the file checks in section 8.

## 12. PR checklist

- Branch: `feat/add-flashpaper`.
- Commit: `feat(flashpaper): add new container`.
- PR title matches the commit.
- Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows the status.
- Honest list of what is untested: the v2.6.1 archive SHA, the ubuntu 26.04 php package names, the nginx config rewrite, arm64, and any run result. Do not check "Built container locally" unless the build and the protocol's run and test steps were done.
