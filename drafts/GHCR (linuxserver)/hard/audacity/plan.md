# audacity — implementation plan
> Source: ./draft.md · Target: apps/audacity/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `4.0.2` (GitHub tag `Audacity-4.0.2`, published 2026-11-02). The draft's chart pins linuxserver `version-3.0.2`, which is stale. Source: https://api.github.com/repos/audacity/audacity/releases/latest |
| Renovate | `// renovate: datasource=github-releases depName=audacity/audacity versioning=loose`. `loose` because the tag is `Audacity-4.0.2`, not plain semver. |
| License | GitHub reports `NOASSERTION` (https://api.github.com/repos/audacity/audacity). UNVERIFIED: SPDX. Read the `LICENSE` file in the source tree before setting `LICENSE` in `docker-bake.hcl`. |
| Source URL | https://github.com/audacity/audacity |
| Download amd64 | https://github.com/audacity/audacity/releases/download/Audacity-4.0.2/audacity-linux-4.0.2-x86_64.AppImage (73726456 bytes) |
| Download arm64 | https://github.com/audacity/audacity/releases/download/Audacity-4.0.2/audacity-linux-4.0.2-aarch64.AppImage (70670856 bytes) |
| Checksum source | https://github.com/audacity/audacity/releases/download/Audacity-4.0.2/CHECKSUMS.txt. sha256 x86_64 `a5f8787aa13cdb500a60fc013403b986776876b960cca962bc6e7fff066172f3`; aarch64 `88b1e16dd40a5b7d36bec5789b03f66bda34a7b964e19f338951bf6034d9db9c` |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-audacity/master/Dockerfile. `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`; downloads the x86_64 AppImage only, extracts it to `/opt/audacity`; apt: python3-xdg, libatk1.0, libatk-bridge2.0, libnss3, libportaudio2; `EXPOSE 3001`; `VOLUME /config`; no `USER`, no `ENTRYPOINT`/`CMD`; `ENV TITLE=Audacity NO_GAMEPAD=true PIXELFLUX_WAYLAND=true`. |
| Port | 3001 only, from upstream `EXPOSE`. It serves the Selkies web desktop. The draft's 3000 is UNVERIFIED. |
| Env vars the app reads | None confirmed for Audacity itself. The `TITLE`, `NO_GAMEPAD` and `PIXELFLUX_WAYLAND` values belong to the Selkies base, not to Audacity. |
| Data / config paths | `/config` (upstream `VOLUME`). Audacity's own config path is UNVERIFIED. |
| Dependencies | None. |

## 2. Target layout

- `apps/audacity/Dockerfile`
- `apps/audacity/docker-bake.hcl`
- `apps/audacity/settings.yaml`
- `apps/audacity/container-test.yaml`
- `apps/audacity/start.sh`

No `defaults/` or `etc/` unless a config seed is shown to be needed (UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md`, because nothing uses this image as `FROM`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. It is a generic userland, and the AppImage is self-contained. Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Map `amd64` to `x86_64` and `arm64` to `aarch64` for the asset name.
2. `ARG SHA256_X86_64=a5f8787a…172f3` and `ARG SHA256_AARCH64=88b1e16d…db9c` (full values in section 1). Select per arch and verify with `sha256sum -c` before use.
3. `USER root`. Download to `/tmp/audacity.AppImage`:
   `curl -fsSL -o /tmp/audacity.AppImage "https://github.com/audacity/audacity/releases/download/Audacity-${VERSION}/audacity-linux-${VERSION}-${ARCH}.AppImage"`
4. Extract at build time so the runtime needs no FUSE: `chmod +x` then `/tmp/audacity.AppImage --appimage-extract` in `/tmp`, then `mv /tmp/squashfs-root /app/audacity`. UNVERIFIED: that extraction works on 26.04 without FUSE.
5. Runtime libraries: the upstream installs `libnss3`, `libatk1.0`, `libatk-bridge2.0` and `libportaudio2` (and `python3-xdg`). Confirm with `ldd` on the extracted binary, install only what is missing, and pin any apt package to the 26.04 version. Versions are UNVERIFIED.
6. License file from the source tree to `/usr/share/licenses/audacity/` (path UNVERIFIED until the tarball is read).
7. `ENV HOME=/config XDG_CACHE_HOME=/tmp`. Clean `/tmp/audacity.AppImage` and apt lists.
8. Final stage: `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`. `EXPOSE` depends on the display decision in section 10.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "audacity" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=audacity/audacity versioning=loose
  default = "4.0.2"
}
variable "LICENSE" { default = "NOASSERTION" }   // placeholder: replace with the SPDX id once confirmed
variable "SOURCE" { default = "https://github.com/audacity/audacity" }
```

Keep the four standard targets and the `default` group from `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/audacity/audacity"
ports: []        # pending section 10: no port is confirmed without a display server
env: []          # no env var is confirmed for Audacity itself
volumes:
  - path: /config
    required: true
```

Dependencies: none.

## 7. start.sh

Cannot be finalized until the display question in section 10 is answered. The shape is:

```bash
#!/usr/bin/env bash
mkdir -p /config
cd /app/audacity
exec ./AppRun
```

`AppRun` is the usual AppImage entry point, UNVERIFIED for 4.0.2. The script never writes to `/app`. It needs a display, which the base does not provide.

## 8. container-test.yaml

Cannot be finalized: no port is confirmed. The file will hold `filePaths` only, until a port exists:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
filePaths:
- /app/audacity/AppRun        # UNVERIFIED path
- /usr/share/licenses/audacity/
```

Add `tcp` and `http` probes for each `settings.yaml` port once one is decided.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Application files under `/opt/audacity` | Extracted at build time into `/app/audacity`. Nothing writes there at runtime. |
| Audacity config and projects | `HOME=/config`, so they land in `/config`. The exact subdirectory is UNVERIFIED. |
| Caches | `XDG_CACHE_HOME=/tmp`. |

Reconciling the draft's security expectations: the chart runs as root with `readOnlyRootFilesystem: false` and capability additions. The target runs as `USER apps` on a read-only rootfs. Extraction at build time means FUSE is not needed at runtime, so the chart's FUSE assumption does not carry over. Not privileged.

## 10. Risks, caveats and open questions

- **Blocker: no display server.** Audacity is a GUI application, and the ubuntu base has no X or Wayland. Upstream supplies one through the Selkies desktop base, which is not a pattern in this repo (no Selkies base app exists; `apps/kasmvnc` and `apps/rdesktop` are existing desktop-over-browser images that could be studied as precedents, UNVERIFIED whether either fits as a base). Decision needed before any build: either approve a desktop-style base (not an existing exemplar, so it should not be invented here), or defer this app. This plan does not choose Selkies.
- Version jump 3.0.2 to 4.0.2 may change behaviour (draft caveat, unverified).
- arm64: an aarch64 AppImage exists. Upstream linuxserver only fetches x86_64, so arm64 is not proven in their image.
- License is `NOASSERTION`, so the SPDX id is UNVERIFIED.
- The draft's port 3000 is UNVERIFIED. Only 3001 is confirmed, and only as an upstream `EXPOSE`.

## 11. Build and test steps

```sh
cd apps/audacity
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name audacity-probe --read-only --tmpfs /tmp -v audacity-probe-config:/config audacity:4.0.2
docker logs -f audacity-probe
forgetool containers test --image audacity:4.0.2 --config ./apps/audacity/container-test.yaml
docker rm -f audacity-probe; docker volume rm audacity-probe-config
```

Readiness signal: UNVERIFIED until the display question is decided. Blocked before step 2 is meaningful.

## 12. PR checklist

- Branch `feat/add-audacity`, commit `feat(audacity): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State that nothing was built or run, if that remains true.
