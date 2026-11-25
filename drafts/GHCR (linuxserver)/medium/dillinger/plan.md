# dillinger — implementation plan
> Source: ./draft.md · Target: apps/dillinger/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v3.39.1 (git tag; `package.json` version 3.39.1). Matches the chart image `ghcr.io/linuxserver/dillinger:3.39.1`. |
| Version source note | GitHub `releases/latest` is stale (returns `3.5.1`, published 2016-08-04). Use tags, not releases. Tags go up to v3.39.1. |
| Draft tag | Matches (3.39.1). |
| Renovate | `datasource=github-tags depName=joemccann/dillinger versioning=semver` (the release feed is stale, so tags are the source). |
| License | MIT (GitHub API `license.spdx_id`, joemccann/dillinger) |
| Source URL | https://github.com/joemccann/dillinger (last pushed 2026-06-21, active) |
| Download | Source tarball `https://github.com/joemccann/dillinger/archive/refs/tags/v3.39.1.tar.gz`. No release assets. Arch-independent source, built with npm on each arch. |
| Checksum source | UNVERIFIED: none published. Pinned by tag; record the sha256 at build time. |
| Upstream Dockerfile reviewed | linuxserver `docker-dillinger` @ 1d1b7d5f198a81964e0e2b1428ba7d6bd4b1526e: `FROM baseimage-alpine:3.18`; apk chromium nss freetype harfbuzz ttf-freefont npm; extracts tarball to `/app/dillinger` (`--strip-components=1`); `npm install --omit=dev --prefix /app/dillinger`; `ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser`; `EXPOSE 8080`; `VOLUME /config`; no USER, no ENTRYPOINT. (Source: facts/111.md) |
| Real launch | linuxserver `root/etc/s6-overlay/s6-rc.d/svc-dillinger/run`: `NODE_ENV=production`, `cd /app/dillinger`, `node app` (`package.json` start: `node app.js`), as `abc`. |
| Init | linuxserver `init-dillinger-config/run`: move `/app/dillinger/configs` to `/config/configs`, symlink it back; chown `/config` and `/app/dillinger/public/`. |
| Ports | 8080/tcp (`app.js`: `app.set('port', process.env.PORT \|\| 8080)`) |
| Env vars (real) | `PORT` (default 8080), `BIND_ADDRESS` (default `localhost`, must be `0.0.0.0` in a container), `NODE_ENV`. Config comes from the `./config` module and the `configs/` directory. |
| Data path | `/config/configs` (via symlink from `/app/dillinger/configs`). UNVERIFIED: no other runtime write path beyond `configs/` and `public/`. |
| PDF export | Uses Chromium via `PUPPETEER_EXECUTABLE_PATH`. Upstream installs `chromium` from apk. Ubuntu's `chromium` apt package is a snap transitional, UNVERIFIED that it works in a container. See section 10. |
| Node engines | `package.json` `engines.node` is `14.x.x` (old). Ubuntu base ships Node 26.13.1 (`apps/ubuntu/docker-bake.hcl`). UNVERIFIED: that v3.39.1 runs on Node 26. |
| arm64 | Source build, arch-independent. linuxserver arm64 image status UNVERIFIED (copy-from is `no`). |

## 2. Target layout

- `apps/dillinger/Dockerfile`
- `apps/dillinger/docker-bake.hcl`
- `apps/dillinger/settings.yaml`
- `apps/dillinger/container-test.yaml`
- `apps/dillinger/start.sh`

No `defaults/`: the `configs/` defaults come from the tarball and are seeded at build time into a staging path (section 4). No `root/`: the linuxserver s6 tree is replaced by `start.sh`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Deviation from the draft: the draft says `python-node`. The repo rule in `.github/agents/container-porter.agent.md` maps "Node" to `ubuntu`, and sibling Node-only apps (`apps/pairdrop`, `apps/it-tools`) use ubuntu. `python-node` is for images that need Python and Node. Dillinger has no Python step, so `ubuntu` is used. The ubuntu base already ships Node 26.13.1 and npm.

Closest sibling: `apps/pairdrop` (Node app on ubuntu, tarball + `npm ci --omit=dev`, `chown -R apps:apps /app`).

## 4. Dockerfile

1. `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV NODE_ENV=production`, `HOME=/tmp`, `NPM_CONFIG_CACHE=/tmp/.npm`.
3. One RUN block (install and build):
   - `mkdir -p /app/dillinger` and fetch the tarball:
     `curl -fL https://github.com/joemccann/dillinger/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /app/dillinger --strip-components=1`
   - Stage the default config for seeding: `mkdir -p /usr/share/dillinger-defaults && mv /app/dillinger/configs /usr/share/dillinger-defaults/configs`. This keeps `/app` read-only at runtime and lets `start.sh` seed `/config` when missing.
   - `cd /app/dillinger && npm install --omit=dev` (upstream `--prefix` form is equivalent). Then `npm cache clean --force`.
   - Remove `/tmp/*` and `/tmp/.npm`.
   - Chromium: the apt package on ubuntu is a snap transitional, so do not install it blindly. Decision in section 10. Default for this plan: do not install Chromium, and set `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true` only if the build needs it (UNVERIFIED that the npm install triggers a download without it).
   - License: `install -D /app/dillinger/LICENSE /usr/share/licenses/dillinger/LICENSE` (MIT file in the tarball; UNVERIFIED that it exists at tag v3.39.1).
   - `chown -R apps:apps /app/dillinger && chmod -R 755 /app/dillinger`.
4. Symlink for `/config` (build time, since `/app` is read-only at runtime):
   `ln -s /config/configs /app/dillinger/configs` (dangling until `start.sh` creates `/config/configs`).
5. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

ENV PORT=8080 BIND_ADDRESS=0.0.0.0
EXPOSE 8080
VOLUME /config
WORKDIR /app/dillinger
```

`BIND_ADDRESS=0.0.0.0` is set in the image to override the upstream default `localhost`. Confirm by reading the env in `app.js` at run time.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "dillinger"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=joemccann/dillinger versioning=semver
  default = "3.39.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/joemccann/dillinger"
}
```

Then the default group and the four standard targets copied from `apps/airsonic-advanced/docker-bake.hcl`. The Dockerfile builds the URL with a `v` prefix from the tag. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/joemccann/dillinger"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "8080"
    required: false
  - name: BIND_ADDRESS
    default: "0.0.0.0"
    required: false
  - name: NODE_ENV
    default: "production"
    required: false
volumes:
  - path: /config
    required: true
```

Only the three env vars the app reads are listed. Dependencies: none (no DB; state is files in `/config/configs`).

## 7. start.sh

```bash
#!/usr/bin/env bash

# seed /config/configs from the image defaults, only when missing
if [[ ! -d /config/configs ]]; then
  mkdir -p /config/configs
  cp -a /usr/share/dillinger-defaults/configs/. /config/configs/
fi

PORT="${PORT:-8080}"
BIND_ADDRESS="${BIND_ADDRESS:-0.0.0.0}"
export PORT BIND_ADDRESS NODE_ENV="${NODE_ENV:-production}"

cd /app/dillinger || exit 1
exec node app.js
```

- Idempotent: seeds `configs` only when `/config/configs` is missing, never overwrites user config.
- Writes nothing to `/app`. The `configs` symlink (built in) points at `/config/configs`.
- `exec node` hands PID 1 to node.
- `BIND_ADDRESS` default is `0.0.0.0` here, not upstream `localhost`, so the container is reachable from other containers.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/dillinger/app.js
- /app/dillinger/package.json
- /config/configs
- /usr/share/licenses/dillinger/LICENSE
```

- `tcp` and `http` on 8080 (every settings port has a probe). The `http` probe on `/` is a proposed check; UNVERIFIED that it returns 200 on first start.
- `filePaths` includes `/config/configs` only if the test creates `/config`. The test runs with a fresh `/config` (the protocol), so the seeded directory is expected; if the harness mounts nothing, drop this entry and record why. Do not weaken other checks.
- No DB dependency, so the DB exception does not apply and functional probes are full.
- No required env code paths (`PORT` and `BIND_ADDRESS` have defaults).
- `timeoutSeconds: 120` is a proposed value, tune to the measured startup.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/dillinger/configs` | Symlink to `/config/configs`, seeded by `start.sh`. |
| `/app/dillinger/public/` (chown in upstream init) | Read-only at runtime. Owned by `apps` at build time. Not written by the app (UNVERIFIED). |
| npm cache and `HOME` | Build stage: `/tmp`. Runtime `HOME=/tmp`. |
| Chromium (PDF export) | Not installed by default (section 10). Upstream PDF export would write to `/tmp` if enabled. |

Security expectations (draft): non-root yes (`USER apps`), read-only-rootfs yes (runtime writes only to `/config`), privileged no, no extra persistence.

## 10. Risks, caveats and open questions

- Chromium / PDF export (open question): upstream installs `chromium` from apk and points Puppeteer at it. On Ubuntu, `chromium` from apt is a snap transitional package and is not expected to run in a container. Plan default: do not install it, so PDF export is disabled in this image. Record in the PR. Alternative (needs a decision): install Chromium from another source (not verified) and keep PDF export.
- Node version: `engines.node` is `14.x.x`. Ubuntu base has Node 26.13.1. UNVERIFIED that v3.39.1 runs on Node 26. If it fails, record a blocker, do not pin a different Node silently.
- Stale-looking releases API: GitHub `releases/latest` shows 3.5.1 (2016). Tags are current (v3.39.1). Renovate uses tags.
- Frontend is built at image build time, so a new upstream version needs a full rebuild, not a runtime update (draft caveat, accepted).
- Base image deviation: draft said `python-node`, plan uses `ubuntu` per the porter table (Node-only app). Record in the PR.
- Checksum: none published for the tarball, pinned by tag.
- arm64: untested. Build amd64 only unless the failure is arm64-specific.
- Blockers: none confirmed beyond the Node-version and Chromium questions above.

## 11. Build and test steps

```sh
cd apps/dillinger
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker volume create dillinger-probe-config
docker run --rm -d --name dillinger-probe --read-only --tmpfs /tmp \
  -v dillinger-probe-config:/config dillinger:3.39.1
docker logs -f dillinger-probe     # wait for the readiness line
docker rm -f dillinger-probe; docker volume rm dillinger-probe-config

forgetool containers test --image dillinger:3.39.1 --config ./apps/dillinger/container-test.yaml
```

- Expected readiness signal: `Express server listening on port 8080` (upstream `app.js` logs it), and port 8080 accepts TCP.
- Fail signals: `EACCES` on `/app/dillinger/...` (read-only violation), `Cannot find module` (dependency install failed), `engine` or `Node` version errors (section 10), Chromium errors only if PDF export is enabled.

## 12. PR checklist

- Branch: `feat/add-dillinger`, from `main`.
- Commit and PR title: `feat(dillinger): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows status.
- PR description: fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, tick only what applies. Put `🤖 This PR is AI generated.` in the Notes section.
- Call out in the PR: the base image deviation (`ubuntu` not `python-node`), PDF export disabled (Chromium), the tag-vs-release version source, and the Node 26 question.
- Untested, to state in the PR: arm64, PDF export, Node 26 runtime compatibility, and any step not run.
- Do not check "Built container locally" unless `image-local` was built and the run passed.
