# h5ai — implementation plan
> Source: ./draft.md · Target: apps/h5ai/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 0.30.0 (tag `v0.30.0`, published 2024-11-09, still latest; matches draft) |
| Renovate | `datasource=github-releases depName=lrsjng/h5ai versioning=loose` (tag has a `v` prefix; Dockerfile uses `v${VERSION#v}`) |
| License | MIT (SPDX `MIT`; UNVERIFIED this session, confirm the repo LICENSE) |
| Source URL | https://github.com/lrsjng/h5ai |
| Download | `https://github.com/lrsjng/h5ai/releases/download/v0.30.0/h5ai-0.30.0.zip` (single arch-neutral asset `h5ai-0.30.0.zip`; PHP/JS) |
| Checksum | GitHub digest is null, upstream publishes none. Compute sha256 once at implementation time and pin it as `ARG H5AI_SHA256`, with a comment that it must be updated with `VERSION` (renovate cannot update it). UNVERIFIED value. |
| Upstream Dockerfile reviewed | `awesometic/docker-h5ai` (archived, read-only): `nginx:1.30.6-alpine3.24`, PHP 8.5 with fpm, session, json, xml, mbstring, exif, intl, gd, imagick, zip; ffmpeg, imagemagick, zip, apache2-utils, patch, supervisor; env `PUID/PGID` (911), `TZ`, `HTPASSWD`, `HTPASSWD_USER`, `HTPASSWD_PW`; `EXPOSE 80`; `VOLUME /config /h5ai`; h5ai at `/usr/share/h5ai/_h5ai`; supervisor runs nginx and php-fpm. Those env vars belong to that wrapper, not to h5ai. |
| Ports | Upstream wrapper 80/http; this plan uses 8080/http because rootless cannot bind 80. |
| Dependencies | none |

## 2. Target layout

```
apps/h5ai/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/nginx.conf
  defaults/php-fpm.conf
  defaults/options.json   # only if a seed is needed (UNVERIFIED, see section 7)
```

`defaults/` holds config templates (allowed by `include/.dockerignore`). No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (nginx already installed, pinned to VERSION there; PHP added with apt). Alternative from draft: ubuntu base plus `nginx`; rejected to avoid duplicating the nginx install. Note the nginx image CMD uses `/config/nginx.conf`; we override with our own start.sh. Closest siblings: `apps/it-tools` (nginx static), `apps/bookstack` (PHP 8.5 on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG H5AI_SHA256`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends php8.5-fpm php8.5-cli php8.5-gd php8.5-xml php8.5-mbstring php8.5-intl php8.5-zip php8.5-imagick ffmpeg imagemagick zip unzip` (php8.5 packages are the ones `apps/bookstack` uses; `php8.5-imagick` and `php8.5-exif` names UNVERIFIED; `exif` ships in php-common/`php8.5-common` on Debian-style packaging). Pin php8.5 version is not tied to h5ai VERSION, so no pin required; confirm the nginx base has no PHP already.
3. `curl -fsSL -o /tmp/h5ai.zip "https://github.com/lrsjng/h5ai/releases/download/v${VERSION#v}/h5ai-${VERSION#v}.zip"`, `echo "${H5AI_SHA256}  /tmp/h5ai.zip" | sha256sum -c -`, `unzip` into `/app/h5ai/` so that `/app/h5ai/_h5ai/` exists.
4. Replace writable subtrees with symlinks into `/tmp`: `_h5ai/public/cache` -> `/tmp/h5ai/public-cache`, `_h5ai/private/cache` -> `/tmp/h5ai/private-cache`, and `_h5ai/private/conf/options.json` handling per section 7. (Directory names UNVERIFIED; confirm by `unzip -l`.)
5. License: copy the LICENSE/README shipped in the zip (or fetch from repo at the tag) to `/usr/share/licenses/h5ai/`.
6. `ENV TZ=Etc/UTC PHP_INI_SCAN_DIR=:/tmp/php.d` only if needed; no HOME cache writes.
7. `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /app/h5ai`, `USER apps`.

## 5. docker-bake.hcl

`APP="h5ai"`, `LICENSE="MIT"`, `SOURCE="https://github.com/lrsjng/h5ai"`, `VERSION` default `"0.30.0"` under `// renovate: datasource=github-releases depName=lrsjng/h5ai versioning=loose`; if an `H5AI_SHA256` variable is added, pass it in `args` and comment it as manually maintained. Standard targets and group (`docker-metadata-action`, `image`, `image-local`, `image-all` amd64+arm64, default `image-local`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/lrsjng/h5ai"`.
- ports: `8080 tcp required: false`.
- env: `TZ` (`"Etc/UTC"`) only. Do not copy the wrapper's `PUID/PGID/HTPASSWD*` unless start.sh implements them (it does not in this plan).
- volumes: `/config` required true (h5ai options and nginx overrides); `/h5ai` required false (the directory to browse, read-only mount recommended, as in the draft's chart).
- dependencies: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Seed `/config/options.json` from `/defaults/options.json` only if missing, and make `_h5ai/private/conf/options.json` a symlink to it (symlink created at build time pointing at `/config/options.json`; if absent, h5ai uses built-in defaults; UNVERIFIED).
- Create `/tmp/h5ai/{public-cache,private-cache}`, `/tmp/nginx-temp`, `/tmp/php`.
- Render nginx config from `/defaults/nginx.conf` to `/tmp/nginx.conf` (envsubst is in the ubuntu base `gettext-base`): `listen 8080` on all interfaces, pid and temp paths in `/tmp`, `root /h5ai` for the browsed dir, `/_h5ai/` alias to `/app/h5ai/_h5ai/`, PHP via unix socket `/tmp/php-fpm.sock`, index `/_h5ai/public/index.php`.
- Start php-fpm in the foreground in the background shell: `php-fpm8.5 -F -y /defaults/php-fpm.conf` (pid, error log to stderr, socket in `/tmp`, user left as the current user), with `clear_env` default fine.
- `exec nginx -c /tmp/nginx.conf -g 'daemon off;'`. Add a `trap` to stop php-fpm on exit; if php-fpm dies, exit non-zero (wait loop with `wait -n`).
- Warn in the log that h5ai has no authentication.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
http:
- port: '8080'
  path: /_h5ai/public/index.php
tcp:
- port: '8080'
filePaths:
- /app/h5ai/_h5ai/public/index.php
- /start.sh
- /usr/share/licenses/h5ai/LICENSE
runners:
- entrypoint: php --version
```

Test runs without env vars and without `/h5ai` content; confirm the http path returns 2xx on an empty `/h5ai` (otherwise use path `/`). Timeout from nginx siblings (default); 120 s assumed.

## 9. Rootless and read-only-rootfs adaptations

- Draft: chart UID 0, writable rootfs, `/h5ai` pvc mounted read-only. Target UID 568, read-only rootfs.
- Writes: nginx pid, temp, logs (stdout/stderr) and php-fpm socket/pid go to `/tmp`; h5ai caches symlinked to `/tmp`; options in `/config`.
- Port 80 -> 8080 (deviation from draft, documented).
- Persistence: `/config` plus the browsed `/h5ai` mount (draft); no other state.

## 10. Risks, caveats and open questions

- No built-in auth: anyone reaching the port sees the mounted files. Optional basic auth (the wrapper's `HTPASSWD` feature) is out of scope; decide whether to implement via nginx `auth_basic` with a file in `/config`.
- h5ai 0.30.0 compatibility with PHP 8.5 is unverified; wrapper uses PHP 8.5 so likely fine.
- Two processes (php-fpm and nginx) without supervisor: failure handling is the `wait -n` loop.
- Cache directory names and zip layout are UNVERIFIED until `unzip -l`.
- Wrapper repo is archived; no upstream container to track.

## 11. Build and test steps

```sh
cd apps/h5ai
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
mkdir -p /tmp/h5ai-sample && echo hi > /tmp/h5ai-sample/a.txt
docker run --rm -d --name h5ai-probe --read-only --tmpfs /tmp -v h5ai-probe-config:/config \
  -v /tmp/h5ai-sample:/h5ai:ro -p 8080:8080 h5ai:0.30.0
docker logs -f h5ai-probe
curl -s http://localhost:8080/ | grep -i h5ai
forgetool containers test --image h5ai:0.30.0 --config ./apps/h5ai/container-test.yaml
docker rm -f h5ai-probe; docker volume rm h5ai-probe-config
```

Expected readiness: nginx started with no `[emerg]` lines, php-fpm "ready to handle connections", and the listing page contains `a.txt`.

## 12. PR checklist

- Branch `feat/add-h5ai`; commit and PR title `feat(h5ai): add new container`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- bake print, version alignment (bake VERSION == Dockerfile ARG), `USER apps`, empty `/config`, read-only rootfs.
- Untested at plan time: build, run, PHP 8.5 compatibility, thumbnail generation (imagick/ffmpeg), license identifier, zip layout, sha256 value.
