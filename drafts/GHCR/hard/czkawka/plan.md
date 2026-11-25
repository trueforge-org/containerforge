# czkawka — implementation plan
> Source: ./draft.md · Target: apps/czkawka/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **12.0.2** (released 2026-09-09, not prerelease). The draft's chart image `ghcr.io/jlesage/czkawka:v26.09.2` builds czkawka 12.0.2 (`CZKAWKA_VERSION=12.0.2` in the upstream Dockerfile). Source: `gh api repos/qarmin/czkawka/releases/latest` and https://raw.githubusercontent.com/jlesage/docker-czkawka/v26.09.2/Dockerfile |
| Renovate | `datasource=github-releases depName=qarmin/czkawka versioning=semver` (tag `12.0.2`, no `v`) |
| License | **MIT** (`czkawka_cli/Cargo.toml` `license = "MIT"` at tag 12.0.2). Repo also has `LICENSE_CC_BY_4_ICONS` (icons) and `LICENSE_MIT_EVERYTHING_OUTSIDE_ANY_CARGO_APP_LIBRARY` (the MIT text file name). Source: `gh api repos/qarmin/czkawka/contents?ref=12.0.2` |
| Source URL | https://github.com/qarmin/czkawka |
| Per-arch download (CLI, the one we will use) | amd64: https://github.com/qarmin/czkawka/releases/download/12.0.2/linux_czkawka_cli_heif_raw_avif_x86_64 (sha256 `b62cf139ba6e0331e4a279d75d0caf5bfa81f16c645fdf0008dc7a830573e05f`) · arm64: https://github.com/qarmin/czkawka/releases/download/12.0.2/linux_czkawka_cli_heif_raw_avif_arm64 (sha256 `6ca6ec65029c3d5ed87ade0690508fcf9566f0bdbb1b480a773499a3a5041022`). Plain CLI builds also exist: `linux_czkawka_cli_x86_64` (`61e7e8ac…`) and `linux_czkawka_cli_arm64` (`3a65408c…`). |
| Checksum source | GitHub release asset `digest` (sha256) from the GitHub API. Upstream publishes no checksum file. The digest is computed by GitHub, not signed, so verify it again with `sha256sum` before pinning. |
| Draft correction | The draft says the arm64 binary may lack HEIF/RAW/AVIF. The release has `linux_czkawka_cli_heif_raw_avif_arm64`, so both arches have the HEIF build. |
| GUI status | **GTK GUI is end-of-life**: the release notes say 12.0 is the last Czkawka GTK release, and the successor is Krokiet (Slint). Source: release body of 12.0.2. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jlesage/docker-czkawka/v26.09.2/Dockerfile: alpine:3.20 build stage compiles czkawka and libheif 1.23.4 from source (cross-compile with tonistiigi/xx), final `jlesage/baseimage-gui:alpine-3.20-v4.14.0`, apk GTK4, ffmpeg, pcmanfm, `VOLUME ["/storage"]`, `set-cont-env DISABLE_GLX 1`. No `EXPOSE`. |
| Ports | The CLI opens no port. The chart's GUI ports (5800 noVNC, 5900 VNC, from the draft and the jlesage base) are **UNVERIFIED** on the page read. |
| Data and config paths | `/storage` is the scan target (VOLUME in upstream). `/trash` is an extra mount in the draft chart. Where the CLI writes its cache or config is **UNVERIFIED**. |
| Dependencies | None. |

## 2. Target layout

- `apps/czkawka/Dockerfile`
- `apps/czkawka/docker-bake.hcl`
- `apps/czkawka/settings.yaml`
- `apps/czkawka/container-test.yaml`
- `apps/czkawka/start.sh`
- `DOWNSTREAM_CHANGES.md`: **not applicable**, not a `FROM` base.
- No `defaults/`, `etc/` or `health/` unless section 10 requires them. No `root/`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Reason: the draft's own base choice. czkawka is a Rust binary, so no language runtime is needed. Closest sibling: `apps/adguardhome-sync` (prebuilt per-arch binary downloaded and extracted on ubuntu, `$TARGETARCH` mapping).

Do not use the upstream `jlesage/baseimage-gui` base: it is Alpine (musl) with a VNC stack, and the CLI binaries are glibc or static builds that do not match it. The draft's "musl-only" concern is answered by the release assets: the glibc-style names are `linux_czkawka_cli_heif_raw_avif_*`; the musl build is a separate asset (`linux_czkawka_cli_musl`) that we do not use. **Confirm with `ldd` after download**: the HEIF build may need `libheif` shared libraries that ubuntu must provide (UNVERIFIED).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the arch: `case "$TARGETARCH" in amd64) asset=linux_czkawka_cli_heif_raw_avif_x86_64; sha=b62cf139ba6e0331e4a279d75d0caf5bfa81f16c645fdf0008dc7a830573e05f ;; arm64) asset=linux_czkawka_cli_heif_raw_avif_arm64; sha=6ca6ec65029c3d5ed87ade0690508fcf9566f0bdbb1b480a773499a3a5041022 ;; *) exit 1 ;; esac`.
3. `curl -fL -o /tmp/czkawka_cli "https://github.com/qarmin/czkawka/releases/download/${VERSION}/${asset}"`, then `echo "${sha}  /tmp/czkawka_cli" | sha256sum -c -`. Pin the sha256 per arch with `ARG`s so Renovate updates stay visible.
4. `install -m 0755 /tmp/czkawka_cli /app/czkawka/czkawka_cli` (directory `/app/czkawka` created by `mkdir -p`).
5. Symlink `/usr/bin/czkawka_cli -> /app/czkawka/czkawka_cli` so `PATH` finds it.
6. Licence: `curl` the MIT licence file from the 12.0.2 tag (name `LICENSE_MIT_EVERYTHING_OUTSIDE_ANY_CARGO_APP_LIBRARY`, **content UNVERIFIED** until read), save to `/usr/share/licenses/czkawka/LICENSE`. Ship `LICENSE_CC_BY_4_ICONS` as well if the binary bundles icons (UNVERIFIED).
7. If `ldd` shows missing shared libraries, add only the apt packages that provide them, and pin the versions against the base (apt is unpinned in the base; check the version used at build).
8. Cleanup: `rm -rf /tmp/* /var/lib/apt/lists/*`. `chown -R apps:apps /app/czkawka && chmod -R 755 /app/czkawka`.
9. Tail:

```dockerfile
ENV HOME=/config XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

VOLUME /config /storage
WORKDIR /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "czkawka"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=qarmin/czkawka versioning=semver
  default = "12.0.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/qarmin/czkawka"
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `docker buildx bake --print` from `apps/czkawka/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/qarmin/czkawka"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
```

- `ports: []`: the CLI opens no port. This only holds if section 10's decision is the CLI-only image. If a GUI is kept, list the port its base exposes (UNVERIFIED).
- No app env vars are listed: none were confirmed in the release or the upstream Dockerfile. Do not invent them.
- `dependencies`: none.

## 7. start.sh

A CLI tool does not run as a server, so the start script must choose a mode. Proposed behaviour (decision in section 10):

- `mkdir -p /config` only, and create nothing in `/app`.
- Run `exec czkawka_cli "$@"` with the arguments taken from the container command, so `docker run ... czkawka:<ver> dup -d /storage` works. Use `exec` so signals reach the process.
- Do not write to `/storage`, which holds the user's files, unless a scan asks for it.
- Keep caches in `/tmp` (`XDG_CACHE_HOME=/tmp/.cache`, set in the Dockerfile).
- There is no default argument. A bare run prints help and exits, so the container test and the health expectations must account for that (section 8).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60
mainRunner:
  enabled: false
runners:
- entrypoint: test -x /app/czkawka/czkawka_cli
- entrypoint: /app/czkawka/czkawka_cli --help
filePaths:
- /app/czkawka/czkawka_cli
- /usr/share/licenses/czkawka/LICENSE
```

- A CLI with no port cannot get the `tcp` or `http` probes that the protocol expects. This is a real gap: state it in the PR and do not invent a port check.
- If the chosen design is a server (for example Krokiet with a display, or a wrapper that listens), add the port probe and the matching `settings.yaml` port.
- `--help` exits 0. It proves the binary runs on ubuntu, which `ldd` in section 4 also checks.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/storage` (scan target, VOLUME in upstream) | Runtime bind mount by the user. Read-only root is fine. |
| `/trash` (draft chart extra mount) | Not in the upstream image. Ask the user (section 10). |
| Cache and config under HOME | `HOME=/config`, `XDG_CACHE_HOME=/tmp/.cache`. Config location **UNVERIFIED**. |
| GUI: VNC, GTK, `DISABLE_GLX` | Dropped in the CLI-only design. |

Draft security expectations: the chart forces root, `readOnlyRootFilesystem: false`, `NET_BIND_SERVICE` and `KILL` capabilities. The CLI-only plan runs as `apps` on a read-only root with no capabilities. `NET_BIND_SERVICE` is only needed for a port below 1024, so it is not needed. `KILL` is not needed by a CLI.

## 10. Risks, caveats and open questions

- **Decision needed (blocker)**: a czkawka CLI is a one-shot scanner, not a long-running server. The ContainerForge rule is that the process stays running and has a readiness signal. A CLI-only image therefore fails the protocol's "process still running" check unless the container is given a command, and it has no port to probe. The user must choose one of:
  1. CLI-only image with a command-driven entrypoint (no port, probes limited to `--help` and file checks). Recommended as the smallest correct step.
  2. A GUI image (Krokiet with a display server and VNC on a non-root user). This needs a new base with a VNC stack and display, which is a much larger job and is not the draft's intent. The GTK GUI must not be used: it is end-of-life.
- **HEIF and arm64**: the draft's caveat is wrong (section 1). Both arches have the HEIF build.
- **Shared library check**: the HEIF build may need libheif on ubuntu. Run `ldd` after download (UNVERIFIED).
- **Large libraries**: duplicate scans read every file in `/storage` (draft caveat). Expect slow scans and disk load.
- **Checksums**: the sha256 values are GitHub digests, not upstream-signed.

## 11. Build and test steps

From `apps/czkawka/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. CLI run check (if CLI-only): `docker run --rm --read-only --tmpfs /tmp -v czkawka-probe-config:/config czkawka:12.0.2 --help`. Expected: help text, exit 0. For a long-running design, use the protocol's `docker run -d` and `docker logs -f` with the readiness line.
4. Clean up: `docker rm -f` and `docker volume rm czkawka-probe-config`.
5. `forgetool containers test --image czkawka:12.0.2 --config ./apps/czkawka/container-test.yaml`. If forgetool is unavailable, check the same assertions by hand.
6. Build arm64 only if amd64 fails in an arm64-specific way. Run arm64 on an arm64 host if one is available; otherwise say it is untested.

## 12. PR checklist

- Branch: `feat/add-czkawka`
- Commit: `feat(czkawka): add new container`
- PR title: `feat(czkawka): add new container`
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Do not tick "Built container locally" unless the build and run in section 11 were done.
- Say what is not tested: the GUI (not built), arm64 (unless run on arm64 hardware), and any shared-library gap found by `ldd`.
- Blocker: the CLI-vs-GUI decision (section 10) must be made before the PR is opened.
