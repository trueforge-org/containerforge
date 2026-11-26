# photoshow — implementation plan
> Source: ./draft.md · Target: apps/photoshow/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Pin the master commit `3c3819f6555c1c7819ee31f6c090da44d0ce2428` (committed 2025-01-13). Source: https://api.github.com/repos/thibaud-rohmer/PhotoShow/commits/master. Draft's tag `v2` is stale: release "Final v2 version." from 2014-07-07, no assets. Source: https://api.github.com/repos/thibaud-rohmer/PhotoShow/releases/latest. The README is titled "PhotoShow 3.0" and master has a `docker/` folder, so master is the current code. |
| Chart image | `ghcr.io/linuxserver/photoshow:version-48aabb98` (draft). The linuxserver image is DEPRECATED: `root/etc/cont-init.d/99-deprecation` says "This image is deprecated ... it will not be updated", and the repo is archived (`linuxserver-archive/docker-photoshow`, last push 2022-10-14). Source: https://api.github.com/repos/linuxserver/docker-photoshow |
| Renovate | `datasource=git-refs depName=https://github.com/thibaud-rohmer/PhotoShow currentValue=master` (same form as `apps/tvheadend`). |
| License | None declared. GitHub API `license` is null and master has no LICENSE file. Source: https://api.github.com/repos/thibaud-rohmer/PhotoShow/contents/LICENSE (404). Caveat in section 10. |
| Source URL | https://github.com/thibaud-rohmer/PhotoShow |
| Download | No prebuilt binary; PHP source. `https://github.com/thibaud-rohmer/PhotoShow/archive/${VERSION}.tar.gz` (GitHub archive by commit). No checksum published, so the commit SHA is the pin. Download itself UNVERIFIED. |
| Upstream Dockerfile reviewed | Two sources. (a) linuxserver/docker-photoshow `Dockerfile`: `FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.13`; apk `curl fbida-exiftran ffmpeg imagemagick jq php7-exif php7-gd php7-imagick zip`; PhotoShow installed at build from `PHOTOSHOW_COMMIT` (default: master HEAD) into `/version.txt`; php-fpm settings appended to `/etc/php7/php-fpm.conf`; `EXPOSE 80`; `VOLUME /config /Thumbs /Pictures`. (b) upstream `docker/Dockerfile` (alpine 3.10.1, supervisor, nginx, php7-fpm, `/opt/PhotoShow/Photos` and `/opt/PhotoShow/generated`, php-fpm user `www-data` uid 33). Source: https://api.github.com/repos/thibaud-rohmer/PhotoShow/contents/docker/Dockerfile |
| linuxserver runtime | `40-install` clones PhotoShow to `/config/www/PhotoShow` at first start, then `sed`s `config.php`: `photos_dir = "/Pictures"`, `ps_generated = "/Thumbs"`, `timezone = "${TZ}"`, and copies `defaults/keyboard.js` over `src/js/keyboard.js`. Source: https://api.github.com/repos/linuxserver/docker-photoshow/contents/root/etc/cont-init.d/40-install |
| linuxserver nginx | `root/defaults/default`: `listen 80;`, `alias /config/www/PhotoShow/;`, `index index.php;`, `fastcgi_pass 127.0.0.1:9000`, `SCRIPT_FILENAME /config/www/PhotoShow/$fastcgi_script_name`, `client_max_body_size 0`, `error_log /config/log/nginx/photoshow.log info`. |
| Config keys | `photos_dir`, `ps_generated`, `timezone`, `imagemagick_path`, `quality_small`, `quality_mini` (README and linuxserver `sed`). |
| Env vars | None read by upstream. Only `TZ` as a linuxserver env, applied to `config.php`. |
| Port | 80 in linuxserver (nginx). ContainerForge: 8080 (section 9). php-fpm on 127.0.0.1:9000 is internal (not in `settings.yaml`). |
| Data paths | Photos read from `photos_dir`. Thumbnails/cache at `ps_generated`. Accounts, settings and themes in `user/` (README: "Make sure that the web server has the rights to read and write in those directories"). |
| Database | None (README: "It doesn't even require a database"). |
| PHP version | No minimum stated (UNVERIFIED). linuxserver used PHP 7 on alpine 3.13; Ubuntu 26.04 package version UNVERIFIED. |
| arm64 | Source is architecture-neutral. ImageMagick, ffmpeg, exiftran, php-gd from apt: arm64 availability on 26.04 UNVERIFIED. |

## 2. Target layout

- `apps/photoshow/Dockerfile`
- `apps/photoshow/docker-bake.hcl`
- `apps/photoshow/settings.yaml`
- `apps/photoshow/container-test.yaml`
- `apps/photoshow/start.sh` (seeds `/config`, starts php-fpm and nginx through supervisord)
- `apps/photoshow/etc/photoshow/nginx.conf`, `etc/photoshow/php-fpm.conf`, `etc/photoshow/supervisord.conf` (only what is needed to run two processes rootless; `etc/` is on the allow-list)
- `apps/photoshow/defaults/photoshow-user/` is NOT needed: the seed comes from the upstream `user/` folder copied at build time (section 4).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: PHP plus nginx come from apt on the Ubuntu base, which matches the sibling `apps/nginx` approach. No PHP base exists in the list. Ubuntu 26.04 packages for nginx, php-fpm and the image tools need checking on the first build (UNVERIFIED names and versions below). Closest siblings: `apps/nginx` (apt nginx, `USER apps`), `apps/bookstack` (PHP stack on ubuntu), `apps/valkey` (apt version pin).

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), aligned with the bake file.
2. `USER root`
3. Install runtime packages (apt, `--no-install-recommends`, lists removed in the same layer). Package names are UNVERIFIED on 26.04 (check `apt-cache policy` in the first build):
   - `nginx`, `php-fpm`, `php-gd`, `php-imagick`, `php-xml`, `php-exif` (if separate), `imagemagick`, `ffmpeg`, `exiftran` (Debian/Ubuntu name `fbida`), `zip`, `jq` (only if an upstream script needs it; check), `supervisor`.
   - Do not pin: PHP version is set by the Ubuntu release, and no PhotoShow release version is pinned via apt. Record the installed PHP version in the PR.
4. Fetch and extract the source:
   - `RUN curl -fL "https://github.com/thibaud-rohmer/PhotoShow/archive/${VERSION}.tar.gz" -o /tmp/photoshow.tar.gz && mkdir -p /app/photoshow && tar xzf /tmp/photoshow.tar.gz -C /app/photoshow --strip-components=1 && rm /tmp/photoshow.tar.gz`
   - `echo "${VERSION}" > /app/photoshow/version.txt` (mirrors linuxserver `/version.txt`).
5. Build-time config (the image is read-only at runtime, so `config.php` changes happen here):
   - `sed -i -e 's#\$config->photos_dir.*#$config->photos_dir = "/Pictures";#' -e 's#\$config->ps_generated.*#$config->ps_generated = "/config/photoshow/generated";#' /app/photoshow/config.php`
   - Set `imagemagick_path` only if `/usr/bin/convert` is not the default (UNVERIFIED on 26.04: check `command -v convert`).
   - Timezone: apply at runtime (section 7) through php-fpm `php_admin_value[date.timezone]`, not in `config.php`.
6. Persistence of `user/`:
   - `mkdir -p /defaults/photoshow && cp -a /app/photoshow/user /defaults/photoshow/user` (seed copy, read by start.sh).
   - `rm -rf /app/photoshow/user && ln -s /config/photoshow/user /app/photoshow/user`. This is the one symlink; it points at a real `/config` directory (the venv rule about symlinks does not apply here). UNVERIFIED that PhotoShow only uses `user/` relative to its root (check `inc/` in the first run).
7. Remove the `docker/` folder and `.git` leftovers from `/app/photoshow` (not needed at runtime).
8. Ownership and license: `chown -R apps:apps /app/photoshow /defaults/photoshow` is NOT needed for `/app` (read-only). Keep `/app` `chmod -R 755`. No LICENSE file exists upstream, so no `/usr/share/licenses` file (section 10).
9. `COPY --chmod=0755 . /` to bring in `start.sh`, `etc/photoshow/`.
10. Tail:

```dockerfile
ENV HOME=/tmp TZ=Etc/UTC
EXPOSE 8080
VOLUME /config
USER apps
CMD ["/start.sh"]
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "photoshow"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/thibaud-rohmer/PhotoShow currentValue=master
  default = "3c3819f6555c1c7819ee31f6c090da44d0ce2428"
}

variable "LICENSE" {
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/thibaud-rohmer/PhotoShow"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = { VERSION = "${VERSION}" }
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

`LICENSE` is a placeholder until the upstream license is confirmed (section 10). `NOASSERTION` is the SPDX value for unknown; confirm the convention in `apps/*/docker-bake.hcl` before merging.

`VERSION` is a commit SHA, so `docker buildx bake --print` is the validation step.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/thibaud-rohmer/PhotoShow"
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
  - path: /Pictures
    required: false
dependencies: []
```

- `/Pictures` is the photo library mount (read-only use is fine; thumbnails go to `/config`). It is listed because the app reads it. Upstream does not write there.
- `/Thumbs` from linuxserver is dropped: thumbnails live in `/config/photoshow/generated` (section 9).
- `TZ` is read by `start.sh` (section 7).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR=/config/photoshow
mkdir -p "${CONFIG_DIR}/generated" /tmp/photoshow

# Seed user data only when missing (never overwrite user state).
if [ ! -d "${CONFIG_DIR}/user" ]; then
  cp -a /defaults/photoshow/user "${CONFIG_DIR}/user"
fi

# Runtime php-fpm pool and supervisord config go to /tmp (read-only /app and /etc).
cat > /tmp/photoshow/php-fpm.conf <<EOF
[global]
daemonize = no
error_log = /proc/self/fd/2
pid = /tmp/photoshow/php-fpm.pid
[www]
listen = 127.0.0.1:9000
pm = ondemand
pm.max_children = 5
php_admin_value[upload_max_filesize] = 10M
php_admin_value[post_max_size] = 10M
php_admin_value[memory_limit] = 64M
php_admin_value[max_execution_time] = 15
php_admin_value[date.timezone] = ${TZ:-Etc/UTC}
clear_env = no
EOF

exec supervisord -n -c /etc/photoshow/supervisord.conf
```

- The `php-fpm` pool sets no `user`/`group`: php-fpm runs as `apps` (rootless).
- `supervisord.conf` (in `etc/photoshow/`) starts two programs: `php-fpm -F -y /tmp/photoshow/php-fpm.conf` and `nginx -g "daemon off;" -c /etc/photoshow/nginx.conf`. `supervisord` supervises both, so a crash in either is visible to the container. Its pid and log go to `/tmp`.
- `nginx.conf` root: `/app/photoshow`, `index index.php`, `fastcgi_pass 127.0.0.1:9000`, `fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name`, `client_max_body_size 0`, `pid /tmp/photoshow/nginx.pid`, all temp paths under `/tmp/photoshow/`, `access_log /dev/stdout`, `error_log /dev/stderr`.
- Listen on `0.0.0.0:8080` (`listen 8080;`), not localhost.
- Idempotent: seeding happens only when `user/` is missing.
- No writes to `/app` at runtime: thumbnails go to `/config`, the `user` symlink points at `/config`.

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
- /app/photoshow/index.php
- /app/photoshow/config.php
- /defaults/photoshow/user
- /etc/photoshow/nginx.conf
```

- `tcp` and `http` probes cover the single port in `settings.yaml`. The `http` probe returns 200 only if the app renders its root page without a library mounted (UNVERIFIED: the app may redirect or show an empty gallery; if it returns a non-200 status, use the status it does return and say so in the PR).
- Empty photo library and no env vars are normal in the test; the photo-path code path is not exercised. Add `/app/photoshow/inc` to `filePaths` if a specific class is needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream / linuxserver write path | ContainerForge remap |
| --- | --- |
| `/config/www/PhotoShow` (install target) | Install at build time into `/app/photoshow` (read-only). |
| `/Thumbs` (`ps_generated`) | `/config/photoshow/generated` (persistent thumbnails; a cache, but kept because regenerating is slow). |
| `/Pictures` (`photos_dir`) | `/Pictures` (read-only mount by the user). |
| `user/` (accounts, settings, themes) | Real directory `/config/photoshow/user`; build-time symlink `/app/photoshow/user` to it; seeded in `start.sh` when missing. |
| php-fpm pid, sockets, logs | `/tmp/photoshow/` |
| nginx temp paths, pid | `/tmp/photoshow/` |
| `/var/run/php`, `/run/nginx` (upstream) | Not used. |
| php-fpm pool `user = www-data` (upstream) | Removed (rootless). |

- `runAsUser: 0` in the chart is replaced by `USER apps`. The chart's `readOnlyRootFilesystem: false` is compatible with `--read-only --tmpfs /tmp`.
- Draft wrote thumbnails to `/tmp` or `/config`. `/config` is chosen so thumbnails persist; this is an explicit exception to the "caches to /tmp" rule and is justified here.
- Privileged: no. Extra persistence: none beyond `/config` and the photo library.

## 10. Risks, caveats and open questions

- License: none declared upstream (no LICENSE file, GitHub `license` null). The bake `LICENSE` value is a placeholder. Before merging, confirm the license with the upstream author or ask the user whether shipping without a confirmed license is acceptable. This is a potential blocker for the PR.
- Version: the draft's `v2` tag (2014) is stale and must not be used. master commit `3c3819f` is the current code.
- The linuxserver image is deprecated and archived. Its design (photos mounted at `/Pictures`, thumbnails in `/Thumbs`) is kept only where it helps users migrate.
- Two processes (php-fpm and nginx) in one container. Supervision through supervisord adds a package. The alternative (start php-fpm in the background, `exec` nginx) hides a php-fpm crash, so it is rejected.
- PHP version and extension names on Ubuntu 26.04 are UNVERIFIED. The `date.timezone` value and `imagemagick_path` depend on the install.
- `user/` symlink: if PhotoShow writes outside `user/` (for example the `config.php` checks or the `inc/` cache), the first run will show it. Check the logs with `--read-only`.
- Thumbnail generation uses ImageMagick, ffmpeg and exiftran. Their arm64 packages are UNVERIFIED.
- Blockers: no license file (section 10, first bullet). No GPU, no privileged, no DB.

## 11. Build and test steps

```sh
cd apps/photoshow
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name photoshow-probe --read-only --tmpfs /tmp \
  -v photoshow-probe-config:/config -v "$PWD/.probe-pictures:/Pictures:ro" photoshow:3c3819f6555c1c7819ee31f6c090da44d0ce2428
docker logs -f photoshow-probe
forgetool containers test --image photoshow:3c3819f6555c1c7819ee31f6c090da44d0ce2428 --config ./apps/photoshow/container-test.yaml
docker rm -f photoshow-probe; docker volume rm photoshow-probe-config
```

- Readiness signals: supervisord `spawned: 'php-fpm'` and `spawned: 'nginx'`, php-fpm `ready to handle connections`, nginx `start worker processes`. Confirm `/config/photoshow/user` exists after start and that a restart keeps it.
- Probe `/` from inside and from the host (`-p 8080:8080`) to prove it is not bound to localhost.
- The `.probe-pictures` folder is a placeholder test mount; do not commit it.

## 12. PR checklist

- Branch `feat/add-photoshow`, commit and PR title `feat(photoshow): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR: no upstream license (or the confirmed one), the deprecated linuxserver source, the untested items (PHP version on 26.04, arm64, the `--read-only` run, the probe status code).
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
