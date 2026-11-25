# cryptpad — implementation plan
> Source: ./draft.md · Target: apps/cryptpad/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | DECISION NEEDED. Latest GitHub release is `2026.10.1` (published 2026-11-10, no assets). The draft and TrueCharts use Docker Hub `version-5.5.0` (last updated 2023-10-12). Recommended: build `2026.10.1` from source and do not ship the 2023 `5.5.0` line. Tags API returned 403, so the `5.5.0` tag commit SHA is UNVERIFIED. |
| Draft tag | `version-5.5.0` (Docker Hub image tag, from the chart). Not used as the build input in the recommended option. |
| Renovate | Proposed: `datasource=github-releases depName=cryptpad/cryptpad versioning=loose` (tags are CalVer `yyyy.MM.n` plus the old `5.x.y`). UNVERIFIED: not checked against Renovate's datasource docs. |
| License | AGPL-3.0. Source: https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/LICENSE |
| Source URL | https://github.com/cryptpad/cryptpad |
| Download | Tag source tarball `https://github.com/cryptpad/cryptpad/archive/refs/tags/${VERSION}.tar.gz`. No release asset. UNVERIFIED: the `2026.10.1` tarball URL was not fetched. |
| Per-arch download URLs | Same source tarball for amd64 and arm64. The app is JavaScript; it is built with npm in the image. UNVERIFIED: native npm modules on arm64. |
| Checksum source | None published. UNVERIFIED: no checksum file on fetched pages. The tag tarball is not content-pinned. Option: pin the commit SHA of the tag (as `apps/fenrus` does) once it is looked up. |
| Upstream Dockerfile reviewed | `Dockerfile` at commit `cbeb1b76a778db9ba6c512c24f71b6186525d4d3`: https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/Dockerfile. UNVERIFIED: this commit's version. Re-read the Dockerfile at the chosen tag before implementing. |
| Upstream build | Build stage `FROM node:lts-slim`. `COPY . /cryptpad`. A `sed` sets installMethod to `docker`. Config is moved to `/cryptpad/config.local`. `npm install --production && npm run install:components`. |
| Upstream runtime | `FROM node:lts-slim`, user and group `cryptpad` UID/GID 4001, home `/cryptpad`. apt: bash, curl, ca-certificates, git, rdfind, unzip. `USER cryptpad`. `ENTRYPOINT ["/bin/bash", "/cryptpad/docker-entrypoint.sh"]`, `CMD ["npm", "start"]`. `EXPOSE 3000`. HEALTHCHECK `curl http://localhost:3000/` every 1m. Only ENV: `DEBIAN_FRONTEND`. |
| Upstream entrypoint | `docker-entrypoint.sh` at the same commit. Copies `config.example.js` to `/cryptpad/config/config.js` and `infra.example.js` to `/cryptpad/config/infra.js` when missing. Runs `npm run build` on every start. Reads `CPAD_INSTALL_ONLYOFFICE` and `CPAD_INSTALL_OFFICE` (`yes` runs `./install-office.sh --accept-license --trust-repository`). `CPAD_HOME` is hard-coded to `/cryptpad`. The header mentions `CPAD_MAIN_DOMAIN`, `CPAD_SANDBOX_DOMAIN` and `CPAD_CONF`, but the script does not use them. |
| Env vars (real) | None read by the upstream Dockerfile. The entrypoint reads only the two `CPAD_INSTALL_*` vars. Config is not templated from env: the operator edits `config.js` and `infra.js`. |
| Data and config paths | `/cryptpad/blob`, `/cryptpad/block`, `/cryptpad/customize`, `/cryptpad/data`, `/cryptpad/datastore`, `/cryptpad/config` (VOLUME in upstream Dockerfile). |
| Ports | 3000 (EXPOSE, web). The sandbox origin (3001 in the draft) is NOT in the Dockerfile. UNVERIFIED: not confirmed on a fetched page. |
| Upstream image | `docker.io/cryptpad/cryptpad:version-5.5.0`. amd64 digest `sha256:e39fefe6…`, arm64 digest `sha256:07a8426c…`, both linux. Source: https://hub.docker.com/v2/repositories/cryptpad/cryptpad/tags/version-5.5.0 |
| Dependencies | None required. Optional OnlyOffice install is a runtime entrypoint feature, not supported in this plan. |

## 2. Target layout

- `apps/cryptpad/Dockerfile`
- `apps/cryptpad/docker-bake.hcl`
- `apps/cryptpad/settings.yaml`
- `apps/cryptpad/container-test.yaml`
- `apps/cryptpad/start.sh` (replaces upstream `docker-entrypoint.sh`)

No `defaults/`, `etc/`, `health/`, `root/` needed. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The `copy-from` image is not used in the recommended option.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Fits because it is the ContainerForge Node runtime (Node 22/24 class is UNVERIFIED for this digest: check `node --version` in the base before the build). Closest sibling: `apps/thelounge` (Node app built with yarn on python-node, `USER apps`, `/config` volume, `EXPOSE`, `VOLUME /config`). The upstream image is `node:lts-slim`, so no Python is needed; python-node is chosen because the draft and the sibling pattern use it. Alternative if `python-node` is judged too heavy: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` with Node installed by apt (UNVERIFIED: no ubuntu-based Node sibling was confirmed here).

## 4. Dockerfile

1. `ARG VERSION`, `USER root`, `WORKDIR /app`.
2. Download and extract the source (no git history, so no `git` is needed):

```dockerfile
RUN curl -fL -o /tmp/cryptpad.tar.gz \
      "https://github.com/cryptpad/cryptpad/archive/refs/tags/${VERSION}.tar.gz" && \
    mkdir -p /app/cryptpad && \
    tar xzf /tmp/cryptpad.tar.gz -C /app/cryptpad --strip-components=1 && \
    rm /tmp/cryptpad.tar.gz
```

3. Build the app in the image, as upstream does, but once at build time instead of on every start:
   - Apply the upstream `sed` that sets `installMethod` to `docker` (copy the exact expression from the upstream Dockerfile at the chosen tag, UNVERIFIED for 2026.10.1).
   - `cd /app/cryptpad && npm install --production && npm run install:components && npm run build` (the first two from the upstream build stage, the last from the entrypoint; re-check each against `package.json` at the chosen tag).
   - Use `npm_config_cache=/tmp/npm` for the install so the cache stays out of `/app` and `/config`. Clear `/tmp/*` at the end.
4. Keep the example configs, then replace the upstream config directory with a symlink to `/config`:

```dockerfile
RUN cd /app/cryptpad && \
    mv config config.default && \
    for d in blob block customize data datastore; do rm -rf "$d"; ln -s "/config/$d" "$d"; done && \
    ln -s /config/config config
```

   The symlinks are dangling until `start.sh` creates the `/config` directories. The `config.default` folder keeps `config.example.js` and `infra.example.js` (the seed source). UNVERIFIED: the exact path of the example files at the chosen tag (the entrypoint refers to them without a directory).
5. Ownership: `chown -R apps:apps /app/cryptpad && chmod -R 755 /app/cryptpad` (after the build, so `npm` output is owned by `apps`).
6. License: `mkdir -p /usr/share/licenses/cryptpad && cp /app/cryptpad/LICENSE /usr/share/licenses/cryptpad/LICENSE` (UNVERIFIED: the `LICENSE` file path at the chosen tag; present at `cbeb1b76`).
7. No apt packages are needed. The ubuntu base already has bash, ca-certificates, curl, git and unzip (checked in `apps/ubuntu/Dockerfile`). `rdfind` is only for the OnlyOffice install, which is not supported here.
8. Tail:

```dockerfile
ENV HOME=/config
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app/cryptpad
```

No `ENTRYPOINT` is set; `start.sh` is the entrypoint via the `COPY . /` rule. Use the same final-stage pattern as `apps/thelounge`.

## 5. docker-bake.hcl

Copy the layout of `apps/adguardhome-sync/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "cryptpad"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=cryptpad/cryptpad versioning=loose
  default = "2026.10.1"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/cryptpad/cryptpad"
}
```

Then the standard `group "default"`, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`) and `image-all` (`linux/amd64`, `linux/arm64`) targets, copied unchanged. The `VERSION` default must equal the Dockerfile `ARG VERSION` (no default in the Dockerfile; passed by bake). Validate with `docker buildx bake --print` from `apps/cryptpad/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/cryptpad/cryptpad"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Port 3000 only, because it is the only EXPOSE in upstream. Do not add 3001 unless the sandbox origin is verified (see section 10).
- No `CPAD_*` env vars: the upstream entrypoint that reads them is replaced, so listing them would be silently ignored.
- No `dependencies`, because none are required.

## 7. start.sh

```bash
#!/usr/bin/env bash

cd /app/cryptpad || exit 1

mkdir -p /config/config /config/blob /config/block /config/customize /config/data /config/datastore

# Seed config only when missing (never overwrite operator edits)
[ -s /config/config/config.js ] || cp /app/cryptpad/config.default/config.example.js /config/config/config.js
[ -s /config/config/infra.js ]  || cp /app/cryptpad/config.default/infra.example.js /config/config/infra.js

exec npm start
```

- Idempotent. Seeds `/config` only when missing. Writes nothing into `/app`.
- The upstream entrypoint runs `npm run build` on every start. It is moved to the image build (section 4), so `start.sh` does not run it. If `npm run build` must be re-run at start for a reason, it must write only to `/tmp` (UNVERIFIED: where the build writes).
- `exec npm start` keeps the upstream `CMD`. If signals are not forwarded through npm, use `exec node <server entry>` (the entry file name is UNVERIFIED: read the `start` script in `package.json`).
- `config.js` and `infra.js` set the domains and the bind address. Check that CryptPad binds `0.0.0.0` on port 3000 (the server must listen on all interfaces). UNVERIFIED: the bind address in the chosen version.

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
- /app/cryptpad/config.default/config.example.js
- /app/cryptpad/package.json
- /usr/share/licenses/cryptpad/LICENSE
```

- `timeoutSeconds: 180` is the most common value across `apps/*/container-test.yaml`.
- The `tcp` and `http` checks both use port 3000, the upstream HEALTHCHECK path `/`. UNVERIFIED: that `/` returns 200 on a fresh `/config` (it may redirect); adjust only the expected behaviour, never remove the check.
- The test runs without env vars, and the app has no env-gated code paths, so no extra `filePaths` for env-only branches are needed. The OnlyOffice path is not built.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this plan |
| --- | --- |
| `/cryptpad/config` (`config.js`, `infra.js`) | `/app/cryptpad/config` -> `/config/config`, seeded by `start.sh` |
| `/cryptpad/blob`, `block`, `customize`, `data`, `datastore` | `/app/cryptpad/<name>` -> `/config/<name>` (build-time symlinks) |
| Entrypoint `npm run build` (writes the frontend build) | Moved to the image build. UNVERIFIED: that the build output needs no runtime write under `/app`. Confirm with `--read-only` |
| `CPAD_HOME` (hard-coded `/cryptpad`) | Not used. The app runs from `/app/cryptpad` |
| TMP / caches | `npm_config_cache=/tmp/npm` during the build. Runtime temp: `/tmp` (tmpfs in the probe) |

Security expectations from the draft, reconciled:

- Upstream runs as UID 4001 (`cryptpad`), not root. The chart runs as root (`runAsUser: 0`). The image here runs as `apps` (568), not UID 4001, so existing data must be made readable by `apps` after migration.
- `readOnlyRootFilesystem`: the chart sets `false`. The plan is compatible with `--read-only --tmpfs /tmp` (to be proven in section 11).
- `privileged`: no. No extra capabilities.
- Persistence: the chart uses five PVCs. ContainerForge uses one `/config` volume with five subfolders plus `config/`. Existing TrueCharts users must copy each old directory into the matching `/config/<name>`.

## 10. Risks, caveats and open questions

- DECISION: version. `2026.10.1` (recommended) is a different release line from the chart's `5.5.0`. Moving to 2026.10.1 changes the data format and the config file layout. Confirm with the user before implementing.
- UNVERIFIED: the upstream Dockerfile and entrypoint were read at commit `cbeb1b76`, not at the chosen tag. The `npm install`, `install:components`, `build` and `sed` steps must be re-read at the chosen tag.
- Second origin (sandbox): CryptPad needs a separate origin for the sandbox (the draft says port 3001, inferred). It is not in the upstream Dockerfile. Serving both origins from one host weakens isolation and can break features. UNVERIFIED: how the sandbox origin is set in `config.js`/`infra.js` for the chosen version and whether a second port is needed. Until verified, `settings.yaml` lists 3000 only.
- Node version: the base `python-node` Node version is UNVERIFIED against the CryptPad `engines` field.
- Build time: the frontend build is large. First build will be slow (inferred from the draft).
- arm64: native npm modules UNVERIFIED. If an arm64 build fails for a native module, the failure is arch-specific and only then try arm64 separately (protocol step 2).
- OnlyOffice: not supported in this plan (the entrypoint installer writes into the app folder). Document as unsupported in the PR.
- Migration: existing data under `/cryptpad/*` must be moved to `/config/*` by the user. The image does not migrate.
- Blockers: none (no GPU, no privileged, no musl-only). The sandbox origin is the only open question that could change `settings.yaml`.

## 11. Build and test steps

```sh
cd apps/cryptpad
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name cryptpad-probe --read-only --tmpfs /tmp \
  -v cryptpad-probe-config:/config cryptpad:2026.10.1
docker logs -f cryptpad-probe
forgetool containers test --image cryptpad:2026.10.1 --config ./apps/cryptpad/container-test.yaml
docker rm -f cryptpad-probe; docker volume rm cryptpad-probe-config
```

- Expected readiness signal: the Node server logs that it is listening on port 3000 (exact text UNVERIFIED: read the server log at the chosen tag). Then `/config/config/config.js` and `/config/config/infra.js` exist, and `/config/blob` etc. exist.
- Restart the container with the same volume; the config must not be overwritten.
- Test an arm64 build only if the amd64 build fails for an arch-specific reason.
- Not tested by this plan: OnlyOffice, the sandbox origin, data migration from TrueCharts.

## 12. PR checklist

- Branch `feat/add-cryptpad`, commit `feat(cryptpad): add new container`, PR title the same, target `main`.
- Tell the user the CLA is needed: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- State what was not tested: the arm64 build, the sandbox origin, OnlyOffice, the `--read-only` run if not performed, data migration.
- `docker buildx bake --print` passes; `VERSION` in `docker-bake.hcl` equals the build's version; no assertion weakened.
