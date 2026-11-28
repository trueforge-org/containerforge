# barcodebuddy — implementation plan
> Source: ./draft.md · Target: apps/barcodebuddy/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts
| Item | Value |
|---|---|
| Version | 1.9.0.1 (tag `v1.9.0.1`, published 25 Sep; draft chart tag is `latest`) |
| Renovate | datasource=github-releases, depName=Forceu/barcodebuddy, versioning=loose (4-part version) |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`; UNVERIFIED: not re-read from the LICENSE file this session; confirm before writing LICENSE, use SPDX `AGPL-3.0-only` or `-or-later` per the file header) |
| Source | https://github.com/Forceu/barcodebuddy |
| Download | https://github.com/Forceu/barcodebuddy/archive/refs/tags/v${VERSION}.tar.gz (source tarball, arch-neutral PHP; avoids git in the image). The latest release shows no uploaded assets via the GitHub API; the source tarball is used |
| Checksum | none published: UNVERIFIED; pin by tag over HTTPS |
| Upstream Dockerfile reviewed | Forceu/barcodebuddy-docker @527c3c6 (alpine 3.24 + php85, golang:1.27-alpine supervisor stage) |
| Ports | 80 and 443 exposed upstream; web UI on 80. Websocket server is proxied by nginx (internal port UNVERIFIED) |
| Volume | /config (upstream: /data is a symlink to /config) |
| Env vars | None documented by the docker README (it points to barcodebuddy-documentation.readthedocs.io). Supervisor `environment.Parse()` reads some (names UNVERIFIED, read supervisor/environment package). Declare TZ only until verified. |

Upstream process model (supervisor/services): redis-server (`/etc/redis.conf --daemonize no`), php-fpm85 `-F`, nginx `-c /etc/nginx/nginx.conf`, `php8 /app/bbuddy/wsserver.php` (restarted up to 10 times), optional input grabber (`example/grabInput.sh`, only if enabled). Build seds: `config-dist.php IS_DOCKER=true`, `incl/db.inc.php DEFAULT_USE_REDIS=1`, php-fpm `pm.max_children=20`, nginx SCRIPT_FILENAME fastcgi param.

## 2. Target layout
- Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh
- defaults/nginx.conf, defaults/php-fpm.conf, defaults/redis.conf (rendered into /tmp)
No Go supervisor is built: it only supervises four processes, which start.sh replaces, so no Go stage and no go-runtime obligations. No root/, no DOWNSTREAM_CHANGES.md.

## 3. Base image
`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (glibc, so the alpine/musl upstream image cannot be copied; draft copy-from is "no"). Closest siblings: apps/bookstack (apt PHP), apps/kasmvnc (rootless nginx edits).

## 4. Dockerfile
1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. apt: `nginx php8.5-fpm php8.5-cli php8.5-curl php8.5-sqlite3 php8.5-mbstring php8.5-xml php8.5-redis php8.5-gettext php8.5-zip redis-server curl` (extension list derived from upstream's alpine php85 set: curl fileinfo fpm gettext json mbstring openssl pdo pdo_sqlite redis session simplexml sockets sqlite3 xml xmlwriter zlib; most are in php8.5-common/-cli on Ubuntu; verify with `php -m`). Check against base before adding.
3. Fetch app: curl the tag tarball, extract to /app/bbuddy with `--strip-components=1`; apply the same seds as upstream (IS_DOCKER true; DEFAULT_USE_REDIS "1"; grabInput.sh paths if grabber kept, otherwise skip the grabber).
4. Data: `ln -s /config /data` is not possible on a read-only rootfs at runtime, so create it in the Dockerfile (`ln -s /config /data`). Barcode Buddy's data dir (config/db) must resolve to /config (UNVERIFIED which constant: check `config-dist.php`, copy to /config/config.php in start.sh if the app expects it there).
5. Licenses: copy LICENSE to /usr/share/licenses/barcodebuddy/.
6. nginx: sed pid to /tmp/nginx.pid, logs to /tmp, temp paths to /tmp, include /tmp/nginx-conf.d/*.conf (kasmvnc pattern). Remove default conf.
7. `chown -R apps:apps /app`, apt cleanup. `ENV HOME=/config`. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl
APP=barcodebuddy; VERSION "1.9.0.1" with `// renovate: datasource=github-releases depName=Forceu/barcodebuddy versioning=loose`; Dockerfile downloads `v${VERSION}`. LICENSE per section 1; SOURCE https://github.com/Forceu/barcodebuddy. Standard 4 targets + default group as apps/adguardhome-sync. Run `docker buildx bake --print`.

## 6. settings.yaml
Header, `schema_version: 1`, `upstream_env_url: "https://github.com/Forceu/barcodebuddy"`. ports: 8080/tcp required false (rootless replacement for 80; 443 dropped, TLS belongs to the ingress, state this in PR). env: TZ only (add supervisor env vars only after verification). volumes: /config required true. dependencies: none (redis runs inside the container; a separate valkey ✅ is possible later via config but is not wired).

## 7. start.sh
```bash
#!/usr/bin/env bash
set -e
mkdir -p /config/data /tmp/nginx-conf.d /tmp/redis /tmp/php
[ -f /config/config.php ] || cp /app/bbuddy/config-dist.php /config/config.php   # UNVERIFIED path logic
cp /defaults/nginx.conf /tmp/nginx-conf.d/bbuddy.conf   # listen 8080, fastcgi_pass unix:/tmp/php-fpm.sock, websocket location proxy
cp /defaults/php-fpm.conf /tmp/php-fpm.conf
cp /defaults/redis.conf /tmp/redis/redis.conf           # bind 127.0.0.1, dir /tmp/redis, daemonize no, save ""
redis-server /tmp/redis/redis.conf &
php-fpm8.5 -y /tmp/php-fpm.conf -F &
php /app/bbuddy/wsserver.php &
exec nginx -g 'daemon off;'
```
Redis on localhost only is fine (internal, no password). nginx binds 0.0.0.0:8080. Cache/state not under /app. Add `wait -n`-style guard so a dead php-fpm or redis exits the container (upstream exits when a zero-restart service fails).

## 8. container-test.yaml
Header; `timeoutSeconds: 120`; `tcp: - port: '8080'`; `http` probe on / (expect 200/redirect to the login/setup page, UNVERIFIED); `filePaths`: /app/bbuddy/index.php, /usr/share/licenses/barcodebuddy/LICENSE. No env is needed to start.

## 9. Rootless and read-only-rootfs adaptations
| Upstream write path | Remap |
|---|---|
| /config (data, config, sqlite db) | stays /config (persistent) |
| /data -> /config symlink | created at build time |
| redis dir /var/lib/redis and conf /etc/redis.conf | rendered to /tmp/redis, redis runs as apps |
| nginx pid/logs/temp, port 80/443 | /tmp, port 8080 |
| php-fpm socket, /var/log/php85 | /tmp socket, error_log to stderr |
| sudo/user switching in supervisor (redis, barcodebuddy users) | removed, everything runs as apps |
Draft expects runAsUser 0 and readOnlyRootFilesystem false; plan targets apps UID with read-only rootfs. Input grabber (evtest on /dev/input) is out of scope and disabled.

## 10. Risks, caveats and open questions
- Replace the Go supervisor with shell: must reproduce restart behaviour of the websocket server (upstream max 10 restarts); open question whether a loop in start.sh is enough.
- Scanner needs host USB/camera device; the container only offers the web UI and websocket (draft caveat).
- musl to glibc: re-test PHP 8.5 behaviour; redis extension package name php8.5-redis is UNVERIFIED on 26.04.
- Env var names, data path constants, websocket port, exact license variant all UNVERIFIED (flagged above).
- No blockers.

## 11. Build and test steps
```sh
cd apps/barcodebuddy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name barcodebuddy-probe --read-only --tmpfs /tmp -v barcodebuddy-probe-config:/config barcodebuddy:1.9.0.1
docker logs -f barcodebuddy-probe   # expect redis "Ready to accept connections", php-fpm "ready to handle connections", nginx up, no wsserver crash loop
curl -sI http://127.0.0.1:8080/; docker rm -f barcodebuddy-probe; docker volume rm barcodebuddy-probe-config
forgetool containers test --image barcodebuddy:1.9.0.1 --config ./apps/barcodebuddy/container-test.yaml
```

## 12. PR checklist
- Branch feat/add-barcodebuddy; commit `feat(barcodebuddy): add new container`; PR title same, target main; use PULL_REQUEST_TEMPLATE.md.
- Notes contain `🤖 This PR is AI generated.`
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only they can sign).
- Untested until done: build, arm64, websocket behaviour, scanner use, license variant, env vars. Do not tick "Built container locally" unless built.
