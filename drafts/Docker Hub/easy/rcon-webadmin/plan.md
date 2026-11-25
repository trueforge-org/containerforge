# rcon-webadmin — implementation plan
> Source: ./draft.md · Target: apps/rcon-webadmin/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.14.1` (GitHub release and tag `0.14.1`, 2020-06-09; `package.json` inside still says 0.13.3). The itzg wrapper image also pins `RCON_WEB_ADMIN_VERSION=0.14.1`. The project is effectively dormant. |
| Renovate | `datasource=github-releases depName=rcon-web-admin/rcon-web-admin` (tags have no `v` prefix) |
| License | `MIT` (`package.json` and GitHub both say MIT) |
| Source | https://github.com/rcon-web-admin/rcon-web-admin (the maintained fork of brainfoolong's project) |
| Download | `https://github.com/rcon-web-admin/rcon-web-admin/archive/0.14.1.tar.gz`, sha256 `b7e2dc23c2d10040214dd9c96f16ee7a9417a5a628ef2a1fae6cda25ad6bb59b` (computed from the download, re-checked during verification; a Renovate bump must update it too; GitHub does not publish checksums, and archive tarballs are not guaranteed byte-stable). Pure JavaScript, so no per-arch artifact. |
| Upstream Dockerfile reviewed | https://github.com/itzg/docker-rcon-web-admin/blob/484fba3/Dockerfile: `node:12`, tarball to `/opt`, `npm install`, `node src/main.js install-core-widgets`, `EXPOSE 4326 4327`, `VOLUME /opt/rcon-web-admin/db`, `ENV RWA_ENV=TRUE`, `ENTRYPOINT node src/main.js start`. |
| Dependencies | `express ^4.17.1`, `fstream`, `lowdb >=0.14.0`, `unzipper ^0.10.5`, `ws`. `package-lock.json` (lockfileVersion 1) pins `lowdb 0.14.0`, which matters: an unlocked `npm install` could pull a newer ESM-only lowdb that breaks `require`. |
| Ports | 4326 (web UI), 4327 (websocket, "port + 1"; both required, from `config.template.js`). Host defaults to all hostnames (`host: null`). |
| Env (read in `src/env.js`, only when `RWA_ENV=TRUE`) | `RWA_USERNAME` (default `admin`), `RWA_PASSWORD` (**required**: the app prints an error and `process.exit(1)` without it), `RWA_ADMIN` (default `FALSE`), `RWA_READ_ONLY_WIDGET_OPTIONS` (default `FALSE`), `RWA_RESTRICT_COMMANDS`, `RWA_RESTRICT_WIDGETS`, `RWA_RCON_HOST` (default `127.0.0.1`), `RWA_RCON_PORT` (default 25575), `RWA_RCON_PASSWORD`, `RWA_GAME` (default `minecraft`), `RWA_SERVER_NAME`, `RWA_WEB_RCON` (default `FALSE`). In `src/config.js`, always read: `RWA_WEBSOCKET_URL`, `RWA_WEBSOCKET_URL_SSL`. |
| Start | `node src/main.js start` (the draft's "start from src/main.js" is right). `node src/main.js install-core-widgets` downloads four widgets from GitHub master zips (`rwa-autobot`, `rwa-console`, `rwa-rustboard`, `rwa-timedcommands`). |
| Writes | The database is **hard-coded** to `<app>/db` (`src/db.js`: `__dirname + '/../db'`) plus `db/server_<id>` folders. Widgets live under `public/widgets`. No other runtime writes found; the README mentions `logs/` and a pid file only for the `startscripts`, which we do not use. |

## 2. Target layout

```
apps/rcon-webadmin/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`: the db seed is created at build time inside the image (section 4). No `root/`, no `DOWNSTREAM_CHANGES.md`. The folder name follows the draft (`rcon-webadmin`).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Matches the draft and the siblings `apps/thelounge` and `apps/budge` (same FROM line; `budge` runs `npm` without installing it, so the base provides Node.js). The python half of the base is unused. Note: `apps/python-node` was deleted from this repo (commit `ab442d1c6`, 2026-11-17), and the current `apps/ubuntu/Dockerfile` installs Node.js itself (`NODE_VERSION` in `apps/ubuntu/docker-bake.hcl`). Maintainers should confirm whether new apps should still use `python-node` or `ubuntu`. UNVERIFIED: that the pinned `ubuntu` digest already contains Node. No Python runtime rules apply (no venv use), but keep the base's `/app/venv` untouched.

## 4. Dockerfile

1. `FROM` as above, `ARG VERSION`, `USER root`.
2. `ENV NODE_ENV=production HOME=/tmp npm_config_cache=/tmp/.npm`.
3. No apt packages: do not reinstall `nodejs`/`npm`, the base provides them (do not copy the apt step of `apps/wikijs`). Check `node --version` and `npm --version` in the base during the build (engines `>=4`, the reviewed upstream image uses 12; `env.js` uses optional `catch {}`, so Node >= 10). UNVERIFIED: the Node version in this base.
4. One `RUN`:
   - `mkdir -p /app/rcon-web-admin`; `curl -fsSL -o /tmp/rwa.tar.gz https://github.com/rcon-web-admin/rcon-web-admin/archive/${VERSION}.tar.gz`; `echo "<sha256>  /tmp/rwa.tar.gz" | sha256sum -c -`; `tar xzf ... -C /app/rcon-web-admin --strip-components=1`.
   - `cd /app/rcon-web-admin && npm ci --omit=dev` (uses `package-lock.json`, so lowdb stays 0.14.0).
   - `node src/main.js install-core-widgets` (network access at build; the widgets come from `master` zips, so they are not reproducible, see section 10).
   - Seed handling: `mv db /app/db-seed && ln -s /config/db db` so the read-only tree points at the volume, while the built-time contents (anything the widget install wrote to `db/`, plus the shipped files) stay available as the first-run seed.
   - `mkdir -p /usr/share/licenses/rcon-web-admin && cp LICENSE /usr/share/licenses/rcon-web-admin/`.
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/* /root/.npm`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 4326 4327`, `VOLUME /config`, `WORKDIR /app/rcon-web-admin`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "rcon-webadmin" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=rcon-web-admin/rcon-web-admin
  default = "0.14.1"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/rcon-web-admin/rcon-web-admin" }
```
With `docker-metadata-action`, `image` (args.VERSION, OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), and `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rcon-web-admin/rcon-web-admin"
ports:
  - port: 4326
    protocol: tcp
    required: false
  - port: 4327
    protocol: tcp
    required: false
env:
  - { name: RWA_USERNAME, default: "admin", required: false }
  - { name: RWA_PASSWORD, default: "", required: false }
  - { name: RWA_ADMIN, default: "FALSE", required: false }
  - { name: RWA_READ_ONLY_WIDGET_OPTIONS, default: "FALSE", required: false }
  - { name: RWA_RESTRICT_COMMANDS, default: "", required: false }
  - { name: RWA_RESTRICT_WIDGETS, default: "", required: false }
  - { name: RWA_RCON_HOST, default: "127.0.0.1", required: false }
  - { name: RWA_RCON_PORT, default: "25575", required: false }
  - { name: RWA_RCON_PASSWORD, default: "", required: false }
  - { name: RWA_GAME, default: "minecraft", required: false }
  - { name: RWA_SERVER_NAME, default: "", required: false }
  - { name: RWA_WEB_RCON, default: "FALSE", required: false }
  - { name: RWA_WEBSOCKET_URL, default: "", required: false }
  - { name: RWA_WEBSOCKET_URL_SSL, default: "", required: false }
volumes:
  - path: /config
    required: true
dependencies: []
```
(Match the multi-line style of sibling files when writing; the flow style above is shortened for the plan.) All names come from `src/env.js` and `src/config.js`. The target game server is external, not a ContainerForge dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# /app/rcon-web-admin/db is a symlink to /config/db (read-only app tree)
mkdir -p /config/db
if [[ -z "$(ls -A /config/db 2>/dev/null)" ]]; then
  cp -a /app/db-seed/. /config/db/
fi

# env-driven setup only when a password is given; env.js exits 1 without RWA_PASSWORD
if [[ -n "${RWA_PASSWORD:-}" ]]; then
  export RWA_ENV=TRUE
else
  unset RWA_ENV
  echo "rcon-webadmin: RWA_PASSWORD not set, starting without env-based user/server setup" >&2
fi

cd /app/rcon-web-admin
exec node src/main.js start
```
Environment-based users are rewritten on every start (`env.js` hashes `RWA_PASSWORD` and sets a new `loginHash` each time), so password changes apply to existing data. The password never reaches a command line. The server binds all hostnames (`host: null`); no `config.js` is written because nothing needs changing.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
http:
- port: '4326'
  path: /
tcp:
- port: '4327'
filePaths:
- /app/rcon-web-admin/src/main.js
- /usr/share/licenses/rcon-web-admin/LICENSE
```
The test runs without env, so the `RWA_PASSWORD` path (user and server creation) is not covered; run it by hand. UNVERIFIED whether `/` returns 200 before any user exists (it may redirect or show a setup page, which would still be an HTTP answer). UNVERIFIED that 4327 listens immediately.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `db/*.json` and `db/server_<id>/` (remapped by the `db -> /config/db` symlink); `public/widgets/*` when a user installs or updates widgets from the UI or `update-all-widgets` (these fail on a read-only `/app`; core widgets are baked in at build, and runtime widget installs are not supported unless the user rebuilds). Node caches go to `/tmp` (`npm_config_cache`, `HOME=/tmp`).
- Draft vs chart: the chart runs UID 0, `runAsNonRoot: false`, writable root and mounts `/opt/rcon-web-admin/db`. Here UID 568, read-only root, persistence at `/config` (the db symlink target). A migration copies the old `db` content into `/config/db`.
- Not privileged. No access control inside the app beyond its own users; put a reverse proxy in front for the websocket, and set `RWA_WEBSOCKET_URL(_SSL)` when proxied.

## 10. Risks, caveats and open questions

- Draft caveats kept: the target game server must expose RCON and its host, port and password must be given (env or UI); the arm64 status of the npm tree was unverified (all dependencies are pure JS, so likely fine; confirm with an arm64 build).
- Draft said "no bundled user management": true only without `RWA_ENV`; with env it creates one user from `RWA_USERNAME`/`RWA_PASSWORD`. The UI also has its own user admin (UNVERIFIED how first-run works without env).
- Core widgets are fetched from GitHub `master` zips during the build, so builds are not reproducible and break if those repos disappear. Option: pin them by commit and verify checksums if the maintainers want that.
- Passwords are stored with `saltedMd5`; this is weak and upstream's choice.
- `src/main.js` calls `process.umask(0)`, so files the app creates under `/config/db` are world-writable. Decide whether to patch that line at build time.
- Old software on a current Node: `npm ci` may warn on deprecated packages (`fstream`, `unzipper`) and lockfile v1; UNVERIFIED that every dependency runs on the Node version apt provides.
- Upstream is dormant since 2020; Renovate will rarely fire.
- No blockers (no musl-only part, no GPU, no privilege).

## 11. Build and test steps

```sh
cd apps/rcon-webadmin
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create rcon-webadmin-probe-config
docker run --rm -d --name rcon-webadmin-probe --read-only --tmpfs /tmp \
  -v rcon-webadmin-probe-config:/config -e RWA_PASSWORD=changeme rcon-webadmin:0.14.1
docker logs -f rcon-webadmin-probe     # expect the JSON config line from config.js and no stack trace
docker exec rcon-webadmin-probe node -e "require('http').get('http://127.0.0.1:4326/',r=>console.log(r.statusCode))"
docker rm -f rcon-webadmin-probe; docker volume rm rcon-webadmin-probe-config
forgetool containers test --image rcon-webadmin:0.14.1 --config ./apps/rcon-webadmin/container-test.yaml
```
Repeat with no env and a fresh volume (the test condition), then restart on the same volume. Check that `/config/db` was seeded and that the app stays up with `--read-only`.

## 12. PR checklist

- Branch `feat/add-rcon-webadmin`, commit and PR title `feat(rcon-webadmin): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: arm64, behaviour on the apt Node version, read-only operation, widget install at build, the env-driven path, anything not built locally.
- Confirm `bake --print` passes; `VERSION` equals the Dockerfile `ARG`; no `root/`.
