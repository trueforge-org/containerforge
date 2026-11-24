# slink — implementation plan
> Source: ./draft.md · Target: apps/slink/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 1.14.6 (git tag `v1.14.6`, published 2026-11-06; draft tag `v1.14.6` is the same). Latest per GitHub releases API. |
| Renovate | `datasource=github-releases depName=andrii-kryvoviaz/slink`, tags carry a `v` prefix so add `extractVersion=^v(?<version>.+)$`; `versioning=semver` |
| License | AGPL-3.0 per the repo README ("AGPLv3"). composer.json has no `license` field and the LICENSE file was not read: use `AGPL-3.0-only`. UNVERIFIED: whether `-only` or `-or-later` |
| Source | https://github.com/andrii-kryvoviaz/slink |
| Download | No release assets. Source tarball `https://github.com/andrii-kryvoviaz/slink/archive/refs/tags/v${VERSION}.tar.gz`, identical for amd64/arm64 (interpreted app: SvelteKit client + Symfony API) |
| Checksum | None published (release has no assets). Pin by tag only. |
| Upstream Dockerfile | `docker/Dockerfile.prod` at commit aefc970: stages `deps-client-prod`, `build-client` (node, pnpm, `NODE_OPTIONS=--max-old-space-size=2048 --expose-gc`), `source`, `vendor` (composer, `--no-dev --optimize-autoloader --no-scripts`), `prod` (FROM `common`). The `common` stage and the s6 service scripts (`docker/config/s6-overlay/s6-rc.d/prod/`) could not be read: UNVERIFIED what exactly runs as services |
| Layout upstream | `services/api` (Symfony 8.1, PHP >= 8.5, needs `ext-gd`, `ext-ffi`, `ext-vips`), `services/client` (SvelteKit, `server.js`) |
| Ports | `EXPOSE 3000` (node client). Healthcheck hits `http://127.0.0.1:8080/api/health` (Caddy/API, internal). Draft's 80 and 6379 are wrong/internal: 80 is not used, redis is internal only |
| Env (docs.slinkapp.io) | `ORIGIN` (default `http://localhost:3000`), `TZ` (UTC), `PORT` (3000), `USER_ALLOW_REGISTRATION` (true), `USER_APPROVAL_REQUIRED` (true), `USER_ALLOW_GUEST_UPLOADS` (false), `USER_ALLOW_UNAUTHENTICATED_ACCESS` (true), `IMAGE_MAX_SIZE` (15M), `STORAGE_PROVIDER` (local; also smb, s3 with `SMB_*` / `AMAZON_S3_*`), `ADMIN_EMAIL`/`ADMIN_USERNAME` (admin)/`ADMIN_PASSWORD` (first-run admin), `REQUIRE_SSL`. Upstream image sets `APP_ENV=prod NODE_ENV=production BODY_SIZE_LIMIT=Infinity MERCURE_HUB_URL=http://localhost:8080/.well-known/mercure MERCURE_PUBLIC_URL=/sse` |
| Data paths | `/app/var/data` (app data, keys in `/app/var/data/keys`), `/app/slink/images` (uploads), `/data/redis`, `/data/caddy` |
| Dependencies | none external (redis, mercure and caddy are bundled upstream) |
| arm64 | draft says yes; upstream builds both. UNVERIFIED: `ext-vips` package availability on ubuntu 26.04 arm64 |

## 2. Target layout

```
apps/slink/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                 # supervises valkey, php-fpm, caddy(+mercure), node client
  defaults/Caddyfile       # adapted from upstream docker/config/caddy (read it at implementation time)
  defaults/php-fpm.conf    # pool config writing only to /tmp, clear_env = no
```
`root/` is not used. No DOWNSTREAM_CHANGES.md (not a FROM base). `defaults/` is on the `.dockerignore` allow-list.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for build stages and the final stage. The ubuntu base already ships node, yarn, go, git, curl, jq. Closest siblings: `apps/bookstack` (PHP from apt on ubuntu), `apps/caddy` (xcaddy build stage), `apps/valkey` (pinned apt package), `apps/it-tools` (node build stage). Draft agrees (ubuntu alone).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG CADDY_VERSION`, `ARG XCADDY_VERSION` (copy the values from `apps/caddy/docker-bake.hcl`, currently 2.11.9 and 0.4.7), `ARG VALKEY_PACKAGE_VERSION` (pinned like `apps/valkey`; resolve with `apt-cache policy valkey-server` on ubuntu 26.04).
2. Stage `client`: `FROM ubuntu... AS client`, `USER root`, `ENV HOME=/tmp`, download `v${VERSION}` tarball to `/tmp`, extract, `cd services/client`, `corepack enable && pnpm install --frozen-lockfile && NODE_OPTIONS="--max-old-space-size=2048 --expose-gc" pnpm build`, then a second `pnpm install --prod` for runtime `node_modules` (mirrors upstream `deps-client-prod`).
3. Stage `vendor`: apt `composer php8.5-cli php8.5-gd php8.5-xml php8.5-mbstring php8.5-curl php8.5-intl php8.5-zip php8.5-sqlite3 libvips-dev` (verify names), `composer install --no-dev --optimize-autoloader --no-scripts` in `services/api`. `ext-vips` and `ext-ffi`: install the ubuntu package if it exists, otherwise `pecl install vips` in this stage (UNVERIFIED) and copy the `.so` into the final stage.
4. Stage `caddy`: copy the `apps/caddy` xcaddy pattern; add the Mercure module only if the upstream Caddyfile uses it (`--with github.com/dunglas/mercure/caddy`, UNVERIFIED), output `/caddy-bin`.
5. Final stage: `USER root` for `apt-get install -y --no-install-recommends php8.5-fpm php8.5-cli php8.5-gd php8.5-xml php8.5-mbstring php8.5-curl php8.5-intl php8.5-zip php8.5-sqlite3 libvips42 valkey-server=${VALKEY_PACKAGE_VERSION}` then `rm -rf /var/lib/apt/lists/*`. Do not reinstall curl, git, node (already in base).
6. `COPY --from=vendor /…/vendor /app/api/vendor`, `COPY --from=…source /app/api`, `COPY --from=client /…/build /app/client`, `COPY --from=caddy /caddy-bin /app/caddy`. Install to `/app` only (read-only at runtime).
7. License files: `mkdir -p /usr/share/licenses/slink && cp LICENSE /usr/share/licenses/slink/` (from the extracted tarball in the build stage).
8. Warm the Symfony cache at build time (`php bin/console cache:warm --env=prod`), as upstream does with `slink cache:warm`, so `/app/api/var/cache` is read-only at runtime. Runtime cache and logs go to `/tmp` via `APP_CACHE_DIR=/tmp/slink/cache` and `APP_LOG_DIR=/tmp/slink/log` (Symfony Kernel convention, UNVERIFIED for this app).
9. Symlinks created at build time: `/app/var/data -> /config/data`, `/app/slink/images -> /config/images` (the upstream literal paths are kept, targets live in `/config`).
10. `ENV APP_ENV=prod NODE_ENV=production BODY_SIZE_LIMIT=Infinity MERCURE_HUB_URL=http://127.0.0.1:8080/.well-known/mercure MERCURE_PUBLIC_URL=/sse HOME=/config`.
11. `chown -R apps:apps /app` only for dirs needing it, then `USER apps`, `COPY --chmod=0755 . /` (last, after `USER apps`, same ordering as siblings), `EXPOSE 3000`, `VOLUME /config`, `WORKDIR /config`.
12. Final line of the file sequence: `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "slink" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=andrii-kryvoviaz/slink extractVersion=^v(?<version>.+)$
  default = "1.14.6"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/andrii-kryvoviaz/slink" }
```
Extra variables `CADDY_VERSION` and `XCADDY_VERSION` (each with its own `// renovate:` github-releases comment, as in `apps/caddy`) and `VALKEY_PACKAGE_VERSION` (`// renovate: datasource=deb depName=valkey-server registryUrl=https://archive.ubuntu.com/ubuntu`), all passed in `args`. Targets: `docker-metadata-action {}`, `image` (args + OCI source/licenses labels), `image-local` (output `type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/andrii-kryvoviaz/slink"
ports:
  - {port: 3000, protocol: tcp, required: true}
env: TZ (Etc/UTC), ORIGIN (http://localhost:3000), USER_APPROVAL_REQUIRED (true),
     USER_ALLOW_REGISTRATION (true), IMAGE_MAX_SIZE (15M), STORAGE_PROVIDER (local),
     ADMIN_EMAIL (""), ADMIN_USERNAME (admin), ADMIN_PASSWORD ("")   # all required: false
volumes:
  - path: /config
    required: true
dependencies: none
```
Write it in the sibling list style (`- name/default/required`). Only vars from docs.slinkapp.io are listed; defaults equal the documented defaults and what `start.sh` exports. Port 8080 is loopback-only inside the container and is not listed. Redis 6379 is loopback-only and not listed.

## 7. start.sh

Bash, `set -euo pipefail`, idempotent.
1. `mkdir -p /config/{data/keys,images,redis,caddy} /tmp/slink/{cache,log,php,caddy}`; `chmod 750 /config/data/keys` only when creating.
2. Defaults: `: "${ORIGIN:=http://localhost:3000}"` etc., exported so php-fpm sees them (`clear_env = no` in `defaults/php-fpm.conf`).
3. Start `valkey-server --bind 127.0.0.1 --port 6379 --dir /config/redis --daemonize no` in background (binds to loopback only; internal service, state in `/config/redis`).
4. Start `php-fpm8.5 -F -y /defaults/php-fpm.conf` (pid, error log and socket under `/tmp/slink/php`).
5. Run DB/schema init on every start (`php /app/api/bin/console doctrine:migrations:migrate --no-interaction` or the upstream `slink` wrapper, UNVERIFIED which command), then admin creation is handled by the app when `ADMIN_EMAIL` is set (per docs).
6. Start `/app/caddy run --config /defaults/Caddyfile` bound to 0.0.0.0:8080 is not required (loopback is enough because only node talks to it), data dir `XDG_DATA_HOME=/config/caddy`.
7. Final foreground: `node /app/client/server.js` listening on `0.0.0.0:3000` (`HOST=0.0.0.0 PORT=3000`). Because several processes run, the script does not `exec` the first one: it backgrounds the helpers, traps TERM/INT, and ends with `wait -n` so the container exits when any child dies (PID 1 is tini from the ubuntu entrypoint). The node client is the last launched process: `exec node /app/client/server.js` replaces the shell only if a small watchdog subshell kills the group on helper exit; otherwise use `wait -n`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
healthCommands:
- command: wget -qO- http://127.0.0.1:8080/api/health
filePaths:
- /start.sh
- /app/client/server.js
- /usr/share/licenses/slink/LICENSE
```
`timeoutSeconds` 240 mirrors the multi-process PHP sibling (`apps/bookstack`). Runs without env vars: defaults let it start with `ORIGIN=http://localhost:3000`. Admin-creation code (`ADMIN_EMAIL`) is not exercised: it is covered by a manual run in section 11. Port 3000 has both tcp and http probes; the 8080 health probe is an extra loopback check.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/app/var/data` (data, keys) | symlink to `/config/data` |
| `/app/slink/images` | symlink to `/config/images` |
| `/data/redis` | `/config/redis` |
| `/data/caddy` | `/config/caddy` (`XDG_DATA_HOME`) |
| Symfony cache and logs | prewarmed in `/app/api/var`, runtime to `/tmp/slink` |
| php-fpm pid/socket/log, caddy temp | `/tmp/slink/*` |
| node/pnpm caches | build only, `HOME=/tmp` in build stages |

Draft expects root (UID 0), `readOnlyRootFilesystem: false`: we run as UID 568 with read-only rootfs. Not privileged. Extra persistence `/app/var/data` and `/app/slink/images` both collapse into the single `/config` volume (subdirs `data/` and `images/`); document in settings and release notes that existing volumes must be remapped.

## 10. Risks, caveats and open questions

- UNVERIFIED: upstream `common` stage and s6 service scripts were not readable. Before implementing, read `docker/config/caddy` and `docker/config/s6-overlay/s6-rc.d/prod/*` at tag v1.14.6 to confirm how PHP is served (fastcgi vs FrankenPHP) and whether Mercure is a Caddy module or a standalone hub.
- Slink needs PHP >= 8.5 with `ext-vips` and `ext-ffi`; ubuntu 26.04 ships php8.5 (as `apps/bookstack` assumes) but a vips PHP extension package may not exist (PECL build needed).
- Four processes in one container (draft caveat): slower first start, a crash of a helper must stop the container.
- Draft guess "port 80" and "6379 exposed" are wrong; real external port is 3000.
- `ext-ffi` requires `ffi.enable` in php.ini for FPM (`preload`/`true`): check at runtime.
- No release checksum available; supply-chain trust is the git tag.
- No blockers (no musl-only, GPU, privileged); arm64 plausible but untested.

## 11. Build and test steps

```sh
cd apps/slink
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name slink-probe --read-only --tmpfs /tmp -v slink-probe-config:/config slink:1.14.6
docker logs -f slink-probe
forgetool containers test --image slink:1.14.6 --config ./apps/slink/container-test.yaml
docker rm -f slink-probe; docker volume rm slink-probe-config
```
Readiness signal: node log line that the server listens on port 3000 and `curl http://127.0.0.1:3000/` returns 200. Also run once with `-e ADMIN_EMAIL=... -e ADMIN_PASSWORD=...` and confirm the admin can log in, and restart the container on the same volume to prove idempotency.

## 12. PR checklist

- Branch `feat/add-slink`, commit `feat(slink): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and check only boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- CLA notice: tell the user a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it.
- State honestly what is untested: arm64 build, ext-vips, S3/SMB storage providers, Mercure/SSE live updates, upgrade from the upstream image's volume layout.
- Pre-completion: bake `--print` ran, `VERSION` aligned in Dockerfile and bake, `USER apps` last, `/config` empty start works.
