# photoprism — implementation plan
> Source: ./draft.md · Target: apps/photoprism/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 261029-963b58c50. Latest GitHub release (published 2026-10-29T22:20:43Z, not prerelease). Source: https://api.github.com/repos/photoprism/photoprism/releases/latest. The draft's chart image `photoprism/photoprism:251130` is older (the Docker Hub tag `photoprism/photoprism:251130` exists; its date was not read). Target the latest release, and confirm the 251130 vs 261029 choice in section 10. |
| Renovate | `// renovate: datasource=github-releases depName=photoprism/photoprism versioning=loose` (tags are `YYMMDD-sha`, not semver). The `loose` choice follows the bake rule (use `loose` when tags are not strict semver). |
| License | UNVERIFIED. GitHub API reports `NOASSERTION` (https://api.github.com/repos/photoprism/photoprism). Read the repo `LICENSE` file and set SPDX before writing `docker-bake.hcl`. |
| Source URL | https://github.com/photoprism/photoprism |
| Download amd64 | https://github.com/photoprism/photoprism/releases/download/261029-963b58c50/photoprism_261029-963b58c50-linux-amd64.tar.gz (confirmed via `gh api`, asset name and URL listed) |
| Download arm64 | https://github.com/photoprism/photoprism/releases/download/261029-963b58c50/photoprism_261029-963b58c50-linux-arm64.tar.gz (confirmed) |
| Checksum source | None attached to the release (only the two tarballs). Checksum: UNVERIFIED, none published. Pin the tarball by SHA256 that we compute and record in the Dockerfile, and note the source is the GitHub release asset. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/photoprism/photoprism/master/docker/photoprism/questing/Dockerfile (fetched). Stage 1: `FROM photoprism/develop:questing`, `make all install DESTDIR=/opt/photoprism`. Stage 2: `FROM photoprism/develop:questing-slim`, sets the env block below, `EXPOSE 2342 2443`, `WORKDIR /photoprism`, `COPY --from=build /opt/photoprism/ /opt/photoprism`. No `VOLUME`, `USER`, `ENTRYPOINT`, `CMD`. |
| Upstream apt packages | None installed explicitly. Stage 2 runs `apt-get update`, `dist-upgrade`, `yt-dlp -U`. The `questing-slim` base carries the runtime tools (ffmpeg, exiftool, libvips). Those are NOT in the release tarball, so they must come from apt here (names UNVERIFIED, see section 4). |
| Env vars (verified) | `PHOTOPRISM_ASSETS_PATH=/opt/photoprism/assets`, `PHOTOPRISM_IMPORT_PATH=/photoprism/import`, `PHOTOPRISM_ORIGINALS_PATH=/photoprism/originals`, `PHOTOPRISM_STORAGE_PATH=/photoprism/storage`, `PHOTOPRISM_BACKUP_PATH=/photoprism/storage/backups`, `PHOTOPRISM_LOG_FILENAME=/photoprism/storage/photoprism.log`, `PHOTOPRISM_PID_FILENAME=/photoprism/storage/photoprism.pid`, `PHOTOPRISM_HTTP_HOST=0.0.0.0`, `PHOTOPRISM_HTTP_PORT=2342`, `PHOTOPRISM_SITE_URL=http://localhost:2342/`, `PHOTOPRISM_DATABASE_DRIVER=sqlite`, `PHOTOPRISM_DATABASE_NAME=photoprism`, `PHOTOPRISM_DATABASE_USER=photoprism`, `PHOTOPRISM_DATABASE_SERVER=""`, `PHOTOPRISM_INIT=https`, `PHOTOPRISM_AUTO_INDEX=300`, `PHOTOPRISM_AUTO_IMPORT=-1`, `PHOTOPRISM_DISABLE_CHOWN=false`, `PHOTOPRISM_DISABLE_TENSORFLOW=false`, `PHOTOPRISM_DISABLE_FACES=false`, `PHOTOPRISM_DISABLE_EXIFTOOL=false`, `PHOTOPRISM_DISABLE_PLACES=false`, `PHOTOPRISM_DISABLE_BACKUPS=false`, `PHOTOPRISM_DISABLE_WEBDAV=false`, `PHOTOPRISM_DISABLE_SETTINGS=false`, `PHOTOPRISM_THUMB_UNCACHED=false`, `PHOTOPRISM_RAW_PRESETS=false`, `PHOTOPRISM_UPLOAD_NSFW=true`, `PHOTOPRISM_DETECT_NSFW=false`, `PHOTOPRISM_EXPERIMENTAL=false`, `PHOTOPRISM_DEBUG=false`, `PHOTOPRISM_PUBLIC=false`, `PHOTOPRISM_READONLY=false`, `TMPDIR=/tmp`, `MALLOC_ARENA_MAX=2`, `DO_NOT_TRACK=true`, `ORT_DISABLE_TELEMETRY=1`. |
| Ports | 2342 (HTTP, `PHOTOPRISM_HTTP_PORT`). Upstream also `EXPOSE 2443` (purpose UNVERIFIED; not used in the env block, so not listed in `settings.yaml`). |
| Dependencies | MariaDB optional (draft). SQLite is the default driver (verified), so no DB is required to start. `apps/mariadb` exists. |
| Arm64 | Release tarball for linux-arm64 exists (verified). |

Draft's chart security: runs as root (`runAsUser 0`), read-only-rootfs no, privileged no. Upstream has no `USER` (root default), which matches the chart.

## 2. Target layout

- `apps/photoprism/Dockerfile`
- `apps/photoprism/docker-bake.hcl`
- `apps/photoprism/settings.yaml`
- `apps/photoprism/container-test.yaml`
- `apps/photoprism/start.sh`

Upstream `/scripts/` (cleanup and dist helper scripts) are not needed: they are part of the image build, not runtime. No `defaults/` or `etc/` unless the first-run config needs seeding (decision in section 7). Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Rationale: the draft says ubuntu alone is enough (Go binary from an upstream tarball, no runtime base). The Go rule (build in a stage, copy into the runtime stage) does not apply because we do not compile. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball from GitHub releases chosen per `TARGETARCH`, `USER root`, `chown -R apps:apps /app`, `COPY --chmod=0755 . /`, `USER apps`).

Upstream image is built on `photoprism/develop:questing-slim`, not Ubuntu. We reproduce runtime needs with apt on Ubuntu 26.04.

## 4. Dockerfile

1. Header: `ARG VERSION` (must match bake default `261029-963b58c50`), `ARG TARGETARCH` (`amd64` or `arm64`, matches tarball name).
2. `USER root` for installs.
3. Runtime apt packages (no recommends; names UNVERIFIED, check against Ubuntu 26.04 archive and the upstream tarball's dependency list):
   - `ffmpeg` (video transcoding and thumbnails)
   - `libvips-tools` (thumbnail generation; draft inferred)
   - `libimage-exiftool-perl` (metadata; draft inferred)
   - `ca-certificates`, `curl` already in base (do not reinstall).
   - Pin nothing unless the package is needed to match `VERSION` (apt versions are the toolchain, not the app; same reasoning as the fenrus plan; `apps/fenrus` does not exist yet). Record the exact versions in the PR body.
4. Fetch and verify the tarball for `TARGETARCH`:
   ```dockerfile
   RUN curl -fsSL -o /tmp/photoprism.tar.gz \
         "https://github.com/photoprism/photoprism/releases/download/${VERSION}/photoprism_${VERSION}-linux-${TARGETARCH}.tar.gz" \
    && echo "<sha256-amd64-or-arm64>  /tmp/photoprism.tar.gz" | sha256sum -c - \
    && mkdir -p /opt/photoprism && tar xzf /tmp/photoprism.tar.gz -C /opt/photoprism --strip-components=1 \
    && rm -f /tmp/photoprism.tar.gz
   ```
   Digests are per arch and must be computed by us (no upstream checksum). Tarball internal layout (`--strip-components` value, `bin/photoprism` path, `assets/` location) is UNVERIFIED until listed with `tar tzf`.
5. Ship license to `/usr/share/licenses/photoprism/LICENSE` (from repo, file name UNVERIFIED).
6. Ownership: `chown -R apps:apps` only for `/config` paths (none in image); `/opt/photoprism` stays root-owned, read-only at runtime (`chmod -R 755`).
7. Caches to `/tmp`: `ENV TMPDIR=/tmp`, `XDG_CACHE_HOME=/tmp/.cache` (UNVERIFIED that photoprism honours XDG; set both regardless).
8. Tail:
   ```dockerfile
   ENV \
     PHOTOPRISM_ASSETS_PATH=/opt/photoprism/assets \
     PHOTOPRISM_STORAGE_PATH=/config/storage \
     PHOTOPRISM_ORIGINALS_PATH=/config/originals \
     PHOTOPRISM_IMPORT_PATH=/config/import \
     PHOTOPRISM_BACKUP_PATH=/config/storage/backups \
     PHOTOPRISM_LOG_FILENAME=/config/storage/photoprism.log \
     PHOTOPRISM_PID_FILENAME=/tmp/photoprism.pid \
     PHOTOPRISM_HTTP_HOST=0.0.0.0 \
     PHOTOPRISM_HTTP_PORT=2342 \
     PHOTOPRISM_DATABASE_DRIVER=sqlite \
     PHOTOPRISM_DISABLE_CHOWN=true \
     DO_NOT_TRACK=true ORT_DISABLE_TELEMETRY=1 TMPDIR=/tmp
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 2342
   VOLUME /config
   WORKDIR /config
   ```
   `PHOTOPRISM_DISABLE_CHOWN=true` is a proposal (upstream default `false`): the image runs as `apps`, so chown would fail. Confirm with a test run.
9. Variables are moved from upstream `/photoprism` paths to `/config` (persistent) and `/tmp` (scratch). Upstream `PHOTOPRISM_DATABASE_SERVER=""` is not needed; leave default.

## 5. docker-bake.hcl

Same shape as `apps/adguardhome-sync/docker-bake.hcl`.

```hcl
variable "APP" { default = "photoprism" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=photoprism/photoprism versioning=loose
  default = "261029-963b58c50"
}
variable "LICENSE" { default = "<confirmed SPDX>" }
variable "SOURCE" { default = "https://github.com/photoprism/photoprism" }
```

Validate with `docker buildx bake --print` from `apps/photoprism/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/photoprism/photoprism"
ports:
  - port: 2342
    protocol: tcp
    required: true
env:
  - name: PHOTOPRISM_ADMIN_PASSWORD
    default: "change-me"   # placeholder; UNVERIFIED design, a baked default password is a shipped secret
    required: true
  - name: PHOTOPRISM_SITE_URL
    default: "http://localhost:2342/"
    required: false
  - name: PHOTOPRISM_DATABASE_DRIVER
    default: "sqlite"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - mariadb
```

- `PHOTOPRISM_ADMIN_PASSWORD` is UNVERIFIED as an env name. Confirm in upstream config docs or source before listing; otherwise drop it. Do not invent names.
- `PHOTOPRISM_DATABASE_DRIVER` default `sqlite` is verified.
- `opt_dependencies: mariadb` (optional, exists in `apps/`). Hard `dependencies:` stays empty because SQLite works.
- Only list env vars that `start.sh` reads or that the app reads (settings rule).

## 7. start.sh

Idempotent. Creates directories under `/config` if missing. Never writes to `/opt/photoprism`.

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/storage /config/originals /config/import

cd /opt/photoprism
exec /opt/photoprism/bin/photoprism start
```

- The binary path (`bin/photoprism`) and subcommand (`start`) are UNVERIFIED until the tarball is listed. Upstream `docker/` scripts use `photoprism start`; confirm.
- If the photoprism `--`-style config file needs seeding, add it only when missing (start-script rule). Not planned.
- `exec` for PID 1 handoff.
- MariaDB: if `PHOTOPRISM_DATABASE_DRIVER=mysql`, the DB env vars (`PHOTOPRISM_DATABASE_SERVER`, `_NAME`, `_USER`, `_PASSWORD`) are applied from the environment on every start (start-script rule). Not in the default path.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '2342'
http:
- port: '2342'
  path: /api/v1/status
filePaths:
- /opt/photoprism/bin/photoprism
- /opt/photoprism/assets
- /usr/share/licenses/photoprism/LICENSE
```

- `timeoutSeconds: 300`: photoprism initialises TensorFlow and indexes on first start; allow more than sibling defaults (UNVERIFIED that 300 is enough; measure in the run step).
- `/api/v1/status` is UNVERIFIED as the health path. Confirm with a real request; if it returns non-200 on a fresh `/config`, use `/` and record the status.
- Test runs without env vars, so the SQLite default path is what gets exercised. MariaDB path is not covered; state this in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream path (chart and image) | ContainerForge target |
| --- | --- |
| `/photoprism/storage` (storage, logs, backups) | `/config/storage` (persistent) |
| `/photoprism/originals` (chart pvc default) | `/config/originals` (persistent). The user may bind-mount a larger library at this path. |
| `/photoprism/import` (chart pvc default) | `/config/import` (persistent). |
| `/photoprism_temp` (chart emptyDir) | `/tmp` (ephemeral). |
| `/assets` (chart pvc default) | `/opt/photoprism/assets` (read-only, shipped in the image). |
| Root user, `PHOTOPRISM_DISABLE_CHOWN=false` | `USER apps`, `PHOTOPRISM_DISABLE_CHOWN=true` (proposal, verify). |
| Chart `readOnlyRootFilesystem: false` | Target read-only-rootfs compatible. |
| `PHOTOPRISM_PID_FILENAME=/photoprism/storage/photoprism.pid` | `/tmp/photoprism.pid` (no need to persist a PID). |

## 10. Risks, caveats and open questions

- Version: draft pins `251130`; latest release is `261029-963b58c50`. Target latest unless the reviewer wants the older tag. Confirm `251130` still exists as a tarball if the old one is wanted.
- License is `NOASSERTION` on GitHub. Confirm before setting `LICENSE`.
- No upstream checksum. We compute and pin SHA256 per arch. Record the computed values in the PR body.
- Runtime tools (ffmpeg, exiftool, libvips) come from apt on Ubuntu 26.04, not from the upstream image. Versions may differ from what upstream tested. The first index and transcode test is the check.
- TensorFlow and Places/face models are bundled in the tarball (UNVERIFIED). Their size and first-run downloads are unknown; a first start may need network.
- Indexing and transcoding are CPU and disk heavy; the first index can take hours (draft, inferred). The container test runs a short startup only.
- `PHOTOPRISM_DISABLE_CHOWN` proposal may change file ownership behaviour; test it on a non-empty `/config`.
- Blockers: no GPU needed. None fatal found. arm64 tarball exists; no arm64 test planned in this pass.

## 11. Build and test steps

From `apps/photoprism/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty-config run on `--read-only --tmpfs /tmp` with a fresh `/config` volume:
   ```sh
   docker run --rm -d --name photoprism-probe --read-only --tmpfs /tmp \
     -v photoprism-probe-config:/config photoprism:261029-963b58c50
   docker logs -f photoprism-probe
   ```
   Expected readiness: a "listening" or "ready" line for port 2342 (UNVERIFIED wording), process still running after the startup window, no fatal line about `/opt` or `/config` writes.
4. Cleanup: `docker rm -f photoprism-probe; docker volume rm photoprism-probe-config`.
5. Restart on the same volume to confirm idempotence.
6. `forgetool containers test --image photoprism:261029-963b58c50 --config ./container-test.yaml`.
7. arm64 only if amd64 fails.

## 12. PR checklist

- Branch `feat/add-photoprism`, commit `feat(photoprism): add new container`, PR title matches.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, checkboxes only where true.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested: arm64, MariaDB path, real indexing and transcoding, the first-run model download if any.
- Record the computed SHA256 values and the apt package versions in the PR body.
- Check "Built container locally" only after the step 2 build succeeds.
