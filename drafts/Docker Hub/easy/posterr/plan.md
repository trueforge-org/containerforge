# posterr — implementation plan
> Source: ./draft.md · Target: apps/posterr/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.21.18` (tag `v1.21.18` = `18d2d31025c5b86daebf2e18d1662671c42e1c57`; `package.json` says `1.21.18`). The draft's `v1.15.0` is the GitHub "latest release" label only; newer tags exist up to `v1.21.18` (tags only, no release assets). The draft's `poster-binaries.zip` binaries are not needed. |
| Renovate | `datasource=github-tags` · `depName=petersem/posterr` · `versioning=semver` (tags have a `v` prefix; Dockerfile uses `v${VERSION}`) |
| License | `MIT` (GitHub API and `package.json`) |
| Source | https://github.com/petersem/posterr |
| Download | `https://github.com/petersem/posterr/archive/refs/tags/v${VERSION}.tar.gz` (verified; 35 MB extracted; arch independent JS) |
| Checksum | None published. HTTPS only. |
| Upstream Dockerfile reviewed | `node:24.1.0-alpine`, `apk add tzdata net-tools`, `NODE_ENV=production`, `WORKDIR /usr/src/app`, `npm install --production && mv node_modules ../`, `COPY . .`, `EXPOSE 3000`, `HEALTHCHECK node healthcheck.js`, `CMD node index.js`. |
| Runtime deps | `package.json` dependencies: axios, express, ejs, express-hbs, express-session, memorystore, plex-api, image-size, fs-extra, ... (no native addons identified; `request` is required by `classes/core/cache.js`; it is not a direct dependency, but `package-lock.json` at the tag has `request@2.88.2` as a non-dev package). `package-lock.json` is present. |
| Port | `PORT` env, default `3000` (`index.js`); also `app.listen(PORT)` on all interfaces. `BASEPATH` env sets a URL prefix (`/` treated as empty). Setup UI at `/settings`. |
| Config | Stored in `config/settings.json` (relative to cwd), written by the web UI; created with defaults when missing (`classes/core/settings.js`). No env var for Plex URL or token. `TZ` is read by Node. |
| Relative write paths (cwd) | `./config` (settings), `./saved` (+ `saved/imagecache`, `saved/mp3cache`: downloaded posters and TV theme mp3s), `./public/custom`, `./public/custom/pictures`, `./public/custom/pictures/default` (user pictures). `index.js` runs `fs.mkdirSync` for these at startup if they do not exist. |
| Ready line | `Web server started on internal port 3000` and `Application ready on http://hostIP:3000...` |
| Healthcheck | `node healthcheck.js`: GET `127.0.0.1:3000${BASEPATH}`; 200/301/302 is healthy. |

## 2. Target layout

```
apps/posterr/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (the app creates its own settings file). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: the draft and the agent table specify the Node-capable base for npm apps (`apps/budge` uses the same image with Node 24 and `npm`). Python is unused here. Closest sibling: `apps/budge` (python-node, npm install, source under `/app/www/public`, `exec npm ...` in `start.sh`). UNVERIFIED: the Node major in this image (budge's comments mention Node 24, matching upstream's `node:24`); confirm with `node --version` in the build step. `apps/python-node` was deleted from the repo on 2026-11-17 (commit `ab442d1c6`), although apps still use the published image; `apps/ubuntu/Dockerfile` now installs Node itself (`NODE_VERSION` 26.13.1 in its bake file). Maintainers should decide whether a new app should use the plain `ubuntu` base instead (see section 10).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `USER root`.
2. `ENV NODE_ENV=production HOME=/config npm_config_cache=/tmp/.npm`.
3. One `RUN`:
   - `curl -fsSL -o /tmp/posterr.tar.gz "https://github.com/petersem/posterr/archive/refs/tags/v${VERSION}.tar.gz"`
   - `mkdir -p /app/posterr && tar xzf /tmp/posterr.tar.gz -C /app/posterr --strip-components=1`
   - `grep -q "\"version\": \"${VERSION}\"" /app/posterr/package.json` (guards version alignment)
   - `cd /app/posterr && npm ci --omit=dev` (lockfile exists; falls back to `npm install --omit=dev` only if `npm ci` rejects it). Do not run `npm` as `apps`; do not leave `~/.npm` behind.
   - Replace the writable dirs with symlinks (targets are created by `start.sh`):
     `mv public/custom /app/posterr-custom.default && rm -rf config saved && ln -s /config/config config && ln -s /tmp/saved saved && ln -s /config/custom public/custom`
   - `mkdir -p /usr/share/licenses/posterr && cp LICENSE /usr/share/licenses/posterr/`
   - `npm cache clean --force; rm -rf /tmp/* /root/.npm; chown -R root:root /app/posterr; chmod -R a+rX,go-w /app/posterr`
4. `USER apps`; `COPY --chmod=0755 . /`.
5. `WORKDIR /app/posterr`; `EXPOSE 3000`; `VOLUME /config`.

No apt packages: upstream's `tzdata` and `net-tools` are already in an Ubuntu based image or unused (`TZ` works with the Ubuntu `tzdata` package; confirm `ls /usr/share/zoneinfo` in the build step, and add `tzdata` only if absent).

## 5. docker-bake.hcl

- `APP = "posterr"`
- `VERSION`: `// renovate: datasource=github-tags depName=petersem/posterr versioning=semver` then `default = "1.21.18"`
- `LICENSE = "MIT"`; `SOURCE = "https://github.com/petersem/posterr"`
- Standard four targets and `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl`; `image` passes `args.VERSION`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/petersem/posterr"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3000"
    required: false
  - name: BASEPATH
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
`PORT` and `BASEPATH` are read in `index.js` and `healthcheck.js`; `TZ` is the documented variable. Plex URL and token are entered in the UI at `/settings` and live in `/config/config/settings.json`, so there are no env vars for them. No `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Targets of the symlinks created in the image (/app/posterr/{config,saved,public/custom}).
mkdir -p \
  /config/config \
  /config/custom/pictures/default \
  /tmp/saved/imagecache \
  /tmp/saved/mp3cache

# seed the shipped custom files (custom.css) only when missing
if [[ ! -f /config/custom/custom.css ]]; then
  cp /app/posterr-custom.default/custom.css /config/custom/custom.css
fi

cd /app/posterr
exec node index.js
```
Idempotent, never writes under `/app`. Seeding only creates missing directories and the shipped `custom.css` (the tag ships it in `public/custom`, which the symlink replaces); the app creates `settings.json` itself when absent. Express binds all interfaces. `saved/` (image and mp3 cache) goes to `/tmp` as a cache; it is rebuilt after a restart. The directory targets must exist before node starts because `existsSync` on a dangling symlink is false and `mkdirSync` would then fail with `EEXIST`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/posterr/index.js
- /app/posterr/healthcheck.js
- /usr/share/licenses/posterr/LICENSE
```
`healthcheck.js` treats 200/301/302 as healthy, so `/` is a valid probe; confirm the exact status (UNVERIFIED) in step 3 and set `statusCode` if it is a redirect. The app starts without any env vars, so nothing is hidden from the test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `./config/settings.json` | `/app/posterr/config` symlink to `/config/config` |
| `./public/custom/**` (user pictures; chart PVC `/usr/src/app/public/custom`) | symlink to `/config/custom` |
| `./saved/imagecache`, `./saved/mp3cache` | symlink to `/tmp/saved` (cache, ephemeral) |
| npm cache | `/tmp/.npm`, removed at build |
| `node_modules` | built into `/app/posterr/node_modules`, read-only |

Draft reconciliation: chart uses UID 0 and `readOnlyRootFilesystem: false`; this image runs as `apps` with a read-only rootfs. The chart's two PVCs (`/usr/src/app/config`, `/usr/src/app/public/custom`) collapse into one `/config` volume (`config/` and `custom/` subdirectories); users migrating must copy their old directories. Not privileged.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: upstream writes inside the app folder; the symlink plan removes that. The draft's arm64 doubt is moot: we build from source tarball (JS only), so there is no per-arch binary.
- Version mismatch in the draft (v1.15.0 binaries zip) vs the real current tag (v1.21.18). If maintainers prefer GitHub *releases*, Renovate will stay on 1.15.0, so `github-tags` is used.
- UNVERIFIED: Node major in `python-node` and whether any transitive dependency needs a native build (add `build-essential python3` temporarily as `apps/budge` does if `npm ci` fails on arm64).
- `classes/core/cache.js` requires the deprecated `request` package, which is only present transitively (in the lockfile); install with `npm ci` so the lockfile is honored.
- `/tmp` is a RAM tmpfs: a large poster cache consumes memory. Alternative is `/config/saved` (persistent), rejected because it is a cache.
- Plex token is stored in plaintext in `/config/config/settings.json`.
- Python half of the base image is unused, and `apps/python-node` no longer exists in the repo, so the pinned image may stop receiving updates. A leaner option is `ghcr.io/trueforge-org/ubuntu`, whose current Dockerfile already installs Node (UNVERIFIED that the pinned ubuntu digest includes it). Maintainer decision.
- No source checksum.

## 11. Build and test steps

```sh
cd apps/posterr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create posterr-probe-config
docker run --rm -d --name posterr-probe --read-only --tmpfs /tmp \
  -v posterr-probe-config:/config posterr:1.21.18
docker logs -f posterr-probe    # expect "Web server started on internal port 3000" and "Application ready on"
docker exec posterr-probe node /app/posterr/healthcheck.js   # expect STATUS: 200 or 302, exit 0
docker exec posterr-probe ls /config /config/config /config/custom
docker rm -f posterr-probe; docker volume rm posterr-probe-config
forgetool containers test --image posterr:1.21.18 --config ./apps/posterr/container-test.yaml
```
Restart with the same volume to confirm idempotence, and save a setting via `/settings` to prove `settings.json` is written to `/config/config`. Round limit 10; clean up each round.

## 12. PR checklist

- Branch `feat/add-posterr`; commit and PR title `feat(posterr): add new container`; base `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, tick only what applies.
- `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it (`license/cla` check).
- Honest untested list: connection to a real Plex server and poster cache download, arm64, Node version of the base, saving settings through the UI. Do not tick "Built container locally" unless built.
- Pre-completion: bake `--print` OK, `VERSION` aligned with the Dockerfile and `package.json`, rootless, read-only rootfs, empty `/config` start, tests not weakened.
