# convertx — implementation plan
> Source: ./draft.md · Target: apps/convertx/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.20.0 (latest release, published 2026-10-28; https://api.github.com/repos/C4illin/ConvertX/releases/latest). Matches draft. The release has no assets. |
| Renovate | `datasource=github-tags depName=C4illin/ConvertX versioning=semver` (proposed; not checked against renovate config) |
| License | AGPL-3.0 (https://api.github.com/repos/C4illin/ConvertX, `license.spdx_id`). `UNVERIFIED: whether LICENSE is AGPL-3.0-only or -or-later`. Set `LICENSE` in bake from the LICENSE file, not the GitHub SPDX alone. |
| Source URL | https://github.com/C4illin/ConvertX |
| Download | Source tarball `https://github.com/C4illin/ConvertX/archive/refs/tags/v0.20.0.tar.gz` (from draft, not fetched). Pin with its SHA-256, computed and committed. |
| Checksum source | None published on the release. `UNVERIFIED`. Pin the commit `42224e3f1f1ad0eb6e6d2bac661a5b3f2b2a2976` (tag v0.20.0 resolves to this commit, confirmed via the git ref API) and verify the tarball against a digest recorded at build time. |
| Per-arch binary | None published. Build from source on both amd64 and arm64. The VTracer helper is a separate binary (see below). |
| copy-from | `ghcr.io/c4illin/convertx:v0.20.0` (draft). `UNVERIFIED: not inspected; prefer a source build.` |
| Upstream Dockerfile reviewed | Commit 42224e3f1f1ad0eb6e6d2bac661a5b3f2b2a2976, https://raw.githubusercontent.com/C4illin/ConvertX/42224e3f1f1ad0eb6e6d2bac661a5b3f2b2a2976/Dockerfile (fetched via summary). Stages: `oven/bun:1.4.4-slim` (base: `bun install --frozen-lockfile`, `bun run build:bin`), `debian:testing-slim` (release, also final target). ENTRYPOINT `/entrypoint.sh`, CMD `/app/convertx`, `EXPOSE 3000/tcp`, no USER (runs as root), no VOLUME, `RUN mkdir data` (creates `/app/data`). |
| Apt packages (upstream) | assimp-utils, ca-certificates, calibre, curl, dasel, dcraw, djvulibre-bin, dvisvgm, ffmpeg, ghostscript, gosu, graphicsmagick, imagemagick-7.q16, inkscape, latexmk, libheif-examples, libjxl-tools, libreoffice, libva2, libvips-tools, libemail-address-perl, libemail-outlook-message-perl, lmodern, mupdf-tools, pandoc, poppler-utils, potrace, python3-numpy, python3-tinycss2, resvg, texlive, texlive-fonts-recommended, texlive-latex-extra, texlive-latex-recommended, texlive-xetex, python3, python3-pip, pipx. `UNVERIFIED: which of these exist in the ubuntu 26.04 archive`. |
| VTracer helper | VTracer 0.6.4, musl builds only: `vtracer-aarch64-unknown-linux-musl.tar.gz` and `vtracer-x86_64-unknown-linux-musl.tar.gz` (https://api.github.com/repos/visioncortex/vtracer/releases/tags/0.6.4). `UNVERIFIED: runs on glibc ubuntu`. |
| Other env (upstream) | `PIPX_HOME=/opt/pipx`, `PIPX_BIN_DIR=/usr/local/bin`, `QTWEBENGINE_CHROMIUM_FLAGS=--no-sandbox`, `NODE_ENV=production` |
| Converter helper | `markitdown[all]` via pipx, with a Brotli upgrade (upstream comment calls it temporary). |
| Port | 3000/tcp (confirmed `EXPOSE 3000/tcp`) |

## 2. Target layout

- `apps/convertx/Dockerfile`
- `apps/convertx/docker-bake.hcl`
- `apps/convertx/settings.yaml`
- `apps/convertx/container-test.yaml`
- `apps/convertx/start.sh` (replaces upstream `/entrypoint.sh`, which is not fetched)
- `defaults/` only if a default config must be seeded

`root/` is not used. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Upstream uses debian:testing-slim, so ubuntu is a choice, not a copy. The draft calls ubuntu a guess; the reason for ubuntu is that every apt package in the list must be present on it (section 1).
- Build stage: bun. `oven/bun:1.4.4-slim` (upstream) pinned with a renovate annotation, or a bun binary installed on the ubuntu build stage. `UNVERIFIED: whether bun 1.4.4 runs on ubuntu`.
- Closest sibling: `apps/python` (apt-based ubuntu with a runtime) and `apps/changedetection` (node or python-node with apt packages). The draft suggests `python-node`; that base has python and node but not the converter set, so `ubuntu` is the better fit.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG BUN_VERSION=1.4.4`.
2. Build stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build`: install bun (pinned, arch-aware), then `curl -fL https://github.com/C4illin/ConvertX/archive/refs/tags/v${VERSION}.tar.gz | tar xz`, verify with a committed SHA-256, `bun install --frozen-lockfile`, `bun run build:bin` (or keep the source and run `bun run` from `/app`, `UNVERIFIED: whether the compiled binary is needed`). Set `BUN_INSTALL_CACHE_DIR=/tmp/bun-cache`.
3. Install the converter apt list in the final stage. Pin each package version only where it matters. The brief says to pin apt packages and check against `VERSION`; here the converters are not versioned with convertx, so record the chosen ubuntu archive version in the comment, `UNVERIFIED`.
4. VTracer: download the arch-matched musl tarball from the GitHub release (`${TARGETARCH}` → `aarch64` or `x86_64`), verify with a SHA-256 recorded in the Dockerfile, `tar -xz -C /usr/local/bin vtracer`, `chmod 0755`. Ship its license.
5. `markitdown[all]` via pipx: install `pipx` and `python3-pip`, set `PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin`. Or pip into a venv under `/opt`, `UNVERIFIED: which the ubuntu 26.04 archive supports`.
6. Final stage: `COPY --from=build /app /app/convertx`, `COPY --from=build /app/public`, license files into `/usr/share/licenses/convertx/`. `mkdir -p /app/data` replaced by the remap in section 9.
7. Environment: `ENV NODE_ENV=production HOME=/config`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app/convertx
```

`start.sh` is the entrypoint. It creates `/config/data` and then `exec bun run` (or the compiled binary, from step 2) with `DATA_DIR`, `UNVERIFIED: the env var upstream reads to point at its data directory; the upstream data path /app/data is hard-coded in the Dockerfile`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "convertx" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=C4illin/ConvertX versioning=semver
  default = "0.20.0"
}
variable "BUN_VERSION" {
  // renovate: datasource=docker depName=docker.io/oven/bun versioning=semver
  default = "1.4.4"
}
variable "VTRACER_VERSION" {
  // renovate: datasource=github-releases depName=visioncortex/vtracer versioning=semver
  default = "0.6.4"
}
variable "LICENSE" { default = "AGPL-3.0" }
variable "SOURCE" { default = "https://github.com/C4illin/ConvertX" }
```

Pass the versions as `args` in the `image` target. Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print` (`UNVERIFIED: not run`).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/C4illin/ConvertX"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only add env vars that `start.sh` or the app reads. The data path env var is added only after it is confirmed. No dependencies.

## 7. start.sh

- `mkdir -p /config/data /tmp/convertx` (`UNVERIFIED: whether the app needs /tmp for temp conversions`).
- Link or point the app's data dir to `/config/data` (section 9). No writes to `/app`.
- Export any env the app needs (the upstream data path var, `UNVERIFIED`).
- `exec bun run /app/convertx/...` or `exec /app/convertx/convertx` (the binary from the build step, `UNVERIFIED`). Use `exec` so signals reach the process.

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
- /app/convertx
- /usr/local/bin/vtracer
- /usr/bin/ffmpeg
- /usr/bin/pandoc
- /usr/bin/magick
```

The `filePaths` entries for `magick` and other converters are `UNVERIFIED` until the apt package names and binary paths are confirmed on ubuntu. `timeoutSeconds: 180` is a guess to be matched to a sibling with a heavy startup (`UNVERIFIED`). No DB dependency, so the narrow exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (`mkdir data` in upstream Dockerfile, chart PVC mount in draft) | `/config/data`, via a symlink created in `start.sh` (not in the image, since `/app` is read-only) |
| temp conversions (converter tools write scratch files) | `/tmp` (ephemeral, under `--read-only --tmpfs /tmp`) |
| `/home/convertx` (upstream user home, UID 1000) | Not used. Our `apps` user (UID 568) uses `HOME=/config` |
| `PIPX_HOME=/opt/pipx` | Written at build time only, read-only at runtime |

Upstream runs as root (no USER). ContainerForge runs as `apps` (UID 568). Converter tools that need root must be checked (`UNVERIFIED`). Chromium `--no-sandbox` is set upstream for calibre; keep it only if calibre runs headless and needs it (`UNVERIFIED`). Draft security expectations: non-root yes, read-only rootfs yes, privileged no, extra persistence `/app/data` (remapped to `/config/data`).

## 10. Risks, caveats and open questions

- Image size: calibre, libreoffice and texlive make the image very large (confirmed from the upstream apt list). Consider whether all converters are needed in one image (`UNVERIFIED`).
- Upstream base is debian:testing-slim, not ubuntu. Packages available on debian testing may not exist on ubuntu 26.04 (`UNVERIFIED`). Blocker if a required converter is missing.
- VTracer is musl-only. If it does not run on glibc ubuntu, the vtracer feature is a blocker or must be dropped with a note (`UNVERIFIED`).
- Upstream runs as root. Some converters may need root (`UNVERIFIED`).
- Draft caveat (inferred): slow or memory-hungry conversions. Not measured.
- arm64: the VTracer musl asset exists for aarch64. Other converters' arm64 availability is `UNVERIFIED`.
- AGPL-3.0 licence: the `LICENSE` value in bake must match the LICENSE file (see section 1).

## 11. Build and test steps

```sh
cd apps/convertx
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name convertx-probe --read-only --tmpfs /tmp \
  -v convertx-probe-config:/config ghcr.io/trueforge-org/convertx:0.20.0
docker logs -f convertx-probe
forgetool containers test --image convertx:0.20.0 --config ./apps/convertx/container-test.yaml
docker rm -f convertx-probe; docker volume rm convertx-probe-config
```

Use a fresh named volume for the empty-`/config` run. Expected readiness signal: `UNVERIFIED` (the upstream startup log line, to be read from a real run). The build needs internet access for bun and the VTracer download.

## 12. PR checklist

- Branch: `feat/add-convertx`. Commit: `feat(convertx): add new container`.
- PR title matches the commit. Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (`license/cla` shows status). Only the user can sign it.
- Tell the user what was not tested: every `UNVERIFIED` item above, plus arm64 if not built. Do not check "Built container locally" unless the build and run were done.
