# flame — implementation plan
> Source: ./draft.md · Target: apps/flame/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2.4.0` (latest stable, GitHub release published 2026-04-24, https://api.github.com/repos/pawelmalak/flame/releases/latest). Draft chart tag `docker.io/pawelmalak/flame:2.4.0` matches. |
| Docker Hub | Tags `2.4.0` and `latest` (2026-04-24) are linux/amd64 only. `multiarch` and `multiarch2.4.0` are amd64, arm64, arm/v7. Upstream build notes say the multiarch build failed under a 2 GB memory limit. |
| Renovate | `datasource=github-releases depName=pawelmalak/flame versioning=semver` in `docker-bake.hcl`, as the source is fetched from the tag (latest release `v2.4.0`). |
| License | MIT (GitHub repo API `license.spdx_id` = `MIT`; the file at the repo root is `LICENSE.md`, not `LICENSE`). |
| Source URL | https://github.com/pawelmalak/flame |
| Download | Source tarball `https://github.com/pawelmalak/flame/archive/refs/tags/v${VERSION}.tar.gz`. No release assets (`assets = []`). Node app built from source, so there is no per-arch binary. |
| Checksum source | None published (no assets). UNVERIFIED whether the git tag is signed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/pawelmalak/flame/069b6690d9fa7a24a6e7727386ab85148c89b90e/.docker/Dockerfile. Builder `node:20`: `npm install --production`, client `npm install --production && npm run build`, `mv ./client/build/* ./public`, `rm -rf ./client`. Final `node:20-alpine`: `ENV NODE_ENV=production`, `ENV PASSWORD=flame_password`, `EXPOSE 5005`, `CMD ["sh","-c","chown -R node /app/data && node server.js"]`. No `USER` line (runs as root), no `VOLUME`. |
| Port | 5005 (`EXPOSE 5005`, README `-p 5005:5005`). |
| Env vars | `PASSWORD` (README examples use `change_me`, no default stated). `PASSWORD_FILE` (example `/run/secrets/password`); any variable can be read from a `_FILE` path, and the secret wins when both are set. `NODE_ENV=production` set by the upstream image. |
| Data path | `/app/data` (README `-v /path/to/data:/app/data`). No env var found that changes it (UNVERIFIED that none exists in server code). |
| Dependencies | None (no database). Optional Docker socket mount in the README compose example, not needed. |
| Copy-from | No. Upstream runtime is `node:20-alpine` (musl), which does not run on glibc Ubuntu. |

## 2. Target layout

- `apps/flame/Dockerfile`
- `apps/flame/docker-bake.hcl`
- `apps/flame/settings.yaml`
- `apps/flame/container-test.yaml`
- `apps/flame/start.sh`

No `defaults/`, `etc/` or `health/` needed: the app creates its own data on first start. No `root/` (not used by agents). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why this and not `python-node` (the draft's choice): the copilot porter table maps Node to `ghcr.io/trueforge-org/ubuntu`. The ubuntu base already installs Node from its own build (`NODE_VERSION` default `26.13.1` in `apps/ubuntu/docker-bake.hcl`), so `python-node` adds Python that flame does not use. Using ubuntu also keeps the Python-runtime rules out of scope.

Closest siblings: `apps/adguardhome-sync` (prebuilt download, `USER apps`, `COPY --chmod`) for layout; `apps/budge` (Node build in the image, `WORKDIR /config`, `EXPOSE`/`VOLUME`) for the Node install pattern.

Open: the upstream builder is `node:20`. Build and run on the base Node (26.13.1) first. Only pin a different Node if that fails (UNVERIFIED that flame works on 26.x).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. Keep the base digest.
2. Single `RUN` step for the source build, with caches in `/tmp`:

```dockerfile
ENV NPM_CONFIG_CACHE=/tmp/npm-cache \
    NODE_ENV=production

RUN echo "**** install flame ****" && \
  mkdir -p /app/flame && \
  curl -fL -o /tmp/flame.tar.gz \
    "https://github.com/pawelmalak/flame/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/flame.tar.gz -C /app/flame --strip-components=1 && \
  cd /app/flame && \
  npm install --omit=dev && \
  cd /app/flame/client && \
  npm install && \
  npm run build && \
  cd /app/flame && \
  mkdir -p public && \
  mv client/build/* public/ && \
  rm -rf client && \
  ln -s /config/data /app/flame/data && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*
```

   - `npm install --omit=dev` mirrors the upstream `--production` flag. The repo root has a `package-lock.json`, so `npm ci --omit=dev` is an option for the server (client lockfile UNVERIFIED).
   - The client build needs its own dependencies. Keep the upstream sequence exactly, then re-check the result.
   - `ln -s /config/data /app/flame/data` is created at build time, so `/app` stays unwritten at runtime. The link is dangling until `start.sh` creates `/config/data`.
3. License: after extraction, `mkdir -p /usr/share/licenses/flame && cp /app/flame/LICENSE.md /usr/share/licenses/flame/LICENSE`.
4. Final lines:

```dockerfile
# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5005
VOLUME /config
```

5. Ownership: the install runs as root, so set `chown -R apps:apps /app/flame` before `USER apps` if any runtime write under `/app/flame` is seen (it should not be, see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "flame"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=pawelmalak/flame versioning=semver
  default = "2.4.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/pawelmalak/flame"
}
```

Then the four standard targets and the default group, copied from `apps/budge/docker-bake.hcl` (`image`, `image-local` with `output = ["type=docker"]` and tag `${APP}:${VERSION}`, `image-all` for amd64 and arm64, and `group "default" { targets = ["image-local"] }`). `VERSION` must equal the Dockerfile `ARG VERSION` default-by-bake. Validate with `docker buildx bake --print` from `apps/flame/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pawelmalak/flame"
ports:
  - port: 5005
    protocol: tcp
    required: false
env:
  - name: PASSWORD
    default: ""
    required: false
  - name: PASSWORD_FILE
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `PASSWORD` is not `required: true`: the test runs without env vars, and a required password would make the container refuse to start. Whether flame needs a password to start at all is open (section 10). Do not copy `flame_password` as a default without a decision.
- `dependencies: []`: no ContainerForge app is needed.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

cd /app/flame
exec node server.js
```

- Idempotent. Seeds nothing: flame creates its files in `data/` on first start (UNVERIFIED for every file it writes; check the logs on `--read-only`).
- Never writes to `/app`. The `data` symlink points at `/config/data`.
- `exec` so `node` gets the signals (PID 1 handoff).
- Binds to all interfaces: the README run line and `server.js` must be checked for `0.0.0.0` or `::`. UNVERIFIED for the server code (not fetched); verify from outside the container, per the start-script rules.
- Drop the upstream `chown -R node /app/data` (`node` user does not exist as the runtime user, and `/app` is read-only).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5005'
http:
- port: '5005'
  path: /
filePaths:
- /app/flame/server.js
- /app/flame/public
- /usr/share/licenses/flame/LICENSE
```

- One tcp and one http probe for port 5005 (the only port in `settings.yaml`).
- `filePaths` covers the built client (`public`) and the license. The license is copied from `LICENSE.md` in the build step.
- The http path `/` may return a login redirect or a non-200 status. Confirm the status on the first run and keep `path: /` only if it returns 200 (UNVERIFIED).
- No `PASSWORD` code path is tested with env vars (the test has none). It is covered by the manual run in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (volume in the chart and README) | Build-time symlink `/app/flame/data` to `/config/data`. The chart's `/app/data` PVC must be remapped to `/config` for existing users (see the draft's caveat). |
| `/app/public` (built client, plus possible uploads) | Read-only in the image. UNVERIFIED whether flame writes uploads here: check the logs on `--read-only` and move any write path to `/config` with a symlink. |
| npm cache, `$HOME` caches | `NPM_CONFIG_CACHE=/tmp/npm-cache` at build. `HOME` is not set at runtime. |
| Root user (upstream) | Runs as `apps` (UID 568). Upstream `chown` is dropped. `/config` is owned by the runtime user through the volume. |
| Docker socket (README optional) | Not used by default. Not mounted by the chart's common defaults (UNVERIFIED). |

Reconciling the draft's security expectations: the chart runs as UID 0, `readOnlyRootFilesystem: false`, and is not privileged. The image is designed to run as `apps`, read-only with `--tmpfs /tmp`, and not privileged. The chart's `/app/data` extra persistence becomes `/config` in this app. Note this for the TrueCharts migration.

## 10. Risks, caveats and open questions

- License: MIT per the GitHub API; the file is named `LICENSE.md`. Confirm the text in the `v2.4.0` tag during the build.
- Admin password: the upstream image hardcodes `PASSWORD=flame_password`. This plan does not bake a default. Decide whether the app refuses to start without a password or uses its own default (UNVERIFIED).
- Node version: upstream builds with `node:20`, the base ships Node 26.13.1. Compatibility UNVERIFIED. Fall back to a pinned Node only if the build fails.
- Multi-arch: `2.4.0` on Docker Hub is amd64 only. The source build is arch-independent only if there are no native npm modules (UNVERIFIED). The memory note in the upstream README (multiarch build failed under 2 GB) means `image-all` may need more build RAM.
- No checksum is published for the tarball. The download is pinned to the tag, so the tag itself is the trust anchor. Signed tag: UNVERIFIED.
- `/app/data` change: existing TrueCharts data at `/app/data` must be mounted at `/config/data`.
- Blockers: none of the musl-only, GPU, privileged or arm64-missing kind. The password default is the only item to settle before a build.

## 11. Build and test steps

```sh
cd apps/flame
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name flame-probe --read-only --tmpfs /tmp \
  -v flame-probe-config:/config ghcr.io/trueforge-org/flame:2.4.0
docker logs -f flame-probe

# Manual check with a password, since the test runs without env vars
docker rm -f flame-probe; docker volume rm flame-probe-config
docker run --rm -d --name flame-probe --read-only --tmpfs /tmp \
  -e PASSWORD=change_me -p 5005:5005 \
  -v flame-probe-config:/config flame:2.4.0
curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:5005/

forgetool containers test --image flame:2.4.0 --config ./apps/flame/container-test.yaml
docker rm -f flame-probe; docker volume rm flame-probe-config
```

- Readiness signal: the server's listening line (UNVERIFIED wording; check the log). The container must still be running after the startup window.
- Confirm `/config/data` exists after start and survives a restart.
- Run once with an empty `/config` volume and once with the same volume again.

## 12. PR checklist

- Branch `feat/add-flame`, commit and PR title `feat(flame): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested, to state honestly in the PR: arm64 build, the client build on Node 26, the `--read-only` run (uses `/config` symlink), the http probe status, and the migration from the chart's `/app/data`.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
