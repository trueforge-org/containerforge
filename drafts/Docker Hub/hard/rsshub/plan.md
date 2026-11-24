# rsshub — implementation plan
> Source: ./draft.md · Target: apps/rsshub/ · Difficulty: hard in the draft (Chrome sidecar), medium for the main image · Role: main (the browserless sidecar is not built) · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `v2026.11.24-8752.ga8c0f05` (latest GitHub release of DIYgod/RSSHub, published 2026-11-24 per the API; the release tag changes almost daily) |
| Draft tag | `browserless/chrome:1.61.1-chrome-stable` (linked as the source repository, https://github.com/browserless/chrome). The draft's source and link point at the Chrome sidecar. The real application is DIYgod/RSSHub. The plan packages RSSHub and does not package browserless. |
| Renovate | `datasource=github-releases depName=DIYgod/RSSHub versioning=loose`. UNVERIFIED: whether the git-describe style tag (`v2026.11.24-8752.ga8c0f05`) is accepted as a valid version by renovate's loose versioning, and whether the daily churn is acceptable (consider pinning updates to weekly in the renovate config). |
| License | AGPL-3.0 (RSSHub repository). UNVERIFIED: not re-fetched this session. SPDX `AGPL-3.0-only`. |
| Source | https://github.com/DIYgod/RSSHub (docs https://docs.rsshub.app/) |
| Download URLs | No release assets are used. Build from the tagged source: `https://github.com/DIYgod/RSSHub/archive/refs/tags/${VERSION}.tar.gz` (standard GitHub archive URL, UNVERIFIED for this tag name containing `+`/`.` characters). |
| Checksum | None published. Pin the tag only (git tags are immutable by convention). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/DIYgod/RSSHub/master/Dockerfile (summary): multi-stage on `node:26-trixie` / `node:26-trixie-slim`; corepack + pnpm, `pnpm install --frozen-lockfile` with `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true`, `pnpm rb`, `pnpm build`, `minify-docker.js` to prune dependencies; final stage copies the minified `/app`; ENV `NODE_ENV=production`, `TZ=Asia/Shanghai`, `PLAYWRIGHT_BROWSERS_PATH=/app/node_modules/.cache/ms-playwright`, `LD_PRELOAD=libjemalloc.so.2`; `EXPOSE 1200`; `ENTRYPOINT ["dumb-init","--"]`, `CMD ["npm","run","start"]`; no `USER`; `/app/.env` written at build with `CHROMIUM_EXECUTABLE_PATH`. |
| Ports | 1200/tcp (RSSHub). The sidecar's 3000 is not part of this image. |
| Env vars (docs.rsshub.app/deploy/config) | `PORT` default 1200; `LISTEN_INADDR_ANY` default 1; `CACHE_TYPE` default `memory` (or `redis`, or empty to disable); `REDIS_URL` default `redis://localhost:6379/` (only for redis cache); `PLAYWRIGHT_WS_ENDPOINT` and its alias `PUPPETEER_WS_ENDPOINT` (remote browser); `CHROMIUM_EXECUTABLE_PATH` (local browser); `ACCESS_KEY` (unset by default); `LOGGER_LEVEL` default `info`. |

## 2. Target layout

- `apps/rsshub/Dockerfile`
- `apps/rsshub/docker-bake.hcl`
- `apps/rsshub/settings.yaml`
- `apps/rsshub/container-test.yaml`
- `apps/rsshub/start.sh`

No `defaults/` (RSSHub is configured by env only). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Build stage: `FROM docker.io/library/node:26-trixie AS build` (copy the exact digest-pinned form the upstream Dockerfile uses at implementation; UNVERIFIED digest). Final stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` as the draft says, provided `node -v` in that image meets RSSHub's `engines` requirement (upstream builds on Node 26, UNVERIFIED for the python-node image). If the Node major differs, use the ubuntu base instead and `COPY --from=build /usr/local/bin/node` plus `/usr/local/lib/node_modules` into it. Closest sibling: `apps/budge`/`apps/changedetection` (python-node final stages).

## 4. Dockerfile

1. Build stage: `corepack enable`, extract the source tarball for `${VERSION}` into `/build`, then follow the upstream recipe verbatim: `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true pnpm install --frozen-lockfile`, `pnpm build`, then the `minify-docker.js` step that produces a minimal `/app` (reproduce the upstream stage order; do not invent the minifier command, copy it from the upstream Dockerfile at the tag).
2. Final stage: `ARG VERSION`, `USER root`.
3. apt packages in the final stage (check `dpkg -l` in the base first, only add what is missing): `dumb-init` (upstream entrypoint; may be replaced by `exec` in `start.sh` and then not needed), `libjemalloc2` (only if keeping `LD_PRELOAD`; optional), `ca-certificates`. No Chromium: browser routes use a remote browser through `PLAYWRIGHT_WS_ENDPOINT` (section 10).
4. `COPY --from=build /app /app`; `chown -R apps:apps /app && chmod -R 755 /app`.
5. Licenses: `mkdir -p /usr/share/licenses/rsshub && cp /app/LICENSE /usr/share/licenses/rsshub/` (UNVERIFIED that the minifier keeps `LICENSE`; copy it in the build stage instead).
6. `ENV NODE_ENV=production TZ=Etc/UTC HOME=/config npm_config_cache=/tmp/.npm XDG_CACHE_HOME=/tmp PLAYWRIGHT_BROWSERS_PATH=/tmp/ms-playwright`. Do not keep the upstream `PLAYWRIGHT_BROWSERS_PATH` under `/app` unless the browser is bundled (it is not).
7. `USER apps`, then `COPY --chmod=0755 . /`.
8. `EXPOSE 1200`, `VOLUME /config`, `WORKDIR /app`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "rsshub" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=DIYgod/RSSHub versioning=loose
  default = "v2026.11.24-8752.ga8c0f05"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/DIYgod/RSSHub" }
```
Targets: `docker-metadata-action`, `image` (arg `VERSION`, OCI labels), `image-local`, `image-all` (amd64, arm64; both work because there is no bundled browser), `group "default"`. Validate with `docker buildx bake --print`. The image tag will contain a long git-describe string; if that is not acceptable, use only the date part `2026.11.24` for `VERSION` and look up the tag with a build step (UNVERIFIED, open question for the user).

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/DIYgod/RSSHub"`.
- `ports`: `1200` tcp, required false.
- `env` (all from the RSSHub config docs): `PORT` 1200; `LISTEN_INADDR_ANY` `1`; `CACHE_TYPE` `memory`; `REDIS_URL` `redis://localhost:6379/` (only used when `CACHE_TYPE=redis`); `PLAYWRIGHT_WS_ENDPOINT` default `""`; `ACCESS_KEY` default `""`; `LOGGER_LEVEL` `info`; `TZ` `Etc/UTC`. All required false.
- `volumes`: `/config` required false (RSSHub is stateless with the memory cache; keep it declared as the working HOME).
- `dependencies:` none required. Optional: `valkey` ✅ (exists in apps/, used with `CACHE_TYPE=redis`).

## 7. start.sh

- `set -eu`; export defaults that match settings.yaml (`PORT`, `LISTEN_INADDR_ANY`, `CACHE_TYPE`, `LOGGER_LEVEL`).
- If `PLAYWRIGHT_WS_ENDPOINT` is empty and `PUPPETEER_WS_ENDPOINT` is set, nothing to do (RSSHub falls back itself per the docs).
- `cd /app`, no writes to `/app`; `mkdir -p /tmp/.npm`.
- Final command (verified upstream CMD): `exec npm run start`. Alternative to avoid the npm layer: `exec node <entry from the "start" script in package.json>` (UNVERIFIED entry path, read `package.json` of the tag). Signal handling: `exec` replaces `dumb-init`.
- Binding: `LISTEN_INADDR_ANY=1` makes it listen on all interfaces.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
http:
- port: '1200'
  path: /
```
The browser-route path (remote Chrome) is not covered, since the test has no env and no sidecar; test it by hand against a browserless/chrome container.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects root and `readOnlyRootFilesystem: false` with no extra persistence. Reconciled: user `apps` 568, read-only rootfs, `/tmp` for npm and Playwright caches, `/config` only as HOME.
- Upstream write paths: `/app/.env` (build time only, not needed because no local Chromium), `/app/node_modules/.cache/ms-playwright` (moved to `/tmp`), npm cache (`npm_config_cache=/tmp/.npm`), RSSHub logs (UNVERIFIED, expected stdout).
- The upstream image has no `USER`, so it runs as root; ours runs as 568 and must not need a privileged port (1200 is fine).

## 10. Risks, caveats and open questions

- The draft sidecar (browserless/chrome 1.61.1 on port 3000, needs `--shm-size` and sandbox flags) is not packaged: that image is old, and bundling Chromium into a rootless read-only image is the hard part. This plan uses a remote browser via `PLAYWRIGHT_WS_ENDPOINT`. Ask whether a separate `chrome`/browserless app should be added instead.
- RSSHub needs a recent Node (upstream builds on 26); python-node's Node version is UNVERIFIED.
- Build size and time: a full pnpm install of the monorepo; the `minify-docker.js` pruning step must be reproduced exactly.
- Tag format (daily git-describe) causes renovate churn.
- Upstream sets `LD_PRELOAD=libjemalloc.so.2`; keeping it needs `libjemalloc2`, otherwise drop it (memory behaviour differs, not a functional issue).
- arm64 is fine since the Node app is arch independent and no browser is bundled.

## 11. Build and test steps

Follow `.github/instructions/build-test-protocol.instructions.md` for `apps/rsshub`, one app at a time, 10 rounds at most.

```sh
cd apps/rsshub
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create rsshub-probe-config
docker run --rm -d --name rsshub-probe --read-only --tmpfs /tmp \
  -v rsshub-probe-config:/config rsshub:v2026.11.24-8752.ga8c0f05
docker logs -f rsshub-probe
forgetool containers test --image rsshub:v2026.11.24-8752.ga8c0f05 --config ./apps/rsshub/container-test.yaml
docker rm -f rsshub-probe; docker volume rm rsshub-probe-config
```

- Expected readiness signal: RSSHub log line "Listening on 0.0.0.0:1200" style message (UNVERIFIED wording) and HTTP 200 on port 1200.
- Always start with an empty `/config` volume (fresh volume each round).
- By-hand checks outside the test: request a feed route (for example /rsshub/routes), run with CACHE_TYPE=redis against the valkey app, and a browser route against a remote Chrome through PLAYWRIGHT_WS_ENDPOINT.
- Only try arm64 if an amd64 build is green and a failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-rsshub` from a freshly pulled `main`; commit and PR title `feat(rsshub): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` keeping its sections; check only the boxes that apply. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows the status). Only the user can sign it.
- Confirm: changes only in `apps/rsshub/`; `ARG VERSION` matches `docker-bake.hcl`; `docker buildx bake --print` passes; final `USER apps`; `COPY --chmod=0755 . /` present; runs read-only with empty `/config`; no assertion weakened.
- Not tested, to state honestly in the PR unless done: arm64, redis cache, remote-browser routes, long-running memory behaviour.
