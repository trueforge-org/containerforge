# littlelink — implementation plan
> Source: ./draft.md · Target: apps/littlelink/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases (API returns 404). The draft image is `ghcr.io/techno-tim/littlelink-server:latest` (rolling). Pin the commit that the draft's Dockerfile came from: `e7fa7dbb3178fcd963e6472f25e96a874f496a11`. UNVERIFIED: the commit behind upstream `latest`. |
| Renovate | `datasource=git-refs depName=https://github.com/techno-tim/littlelink-server currentValue=main` (precedent `apps/fenrus`, which pins a commit the same way). |
| License | MIT for `timothystewart6/littlelink-server` (GitHub SPDX `MIT`). UNVERIFIED for the `techno-tim/littlelink-server` fork that the Dockerfile lives in; confirm before merge. Source: https://api.github.com/repos/timothystewart6/littlelink-server |
| Source URL | Draft lists three repos. Image comes from `techno-tim/littlelink-server` (Dockerfile source, commit above). Application source is `timothystewart6/littlelink-server` (main branch, `package.json` version 1.0.0). Plan builds the Dockerfile's own commit so the image matches upstream. UNVERIFIED that the two trees are identical at that commit. |
| Download | Source archive `https://github.com/techno-tim/littlelink-server/archive/${VERSION}.tar.gz` (VERSION = commit SHA). Content-addressed by the commit. Not the draft's `master.tar.gz`, which moves. |
| Checksum source | None published (no release assets). Pinned by commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/techno-tim/littlelink-server/e7fa7dbb3178fcd963e6472f25e96a874f496a11/Dockerfile: every stage `node:26.12.1-alpine@sha256:40cd011b...` (musl). Yarn Classic 1.22.22 installed with npm. Frozen-lockfile `yarn install`. `yarn build`. Removes linux `sharp` libvips from the standalone output. Final stage copies `.next/standalone`, `.next/static`, `public` owned by `node`. `EXPOSE 3000`, `USER node`, `CMD ["node","server.js"]`, `WORKDIR /usr/src/app`, `HOSTNAME=0.0.0.0`, `PORT=3000`, `NEXT_TELEMETRY_DISABLED=1`. HEALTHCHECK `wget http://127.0.0.1:3000/healthcheck`. |
| package.json | https://raw.githubusercontent.com/timothystewart6/littlelink-server/main/package.json: `build` = `next build && tsc -p tsconfig.server.json`, `start` = `NODE_ENV=production node dist-server/server.js`. The upstream image runs `server.js` from the standalone output. UNVERIFIED which entry point the chosen commit's image should run; the plan follows the Dockerfile's `CMD`. |
| Port | 3000/tcp (README example maps `8080:3000`). |
| Env vars (README) | Profile: `NAME`, `BIO`, `AVATAR_URL`, `AVATAR_2X_URL`, `AVATAR_ALT`, `FAVICON_URL`, `THEME`, `FOOTER`. Meta: `META_TITLE`, `META_DESCRIPTION`, `META_AUTHOR`, `META_KEYWORDS`, `LANG`, `META_INDEX_STATUS`, `OG_SITE_NAME`, `OG_TITLE`, `OG_DESCRIPTION`, `OG_URL`, `OG_IMAGE`, `OG_IMAGE_WIDTH`, `OG_IMAGE_HEIGHT`. Robots: `ROBOTS_ADDITIONAL_RULES`, `ROBOTS_TXT`. Buttons: `BUTTON_ORDER`, `CUSTOM_BUTTON_TEXT`, `CUSTOM_BUTTON_URL`, `CUSTOM_BUTTON_COLOR`, `CUSTOM_BUTTON_TEXT_COLOR`, `CUSTOM_BUTTON_ALT_TEXT`, `CUSTOM_BUTTON_NAME`, `CUSTOM_BUTTON_ICON`. Social platform names (`GITHUB`, `TWITTER`, `INSTAGRAM`, `LINKED_IN`, `YOUTUBE`, `TWITCH`, `DISCORD`, `TIKTOK`, `FACEBOOK`, `PATREON`). Analytics: `GA_TRACKING_ID`. `TZ`. Source: https://raw.githubusercontent.com/timothystewart6/littlelink-server/main/README.md |
| Config model | Configuration is read at request time from env (README: restart applies changes). No config file and no data directory are documented. |
| Data paths | None documented. UNVERIFIED: no writable path in README or Dockerfile. |
| Dependencies | None: no database, one process. |

## 2. Target layout

- `apps/littlelink/Dockerfile`
- `apps/littlelink/docker-bake.hcl`
- `apps/littlelink/settings.yaml`
- `apps/littlelink/container-test.yaml`
- `apps/littlelink/start.sh`

No `defaults/`, `etc/` or `health/` needed: all configuration is env. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Upstream's final stage is alpine/musl, so `COPY --from=` of the upstream image is not usable on glibc Ubuntu (the draft already says `copy-from: no`). The build runs from source on the python-node base, which provides Node. Node major shipped by `python-node:3.15.2` is UNVERIFIED here (the budge Dockerfile comment suggests Node 24). Closest siblings: `apps/budge` and `apps/changedetection` (python-node with a Node build step).

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), `ARG TARGETARCH`, `USER root`. `ENV NEXT_TELEMETRY_DISABLED=1 NODE_ENV=production HOSTNAME=0.0.0.0 PORT=3000`.
2. Install Yarn Classic: `npm install -g yarn@1.22.22` (matches upstream's pinned yarn; the base has npm).
3. Download source: `curl -fsL -o /tmp/littlelink.tar.gz "https://github.com/techno-tim/littlelink-server/archive/${VERSION}.tar.gz"` and extract into `/app/littlelink` with `--strip-components=1`. Remove the archive.
4. Dependencies: `cd /app/littlelink && yarn install --frozen-lockfile --cache-folder /tmp/yarn`.
5. Build: `NEXT_TELEMETRY_DISABLED=1 yarn build`. UNVERIFIED that `yarn build` works without the upstream `sharp` removal step; if `sharp` fails on musl-free glibc, follow upstream and remove the linux `sharp` libvips packages from the standalone output (`rm -rf .next/standalone/node_modules/@img/sharp-linux*`).
6. Prune: `yarn install --production --frozen-lockfile --cache-folder /tmp/yarn` only if the standalone output needs it (standalone already includes runtime deps). Then `rm -rf /tmp/yarn /tmp/*`.
7. Licence: copy `LICENSE` from the source tree to `/usr/share/licenses/littlelink/LICENSE` (UNVERIFIED: file exists in the techno-tim tree; if not, fetch from the timothystewart6 MIT repo at `main` and record the source).
8. Assemble runtime layout (still under `/app`, which is read-only at runtime): `/app` = standalone output (`.next/standalone` content), `.next/static` copied to `/app/.next/static`, `public` to `/app/public`. Do this at build time, so `/app` is never written at runtime.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
WORKDIR /app
```

No `VOLUME`: the app has no persistent state (no `/config` required). UNVERIFIED that the chart has no `/config` need: the draft says no persistence block. If an empty `/config` is required for the probe, add `VOLUME /config` and an empty `start.sh` seed step; do not invent state.

Use `CMD` only through `start.sh`: `start.sh` ends with `exec node server.js`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "littlelink"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/techno-tim/littlelink-server currentValue=main
  default = "e7fa7dbb3178fcd963e6472f25e96a874f496a11"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/techno-tim/littlelink-server"
}
```

Then the standard `group "default"`, `target "image"` (args `VERSION`, OCI labels `source` and `licenses`), `image-local` (tag `${APP}:${VERSION}`; a commit SHA tag is long, so `${APP}:${substr(VERSION, 0, 12)}` is acceptable: check sibling convention, UNVERIFIED), `image-all` (linux/amd64, linux/arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/timothystewart6/littlelink-server"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: NAME
    default: ""
    required: false
  - name: BIO
    default: ""
    required: false
  - name: THEME
    default: ""
    required: false
  - name: META_TITLE
    default: ""
    required: false
  - name: LANG
    default: "en"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
```

- Only the README-documented names are listed (the full list is in section 1). Add the rest as needed; each is documented upstream, so listing is not invented. Defaults for profile values are empty (the upstream defaults are UNVERIFIED; leave empty rather than guess).
- `LANG` default `en` is a guess: UNVERIFIED; set to empty if the app has no default. Keep consistent with the app's own default during the run.
- `volumes`: none, since the app keeps no state (section 4).
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash

export PORT="${PORT:-3000}"
export HOSTNAME="${HOSTNAME:-0.0.0.0}"
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1

cd /app || exit 1
exec node server.js
```

- No seeding, no writes: configuration is read from env per request (README).
- Binds `0.0.0.0` via `HOSTNAME` so other containers can reach it.
- `exec` so `node` is PID 1.
- The draft says the profile content is set by a config file the operator must create (inferred). The README says env, not a file (section 1). Plan follows the README; the draft caveat is recorded as not confirmed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/server.js
- /app/.next/static
- /usr/share/licenses/littlelink/LICENSE
```

- Port 3000 has both probes (settings lists it).
- UNVERIFIED: `/` returns 200 with no env; the upstream healthcheck uses `/healthcheck`, so use `/healthcheck` if `/` does not return 200, and record why.
- `filePaths` check the server entry (standalone `server.js`), the static output and the licence.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| None documented (no data dir, no config file) | Nothing to remap. |
| Next.js cache `.next/cache` at runtime (UNVERIFIED whether `next` standalone writes it) | If the app writes at runtime, the read-only rootfs fails. Decide after the run in section 11. Options: set the cache elsewhere if supported, or document the failing path. Do not write into `/config` for a cache. |
| Yarn/npm caches during build | `--cache-folder /tmp/yarn`, `/tmp/*` removed in the same layer |
| Upstream `USER node` | Replaced by `USER apps` (base image rule). |
| Upstream alpine base | Replaced by python-node glibc base (section 3). |

Draft security expectations reconciled: chart runs as 568, read-only rootfs true, not privileged. The image fits `--read-only --tmpfs /tmp` on paper; the runtime cache question is the one to confirm.

## 10. Risks, caveats and open questions

- No releases and no tags: the commit pin is rolling only through Renovate's git-refs datasource. Each push to `main` of the techno-tim repo will propose a bump.
- Three source repos (draft): the image comes from `techno-tim`, the app source is `timothystewart6`. Confirm the canonical repo before merge; this plan pins the techno-tim commit because that is the Dockerfile the image was built from.
- Licence of the techno-tim fork is UNVERIFIED (section 1).
- The upstream `latest` image is rolling, so the pinned commit may not equal what users run today. Record this in the PR.
- `sharp` (libvips) on glibc: the upstream step removed the musl build; the glibc build may need the same removal or a different sharp binary (UNVERIFIED, section 4 step 5).
- arm64: UNVERIFIED for the build (native `sharp` on arm64).
- Blockers: none known. Not musl-only at runtime (the build is done on glibc here), no GPU, not privileged, no dependency containers.

## 11. Build and test steps

```sh
cd apps/littlelink
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name littlelink-probe --read-only --tmpfs /tmp \
  -e NAME=test littlelink:e7fa7dbb3178
docker logs -f littlelink-probe
forgetool containers test --image littlelink:e7fa7dbb3178 --config ./apps/littlelink/container-test.yaml
docker rm -f littlelink-probe
```

- No volume is needed (no `/config`); the run still uses `--tmpfs /tmp`.
- Expected readiness signal: Next.js startup line (`ready - started server on 0.0.0.0:3000` is the usual form; UNVERIFIED for this build) and the port open.
- Check the `/` (or `/healthcheck`) status code from the host after `-p 3000:3000`.
- Check whether the run writes under `/app` (the read-only rootfs will show it in the log as `EROFS`).
- arm64 only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-littlelink`, commit and PR title `feat(littlelink): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Untested to state honestly: the build on arm64, the `sharp` handling on glibc, the runtime cache writes under `--read-only`, the status code of the probe path, and which source repo is canonical.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
