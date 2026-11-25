# ersatztv — implementation plan
> Source: ./draft.md · Target: apps/ersatztv/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v26.3.0`. GitHub release published 2026-02-24, not a prerelease (`gh api repos/ErsatzTV/ErsatzTV/releases/tags/v26.3.0`). Chart also pins `v25.2.0-nvidia` and `v25.2.0-vaapi` (image tags). |
| Renovate | `datasource=github-releases depName=ErsatzTV/ErsatzTV versioning=semver` (proposed) |
| License | Zlib (GitHub license API, `repos/ErsatzTV/ErsatzTV/license`) |
| Source URL | https://github.com/ErsatzTV/ErsatzTV |
| Per-arch download | Release assets are on `ErsatzTV/ErsatzTV` (checked with `gh api`; `ErsatzTV/legacy` also lists the same names, but it is not used). amd64: https://github.com/ErsatzTV/ErsatzTV/releases/download/v26.3.0/ErsatzTV-v26.3.0-linux-x64.tar.gz . arm64: https://github.com/ErsatzTV/ErsatzTV/releases/download/v26.3.0/ErsatzTV-v26.3.0-linux-arm64.tar.gz . Also `linux-arm.tar.gz` and `linux-musl-x64.tar.gz` (not used; musl does not run on Ubuntu glibc). |
| Checksum source | None listed on the release. `UNVERIFIED`. Pin the asset URL and verify size or digest after download. |
| Upstream Dockerfile reviewed | `docker/nvidia/Dockerfile` at the draft's pinned commit `2271d5497becc30f8cf689715d115fb36d0abc8a` (read via `gh api ...contents/docker/nvidia/Dockerfile?ref=…`). |
| Upstream Dockerfile summary | `FROM mcr.microsoft.com/dotnet/aspnet:9.0-noble-amd64` (dotnet runtime, copied). `FROM jasongdove/ersatztv-ffmpeg:7.1.1 AS runtime-base` (third-party ffmpeg image, tag exists). Build stage `mcr.microsoft.com/dotnet/sdk:9.0-noble-amd64`, `dotnet publish -r linux-x64 --self-contained false`. Final `FROM runtime-base`, `WORKDIR /app`, `COPY --from=build /app`, `ENV FONTCONFIG_PATH=/etc/fonts`, `ENV ETV_CONFIG_FOLDER=/config`, `ENV ETV_TRANSCODE_FOLDER=/transcode`, `ENV ETV_DISABLE_VULKAN=1`, `ENTRYPOINT ["./ErsatzTV"]`. No EXPOSE, VOLUME, USER. |
| Port | 8409 is in the draft only; **not declared** in the Dockerfile. `UNVERIFIED`. |
| Env vars (real) | `ETV_CONFIG_FOLDER`, `ETV_TRANSCODE_FOLDER`, `ETV_DISABLE_VULKAN`, `FONTCONFIG_PATH` (from the Dockerfile) |
| Chart / data path | Draft claims `/root/.local/share/ersatztv`. Not in the Dockerfile. `UNVERIFIED`. |
| Docs | https://ersatztv.org/docs/ not fetched. `UNVERIFIED`. |
| Dependencies | ffmpeg from the third-party `jasongdove/ersatztv-ffmpeg` image (not a ContainerForge image). Hardware transcoding needs the NVENC or VAAPI build of ffmpeg. |

## 2. Target layout

- `apps/ersatztv/Dockerfile`
- `apps/ersatztv/docker-bake.hcl`
- `apps/ersatztv/settings.yaml`
- `apps/ersatztv/container-test.yaml`
- `apps/ersatztv/start.sh` (creates `/config` and the transcode folder on first start, then `exec ./ErsatzTV`)

No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. ErsatzTV ships self-contained linux-x64 and linux-arm64 tarballs. No .NET runtime base exists in ContainerForge, and the tarball does not need one installed. `ffmpeg` comes from apt (see section 4) or from a ContainerForge ffmpeg sibling if one is added later (none in `apps/` today).

Closest sibling: `apps/ubuntu` (base), `apps/webgrabplus` (dotnet on ubuntu, per the fenrus precedent). Verify the sibling before finalising.

## 4. Dockerfile

1. `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS final`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Architecture mapping: `case "${TARGETARCH}" in amd64) ETV_ARCH=x64 ;; arm64) ETV_ARCH=arm64 ;; esac`.
3. `apt-get install -y --no-install-recommends ffmpeg libva-drm2 ca-certificates` (`UNVERIFIED`: which ffmpeg build has NVENC or VAAPI; the apt build may lack NVENC). Pin apt versions and check against `VERSION` where applicable. Clean apt lists.
4. Download and extract: `curl -fL https://github.com/ErsatzTV/ErsatzTV/releases/download/v${VERSION}/ErsatzTV-v${VERSION}-linux-${ETV_ARCH}.tar.gz | tar xz -C /app` (create `/app` first; check whether the tarball has a top-level folder, UNVERIFIED). Verify the download (no checksum published, `UNVERIFIED`).
5. License: fetch `LICENSE` from the source repo tag `v${VERSION}` (or from the tarball if it ships one; UNVERIFIED) to `/usr/share/licenses/ersatztv/LICENSE`.
6. `ENV ETV_CONFIG_FOLDER=/config ETV_TRANSCODE_FOLDER=/tmp/transcode ETV_DISABLE_VULKAN=1 FONTCONFIG_PATH=/etc/fonts XDG_CACHE_HOME=/tmp/.cache HOME=/config`.
7. `VOLUME /config`, `EXPOSE 8409`.
8. Final: `COPY --chmod=0755 . /`, `USER apps`. The transcode folder defaults to `/tmp/transcode` (writable tmpfs); users may point `ETV_TRANSCODE_FOLDER` at a mounted volume.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "ersatztv"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ErsatzTV/ErsatzTV versioning=semver extractVersion=^v(?<version>.+)$
  default = "26.3.0"
}

variable "LICENSE" {
  default = "Zlib"
}

variable "SOURCE" {
  default = "https://github.com/ErsatzTV/ErsatzTV"
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

The tag is `v26.3.0` while `VERSION` is `26.3.0`; add `extractVersion=^v(?<version>.+)$` to the renovate comment. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ErsatzTV/ErsatzTV"
ports:
  - port: 8409
    protocol: tcp
    required: true
env:
  - name: ETV_CONFIG_FOLDER
    default: "/config"
    required: false
  - name: ETV_TRANSCODE_FOLDER
    default: "/tmp/transcode"
    required: false
  - name: ETV_DISABLE_VULKAN
    default: "1"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 8409 is unverified (not in the Dockerfile); keep it only after confirming it in the app's own config or docs, else drop the port entry.

## 7. start.sh

1. `set -eu`. `mkdir -p /config "${ETV_TRANSCODE_FOLDER}"` (the rootless user cannot create `/transcode` at the filesystem root).
2. Export `ETV_CONFIG_FOLDER=/config`, `ETV_TRANSCODE_FOLDER` (default `/tmp/transcode`), `HOME=/config`.
3. Bind the web server to `0.0.0.0:8409` (upstream default is `UNVERIFIED`; confirm in the app's config).
4. `cd /app && exec ./ErsatzTV`.

No writes to `/app`. Caches and temp in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '8409'
http:
- port: '8409'
  path: /
filePaths:
- /app/ErsatzTV
- /usr/share/licenses/ersatztv/LICENSE
```

The tcp and http probes both check `8409`. `filePaths` checks the binary and license. The GPU hardware path (NVENC or VAAPI) is not reached without a GPU, so it is not tested. Add a `filePaths` entry for the ffmpeg binary only if it is a required file. The database lives under `/config`, so the test starts without env vars.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/root/.local/share/ersatztv` (draft; database and state) | Under `/config` via `HOME=/config` or `ETV_CONFIG_FOLDER`. `UNVERIFIED` where the app writes its DB. |
| `/transcode` (transcode scratch) | Default `/tmp/transcode` (ephemeral); optional user-mounted volume via `ETV_TRANSCODE_FOLDER`. |
| Fontconfig cache | `/tmp` via `XDG_CACHE_HOME`. Run `fc-cache` at build time, not at runtime. |
| `/app` | Read-only at runtime. Nothing writes there. |

The draft's security expectations (chart runs as root, read-only rootfs false, not privileged) are **not** carried over. ContainerForge requires `USER apps` and read-only rootfs. GPU device access (NVENC or VAAPI) needs `/dev/dri` or the NVIDIA runtime. Note this for the chart, not the image.

## 10. Risks, caveats and open questions

- **Hard band:** .NET server, needs its custom ffmpeg (NVENC or VAAPI). Without a GPU device the CPU path is not what the tags are built for.
- **Third-party ffmpeg:** the nvidia image's ffmpeg is `jasongdove/ersatztv-ffmpeg:7.1.1`, a Docker Hub image outside ContainerForge. Reusing it as a `FROM` base is not an option (not a ContainerForge base). Build or install ffmpeg via apt, which may lack NVENC or VAAPI (`UNVERIFIED`).
- **Database and state path:** the draft says `/root/.local/share/ersatztv`; the upstream Dockerfile sets `/config` for config and `/transcode` for transcode (this image uses `/tmp/transcode`). Confirm the DB path in the app before finalising persistence.
- **Port 8409:** not declared in the Dockerfile (`UNVERIFIED`).
- **Checksums:** none published on the release (`UNVERIFIED`).
- **arm64:** the linux-arm64 tarball exists. Hardware transcode for arm64 is `UNVERIFIED`.
- **Docs not read:** https://ersatztv.org/docs/ not fetched.
- Blockers to confirm: GPU device access (needs `/dev/dri` or NVIDIA runtime), the ffmpeg build used, and the DB path.

## 11. Build and test steps

Run from `apps/ersatztv/`, one app at a time:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe run with a fresh config volume:
   ```sh
   docker run --rm -d --name ersatztv-probe --read-only --tmpfs /tmp \
     -v ersatztv-probe-config:/config ersatztv:26.3.0
   docker logs -f ersatztv-probe
   ```
   Expected readiness signal: the web server listening on `8409` (`UNVERIFIED` exact string; confirm from the first real start).
4. `forgetool containers test --image ersatztv:26.3.0 --config ./apps/ersatztv/container-test.yaml`.
5. Cleanup: `docker rm -f ersatztv-probe; docker volume rm ersatztv-probe-config`.

## 12. PR checklist

- Branch: `feat/add-ersatztv`
- Commit: `feat(ersatztv): add new container`
- PR title: `feat(ersatztv): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: GPU transcoding, arm64, and the full data path are not validated until built.
- If the image is not built, do not check "Built container locally".
