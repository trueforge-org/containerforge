# socials — implementation plan
> Source: ./draft.md · Target: apps/socials/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream has no releases (GitHub API `releases/latest` returns 404) and no tags. Chart uses the untagged `ghcr.io/diamkil/socials:main@sha256:ec22a94aad6850b2667c506dfec53cdd39b241f039c5a1187b569f3aefc2c75b` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/socials/values.yaml). This plan pins a commit SHA instead. Commit `2b7a17b519896cc18b775536d7f9016921df133a` (2022-02-21, "Removed minify") has the same Dockerfile as `main` (both fetched). UNVERIFIED: the current `main` HEAD SHA. Resolve it at build time with `gh api repos/diamkil/socials/commits/main --jq .sha` and pin that. Repo last pushed 2023-03-06. |
| package.json version | `2.0.0` (https://raw.githubusercontent.com/diamkil/socials/2b7a17b519896cc18b775536d7f9016921df133a/package.json). Not used as `VERSION`, because it does not change per release. |
| Renovate | `// renovate: datasource=git-refs depName=https://github.com/diamkil/socials currentValue=main` (precedent: `apps/fenrus`, `apps/tvheadend`). |
| License | `ISC` per package.json (`"license": "ISC"`). GitHub API reports no license (null). No `LICENSE` file found (URL 404). UNVERIFIED: the licence text. Bake `LICENSE` is `ISC`. |
| Source URL | https://github.com/diamkil/socials |
| Download | Source tarball `https://github.com/diamkil/socials/archive/${VERSION}.tar.gz` (VERSION = commit SHA). No release binary. |
| Checksum source | None published. The tarball is content-addressed by commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/diamkil/socials/2b7a17b519896cc18b775536d7f9016921df133a/Dockerfile: build stage `FROM node:lts-alpine AS build`, `COPY . .`, `yarn install`, `yarn build`, `yarn install --production`; runtime `FROM node:lts-alpine`, `WORKDIR /app`, copies `public`, `dist`, `node_modules`, `views`, `COPY people/ ./people/`; `EXPOSE 7574`; `CMD node dist/app.js`. No `USER` (runs as root). |
| Build script | `"build": "tsc && sass --no-source-map styles/:public/css --style compressed"` (package.json). Start: `node dist/app.js`. |
| Env vars (real) | `PORT` (default `7574`), `DEFID` (default `default`) (`src/app.ts`, https://raw.githubusercontent.com/diamkil/socials/2b7a17b519896cc18b775536d7f9016921df133a/src/app.ts). The chart sets `LOG_LEVEL=info`, but no code in `src/app.ts` reads it, so do not list it. |
| Port | **7574/tcp** (Dockerfile EXPOSE, `PORT` default, README `-p 7574:7574`). The draft's `3000` guess is wrong. |
| Data path | `people/*.json` (README). `default.json` is bound to `/`, other files to `/<name>`. Upstream image copies `people/` to `/app/people`; the chart mounts `/app/people`. |
| Dependencies | Express `^4.17.1`, EJS `^3.1.6`, TypeScript `^4.3.5`, sass `^1.38.0` (package.json). No database. |
| Chart security | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0` (values.yaml). |

## 2. Target layout

- `apps/socials/Dockerfile`
- `apps/socials/docker-bake.hcl`
- `apps/socials/settings.yaml`
- `apps/socials/container-test.yaml`
- `apps/socials/start.sh`
- `apps/socials/defaults/people/default.json` (example profile seeded into `/config` on first start; needed, reason: `/config` is empty on first run and the app needs a `default.json`). Copy the upstream example from `people/default.json` at the pinned commit. Check its licence before copying (section 10).
- No `etc/`, `root/`, or `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Runtime and build base: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. This is the base used by the node-based sibling `apps/budge` (node build, npm, glibc). The upstream `node:lts-alpine` base is musl and cannot be reused (copy-from is `no`, see draft). Closest sibling: `apps/budge` (Node backend and frontend built in the image, `/app/www/public` layout, `npm pkg set`, cleanup block). The Python part of the base is unused, which is acceptable because the sibling does the same. Check `node --version` in the base before the build, because upstream `typescript@^4.3.5` and `node-sass`-free `sass` need a supported Node. UNVERIFIED: node major in this base.

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), `ARG TARGETARCH`, `USER root`.
2. `ENV YARN_CACHE_FOLDER=/tmp/.yarn-cache HOME=/config` (caches go to `/tmp`, repo rule). Keep the node cache under `/tmp` too (`npm config set cache /tmp/.npm`).
3. Download and unpack the pinned commit into `/app/socials`:

```sh
curl -fL -o /tmp/socials.tar.gz "https://github.com/diamkil/socials/archive/${VERSION}.tar.gz"
mkdir -p /app/socials
tar xf /tmp/socials.tar.gz -C /app/socials --strip-components=1
rm /tmp/socials.tar.gz
```

4. Build: `cd /app/socials && yarn install --frozen-lockfile` (UNVERIFIED: that a `yarn.lock` is committed; if not, `yarn install`). Then `yarn build`, then `yarn install --production --frozen-lockfile` (or the same fallback). Install `yarn` with `npm i -g yarn@1` only if the base lacks it (`corepack` status UNVERIFIED for this base).
5. Remove what the app does not need at runtime: `rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*`.
6. Point the people directory at `/config` so `/app` stays read-only at runtime:

```sh
ln -s /config/people /app/socials/people
```

The symlink is dangling until `start.sh` creates `/config/people`. Confirm in `src/lib/getData.ts` that the app reads `people/` relative to its working directory (UNVERIFIED: file not fetched in this run; the README only says "folder `/people`").

7. `chown -R apps:apps /app/socials && chmod -R 755 /app/socials` (repo practice; sibling `budge` does not chown, but `/app` must be owned by the runtime user only if it writes there, so keep the minimum: only if a build step leaves root-owned files the runtime user must read).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

ENV PORT=7574 DEFID=default
EXPOSE 7574
VOLUME /config
WORKDIR /app/socials
```

`COPY --chmod=0755 . /` copies `start.sh` and `defaults/`, as required.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "socials" }

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/diamkil/socials currentValue=main
  default = "2b7a17b519896cc18b775536d7f9016921df133a"   // replace with the current main HEAD SHA at build time (section 1)
}

variable "LICENSE" { default = "ISC" }
variable "SOURCE" { default = "https://github.com/diamkil/socials" }

group "default" { targets = ["image-local"] }
```

Then the four standard targets, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/socials`. The Dockerfile `ARG VERSION` default must be the same SHA.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/diamkil/socials"
ports:
  - port: 7574
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "7574"
    required: false
  - name: DEFID
    default: "default"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. Only `PORT` and `DEFID` are read by the app. Do not list `LOG_LEVEL` (chart-only, not read by the code reviewed).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu

mkdir -p /config/people
if [ ! -f /config/people/default.json ]; then
    cp /defaults/people/default.json /config/people/default.json
fi

cd /app/socials
exec node dist/app.js
```

- Idempotent: the example profile is copied only when `default.json` is missing (repo rule). Existing user files are never overwritten.
- Nothing is written under `/app`, except the dangling symlink, which points at `/config`.
- Node caches (none at runtime) would go to `/tmp`.
- `exec` hands PID 1 to node.
- Listens on all interfaces: Express `app.listen(port)` with no host binds to `::`/`0.0.0.0` by default (UNVERIFIED on this Node version, confirm with `ss -ltn` in the probe).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '7574'
http:
- port: '7574'
  path: /
filePaths:
- /app/socials/dist/app.js
- /app/socials/views/someone.ejs
- /defaults/people/default.json
```

- Test runs with no env vars: `PORT` defaults to 7574, `DEFID` to `default`. The `/` route renders `default.json` (seeded), so the http probe covers the data path. Confirm the status code is 200 when run (UNVERIFIED).
- Every port in settings.yaml has a tcp probe (repo rule).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path or privilege | Remap or decision |
| --- | --- |
| `/app/people` (chart mount; image copies people to `/app/people`) | `/config/people` through the symlink `/app/socials/people -> /config/people`. Users with an existing `/app/people` mount must move the content to `/config/people`. |
| Runs as root (no `USER`), chart `runAsUser 0` | Runs as `apps`. Port 7574 is above 1024, so no root is needed. |
| Node caches, yarn cache | `/tmp` only (`YARN_CACHE_FOLDER`, npm cache). |
| Chart `readOnlyRootFilesystem: false` | Image is compatible with `--read-only --tmpfs /tmp`. |
| Chart persistence `socials` at `/app/people` | Replaced by `/config`. |

## 10. Risks, caveats and open questions

- Rolling source: no tags, last upstream commit 2022-02-21, repo last pushed 2023-03-06. Pinning a commit SHA means Renovate proposes every `main` push (`git-refs`). Consider a schedule or a manual pin if the upstream stays dormant.
- Draft's caveat about `/app/people` is confirmed: the data must be mounted or it is lost on update. Our `/config/people` is the fix.
- Port in the draft (3000) is wrong. The app uses 7574 (section 1).
- Build tooling: `yarn` 1.x is used by the Dockerfile (`yarn install`, `yarn build`), but `yarn.lock` is UNVERIFIED. Confirm before the build.
- The app has no authentication. The data is only the user's public links, so no secret is stored. Still, the README says nothing about access control, so state this in the PR.
- Licence: ISC from package.json, no LICENSE file in the repo. Ask upstream or record as-is in the PR. Example profile `people/default.json` is copied into the image, so it has the same licence as the source (UNVERIFIED for the example content).
- Node version compatibility of `typescript@^4.3.5`, `sass@^1.38.0`, `express@^4.17.1` with the base's Node: UNVERIFIED until the build runs.
- Untested: build, runtime on `--read-only`, arm64, the `/` route status code.
- Blockers: none known (not musl-only, no GPU, not privileged, arm64 builds from source).

## 11. Build and test steps

```sh
cd apps/socials
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name socials-probe --read-only --tmpfs /tmp \
  -v socials-probe-config:/config socials:2b7a17b519896cc18b775536d7f9016921df133a
docker logs -f socials-probe
forgetool containers test --image socials:2b7a17b519896cc18b775536d7f9016921df133a --config ./apps/socials/container-test.yaml
docker rm -f socials-probe; docker volume rm socials-probe-config
```

- Readiness signal: `Listening on http://localhost:7574` (from `src/app.ts`), process stays up.
- Confirm `/config/people/default.json` exists after the first start and that a restart keeps any edited file.
- Probe `curl -fsS http://127.0.0.1:7574/` inside and from the host with `-p 7574:7574`.

## 12. PR checklist

- Branch `feat/add-socials`, commit `feat(socials): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- CLA: the PR needs a signed Contributor License Agreement (https://cla-assistant.io/trueforge-org/containerforge). Tell the user. Only the user can sign it, and the `license/cla` check shows the status.
- State that the image is pinned to a commit SHA (no releases upstream) and that the upstream main is untagged.
- Untested to state honestly if not run: the build, read-only runtime, arm64, the http status code.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`.
