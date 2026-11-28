# agregarr — implementation plan
> Source: ./draft.md · Target: apps/agregarr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2.4.2` (GitHub release `v2.4.2`, published 2026-03-17). Matches the chart tag `v2.4.2`. Confirmed via `gh api repos/agregarr/agregarr/releases/latest`. |
| Renovate | `datasource=github-releases depName=agregarr/agregarr versioning=semver` (proposed; the version is confirmed, the annotation is a proposal). |
| License | GPL-3.0 (GitHub SPDX). Source: https://api.github.com/repos/agregarr/agregarr |
| Source URL | https://github.com/agregarr/agregarr |
| Per-arch download | **None**. The release `v2.4.2` has no assets. Only the source archive for the tag is available (`https://github.com/agregarr/agregarr/archive/refs/tags/v2.4.2.tar.gz`, not downloaded in this run). No npm package (`"private": true`). So amd64 and arm64 are builds from source, not downloads. |
| Checksum source | None published on the release. Verify the source archive by the tag commit SHA if pinned (UNVERIFIED: commit SHA for `v2.4.2` not resolved in this run). |
| Upstream Dockerfile reviewed | Blob `4a101503a89ebfbb3d8ba63445f87053b11b991a`. Builder `node:20.19.5-alpine`: apk build deps, `yarn install --frozen-lockfile`, `yarn build`, prod `yarn install --production --ignore-scripts`. Final `node:20.19.5-alpine`: fonts, Chromium, Deno (`deno@edge`), `yt-dlp` (unpinned latest download), `COPY --from=build_image /app ./`, `ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`, `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium`, `ENTRYPOINT ["/sbin/tini","--"]`, `CMD ["yarn","start"]`, `EXPOSE 7171`. No `USER`. |
| Port | **7171** (upstream `EXPOSE 7171`; chart service `port 7171`, `targetPort 7171`). The draft's `3000` is wrong and must not be used. |
| Start command | `package.json` `start` = `NODE_ENV=production node dist/index.js`. |
| Env vars | `NODE_ENV=production` (from `start`). `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD`, `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH` are set by the upstream image. Others UNVERIFIED (the server source was not read in this run). |
| Data path | `/app/config` (chart mount `/app/config`; upstream writes `/app/config/DOCKER` and `/app/config/fonts`). |
| Dependencies | None required by the image. Media-server and request-service keys are entered in the UI (draft claim, UNVERIFIED). |
| Draft versus verified | Draft's port 3000 is wrong (7171). Draft's `copy-from` = `no` is correct (upstream is musl). Draft's `amd64`/`arm64` = `yes` is not supported by a release asset; it means a source build. |

## 2. Target layout

- `apps/agregarr/Dockerfile`
- `apps/agregarr/docker-bake.hcl`
- `apps/agregarr/settings.yaml`
- `apps/agregarr/container-test.yaml`
- `apps/agregarr/start.sh`

`defaults/` is not needed. `etc/` is needed only for the fontconfig file (section 4 step 5) if the Dockerfile cannot write it at build time, which it can, so no `etc/` copy. Never `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, as the draft says. The upstream runtime is Node 20.19.5; `python-node` ships Node 24 per the repo comment in `apps/budge`. Node 24 compatibility of this app is UNVERIFIED and must be proven by the build and run. Closest sibling: `apps/budge` (node app on python-node). Fallback: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` with the Node runtime added from a pinned source.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `ARG COMMIT_TAG`, `USER root`.
2. Install build deps for the native modules that the upstream builder uses (from the glibc base, use `apt-get` for `build-essential`, `python3`, `libcairo2-dev`, `libpango1.0-dev`, `libjpeg-dev`, `libgif-dev`, `libpixman-1-dev`; exact package names and availability for Ubuntu 26.04 UNVERIFIED, pin per `apps/valkey` style if they are versioned).
3. Source: `curl -fL https://github.com/agregarr/agregarr/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1` (the tag is `v2.4.2`, so `VERSION` must be the bare `2.4.2` form, matching the bake value, or the URL must add `v`). Record the commit SHA for the tag in the PR (UNVERIFIED).
4. `corepack enable` or `npm install -g yarn@<pinned>` (the upstream uses the Yarn version that the repo declares; check the lockfile format before pinning; UNVERIFIED which Yarn release the repo uses).
5. `cd /tmp/src && yarn install --frozen-lockfile`, then `yarn build`, then `yarn install --production --ignore-scripts --prefer-offline`.
6. Replicate the upstream prep: `rm -rf src server .next/cache`, `mkdir -p config && touch config/DOCKER`, `echo '{"commitTag":"..."}' > committag.json` (keep `COMMIT_TAG` as a build arg).
7. Final stage `FROM <python-node>`. Install the runtime packages from the upstream list that the base lacks: `tzdata`, `tini`, `fontconfig`, `ffmpeg`, `python3` (check against the base first; `python3` and `ffmpeg` may already be present). Chromium: install from the Ubuntu archive (`chromium` or `chromium-browser`, UNVERIFIED package name on 26.04) and set `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH` to its path. Deno: the Alpine edge package has no direct Ubuntu equivalent; decide between the `deno` Ubuntu package or the official release binary with a pinned checksum (UNVERIFIED availability; this is an open risk, section 10).
8. Fonts: the upstream downloads about 25 Google Fonts and Fira Code. Keep the same set, fetched from pinned commits or the Google Fonts repository tag (UNVERIFIED pinning; prefer pinned URLs and record checksums).
9. Fontconfig: write `/etc/fonts/conf.d/99-agregarr-custom-fonts.conf` pointing at `/app/config/fonts`. This is a read-only path (`/app`), so the custom-fonts dir must be `/config/fonts`, not `/app/config/fonts`. Adjust the conf path and `start.sh` to match (section 7).
10. `yt-dlp`: download `yt-dlp` from its release, pinned by version (not `latest`), with its checksum from the release's `SHA2-256SUMS` (UNVERIFIED file name; check the release page). Set `chmod a+rx`.
11. Copy the built app: `COPY --from=build /tmp/src /app` then `chown -R apps:apps /app && chmod -R 755 /app`. Ship the license: `mkdir -p /usr/share/licenses/agregarr && cp /app/LICENSE /usr/share/licenses/agregarr/LICENSE`.
12. Tail:

```dockerfile
ENV NODE_ENV=production \
    HOME=/config \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium

USER apps
COPY --chmod=0755 . /

EXPOSE 7171
VOLUME /config
CMD ["/start.sh"]
```

Cleanup in the same layer as each install: `rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "agregarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=agregarr/agregarr versioning=semver
  default = "2.4.2"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/agregarr/agregarr"
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

`LICENSE` is `GPL-3.0`, matching upstream `package.json` (`"license": "GPL-3.0"`) and the GitHub SPDX value. No `-only`/`-or-later` is claimed. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/agregarr/agregarr"
ports:
  - port: 7171
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Do not list `NODE_ENV` or the Playwright variables as user env (they are image-internal). Add app variables only after they are confirmed in the server source. `/config` is the persistent path; the chart's `/app/config` mount is replaced by `/config` through the build-time symlink (section 7).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/fonts
touch /config/DOCKER

# /app/config is a build-time symlink to /config (Dockerfile), so /app is never written here.
cd /app || exit 1
export NODE_ENV=production
exec node dist/index.js
```

- `/app/config` is needed by the app and step 6 creates it at build time as `config/DOCKER`. Add to the Dockerfile (after step 6): `rm -rf /app/config && ln -s /config /app/config`. Because the upstream `DOCKER` marker then lives in the volume, `start.sh` must `touch /config/DOCKER` (add it after the `mkdir`), idempotent. UNVERIFIED that the app only checks for the marker's existence.
- Upstream `CMD` is `yarn start`, whose script is `NODE_ENV=production node dist/index.js` (confirmed in `package.json`). `exec node dist/index.js` with `NODE_ENV=production` gives a direct PID 1 signal path.
- Listen address: confirm the server binds `0.0.0.0` (or `::`). Next.js binds to all interfaces by default when `HOSTNAME` is unset; confirm for the custom server in `dist/index.js` (UNVERIFIED). If it defaults to localhost, set the confirmed host variable.
- Fontconfig must point at `/config/fonts` (not `/app/config/fonts`) once the symlink exists; the build writes the conf with `/config/fonts` directly.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '7171'
http:
- port: '7171'
  path: /
filePaths:
- /app/dist/index.js
- /app/committag.json
- /usr/share/licenses/agregarr/LICENSE
```

- Port 7171 has both `tcp` and `http` probes (the only declared port). `GET /` expected to return 200 on first run (UNVERIFIED; a first-run redirect to a setup page is possible, so confirm and adjust the path).
- `timeoutSeconds: 180` is a starting value: the Next.js app is slow to start; align with the largest sibling Node app timeout (UNVERIFIED value).
- No env is needed to start (the test runs with none).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/config` (chart PVC, config, fonts, `DOCKER` marker) | build-time symlink `/app/config -> /config`; `/config` is the volume. |
| `/app/config/fonts` (custom fontconfig dir) | `/config/fonts`, created in `start.sh` (`mkdir -p`). |
| `/tmp` (Playwright, yt-dlp, scratch) | `/tmp` (tmpfs at test time). `HOME=/config` must not hold caches: set `XDG_CACHE_HOME=/tmp/cache` if the app caches to `$HOME/.cache`. |
| Chromium profile | `/tmp` (Playwright launches with a temp profile; confirm). |
| `/app` (code and `.next`) | Read-only at runtime; the build has written `.next/cache` removal already. |
| Upstream root user | Not used. Runs as `apps` (`USER apps`). Upstream has no `USER`, so verify all paths are readable by `apps`. |

Privileged: `no`. Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- **No release binary**: the `amd64`/`arm64` "yes" in the draft is a source build, not a download. Recorded so it is not mistaken for a prebuilt binary.
- **Node 20 vs Node 24**: upstream builds on `node:20.19.5-alpine`; `python-node` ships Node 24. Native modules (`better-sqlite3` or `sharp` if used, and `node-gyp` deps) must build on Node 24 glibc. UNVERIFIED.
- **Chromium and Deno on Ubuntu**: Alpine packages (`chromium`, `deno@edge`) have no direct Ubuntu equivalent in the Dockerfile. Check the Ubuntu 26.04 archive for `chromium` and `deno`; if Deno is only an Alpine edge package, the official Deno release binary with a pinned checksum is the fallback. This is the largest open risk and may block the build.
- **yt-dlp unpinned**: the upstream downloads `latest`. The plan pins a version; the chosen version and checksum are UNVERIFIED in this run.
- **Fonts from Google Fonts `main`**: upstream uses branch `main` URLs (not pinned). Pin commits or tags when writing the Dockerfile; checksums UNVERIFIED.
- **Read-only rootfs**: the app writes `config` and maybe other paths under `/app`. The symlink approach covers `/app/config` only; any other write path found during the run is a blocker to log, not to hack around.
- **Media-server keys**: configured in the UI after start (draft claim, UNVERIFIED). Not required at start, so the test is unaffected.
- **Build time**: the yarn build and the font downloads are slow and network dependent.
- **Upstream image arch list and digest**: the chart pins `ghcr.io/agregarr/agregarr:v2.4.2@sha256:5f1390bc43fefbbfb67f38a7a8dd65b4086c1f187a37c8df5c6020a498e5d1b5`; arch list UNVERIFIED.

## 11. Build and test steps

From `apps/agregarr/`:

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local` (arm64 only if amd64 fails for an arch-specific reason).
3. Probe with an empty config volume:
   ```sh
   docker volume create agregarr-probe-config
   docker run --rm -d --name agregarr-probe --read-only --tmpfs /tmp \
     -v agregarr-probe-config:/config agregarr:2.4.2
   docker logs -f agregarr-probe
   ```
   Expected readiness signal: a Next.js/custom-server "ready" or "listening" line on port 7171 (confirm the exact text from a real run). Then `docker rm -f agregarr-probe; docker volume rm agregarr-probe-config`.
4. `forgetool containers test --image agregarr:2.4.2 --config ./container-test.yaml`.

## 12. PR checklist

- Branch `feat/add-agregarr`, commit `feat(agregarr): add new container`, PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64 build, Chromium/Deno availability if unresolved, any first-run UI flow, and the source-build reproducibility (no release asset).
- If the image could not be built or run, say so; do not tick "Built container locally".
