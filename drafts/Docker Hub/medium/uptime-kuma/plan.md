# uptime-kuma — implementation plan
> Source: ./draft.md · Target: apps/uptime-kuma/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 2.5.12 recommended (GitHub latest, not prerelease, published 2026-11-17T15:26:08Z). The draft and the chart pin 1.23.17 (published 2025-10-20T15:54:28Z, the last 1.x release). Choosing 2.x is a decision for the user; see section 10. |
| Renovate | `datasource=github-releases depName=louislam/uptime-kuma versioning=loose` (tags have no `v` prefix) |
| License | MIT (GitHub license API, https://api.github.com/repos/louislam/uptime-kuma/license). LICENSE file not read directly: UNVERIFIED. |
| Source URL | https://github.com/louislam/uptime-kuma |
| Download (source) | `https://github.com/louislam/uptime-kuma/archive/refs/tags/${VERSION}.tar.gz`. UNVERIFIED: the tag archive for 2.5.12 and 1.23.17 was not fetched; the URL pattern follows the GitHub tag archive used by `apps/changedetection`. |
| Download (1.23.17 binary, for reference) | `dist.tar.gz` only, arch-independent prebuilt frontend: https://github.com/louislam/uptime-kuma/releases/download/1.23.17/dist.tar.gz. The 2.5.12 release has no asset list fetched. |
| Per-arch | No per-arch release assets. Both arches are built from source in the image build (`TARGETARCH` is not needed). Native modules (sqlite) are compiled per arch: UNVERIFIED which packages compile. |
| Checksum source | None published on the release. Pin by tag and record the observed sha256 in the PR. |
| Upstream Dockerfile 1.23.17 | https://raw.githubusercontent.com/louislam/uptime-kuma/1.23.17/docker/dockerfile. Bases `louislam/uptime-kuma:builder-go` (healthcheck) and `louislam/uptime-kuma:base-debian`; stages build (`npm ci --omit=dev`, copies healthcheck), release, nightly, pr-test, upload-artifact. `ENV UPTIME_KUMA_IS_CONTAINER=1`, `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1`; `EXPOSE 3001`; `VOLUME ["/app/data"]`; `ENTRYPOINT ["/usr/bin/dumb-init", "--", "extra/entrypoint.sh"]`; `CMD ["node", "server/server.js"]`; `HEALTHCHECK ... CMD extra/healthcheck`. |
| Upstream Dockerfile 2.5.12 | https://raw.githubusercontent.com/louislam/uptime-kuma/2.5.12/docker/dockerfile. Bases `louislam/uptime-kuma:base2` (build, release default, pr-test2, upload-artifact) and `builder-go` (healthcheck). Stages: release, rootless, nightly, nightly-rootless, pr-test2, upload-artifact. `EXPOSE 3001`; no VOLUME; release sets no USER; `ENTRYPOINT ["/usr/bin/dumb-init", "--"]`; `CMD ["node", "server/server.js"]`. `base2` contents UNVERIFIED (not fetched). |
| Published image | Docker Hub `louislam/uptime-kuma:1.23.17-debian`: amd64, arm64, arm (last_updated 2025-10-20). The draft's copy-from links are valid for 1.23.17. This plan builds from source, so `COPY --from` is not used. |
| Data path | 1.23.17 `VOLUME ["/app/data"]` (SQLite DB). 2.5.12 has no VOLUME. Env override for the data path: UNVERIFIED (`DATA_DIR` is assumed, not confirmed). |
| Ports | 3001/tcp (EXPOSE in both lines). Confirmed. |

## 2. Target layout

- `apps/uptime-kuma/Dockerfile`
- `apps/uptime-kuma/docker-bake.hcl`
- `apps/uptime-kuma/settings.yaml`
- `apps/uptime-kuma/container-test.yaml`
- `apps/uptime-kuma/start.sh`

No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The upstream Go healthcheck (`extra/healthcheck`) is not ported: the container-test HTTP probe covers readiness (see section 8).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Fits because uptime-kuma is a Node app and the python-node base provides `node` and `npm` (the draft's choice). Closest sibling: `apps/changedetection` (python-node base, `/app/<app>` source tree installed at build time, `apt` build deps purged after install, `USER apps`, `/config` WORKDIR and VOLUME). Node version provided by the base and the version uptime-kuma 2.5.12 needs: UNVERIFIED (check `node --version` in the build; if the base's Node is too old for 2.5.12, record it as a blocker).

## 4. Dockerfile

1. `FROM` line from section 3. `ARG VERSION`.
2. `ENV UPTIME_KUMA_IS_CONTAINER=1 PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 NPM_CONFIG_CACHE=/tmp/npm-cache`. The first is upstream runtime behaviour, the second skips the Chromium download (upstream build ENV), the third keeps npm cache off `/config`.
3. `USER root`.
4. Build deps for native modules (sqlite): `RUN apt-get update && apt-get install -y --no-install-recommends build-essential python3 && rm -rf /var/lib/apt/lists/*`. UNVERIFIED which modules need compiling; purge in step 7 if unused.
5. Download and extract the source (no checksum published; pinned by `${VERSION}`):
   ```dockerfile
   RUN mkdir -p /app/uptime-kuma /tmp/uptime-kuma-src \
    && curl -fsSL -o /tmp/uptime-kuma.tar.gz "https://github.com/louislam/uptime-kuma/archive/refs/tags/${VERSION}.tar.gz" \
    && tar -xzf /tmp/uptime-kuma.tar.gz -C /app/uptime-kuma --strip-components=1 \
    && rm -f /tmp/uptime-kuma.tar.gz
   ```
   UNVERIFIED: the tag archive URL for 2.5.12 (not fetched). Fallback: `ghcr`-free upstream `dist.tar.gz` plus the source tarball for `server/`.
6. Build the app inside `/app/uptime-kuma`:
   ```dockerfile
   RUN cd /app/uptime-kuma \
    && npm ci \
    && npm run build \
    && npm prune --omit=dev
   ```
   UNVERIFIED: the `build` script name in 2.5.12 `package.json` (1.x used `npm run build`; not fetched). `npm ci` is run without `--omit=dev` because the frontend build needs dev dependencies; `npm prune --omit=dev` strips them afterwards.
7. Purge build tools and caches: `RUN apt-get purge -y --auto-remove build-essential python3 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /tmp/npm-cache`.
8. Data redirect: `RUN ln -s /config /app/uptime-kuma/data` (dangling until `/config` is mounted; `/config` is the VOLUME). If UNVERIFIED `DATA_DIR` is confirmed in 2.5.12, use `ENV DATA_DIR=/config` instead and drop the symlink.
9. License: `RUN mkdir -p /usr/share/licenses/uptime-kuma && cp /app/uptime-kuma/LICENSE /usr/share/licenses/uptime-kuma/LICENSE` (UNVERIFIED that the source tarball contains LICENSE at its root; it is the standard repo layout).
10. `RUN chown -R root:root /app && chmod -R 755 /app` (`/app` read-only at runtime).
11. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /app/uptime-kuma`, `EXPOSE 3001`, `VOLUME /config`.

The upstream `dumb-init` PID 1 is not used: `start.sh` ends in `exec node`, which gives PID 1 the signals directly (start-script rule). Upstream `extra/entrypoint.sh` is not copied (it performs upstream-specific setup; UNVERIFIED what it does).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "uptime-kuma"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=louislam/uptime-kuma versioning=loose
  default = "2.5.12"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/louislam/uptime-kuma"
}
```
Then the standard `group "default"`, `target "image"`, `target "image-local"`, `target "image-all"` copied from `apps/changedetection/docker-bake.hcl`. Validate with `docker buildx bake --print`. `ARG VERSION` in the Dockerfile must equal this default.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/louislam/uptime-kuma"
ports:
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
Notes: no env var is added until it is confirmed that 2.5.12 reads it (`UPTIME_KUMA_IS_CONTAINER` is set by the image, not a user setting). If `DATA_DIR` is confirmed, add it with `default: "/config"`. Dependencies: none (SQLite is embedded).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app/uptime-kuma
exec node server/server.js
```
Idempotent: nothing is seeded; uptime-kuma creates its SQLite database under the data directory on first run (UNVERIFIED behaviour on an empty `/config`). Nothing writes to `/app` at runtime. The data directory is `/config` through the symlink (section 4 step 8) or `DATA_DIR`. The server must bind all interfaces (UNVERIFIED default; check with a probe from outside the container, per the start-script rule).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3001'
http:
- port: '3001'
  path: /
filePaths:
- /app/uptime-kuma/server/server.js
- /usr/share/licenses/uptime-kuma/LICENSE
```
`timeoutSeconds: 180` matches `apps/changedetection` (Node start with a frontend). The HTTP path `/` returning 200 is UNVERIFIED: confirm the status during the run. The `filePaths` entries are standard for the repo layout (UNVERIFIED for 2.5.12).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (SQLite DB, chart PVC, 1.23.17 VOLUME) | `/config` via symlink `/app/uptime-kuma/data -> /config` (or `DATA_DIR=/config` if confirmed) |
| npm cache (`$HOME/.npm`) | `/tmp/npm-cache` (`NPM_CONFIG_CACHE`); removed after build |
| apt and build scratch | `/tmp` during build; purged |
| `/app/uptime-kuma` (source, build output) | read-only at runtime, root-owned, built at image build time |

Draft expectations reconciled:
- Chart: `runAsUser 0` and `runAsNonRoot: false` (PUID 0). Image: `USER apps` (568). Existing chart users must make `/config` writable for UID 568 or migrate the DB from their old `/app/data` PVC: document in the PR.
- Chart: `readOnlyRootFilesystem: true`. Image: compatible with `--read-only --tmpfs /tmp`, to be proven in section 11.
- Chart: not privileged. Image: not privileged.
- Upstream 2.5.12 has a `rootless` stage (node user). Not ported: the ContainerForge `USER apps` covers the same goal. UNVERIFIED whether the rootless stage changes anything else.

## 10. Risks, caveats and open questions

- Version choice (decision needed before the Dockerfile is written): the draft and the chart use 1.23.17, the 2.x line is the current stable (2.5.12). The draft caveat says 2.x changes the database and may need a manual migration. Whether a fresh `/config` with 2.5.12 is simple is UNVERIFIED (2.5.12 release notes fetched; the migration notes were not). Recommendation: build 2.5.12, since 1.23.17 is an end-of-line release, and document the migration path from the chart's 1.23.17 data.
- Checksum: none published for the source tarball. Pin by tag; record the observed sha256 in the PR.
- The source tarball build is compiled per arch (native sqlite modules). arm64 is UNTESTED here.
- The upstream healthcheck (`extra/healthcheck`, a Go binary) is not ported. Readiness is covered by the test's HTTP probe, not by the Docker HEALTHCHECK.
- Network checks need outbound access; ICMP ping monitors need extra capabilities on some hosts (draft caveat, inferred; not changed here).
- Blockers: the Node version of `python-node:3.15.2` against 2.5.12 is UNVERIFIED (see section 3). Not musl-only, no GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/uptime-kuma
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name uptime-kuma-probe --read-only --tmpfs /tmp \
  -v uptime-kuma-probe-config:/config uptime-kuma:2.5.12
docker logs -f uptime-kuma-probe
forgetool containers test --image uptime-kuma:2.5.12 \
  --config ./apps/uptime-kuma/container-test.yaml
docker rm -f uptime-kuma-probe; docker volume rm uptime-kuma-probe-config
```
Expected readiness signal: UNVERIFIED exact log line; look for the server listening on port 3001 and the process staying alive. Confirm the SQLite database exists under `/config` after start, and that a restart keeps it. Probe 3001 from the host with `-p 3001:3001` to prove it is not bound to localhost only.

## 12. PR checklist

- Branch `feat/add-uptime-kuma`; commit and PR title `feat(uptime-kuma): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested: arm64 build and run, the 2.x database migration path from 1.23.17, the HTTP probe status, the tag archive checksum (none published), the upstream healthcheck is not ported.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no test assertion was weakened.
- Downstream: not used as a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
