# immich — implementation plan
> Source: ./draft.md · Target: apps/immich/ · Difficulty: hard · Role: main (row 1, server; row 2 machine-learning is a separate sidecar app, see section 10) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest tag (server row) | `v3.4.2`, published 2026-11-18 (https://api.github.com/repos/immich-app/immich/releases/tags/v3.4.2). Tag `v3.4.1` exists (ML row). |
| Draft image (server) | `ghcr.io/immich-app/immich-server:v3.4.2` (compose uses `${IMMICH_VERSION:-release}`; https://api.github.com/repos/immich-app/immich/contents/docker/docker-compose.yml?ref=v3.4.2) |
| Draft image (ML) | `ghcr.io/immich-app/immich-machine-learning:v3.4.1-openvino`, `v3.4.2`, `v3.4.2-cuda` (draft lists several) |
| Renovate | `datasource=github-releases depName=immich-app/immich versioning=semver` (server). ML shares the same repo and tag. |
| License | AGPL-3.0 (GitHub API, immich-app/immich). |
| Source URL | https://github.com/immich-app/immich |
| Binary download | The draft's "Application binary" links point to the **Android app** APKs (`app-x86_64-release.apk`, `app-arm64-v8a-release.apk`). These are the mobile client, NOT the server. The server is not a release asset. The draft's amd64/arm64 `yes*` for row 1 is therefore wrong and is corrected here: the server is built from source or taken from the upstream image (see section 4). |
| Server Dockerfile reviewed | https://raw.githubusercontent.com/immich-app/immich/v3.4.2/server/Dockerfile: builder `ghcr.io/immich-app/base-server-dev:202610291416@sha256:5f4f9f77059e1cd0182994419a19f4ee045c3fd48e611f5e77623ed63f7aa1e4`; final `ghcr.io/immich-app/base-server-prod:202610291416@sha256:6211bec52cbccc19076889b0c39ef473a1a1d02ceb635ccd2e0ecb4683e5fd4d`; stages `sdk`, `plugin-sdk`, `server`, `web`, `cli`, `plugins` (`mise install --locked`); `restic-proxy` v1.11.2 and `restic` 0.19.1-futo.2 copied into `/usr/local/bin`; `sharp` built against global libvips; `EXPOSE 2283`; `VOLUME /data`; `ENTRYPOINT ["tini","--","/bin/bash","-c"]`; `CMD ["start.sh"]`; `HEALTHCHECK CMD immich-healthcheck`; no `USER` (base default). |
| ML Dockerfile reviewed | https://raw.githubusercontent.com/immich-app/immich/v3.4.1/machine-learning/Dockerfile: `python:3.13-slim-trixie` (cpu, openvino), `nvidia/cuda:12.2.2-runtime-ubuntu22.04` (cuda), `python:3.12` (rknn), `python:3.13-trixie` (armnn, aarch64); `uv sync --frozen --extra ${DEVICE} --no-dev`; `ENTRYPOINT ["tini","--"]`; `CMD ["python","-m","immich_ml"]`; `HEALTHCHECK CMD python3 healthcheck.py`. |
| Ports | Server `2283/tcp` (compose `2283:2283`; Dockerfile `EXPOSE 2283`). ML `3003/tcp` (confirmed default `immich_port = 3003` in `machine-learning/immich_ml/config.py`, tag v3.4.1). |
| Data paths | Server: upload media at `/data` (`VOLUME /data`; compose `${UPLOAD_LOCATION}:/data`). Draft's `/usr/src/app/upload` is NOT confirmed by the v3.4.2 Dockerfile. ML: `/cache` (`MACHINE_LEARNING_CACHE_FOLDER`, `HF_HOME=/cache/hf-cache`, `TRANSFORMERS_CACHE=/cache`, JIT caches under `/cache/jit`). |
| Env vars (confirmed) | Server (compose): `DB_PASSWORD`, `DB_USERNAME`, `DB_DATABASE_NAME`, `DB_STORAGE_TYPE` (optional, `HDD`), `UPLOAD_LOCATION`, `DB_DATA_LOCATION`, `IMMICH_VERSION`. ML: `MACHINE_LEARNING_*` prefix (confirmed), `MACHINE_LEARNING_MODEL_ARENA=false` in image. |
| Env vars (UNVERIFIED) | Server DB host, port, Redis/Valkey host names (for example `DB_HOSTNAME`, `DB_PORT`, `REDIS_HOSTNAME`): NOT confirmed by fetched pages. Do not add to `settings.yaml` until read from the server source (UNVERIFIED). |
| Dependencies (confirmed by compose) | PostgreSQL 14 with vector extension: `ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0` (upstream image, vectorchord + pgvectors). Valkey: `docker.io/valkey/valkey:9`. ContainerForge has `apps/valkey` and `apps/postgresql`; neither is confirmed to ship the vectorchord or pgvectors extension (UNVERIFIED). |
| Architectures | Server image: no platform list in the Dockerfile (UNVERIFIED). ML: CPU works on amd64 and arm64; openvino and cuda are amd64 only; armnn is aarch64. |

## 2. Target layout

- `apps/immich/Dockerfile`
- `apps/immich/docker-bake.hcl`
- `apps/immich/settings.yaml`
- `apps/immich/container-test.yaml`
- `apps/immich/start.sh`

Plus `defaults/` only if a config template is required (UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

Row 2 (machine-learning) is a separate app folder, for example `apps/immich-machine-learning/`, and is NOT part of this plan. It is listed as missing in the draft (dependency `immich-machine-learning` ❌).

## 3. Base image

Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, as the draft says. The server is Node.js, and no Node base exists in the brief's base table, so Node must be installed on the ubuntu base (version UNVERIFIED: read `engines` and `.nvmrc` from the v3.4.2 source). Closest sibling for a Node-on-ubuntu server: none confirmed; use the `apps/bookstack` multi-package apt pattern and the `apps/adguardhome-sync` single-binary layout as shape references only.

Build stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` with Node, pnpm (via corepack) and `libvips` headers installed by apt.

## 4. Dockerfile

Route decision (open, section 10): build from source in a build stage. Upstream `base-server-prod` is a copy-from option only and is not a ContainerForge base, so it is not used as a runtime base.

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION` (`3.4.2`), `ARG TARGETARCH`, `USER root`.
2. `apt-get install` Node (pinned to the version found in step 1 of section 1, UNVERIFIED), `libvips-dev`, `build-essential`, `ca-certificates`, `git`, `tini`, `bash`.
3. Download the source (checksum: none published as a file; pin by tag):
   ```dockerfile
   RUN curl -fL -o /tmp/immich.tar.gz "https://github.com/immich-app/immich/archive/refs/tags/v${VERSION}.tar.gz" && \
       tar xzf /tmp/immich.tar.gz -C /tmp --strip-components=1
   ```
4. `corepack enable pnpm` with `COREPACK_HOME=/tmp`, `PNPM_HOME=/tmp/pnpm-store`. Build in the upstream order: `sdk`, `plugin-sdk`, `server` (`server/bin`), `web`, `cli`. `SHARP_FORCE_GLOBAL_LIBVIPS=true` on the server build.
5. Copy restic: `restic` and `restic-proxy` are upstream binaries (`COPY --from=` of their images, versions above). Use `restic` only if the server needs it at runtime: UNVERIFIED; if used, verify the release checksum from the upstream restic release (not fetched).
6. Final stage `FROM <ubuntu>`, `USER root`: `apt-get install` the Node runtime, `tini` (start.sh uses it) and `libvips42`. Copy `/tmp/server-pruned` to `/app/immich/server`, `web` build to `/app/immich/web`, `cli` to `/app/immich/cli`. Symlink `/data` to `/config/data` (see section 9).
7. Licence: copy `LICENSE` to `/usr/share/licenses/immich/LICENSE`.
8. `ENV NODE_ENV=production IMMICH_MEDIA_LOCATION=/data` (variable name UNVERIFIED; read it from the source before setting), `PATH=/app/immich/server/bin:$PATH`, `HOME=/config`.
9. `chown -R apps:apps /app/immich && chmod -R 755 /app/immich`.
10. Tail:
    ```dockerfile
    USER apps
    COPY --chmod=0755 . /

    EXPOSE 2283
    VOLUME /config
    WORKDIR /app/immich/server
    ```

No `pnpm` or build tools in the final stage. No writes to `/app` at runtime (see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "immich"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=immich-app/immich versioning=semver
  default = "3.4.2"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/immich-app/immich"
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

Run `docker buildx bake --print` before commit. `ARG VERSION` in the Dockerfile must equal `3.4.2`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/immich-app/immich"
ports:
  - port: 2283
    protocol: tcp
    required: true
env:
  - name: DB_USERNAME
    default: "immich"
    required: true
  - name: DB_PASSWORD
    default: ""
    required: true
  - name: DB_DATABASE_NAME
    default: "immich"
    required: true
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
  - name: valkey
```

Env defaults match the compose file. `DB_PASSWORD` has `required: true` with an empty default, so `start.sh` must refuse to start with a clear message when it is unset (protocol: test runs with no env vars, so the `DB_PASSWORD`-required path goes to `filePaths`, see section 8). `DB_HOSTNAME`, `DB_PORT`, Redis host variables: add only after they are read from the source (UNVERIFIED, section 1). Both dependencies exist in ContainerForge (`apps/postgresql`, `apps/valkey`).

## 7. start.sh

```bash
#!/usr/bin/env bash

: "${DB_PASSWORD:?DB_PASSWORD must be set}"

mkdir -p /config/data /tmp/immich

cd /app/immich/server
exec tini -- node dist/main.js
```

- Idempotent: creates directories only, never overwrites user data in `/config`.
- Applies `DB_PASSWORD` from the environment on every start (protocol rule for databases), through the environment the server reads, not written to files.
- No writes to `/app`; caches and temp go to `/tmp` (`/tmp/immich`).
- The final command is a placeholder: the real entry point (`start.sh` upstream, `node` path, and `dist/main.js` name) is UNVERIFIED. Confirm against the v3.4.2 image entry before finalising. Keep `exec`.
- `DB_PASSWORD` missing: the `:?` guard exits non-zero by design. This is the one path the empty-env test cannot reach (section 8).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '2283'  # narrowed: requires external postgresql and valkey; full functional test not feasible in single-container suite
http:
- port: '2283'
  path: /  # narrowed: requires external postgresql and valkey; full functional test not feasible in single-container suite
filePaths:
- /app/immich/server
- /app/immich/web
- /usr/share/licenses/immich/LICENSE
```

Immich meets the database-dependency exception criteria: a hard dependency on PostgreSQL and Valkey in `settings.yaml`; the server will not come up without them; and a sidecar DB cannot be wired into `container-test.yaml` with the available primitives. The narrowing comment above is required. The `tcp` and `http` probes stay real: they confirm the process listens on 2283. Do not replace them with always-true checks. The `/` path is a placeholder; confirm the status code on a real run (UNVERIFIED).

Because the test runs without environment variables, `DB_PASSWORD` missing is not exercised by the suite. Run it manually per the protocol to confirm the guard exits non-zero.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (media, VOLUME) | symlink `/data` -> `/config/data` at build time (needs root in the build stage, which is already the case) |
| `/usr/src/app/upload` (draft path) | Not confirmed by the v3.4.2 Dockerfile; the server uses `/data` (UNVERIFIED for sub-folders library, upload, thumbs, profile, encoded-video) |
| Node temp, npm, pnpm, `/tmp` | `/tmp` (`HOME=/config` only for user config; caches set explicitly to `/tmp`) |
| `/cache` (ML models, row 2 only) | Not in this app |

Draft expectations reconciled: the chart runs as UID 0 and `readOnlyRootFilesystem false`, plus `disableS6Caps true`. This image runs as `apps` and works with `--read-only --tmpfs /tmp`. The chart's `emptyDir` at `/mlcache` and `/microcache` belong to row 2 (ML), not this app. The upload dirs mount under `/config/data`; existing chart users copy their `/usr/src/app/upload` data into the new location.

Rootless: the upstream `docker-compose.rootless.yml` (release asset) shows the official rootless deployment (UNVERIFIED contents, not fetched).

## 10. Risks, caveats and open questions

- **Route decision (needs the user):** the server is built from source in a Node build stage (section 4). The alternative is `COPY --from=ghcr.io/immich-app/immich-server:v3.4.2`, which ContainerForge rules do not prohibit but which makes the image a rebuild of an upstream image on a different base. Pick one before implementation.
- **Node version:** UNVERIFIED. Read `engines` and `.nvmrc` from the v3.4.2 source. The build and runtime must match.
- **Row 2 (ML) is missing** (`immich-machine-learning` ❌ in the draft). Immich's search and face recognition do not work without it. Port it as its own app with `python:3.13` behaviour; ContainerForge's `python` base is `3.15.2`, so the ML app needs a `uv`-managed Python 3.13 or a version check (UNVERIFIED that 3.15 works with the upstream pins).
- **PostgreSQL extension:** the server needs the vectorchord and pgvectors extensions. `apps/postgresql` is not confirmed to ship them. Blocker until the extension is in the postgres app or a compatible image is used (UNVERIFIED).
- **Binary download in the draft is wrong** (Android APK, section 1). The server has no release asset; this plan uses a source build.
- **Database and Redis env names** are unverified; the settings list is incomplete until they are read from the source.
- **Model downloads** happen on first ML use: disk, internet and time (draft caveat, plausible; sizes UNVERIFIED). This is row 2, not this app.
- CUDA and OpenVINO variants are amd64-only (row 2, draft caveat).
- Difficulty stays `hard`: multi-service, source build of Node plus libvips, and a missing sidecar.

## 11. Build and test steps

```sh
cd apps/immich
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name immich-probe --read-only --tmpfs /tmp \
  -e DB_PASSWORD=test -v immich-probe-config:/config immich:3.4.2
docker logs -f immich-probe
forgetool containers test --image immich:3.4.2 --config ./apps/immich/container-test.yaml
docker rm -f immich-probe; docker volume rm immich-probe-config
```

Note: `-e DB_PASSWORD=test` is only for this manual run. The `forgetool` run has no env vars, so the `DB_PASSWORD` guard is checked separately: `docker run --rm immich:3.4.2` with no env must exit non-zero with the guard message.

Expected readiness signal: the server log line that the HTTP server is listening on 2283 (exact text UNVERIFIED). Since no database is present, the server is expected to log connection retries: the protocol accepts that only when the process stays alive and there is no fatal exit. Run a second time with the same `/config` volume to confirm restart keeps data.

## 12. PR checklist

- Branch `feat/add-immich`, commit and PR title `feat(immich): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the full server with PostgreSQL and Valkey, the ML sidecar (not in this PR), the arm64 build, the exact readiness log line, and the `/` probe status code.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; the narrowed DB-dependent assertions carry the required comment.
