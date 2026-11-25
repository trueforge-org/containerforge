# node-red — implementation plan
> Source: ./draft.md · Target: apps/node-red/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `5.0.10` (release tag `5.0.10`, published 2026-11-17). Confirmed latest via `gh api repos/node-red/node-red/releases/latest`. Draft's chart version matches. |
| Renovate | `datasource=npm depName=node-red versioning=semver`. Use the npm package for the build, not the git release. |
| License | Apache-2.0 (https://raw.githubusercontent.com/node-red/node-red/master/LICENSE, "Copyright OpenJS Foundation and other contributors"). |
| Source URL | https://github.com/node-red/node-red |
| Docs | https://nodered.org/docs/ (not fetched) |
| Per-arch download | npm package `node-red@5.0.10` for all arches (no arch-specific binary). Tarball: https://registry.npmjs.org/node-red/-/node-red-5.0.10.tgz (sha512 integrity published in the npm registry). |
| Checksum source | npm registry `dist.integrity` (sha512) for `node-red@5.0.10`, from https://registry.npmjs.org/node-red/latest. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/node-red/node-red-docker/master/.docker/Dockerfile.debian: `FROM node:24-trixie-slim`; build stage `npm install --unsafe-perm --no-update-notifier --no-fund --only=production`; release stage `USER node-red` (UID 1000), `WORKDIR /usr/src/node-red`; `ENV NODE_RED_VERSION`, `NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules`, `PATH` with `node_modules/.bin`, `FLOWS=flows.json`; `npm config set cache /data/.npm --global`; `EXPOSE 1880`; `ENTRYPOINT ["./entrypoint.sh"]`; healthcheck `node /healthcheck.js`; no VOLUME. entrypoint.sh NOT fetched: UNVERIFIED. |
| Port | `1880/tcp` (web UI and editor). From the upstream `EXPOSE 1880`. |
| Env vars | Upstream: `NODE_RED_VERSION`, `NODE_PATH`, `PATH`, `FLOWS`. Safe-mode and projects vars are commented out upstream. Other vars (e.g. `NODE_RED_ENABLE_SAFE_MODE`, `NODE_RED_ENABLE_PROJECTS`, `PORT`) are UNVERIFIED for this build. |
| Data path | Upstream uses `/data` as the user dir. The draft puts flows and settings in `/config`. UNVERIFIED that the packaged build honours a user dir override; confirm in `settings.js` or by a run. |
| Auth | Node-RED has no login by default (draft caveat). UNVERIFIED on a fetched page. |
| arm64 | Yes: the npm package is architecture-independent, and the Node base is multi-arch. |

Draft correction: the draft calls the install "unpinned `npm install`". Pin `node-red@5.0.10` in the Dockerfile to match the chart and the verified release.

## 2. Target layout

Files in `apps/node-red/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: seeds `/config` with a default `settings.js` and `flows.json` only when missing, then `exec`s `node-red`)
- `defaults/` — `settings.js` and an empty `flows.json`, only if seeded (decide in section 7)
- `DOWNSTREAM_CHANGES.md` — not needed (not a `FROM` base)

## 3. Base image

- Draft says runtime image `ghcr.io/trueforge-org/python-node`. The protocol table maps Node-only apps to `ghcr.io/trueforge-org/ubuntu`, and Node-RED needs no Python.
- Decision needed: Node-RED needs Node 24 (the upstream base). The ContainerForge `ubuntu` base has no Node, so the build must install it. The only ContainerForge base in this repo that ships Node is `python-node` (used by `apps/budge` and `apps/changedetection`). Its Node version is UNVERIFIED.
- Recommended: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (the digest from the brief), since it is the existing Node base in the repo and avoids a second Node install. Record the Node version in the PR.
- Closest sibling: `apps/budge` (python-node, npm install of an app, `USER root` for install then `apps`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install Node-RED globally into `/app` (not `/usr/local`, so `/app` holds the app):
   ```sh
   npm install --prefix /app node-red@${VERSION} --omit=dev --no-audit --no-fund
   ```
   Confirm the flag set against the upstream build (upstream uses `--only=production`).
3. Set the npm cache to `/tmp` (`npm config set cache /tmp/.npm --global`), not `/config` or `/data`.
4. Ship the license: `/usr/share/licenses/node-red/LICENSE` from the npm tarball (`node_modules/node-red/LICENSE`).
5. `chown -R apps:apps /app`, then `npm cache clean --force` and `rm -rf /tmp/*`.
6. `ENV FLOWS=flows.json NODE_PATH=/app/node_modules PATH=/app/node_modules/.bin:$PATH` (names from the upstream Dockerfile; keep only ones the app reads).
7. `USER apps`, `COPY --chmod=0755 . /`.
8. `EXPOSE 1880`, `VOLUME /config`.

Keep `COPY --chmod=0755 . /` as the required directive.

## 5. docker-bake.hcl

- `APP = "node-red"`
- `VERSION = "5.0.10"` with `// renovate: datasource=npm depName=node-red versioning=semver`.
- `LICENSE = "Apache-2.0"`.
- `SOURCE = "https://github.com/node-red/node-red"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (`linux/amd64`, `linux/arm64`), `group "default"`.
- Validate with `docker buildx bake --print` from `apps/node-red/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/node-red/node-red"
ports:
  - port: 1880
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

- Only list env vars that `start.sh` or Node-RED reads. Add more after confirming them (section 1 UNVERIFIED list).
- `FLOWS` is set in the image and is read by Node-RED, so it can be listed with default `flows.json` once confirmed.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Set `HOME=/config` only if Node-RED writes its user files there. Otherwise keep `HOME=/tmp`.
- Seed `/config/settings.js` and `/config/flows.json` from `/defaults/` only when missing or empty (`cp -n`), so user state is not overwritten.
- Start with `cd /config` and `exec node /app/node_modules/node-red/red.js --userDir /config "$@"`. The entry file is `red.js` (from the npm `bin` field: `node-red` → `red.js`, verified from the registry metadata).
- Do not write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '1880'

filePaths:
- /start.sh
- /app/node_modules/node-red/red.js
```

- `tcp` probe for `1880` covers the declared port (section 6). An `http` probe on `/` is an option once the UI is confirmed; keep `tcp` as the minimum.
- `timeoutSeconds`: use the sibling value (`apps/budge`) once confirmed.
- No env vars are needed for the test.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (not the upstream UID 1000 `node-red`). The chart's `runAsUser` is 568 (draft). Keep `apps`.
- Read-only rootfs: Node-RED writes flows, settings, and palette installs. Palette installs need a writable user dir, so `/config` must be writable. This is the draft's caveat and is correct.
- The npm cache and temp files go to `/tmp`.
- Privileged: no. Extra persistence: none beyond `/config` (chart also mounts `/data`; decide whether `/data` is needed, probably not).

## 10. Risks, caveats and open questions

- **Base choice.** python-node versus ubuntu (section 3). Decide before writing the Dockerfile. Node version of python-node is UNVERIFIED.
- **Userdir.** Node-RED's default user dir is `~/.node-red`, and upstream uses `/data`. Confirm the `--userDir` flag and that it works with the packaged install.
- **Palette installs.** A read-only `/config` breaks palette installs (draft). Document in the PR that `/config` must be writable for this feature.
- **No login.** The editor on 1880 is open by default. Document the reverse-proxy or `adminAuth` setting in the PR; do not enable auth by default without a decision.
- **entrypoint.sh UNVERIFIED.** The upstream entrypoint was not fetched. Do not copy it blindly; the plan above execs node-red directly.
- **Version pinning.** The draft's `npm install` was unpinned. Pin `5.0.10` (section 4).
- Blockers: none. No arm64 problem (npm package).

## 11. Build and test steps

From `apps/node-red/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe with an empty `/config` volume, read-only rootfs:
   ```sh
   docker run --rm -d --name node-red-probe --read-only --tmpfs /tmp \
     -v node-red-probe-config:/config node-red:5.0.10
   docker logs -f node-red-probe
   docker rm -f node-red-probe; docker volume rm node-red-probe-config
   ```
   Expected readiness signal: Node-RED's startup line (e.g. "Server now running at http://127.0.0.1:1880/", UNVERIFIED wording until seen in a run). Confirm the wording from the first real log.
4. `forgetool containers test --image node-red:5.0.10 --config ./apps/node-red/container-test.yaml`
5. Clean up scratch containers and volumes.

## 12. PR checklist

- Branch `feat/add-node-red`, commit `feat(node-red): add new container`, PR title the same.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, all sections and checkboxes kept; only tick boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested: arm64 build, palette installs on a read-only `/config`, the UI on port 1880, and the unverified entrypoint and env vars.
