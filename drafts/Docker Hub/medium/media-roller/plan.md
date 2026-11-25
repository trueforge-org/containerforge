# media-roller — implementation plan
> Source: ./draft.md · Target: apps/media-roller/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub release and no git tags exist. Pin a commit. The upstream Dockerfile the draft links is at commit `968415c8a43992941c4aaf54eb7d2f97b85120be`, which this plan reviewed. Docker Hub `ronnieroller/media-roller` `latest` and `sha-e1c5efc` were pushed 2026-11-24, so `master` may be newer. Re-review the Dockerfile at the chosen commit before writing (UNVERIFIED whether `e1c5efc` changes it). |
| Renovate | Source commit: `datasource=git-refs depName=https://github.com/rroller/media-roller currentValue=master` (precedent: `apps/tvheadend/docker-bake.hcl`). UNVERIFIED: no renovate config checked. |
| License | UNVERIFIED: the GitHub license API returns 404 (no detected license). The bake `LICENSE` cannot be set until the upstream license is found (blocker). |
| Source URL | https://github.com/rroller/media-roller |
| Source tarball | `https://github.com/rroller/media-roller/archive/${VERSION}.tar.gz` with `VERSION` = commit SHA (pattern as in `apps/fenrus`). |
| Checksum source | None published. The tarball is content-addressed by the commit SHA. Record a locally computed `sha256` in the Dockerfile and say so in the PR (UNVERIFIED that the archive hash is stable). |
| Upstream Dockerfile reviewed | Commit `968415c`: builder `golang:1.27.4-alpine3.24`, `apk add curl`, `go mod download`, `go build -x -o media-roller ./src`. Final `python:3.15.2-alpine3.24`. `apk add deno curl gcc musl-dev python3-dev libffi-dev`. `COPY --from=mwader/static-ffmpeg:9.0.2-1` for ffmpeg and ffprobe to `/usr/local/bin`. `pip install curl_cffi --upgrade --pre`, `pip install -U yt-dlp-ejs`. yt-dlp `2026.10.26` downloaded from `https://github.com/yt-dlp/yt-dlp/releases/download/2026.10.26/yt-dlp` with sha256 `e51e69e89489f199530f13d32a4342da3ddb2cf34842f364603a066db05afbf3`, then `yt-dlp --update --update-to nightly`. `ENV MR_DOWNLOAD_DIR=/download`, `WORKDIR /app`, `ENTRYPOINT ["/app/media-roller"]`, templates and static copied. No `EXPOSE`, no `USER`. |
| yt-dlp (latest, verified) | `2026.11.23` (GitHub latest release). SHA2-256SUMS: generic `yt-dlp` `e8665ed64d6b9172773e812f891fb707a0cb1ee8d9ef4fc1acb00cabee4c5256`; `yt-dlp_linux` `249ddb058234276bc449b9cd9492aad9f133bda5923c61a9e39983ae114ef17d`; `yt-dlp_linux_aarch64` `fb847a2e4a9ddc8cf5fcfb4bb7f42ba8969ecf72068def0278074f9d300bd13c`. URL pattern `https://github.com/yt-dlp/yt-dlp/releases/download/2026.11.23/<asset>`. The `yt-dlp_linux*` assets are PyInstaller builds, glibc; the generic `yt-dlp` is the Python zipapp that upstream's URL pattern also uses (inferred from the same path). |
| ffmpeg | Upstream: `mwader/static-ffmpeg:9.0.2-1` (arch availability UNVERIFIED). This plan uses apt `ffmpeg` instead (see section 3). |
| deno | Upstream: apk on alpine. Ubuntu: UNVERIFIED package name or release URL and its checksum. Options are section 4 step 5. |
| Port | UNVERIFIED: upstream has no `EXPOSE` and the README was not fetched. The draft's 8080 is a guess. Read the listen address from `src/` at the pinned commit before writing any port. |
| Env vars (real) | `MR_DOWNLOAD_DIR` (default `/download`, from Dockerfile). Others: UNVERIFIED (README not fetched). |
| Write paths (upstream) | `/download` (`MR_DOWNLOAD_DIR`, the chart PVC). Temp downloads in `/tmp` (draft; UNVERIFIED). |
| Dependency containers | None. Needs ffmpeg, yt-dlp, deno and python at runtime, all in the image. |

## 2. Target layout

- `apps/media-roller/Dockerfile`
- `apps/media-roller/docker-bake.hcl`
- `apps/media-roller/settings.yaml`
- `apps/media-roller/container-test.yaml`
- `apps/media-roller/start.sh`

No `defaults/`, `etc/` or `health/` unless the port check (section 8) needs them. No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

Build stage: `FROM golang:1.27.4 AS build` (tag from upstream's builder; the official Go image is glibc, not alpine). UNVERIFIED: the image digest. Look it up with `docker buildx imagetools inspect golang:1.27.4` and pin `@sha256:...` before the build, as the go-runtime rules require.

Runtime stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`.

Why python and not ubuntu: the draft offers `ubuntu` with python as the alternative, but yt-dlp (the zipapp) and the yt-dlp-ejs plugin need Python on the PATH, and the python sibling already provides `/usr/local/bin/python3` and pip, on the same ubuntu base. This avoids installing Python from apt. Closest sibling for the build-then-copy pattern: `apps/pwndrop` (build stage, `COPY --from=buildstage`); for a python base with a binary from a tarball: `apps/webhook`.

There is no `apps/ffmpeg` and no `apps/deno`. The draft's "ffmpeg from the ffmpeg sibling" does not exist. Use apt `ffmpeg` (inferred; `apps/bazarr` installs `ffmpeg` with apt on the python base).

## 4. Dockerfile

1. Build stage:

```dockerfile
FROM golang:1.27.4@sha256:<UNVERIFIED digest> AS build
ARG VERSION
RUN set -eux; \
    mkdir -p /tmp/src /tmp/build; \
    curl -fsSL -o /tmp/src.tar.gz "https://github.com/rroller/media-roller/archive/${VERSION}.tar.gz"; \
    echo "<sha256>  /tmp/src.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1; \
    cd /tmp/src && go mod download && \
    go build -o /tmp/build/media-roller ./src
```

   `curl` is present in the golang image (UNVERIFIED for this tag; add `apt-get install curl` if not). `GOCACHE` and `GOPATH` go to `/tmp` (go-runtime rule): set `ENV GOCACHE=/tmp/go-cache GOMODCACHE=/tmp/go-mod`. The `<sha256>` placeholder is a local computation, not shipped.
2. Runtime stage: apt packages (not in base; ffmpeg is the app's conversion tool, so it is pinned to the distro version and not to `VERSION`):

```dockerfile
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
        unzip \
    && rm -rf /var/lib/apt/lists/*
```

   `unzip` is only needed if deno is taken as a zip (step 5). Otherwise drop it.
3. Go binary and assets from the build stage:

```dockerfile
COPY --from=build /tmp/build/media-roller /app/media-roller
COPY --from=build /tmp/src/templates /app/templates
COPY --from=build /tmp/src/static /app/static
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/media-roller/LICENSE
```

   Paths of `templates` and `static` are UNVERIFIED; read them from the upstream `Dockerfile` at the pinned commit (it copies them, so the source path is there). The LICENSE line depends on the license blocker (section 10).
4. yt-dlp, pinned, arch-independent zipapp, checksum-verified (renovate-annotated separately from the app VERSION):

```dockerfile
# renovate: datasource=github-releases depName=yt-dlp/yt-dlp versioning=semver
ARG YTDLP_VERSION=2026.11.23
RUN set -eux; \
    curl -fsSL -o /usr/local/bin/yt-dlp \
        "https://github.com/yt-dlp/yt-dlp/releases/download/${YTDLP_VERSION}/yt-dlp"; \
    echo "e8665ed64d6b9172773e812f891fb707a0cb1ee8d9ef4fc1acb00cabee4c5256  /usr/local/bin/yt-dlp" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/yt-dlp
```

   The `--update --update-to nightly` step of upstream is dropped: `/app` is read-only and the version is pinned. Updates come from the renovate bump. The `yt-dlp-ejs` plugin and `curl_cffi` (upstream pip) are UNVERIFIED for this zipapp: check whether yt-dlp loads the plugin from the image's Python. If not, use a venv (`/app/media-roller/venv`, `python3 -m venv`, pip into it, `/app/media-roller/venv/bin/yt-dlp`) and pin its wheels with hashes.
5. deno (JS runtime for yt-dlp). Options, pick one and verify its checksum from the release's published `.sha256sum`:
   - a. Download the release zip `deno-x86_64-unknown-linux-gnu.zip` / `deno-aarch64-unknown-linux-gnu.zip` for `${TARGETARCH}` (asset names and version UNVERIFIED), unzip to `/usr/local/bin`.
   - b. An Ubuntu apt package, if the archive has one for 26.04 (UNVERIFIED).
   Use the per-arch `TARGETARCH` mapping (`amd64` to `x86_64`, `arm64` to `aarch64`) in a `case` statement.
6. Environment, data and PATH:

```dockerfile
ENV MR_DOWNLOAD_DIR=/config/download \
    TMPDIR=/tmp \
    XDG_CACHE_HOME=/tmp/cache \
    DENO_DIR=/tmp/deno
```

   `MR_DOWNLOAD_DIR` is remapped from `/download` to `/config/download` (section 9).
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
# EXPOSE only after the port is verified (section 8)
```

   `WORKDIR` is `/config` (sibling pattern). The binary path is absolute: `/app/media-roller`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "media-roller"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/rroller/media-roller currentValue=master
  default = "968415c8a43992941c4aaf54eb7d2f97b85120be"
}

variable "LICENSE" {
  default = "UNVERIFIED"   // blocker: the upstream license is not found; set the SPDX value before merge
}

variable "SOURCE" {
  default = "https://github.com/rroller/media-roller"
}
```

The default `VERSION` is the reviewed commit. Use the chosen commit (section 1) and match the Dockerfile `ARG VERSION`. Standard `group "default"`, `image`, `image-local`, `image-all` targets from `apps/tvheadend/docker-bake.hcl` or `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/media-roller/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rroller/media-roller"
ports:
  []   # add the verified port here (section 8); none is listed until then
env:
  - name: MR_DOWNLOAD_DIR
    default: "/config/download"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`MR_DOWNLOAD_DIR` must match `start.sh`. Other README variables are added only after they are confirmed in the source (UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash

export MR_DOWNLOAD_DIR="${MR_DOWNLOAD_DIR:-/config/download}"
mkdir -p "${MR_DOWNLOAD_DIR}"

cd /app
exec /app/media-roller
```

- Idempotent: only `mkdir -p` on `/config/download`. Nothing is seeded.
- Writes: `/config` and `/tmp` only. Nothing under `/app`. yt-dlp and deno caches go to `/tmp` via `XDG_CACHE_HOME` and `DENO_DIR`.
- Network: the bind address is UNVERIFIED. Read it from the source at the pinned commit; the server must listen on all interfaces.
- `exec` so the Go process is PID 1's replacement and gets signals.
- Any flags (such as a port flag) are UNVERIFIED until read from `src/`.

## 8. container-test.yaml

No port is verified, so no port probe is written yet. The draft's 8080 is a guess and must not become a probe. Once the listen address is read from `src/` at the pinned commit, add one `tcp` and one `http` probe for that port and add the port to `settings.yaml`.

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/media-roller
- /usr/local/bin/yt-dlp
- /usr/bin/ffmpeg
- /usr/share/licenses/media-roller/LICENSE
runners:
- entrypoint: /usr/local/bin/yt-dlp
  cmd: --version
  expectedOutput: 2026.11.23
```

- The `runners` `expectedOutput` match semantics (exact or substring) are UNVERIFIED: check the forgetool schema before relying on it.
- Add a deno runner (`deno --version`) once the deno install is chosen (step 5).
- If the application has no test-able port at all, record that in section 10 and keep the file-level checks above as the real assertions. Do not weaken them.
- `filePaths` for the LICENSE line fails until the license blocker is solved (it is only copied when the upstream LICENSE exists).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/download` (`MR_DOWNLOAD_DIR`, chart PVC) | `/config/download` (default in image and `start.sh`). Chart users must move their `/download` PVC content, or mount it at `/config/download`. |
| Temp downloads in `/tmp` (draft) | Kept in `/tmp` (`TMPDIR`). |
| yt-dlp cache (`~/.cache`) | `XDG_CACHE_HOME=/tmp/cache`. |
| deno cache | `DENO_DIR=/tmp/deno`. |
| Go build cache (build stage only) | `GOCACHE` and `GOMODCACHE` in `/tmp`. Not in the runtime image. |
| `yt-dlp --update` at build | Dropped (read-only `/app`; pinned). |

Draft expectations reconciled: the chart runs as UID 0 (forced), `readOnlyRootFilesystem: false`. The image is compatible with `--read-only --tmpfs /tmp` only once the download dir is `/config/download` and every write is in `/config` or `/tmp` (to verify). Not privileged. Extra persistence is `/config/download`, not a separate `/download`.

## 10. Risks, caveats and open questions

- **License (blocker)**: no license detected. The image cannot be published with a `LICENSE` value or a license file that is not confirmed. Ask the upstream or find `LICENSE` in the repo before merge.
- **Version (blocker-ish)**: no tags or releases. The commit must be pinned and the Dockerfile re-reviewed at that commit. Renovate will bump on every master push (noisy); consider `schedule` or `limitConcurrent` in renovate config (not checked).
- **Port**: UNVERIFIED. The draft's 8080 is a guess. Settings and probes wait for the source read.
- **yt-dlp**: needs a JS runtime (deno) and frequent updates to keep working with the sites it downloads from. The pinned version will go stale; the renovate bump is the update path.
- **yt-dlp-ejs and curl_cffi**: upstream installs them with pip. Whether the zipapp loads them is UNVERIFIED (section 4 step 4).
- **ffmpeg**: apt `ffmpeg` is used instead of upstream's static build. Its codec set and arm64 package availability are UNVERIFIED. The large-disk note from the draft applies (inferred).
- **deno**: source and checksum are UNVERIFIED (section 4 step 5).
- **Go version**: the upstream builder is Go 1.27.4 (alpine). The go build on the glibc `golang:1.27.4` image is UNVERIFIED to produce the same binary; the image digest is UNVERIFIED.
- **Arch**: `compile` on amd64 and arm64 (Go builds for `TARGETARCH`). yt-dlp zipapp is arch-neutral. deno and ffmpeg are arch-specific (checked per section 4). arm64 build under QEMU is slow.
- **copy-from**: `no` for both arches. Upstream's `mwader/static-ffmpeg` is an ffmpeg image, not the app, and is not used.
- Blockers: the license, the port, the commit pin and the deno install. None is a musl-only, GPU or privileged issue.

## 11. Build and test steps

```sh
cd apps/media-roller
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name media-roller-probe --read-only --tmpfs /tmp \
  -v media-roller-probe-config:/config media-roller:<commit-sha>
docker logs -f media-roller-probe
forgetool containers test --image media-roller:<commit-sha> --config ./apps/media-roller/container-test.yaml
docker rm -f media-roller-probe; docker volume rm media-roller-probe-config
```

- Expected readiness signal: UNVERIFIED (no port, no log lines known). Read the first run's log and record the exact line in the PR. The container must stay running after the startup window and show no fatal error.
- Run `yt-dlp --version` and `deno --version` inside the container (`docker run --rm ... yt-dlp --version`) to confirm both run on the image's Python and glibc.
- Empty `/config` with a fresh volume, then restart with the same volume.
- Round limit: 10 rounds per the build-test protocol.

## 12. PR checklist

- Branch `feat/add-media-roller`, commit and PR title `feat(media-roller): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Untested, to state honestly in the PR: the port and the web UI, the deno and yt-dlp plugin behaviour, the arm64 build, `--read-only` behaviour, the chart's download PVC migration, and the license.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; the yt-dlp checksum is verified; no assertion weakened; `LICENSE` confirmed before merge.
