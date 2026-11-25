# fotosho — implementation plan
> Source: ./draft.md · Target: apps/fotosho/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Status: blocked. Do not start the port until the license, the Node version and the port are settled (section 10).

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub release (`releases/latest` returns 404; releases page empty). Latest `package.json` version: `1.0.42` (https://raw.githubusercontent.com/advplyr/fotosho/master/package.json). No tag confirmed; release date UNVERIFIED. The build must pin a master commit SHA (not resolved in this run; UNVERIFIED). |
| Docker Hub | `advplyr/fotosho` has one tag, `latest`, last updated 2021-07-30, linux/amd64 only. Draft chart tag `docker.io/advplyr/fotosho:latest` is that tag. The image is from 2021 and unmaintained. |
| Renovate | Chart image: `datasource=docker depName=docker.io/advplyr/fotosho versioning=docker`, but the only tag is `latest`, so no version updates are possible. For the source build, use `datasource=git-refs depName=https://github.com/advplyr/fotosho currentValue=master` (the pattern used by `apps/tvheadend` and the fenrus plan). |
| License | UNVERIFIED: no `LICENSE` file (404 at master) and no `license` field in `package.json`. Repo API returns 403. The bake `LICENSE` cannot be set without a license (section 10). |
| Source URL | https://github.com/advplyr/fotosho |
| Download | Source only, no release assets. Node app. Tarball by commit SHA: `https://github.com/advplyr/fotosho/archive/${VERSION}.tar.gz`. |
| Checksum source | None. Pin the commit SHA to make the source content-addressed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/advplyr/fotosho/master/Dockerfile. Build stage `node:12-alpine`: `WORKDIR /client`, `COPY /client /client`, `npm install`, `npm run generate`. Final stage `node:12-alpine`: `ENV NODE_ENV=production`, `ENV LOG_LEVEL=INFO`, copies `/client/dist`, `index.js`, `package.json`, `server`, `static`, `npm install --production`, `EXPOSE 80`, `CMD ["node","index.js"]`. No `USER`, `VOLUME`, `ENTRYPOINT` or `WORKDIR` in the final stage. Runs as root. |
| Port | 80 (`EXPOSE 80`, upstream Dockerfile). The draft's 3000 is contradicted by the upstream Dockerfile (the draft marks it as inferred). |
| Env vars | `NODE_ENV=production`, `LOG_LEVEL=INFO` (upstream Dockerfile). Other app variables: UNVERIFIED (`index.js` and `server/` not fetched). |
| Data path | UNVERIFIED. `package.json` dependencies include `njodb` (file-based DB) and `chokidar`. The data directory is not confirmed. |
| Dependencies | None (no database server). |
| Copy-from | No. The Hub image is a 2021 Node 12 alpine build, not usable on glibc Ubuntu. |

## 2. Target layout

- `apps/fotosho/Dockerfile`
- `apps/fotosho/docker-bake.hcl`
- `apps/fotosho/settings.yaml`
- `apps/fotosho/container-test.yaml`
- `apps/fotosho/start.sh`

No `defaults/` or `etc/` until the data path is known. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why not `python-node` (the draft's choice): the copilot porter table maps Node to the ubuntu base, which already ships Node 26.13.1 (`apps/ubuntu/docker-bake.hcl`). Python is not used. Node 12 is EOL, so the app must run on a newer Node (section 10).

Closest siblings: `apps/adguardhome-sync` (layout, `USER apps`, `COPY --chmod`), `apps/budge` (Node build inside the image, npm install, cache cleanup).

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), `ARG TARGETARCH`, `USER root`. Keep the base digest.
2. Source download with caches in `/tmp`:

```dockerfile
ENV NPM_CONFIG_CACHE=/tmp/npm-cache \
    NODE_ENV=production \
    LOG_LEVEL=INFO

RUN echo "**** install fotosho ****" && \
  mkdir -p /app/fotosho && \
  curl -fL -o /tmp/fotosho.tar.gz \
    "https://github.com/advplyr/fotosho/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/fotosho.tar.gz -C /app/fotosho --strip-components=1 && \
  cd /app/fotosho/client && \
  npm install && \
  npm run generate && \
  cd /app/fotosho && \
  npm install --omit=dev && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*
```

   - Upstream copies `/client/dist` to the final image. Keep the built output in `/app/fotosho/client/dist` (or the path the server reads: UNVERIFIED, check `server/`).
   - Native `sharp` (`^0.28.3`) is a build-time risk: a prebuilt binary for the chosen Node is needed, or build tools and libvips. Test on amd64 first.
3. License: only after the license is confirmed (section 10), copy it to `/usr/share/licenses/fotosho/LICENSE`.
4. Final lines:

```dockerfile
USER apps
COPY --chmod=0755 . /

# ports and volumes (port must be confirmed, see section 10)
EXPOSE 80
VOLUME /config
```

   - `EXPOSE 80` follows upstream. If the port is changed, update the same value in `settings.yaml`, `container-test.yaml` and this line together.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "fotosho"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/advplyr/fotosho currentValue=master
  default = "UNRESOLVED_MASTER_COMMIT_SHA"
}

variable "LICENSE" {
  default = "UNVERIFIED"   // no license found: must be set before a build
}

variable "SOURCE" {
  default = "https://github.com/advplyr/fotosho"
}
```

- `VERSION` must be a real commit SHA from `master`, resolved at build time of the PR (not done in this run). The Dockerfile `ARG VERSION` default must match.
- Four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/fotosho/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/advplyr/fotosho"
ports:
  - port: 80
    protocol: tcp
    required: false
env:
  - name: NODE_ENV
    default: "production"
    required: false
  - name: LOG_LEVEL
    default: "INFO"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  # /photos (read-only library) and /thumbnails are chart extra persistence (draft); map them
  # only after the app's data and photo paths are confirmed (UNVERIFIED).
dependencies: []
```

- Port 80: a non-root `apps` user (UID 568) cannot bind port 80 without `CAP_NET_BIND_SERVICE` or a host sysctl. This is a real blocker for a rootless image. Options: (a) the app takes a port variable (UNVERIFIED), so use 3000 and expose 3000; (b) change the code in the image (requires a patch; not preferred). Decide before writing `settings.yaml`.
- `dependencies: []`: no other ContainerForge app is needed.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

cd /app/fotosho
exec node index.js
```

- Idempotent. Seeds nothing (UNVERIFIED for the app's first-run files).
- Never writes to `/app`. Data and thumbnails go to `/config` only when the data path is confirmed.
- `exec` so the process gets signals.
- Listens on all interfaces: check the bind address in `index.js` (UNVERIFIED). Confirm from outside the container.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '80'   # must match the final port (see section 6)
http:
- port: '80'
  path: /
filePaths:
- /app/fotosho/index.js
- /app/fotosho/server
- /app/fotosho/static
```

- One tcp and one http probe for the port in `settings.yaml`. Keep the probe in step with the final port choice.
- `filePaths` for the built client output and the license are added once their paths are confirmed.
- The http status for `/` is UNVERIFIED; confirm on the first run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Port 80 (upstream, root) | Non-root cannot bind; see section 6. |
| Photo database and thumbnail cache (`njodb`, draft: under `/config`; UNVERIFIED) | Point the app's data variable or symlink to `/config` once confirmed. |
| `/photos` library (draft: read access, PVC) | Read-only mount. File ownership must match UID 568. Not in `/config`. |
| `/thumbnails` (draft: PVC) | Use `/config/thumbnails` if the app's thumbnail path is set; UNVERIFIED. |
| npm cache | `NPM_CONFIG_CACHE=/tmp/npm-cache` at build. |

Reconciling the draft's security expectations: the chart runs as UID 0, `readOnlyRootFilesystem: false`, not privileged. The image would run as `apps` with `--read-only --tmpfs /tmp`. The chart's `/photos` and `/thumbnails` PVCs need their own mounts in the TrueCharts chart. The image does not change that.

## 10. Risks, caveats and open questions

- Blocker, license: no LICENSE file and no license field found. Do not add a license value in the bake or ship a license file until the owner confirms it. Without a license, the image cannot be published in good faith.
- Blocker, release: no tag or release. `VERSION` must be a master commit SHA. Renovate tracks `master` and may move every push (noisy).
- Blocker, port: upstream is `EXPOSE 80`; the draft says 3000. Port 80 cannot be bound by UID 568. Decide the port and confirm whether the app reads a port variable (UNVERIFIED).
- Node version: upstream uses Node 12 (EOL). `sharp ^0.28.3` and `socket.io 4.1` need a tested newer Node. Compatibility on Node 26.x and arm64 is UNVERIFIED. Source build of `sharp` on arm64 is a risk.
- Maintenance: the image is from 2021 and the project shows little recent activity (inferred). Future fixes will come from ContainerForge.
- Data path: UNVERIFIED (`njodb` in use, path not fetched).
- Port and env vars: `NODE_ENV` and `LOG_LEVEL` only are confirmed; other variables UNVERIFIED.
- arm64: UNVERIFIED for the upstream image (Hub is amd64 only). Native `sharp` adds build risk.
- Blockers: no license, no release, port 80 vs non-root, Node 12 era dependencies. No GPU or privileged need is known.

## 11. Build and test steps

```sh
cd apps/fotosho
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name fotosho-probe --read-only --tmpfs /tmp \
  -v fotosho-probe-config:/config fotosho:<commit-sha>
docker logs -f fotosho-probe

forgetool containers test --image fotosho:<commit-sha> --config ./apps/fotosho/container-test.yaml
docker rm -f fotosho-probe; docker volume rm fotosho-probe-config
```

- Readiness signal: the server's listening line (UNVERIFIED wording). The container must stay running.
- Use the commit SHA as the image tag because there is no version tag.
- Run with an empty `/config` volume, then again with the same volume.

## 12. PR checklist

- Branch `feat/add-fotosho`, commit and PR title `feat(fotosho): add new container`, target `main`.
- Do not open the PR until the license is confirmed and the port decision is made.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested, to state honestly in the PR: the Node version choice, `sharp` on arm64, the port, the data path, the photo library mount, and the license.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
