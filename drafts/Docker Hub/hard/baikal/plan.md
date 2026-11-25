# baikal — implementation plan
> Source: ./draft.md · Target: apps/baikal/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts
| Item | Value |
|---|---|
| Version | 0.13.0 (draft's chart tag is ckulka/baikal 0.10.1-nginx; upstream release page shows 0.13.0 as Latest, published 19 Oct) |
| Renovate | datasource=github-releases, depName=sabre-io/Baikal, versioning=semver (tags are bare `0.13.0`, no `v`) |
| License | GPL-3.0-only (composer.json `license` field, 0.13.0) |
| Source | https://github.com/sabre-io/Baikal |
| Download (arch-neutral, pure PHP) | https://github.com/sabre-io/Baikal/releases/download/0.13.0/baikal-0.13.0.zip (asset `baikal-0.13.0.zip` confirmed on the 0.13.0 release via the GitHub API) |
| Checksum | UNVERIFIED: release page did not show a checksum asset; if none exists, pin by HTTPS tag download only and say so in the PR |
| PHP requirement | php ^8.2 with dom, pdo, zlib (composer.json) |
| Upstream Dockerfile reviewed | ckulka/baikal-docker nginx.dockerfile @06c5398: nginx base, PHP 8.1 from Sury, pool user nginx, socket /var/run/php-fpm.sock, volumes /var/www/baikal/config and /var/www/baikal/Specific, entrypoint.d script chowns files, no EXPOSE (nginx listens on 80), no env vars for nginx variant except BAIKAL_SKIP_CHOWN |
| Ports | 80 in upstream; this image uses 8080 (rootless, see section 9) |
| Env vars | Baikal itself reads none; config is written by the web setup wizard into config/baikal.yaml. Only TZ is declared. |

## 2. Target layout
- apps/baikal/Dockerfile
- apps/baikal/docker-bake.hcl
- apps/baikal/settings.yaml
- apps/baikal/container-test.yaml
- apps/baikal/start.sh
- apps/baikal/defaults/nginx.conf, defaults/php-fpm.conf (templates copied/rendered into /tmp at start; allow-listed by include/.dockerignore)
No root/. No DOWNSTREAM_CHANGES.md (not used as a FROM base).

## 3. Base image
`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Pure PHP app, no language base needed; nginx and PHP come from apt exactly like apps/bookstack (php8.5-* on 26.04). Closest sibling: apps/bookstack (PHP stack) plus apps/kasmvnc (rootless nginx with pid/logs in /tmp).

## 4. Dockerfile
1. `ARG VERSION`, `ARG TARGETARCH` (arch is unused, the zip is arch-neutral), `USER root`.
2. apt (no pins needed, VERSION is the app, not a distro package): `nginx php8.5-fpm php8.5-cli php8.5-sqlite3 php8.5-mysql php8.5-xml php8.5-mbstring php8.5-curl unzip sqlite3` (package names follow apps/bookstack's php8.5-* scheme; verify availability on 26.04 at build time. mysql is optional: only needed if the user selects MySQL in the wizard). `dom`/`pdo`/`zlib` come with php8.5-xml/-common/-cli.
3. Download: `curl -fL -o /tmp/baikal.zip "https://github.com/sabre-io/Baikal/releases/download/${VERSION}/baikal-${VERSION}.zip"`; `unzip` to /tmp, move the `baikal` folder to /app/www.
4. Persistent dirs: remove the shipped /app/www/config and /app/www/Specific and replace with symlinks `/app/www/config -> /config/config` and `/app/www/Specific -> /config/Specific` (same pattern as apps/bookstack symlinks). Keep a pristine copy of the shipped dirs at /defaults/baikal-skel for seeding (copy to /defaults before symlinking).
5. Licenses: `mkdir -p /usr/share/licenses/baikal && cp /app/www/LICENSE* /usr/share/licenses/baikal/` (and vendor/sabre license files).
6. nginx rootless edits, as in apps/kasmvnc: `sed` nginx.conf to `pid /tmp/nginx.pid;`, error/access log to /tmp or stderr, and add `include /tmp/nginx-conf.d/*.conf;`; also remove the distro default site (`/etc/nginx/sites-enabled/default`, `conf.d/default.conf` if present) so nginx does not try to bind port 80 as non-root; `mkdir -p /var/lib/nginx/{body,fastcgi,proxy,scgi,uwsgi}` and chown to apps (or point temp paths at /tmp in the rendered conf).
7. `chown -R apps:apps /app`, apt cleanup, `rm -rf /var/lib/apt/lists/* /tmp/*`.
8. `ENV HOME=/config`; `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8080`; `VOLUME /config`; `WORKDIR /config`.

## 5. docker-bake.hcl
APP=baikal; VERSION default "0.13.0" preceded by `// renovate: datasource=github-releases depName=sabre-io/Baikal versioning=semver`; LICENSE "GPL-3.0-only"; SOURCE "https://github.com/sabre-io/Baikal". Standard targets docker-metadata-action, image, image-local (type=docker, tag ${APP}:${VERSION}), image-all (linux/amd64, linux/arm64), group default -> image-local, copied from apps/adguardhome-sync. Validate with `docker buildx bake --print`.

## 6. settings.yaml
Schema header + `schema_version: 1`, `upstream_env_url: "https://github.com/sabre-io/Baikal"`.
- ports: 8080/tcp required false.
- env: TZ default "Etc/UTC" required false (only; Baikal reads no env of its own, do not invent BAIKAL_* vars: BAIKAL_SKIP_CHOWN/SERVERNAME belong to the ckulka entrypoint, not upstream).
- volumes: /config required true.
- dependencies: none (SQLite default; MySQL optional via wizard, mariadb ✅ exists but is not a hard dependency, so use `opt_dependencies: - name: mariadb` as apps/bookstack does).

## 7. start.sh
```bash
#!/usr/bin/env bash
set -e
mkdir -p /config/config /config/Specific /tmp/nginx-conf.d /tmp/php
# seed only when missing/empty
[ -n "$(ls -A /config/config 2>/dev/null)" ] || cp -rn /defaults/baikal-skel/config/. /config/config/
[ -n "$(ls -A /config/Specific 2>/dev/null)" ] || cp -rn /defaults/baikal-skel/Specific/. /config/Specific/
cp /defaults/nginx.conf /tmp/nginx-conf.d/baikal.conf        # listen 8080, root /app/www/html, fastcgi_pass unix:/tmp/php-fpm.sock
cp /defaults/php-fpm.conf /tmp/php-fpm.conf                  # listen /tmp/php-fpm.sock, no user= directive, clear_env=no
php-fpm8.5 -y /tmp/php-fpm.conf -F &
exec nginx -g 'daemon off;'
```
Idempotent, no writes to /app, session/upload temp in /tmp, nginx binds 0.0.0.0:8080 (`listen 8080;`, not 127.0.0.1). nginx.conf must use `fastcgi_param SCRIPT_FILENAME` and route /dav.php per upstream sabre docs (UNVERIFIED: copy the ckulka files/nginx.conf rules after reading it at build time). Final `exec nginx`; php-fpm is a background child (acceptable pair; if php-fpm dies, add a `wait -n` guard that exits).

## 8. container-test.yaml
Schema header; `timeoutSeconds: 60` (sibling apps use short values for simple servers; raise to 120 if the build host is slow); `tcp: - port: '8080'`; `http:` probe on 8080 path / expecting a 2xx/3xx (the wizard page redirects to /admin/install/ on a fresh /config; the http probe must accept the redirect: UNVERIFIED how forgetool treats 3xx, otherwise use the tcp probe only and add `filePaths` for /app/www/html/index.php and /usr/share/licenses/baikal). Test runs without env, which is fine since none are required.

## 9. Rootless and read-only-rootfs adaptations
| Upstream write path | Remap |
|---|---|
| /var/www/baikal/config (baikal.yaml written by wizard) | symlink /app/www/config -> /config/config |
| /var/www/baikal/Specific (SQLite db, INSTALL_DISABLED marker) | symlink /app/www/Specific -> /config/Specific |
| nginx pid, logs, temp dirs | /tmp (sed in Dockerfile, rendered conf) |
| php-fpm socket, pid, sessions | /tmp (php.ini session.save_path=/tmp/php via -d or conf) |
| nginx on port 80 | 8080 (no NET_BIND_SERVICE needed) |
| pool user nginx, chown entrypoint (BAIKAL_SKIP_CHOWN) | dropped; everything runs as apps |
Draft expected runAsUser 0 and read-only=false; this plan runs as apps with readOnlyRootFilesystem true. Draft's extra persistence (/var/www/baikal/config and Specific) is collapsed into the single /config volume.

## 10. Risks, caveats and open questions
- Draft caveat confirmed: nginx plus php-fpm in one container; two processes handled in start.sh, not a supervisor.
- Wizard writes baikal.yaml and removes the install guard in Specific; verify that writing through the symlinks works with PHP open_basedir (none by default).
- Upgrade note from 0.13.0 release: back up before upgrading (SQLite sharing fix).
- Checksum asset UNVERIFIED (the release lists only `baikal-0.13.0.zip`, no checksum file seen). License is GPL-3.0-only, not "or-later".
- Version drift: draft/chart 0.10.1 vs upstream 0.13.0; data created with 0.10.x must be upgraded through Baikal's own web upgrade page.
- No blockers (pure PHP, both arches).

## 11. Build and test steps
```sh
cd apps/baikal
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name baikal-probe --read-only --tmpfs /tmp -v baikal-probe-config:/config baikal:0.13.0
docker logs -f baikal-probe        # expect nginx start with no [emerg]/[crit], php-fpm "ready to handle connections"
curl -sI http://127.0.0.1:8080/ ; docker rm -f baikal-probe; docker volume rm baikal-probe-config
forgetool containers test --image baikal:0.13.0 --config ./apps/baikal/container-test.yaml
```
Also complete the setup wizard once manually and restart the container to confirm persistence.

## 12. PR checklist
- Branch feat/add-baikal; commit `feat(baikal): add new container`; Conventional Commit PR title, target main.
- Fill .github/PULL_REQUEST_TEMPLATE.md; Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Tick "Built container locally" only if actually built. Currently untested: build, arm64, wizard flow, MySQL mode, checksum.
