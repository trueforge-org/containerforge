# website-shot — implementation plan
> Source: ./draft.md · Target: apps/website-shot/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `0.10.2` (GitHub release/tag `v0.10.2`, published 2023-06-15). Draft pins `latest` only. Docker Hub tag mapping of `flowko1/website-shot:latest` to 0.10.2 is UNVERIFIED (package.json on `main` still says `0.4.0`). |
| Renovate | `datasource=github-releases depName=Flowko/website-shot versioning=semver` (repo is archived since 2024-03-10, so renovate will never find a newer version) |
| License | `AGPL-3.0` per GitHub API; SPDX for the bake file: `AGPL-3.0-only` (GitHub reports `AGPL-3.0`; the exact "or-later" clause is UNVERIFIED, confirm against `LICENSE` header) |
| Source | https://github.com/Flowko/website-shot |
| Download | Source tarball `https://github.com/Flowko/website-shot/archive/refs/tags/v${VERSION}.tar.gz` (arch-independent, built in image). No per-arch binary. |
| Checksum | None published by upstream. Pin integrity through `yarn.lock` plus `yarn install --frozen-lockfile`. |
| Upstream Dockerfile | Reviewed: `node:16.18.1-alpine`, WORKDIR `/usr/src/website-shot`, `apk add git chromium wqy-zenhei`, `yarn install`, `yarn generate`, `yarn build`, `EXPOSE 3000`, `CMD yarn start`. |
| Port | `3000/tcp` HTTP (Nuxt 2 server, `NUXT_HOST=0.0.0.0`, `NUXT_PORT=3000`) |
| Env vars (read by code) | `PASSWORD_PROTECT` (0/1, `nuxt.config.js` + middleware), `PASSWORD` (compared with request password; README says default `admin`, Dockerfile sets `null`), `RUNNING_DOCKER` (`1` makes puppeteer use `/usr/bin/chromium-browser`), `USER_AGENT`, `BLOCK_ADS` (set in Dockerfile; read site UNVERIFIED), `NUXT_HOST`, `NUXT_PORT` |
| Write paths | `server-middleware/utils.js` writes to `<app dir>/screenshots` (`path.join(__dirname + "/../screenshots")`, `makeDir` + `writeFileSync`). Chromium needs a writable profile/tmp dir. |
| Chromium | Launched by `puppeteer@^14.4.1` via `@cliqz/adblocker-puppeteer`/`capture-website` style options, args `--no-sandbox --disable-setuid-sandbox`, `executablePath=/usr/bin/chromium-browser` when `RUNNING_DOCKER=1`. |

## 2. Target layout

```
apps/website-shot/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: Node app built with yarn (draft). Closest sibling: `apps/budge/Dockerfile` (python-node, npm build from a GitHub tarball into `/app`). Node major shipped in the base is UNVERIFIED (budge comments mention Node 24). Nuxt 2 and webpack 4 on Node >= 17 need `NODE_OPTIONS=--openssl-legacy-provider` during build and at runtime. The python half of the base is not used by the app.

## 4. Dockerfile

1. `FROM` line above, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV` (build and runtime): `HOME=/tmp`, `NODE_OPTIONS=--openssl-legacy-provider`, `NUXT_HOST=0.0.0.0`, `NUXT_PORT=3000`, `PASSWORD_PROTECT=0`, `RUNNING_DOCKER=1`, `BLOCK_ADS=1`, `PUPPETEER_SKIP_DOWNLOAD=1`, `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1`, `PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright`, `YARN_CACHE_FOLDER=/tmp/yarn-cache`, `npm_config_cache=/tmp/npm-cache`.
3. Chromium (Ubuntu's `chromium-browser` is a snap shim, unusable in a container): install a non-snap Chromium. Plan: `npm install -g yarn@1.22.22 playwright@1.65.1` (skip yarn if already in base, check with `command -v yarn`) then `playwright install --with-deps chromium` (apt deps via Playwright, supports amd64 and arm64), then `ln -s "$(find /usr/local/share/playwright -name chrome -path '*chrome-linux*' -type f | head -1)" /usr/bin/chromium-browser`. Add a CJK font via `apt-get install -y --no-install-recommends fonts-wqy-zenhei` (upstream installs wqy-zenhei). Chromium 14-era puppeteer against a newer Playwright Chromium is UNVERIFIED (see section 10).
4. Download and build in `/app/website-shot`:
   ```
   mkdir -p /app/website-shot && curl -fsSL "https://github.com/Flowko/website-shot/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /app/website-shot --strip-components=1
   cd /app/website-shot && yarn install --frozen-lockfile && yarn generate && yarn build
   ```
5. Screenshots path: `rm -rf /app/website-shot/screenshots; ln -s /config/screenshots /app/website-shot/screenshots` (symlink into the persistent volume, `/app` itself stays read-only at runtime).
6. License: `mkdir -p /usr/share/licenses/website-shot && cp /app/website-shot/LICENSE /usr/share/licenses/website-shot/`.
7. Cleanup: `rm -rf /tmp/* /var/lib/apt/lists/*`, `chown -R root:root /app && chmod -R a+rX /app`.
8. `COPY --chmod=0755 . /` then `EXPOSE 3000`, `VOLUME /config`, `WORKDIR /app/website-shot`, `CMD ["/start.sh"]`.
9. Final line order: `USER apps` before `COPY --chmod=0755 . /` (as in adguardhome-sync), image ends with `USER apps`.

## 5. docker-bake.hcl

- `APP` = `website-shot`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=Flowko/website-shot versioning=semver
  default = "0.10.2"
  ```
- `LICENSE` = `AGPL-3.0-only` (confirm), `SOURCE` = `https://github.com/Flowko/website-shot/`
- Targets and group exactly as in `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default" { targets = ["image-local"] }`.
- Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Flowko/website-shot/"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: PASSWORD_PROTECT
    default: "0"
    required: false
  - name: PASSWORD
    default: "admin"
    required: false
  - name: USER_AGENT
    default: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
    required: false
  - name: BLOCK_ADS
    default: "1"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none (no `dependencies:` block). `PASSWORD` default matches the README (`admin`), which only matters when `PASSWORD_PROTECT=1`.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `mkdir -p /config/screenshots /tmp/website-shot` (idempotent; never touches `/app`).
- `export HOME=/tmp NUXT_HOST=${NUXT_HOST:-0.0.0.0} NUXT_PORT=${NUXT_PORT:-3000} PASSWORD_PROTECT=${PASSWORD_PROTECT:-0} PASSWORD=${PASSWORD:-admin} RUNNING_DOCKER=1`.
- `cd /app/website-shot`
- `exec yarn start` (or `exec node_modules/.bin/nuxt start` to skip yarn writing anything, preferred so signals reach Nuxt directly).
- Secrets: `PASSWORD` stays in the environment, never written to a file or command line.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '3000'
  path: /
tcp:
- port: '3000'
filePaths:
- /app/website-shot/.nuxt
- /usr/bin/chromium-browser
- /usr/share/licenses/website-shot/LICENSE
```

`timeoutSeconds`: copy the value from a Node sibling (`apps/budge/container-test.yaml`, if it sets one; otherwise omit). Test runs without env vars, so the password-protected code path is not covered (run it by hand per section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `<app>/screenshots` | build-time symlink to `/config/screenshots`, created by `start.sh` |
| Chromium profile and crash dumps (`~/.config`, `/tmp/.org.chromium*`) | `HOME=/tmp`, `--tmpfs /tmp` |
| yarn/npm caches | `/tmp` |
| Nuxt build output `.nuxt` | produced at build time into `/app`, read-only at runtime |

Draft security expectations: runAsUser 1000, rootfs writable. Image runs as UID 568 (`apps`), rootfs read-only is supported by the remaps above. Extra persistence `/usr/src/website-shot/screenshots` maps to `/config/screenshots`. Chromium sandbox is disabled by upstream args (`--no-sandbox`), so no extra capabilities are needed.

## 10. Risks, caveats and open questions

- Upstream is archived (2024-03-10): no security fixes; stale Nuxt 2, webpack 4, puppeteer 14.
- Chromium source: UNVERIFIED that a Playwright Chromium works with puppeteer 14 over CDP; fallback is `PUPPETEER_EXECUTABLE_PATH` with a Chrome-for-Testing download (amd64 only, no linux arm64 build) which would force amd64-only.
- Node version of the python-node base is UNVERIFIED; if it is >= 17, keep `--openssl-legacy-provider`. If the dependency tree fails (draft caveat), consider pinning an older Node via a separate download.
- Memory-hungry Chromium: recommend >= 1 GiB limit.
- `BLOCK_ADS` read location UNVERIFIED (set in upstream Dockerfile).
- Renovate cannot track new versions (archived repo).
- Draft's `docker.io/flowko1/website-shot:latest` could differ from tag `v0.10.2`; compare behaviour once built.

## 11. Build and test steps

```sh
cd apps/website-shot
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create website-shot-probe-config
docker run --rm -d --name website-shot-probe --read-only --tmpfs /tmp \
  -v website-shot-probe-config:/config website-shot:0.10.2
docker logs -f website-shot-probe
forgetool containers test --image website-shot:0.10.2 --config ./apps/website-shot/container-test.yaml
docker rm -f website-shot-probe; docker volume rm website-shot-probe-config
```

Expected readiness: Nuxt log line `Listening on: http://0.0.0.0:3000`. Manual extra: take a screenshot via the UI/API, and rerun with `-e PASSWORD_PROTECT=1 -e PASSWORD=x` to confirm the password path. Try arm64 only if amd64 passes.

## 12. PR checklist

- Branch `feat/add-website-shot`, commit `feat(website-shot): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, check only boxes that apply; put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Honest untested list: no build run, no arm64 run, Chromium/puppeteer compatibility, Node base version, password-protected path, license SPDX "only vs or-later".
