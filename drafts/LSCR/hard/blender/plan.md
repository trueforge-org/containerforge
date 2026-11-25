# blender — implementation plan
> Source: ./draft.md · Target: apps/blender/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `5.0.1` (Blender tarball). Source: https://download.blender.org/release/Blender5.0/blender-5.0.1-linux-x64.tar.xz (HTTP 200, 374154072 bytes, last-modified 2025-12-16). Draft tag `latest` on the chart is not pinned; this plan pins `5.0.1`. |
| Renovate | `datasource=github-tags depName=blender/blender versioning=semver-coerced` (proposed, UNVERIFIED against a renovate run). |
| License | UNVERIFIED: `LICENSE` raw path on `blender/blender` main returned 404. Blender is GPL-family. Confirm the SPDX from the repo before writing `LICENSE`. |
| Source | https://github.com/blender/blender |
| Per-arch download | amd64: https://download.blender.org/release/Blender5.0/blender-5.0.1-linux-x64.tar.xz (confirmed). arm64: no official tarball (`blender-5.0.1-linux-arm64.tar.xz` returned 404). arm64 uses the Ubuntu package `blender 5.0.1+dfsg-1ubuntu1` (arm64 `.deb` listed at https://packages.ubuntu.com/resolute/arm64/blender/download). |
| Checksum source | https://download.blender.org/release/Blender5.0/blender-5.0.1.sha256 contains `8019580ee1b7262e505f4196a00237ccf743c88d205b38d34201510676e60b09  blender-5.0.1-linux-x64.tar.xz`. The per-file `.sha256` URL returned 404, so use the combined file. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-blender/16e1a2aec1d331f2a4462eb52538b99d6d1c2932/Dockerfile: `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`; ENV `TITLE=Blender NO_GAMEPAD=true PIXELFLUX_WAYLAND=true`; installs `ocl-icd-libopencl1`, `xz-utils`; symlinks `libOpenCL.so.1`; downloads the tarball from `mirror.clarkson.edu` (fallback `mirrors.iu13.net`) to `/blender`; `/usr/bin/blender` symlink; `EXPOSE 3001`; `VOLUME /config`; `COPY /root /`. |
| Selkies base | UNVERIFIED: the `baseimage-selkies` Dockerfile was not fetched, so its ports (3000 and 3001 in the draft), its s6 init and its user model are not confirmed. |
| Ports | `3001/tcp` confirmed (linuxserver `EXPOSE`). `3000` (draft) is UNVERIFIED. |
| Env vars | `TITLE`, `NO_GAMEPAD`, `PIXELFLUX_WAYLAND` (upstream Dockerfile). The rest is UNVERIFIED. |
| Data write paths | `/config` (VOLUME). Others UNVERIFIED. |
| Dependencies | None. |

## 2. Target layout

- `apps/blender/Dockerfile`
- `apps/blender/docker-bake.hcl`
- `apps/blender/settings.yaml`
- `apps/blender/container-test.yaml`
- `apps/blender/start.sh`
- `apps/blender/root/` is not used (never touched by agents). Desktop launch files go in `etc/` or `scripts/` only if the desktop stack needs them.

No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Chosen: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Reason: Blender only needs the Ubuntu userland. The linuxserver selkies base would be a root s6 image that conflicts with `USER apps` and the read-only rootfs, so it is not reused.

Closest siblings: `apps/xvfb` (virtual X display on ubuntu:26.04, `USER apps`) and `apps/kasmvnc` (desktop over web on python-node/ubuntu, `EXPOSE 3000 3001`). Reuse their desktop approach, not linuxserver's.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. amd64 branch: download the tarball and verify with the combined sha256 file, then extract to `/app/blender`.
   ```dockerfile
   RUN set -eux; \
     curl -fL -o /tmp/blender.tar.xz \
       "https://download.blender.org/release/Blender${VERSION%.*}/blender-${VERSION}-linux-x64.tar.xz"; \
     echo "8019580ee1b7262e505f4196a00237ccf743c88d205b38d34201510676e60b09  /tmp/blender.tar.xz" | sha256sum -c -; \
     mkdir -p /app/blender && tar xf /tmp/blender.tar.xz -C /app/blender --strip-components=1; \
     rm -f /tmp/blender.tar.xz
   ```
   The checksum is for `5.0.1` only, so the `VERSION` must stay `5.0.1` or the checksum must be looked up again. Use a `case` on `TARGETARCH` to pick the path.
3. arm64 branch: `apt-get install -y --no-install-recommends blender` (Ubuntu 26.04 package `5.0.1+dfsg-1ubuntu1`). Pin the package version to match `VERSION` (`blender=5.0.1+dfsg-1ubuntu1`), per the Dockerfile rule. Symlink `/usr/bin/blender` to `/app/blender/blender` on amd64 only.
4. Packages not in the base: `libxkbcommon0`, `libxi6`, `libsm6`, `libegl1`, `ocl-icd-libopencl1` (inferred from draft; check each against the base before installing).
5. Desktop: the upstream selkies session is NOT reused. Use `xvfb` (sibling) and a web viewer (`kasmvnc` sibling pattern) as the desktop. Which exact package set is needed is UNVERIFIED.
6. `ENV HOME=/config XDG_CACHE_HOME=/tmp TITLE=Blender`, and `chown -R apps:apps /app && chmod -R 755 /app`.
7. License: copy the Blender license file from the tarball to `/usr/share/licenses/blender/` (path inside the tarball is UNVERIFIED). Ship the third-party notices too.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3001` (and 3000 only if confirmed), `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "blender"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=blender/blender versioning=semver-coerced
  default = "5.0.1"
}

variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/blender/blender"
}
```

`LICENSE` is UNVERIFIED (see section 1); set it from the repo before merging. The default group and the four standard targets follow `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/blender/blender"
ports:
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: TITLE
    default: "Blender"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Ports: add `3000` only when the chosen desktop stack confirms it. `TITLE` and `TZ` only; add others after the start script reads them.

## 7. start.sh

- `set -eu`; `mkdir -p /config/blender` (user files, seeded only when missing).
- Export `HOME=/config`, `XDG_CACHE_HOME=/tmp`.
- Start the virtual display (Xvfb) on `:99` in the background, then the web viewer on port 3001 (TLS per the kasmvnc sibling, UNVERIFIED).
- Start Blender with `exec` so signals reach it: `exec /app/blender/blender` on amd64, `exec blender` on arm64. Launch order and whether Blender runs as the main process or as a child of the viewer are UNVERIFIED and must be settled with the desktop choice.
- Bind the viewer on `0.0.0.0`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3001'
filePaths:
- /app/blender/blender
- /usr/share/licenses/blender
```

Notes: the probe for `3001` must match the settings and the desktop stack. The http probe is not added until the viewer's response is known (UNVERIFIED). `timeoutSeconds` is larger than the normal default because Blender is large (inferred from size; check the family value). The arm64 path needs the `filePaths` entry changed to `/usr/bin/blender`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| linuxserver `/config` (VOLUME) | `/config` (kept) |
| `/blender` (tarball extract) | `/app/blender` (build time only) |
| `/tmp/*` cleanup | kept as `/tmp` (ephemeral) |
| Blender cache and `XDG_CACHE_HOME` | `/tmp` |
| Selkies s6 init (root) | not reused; replaced by Xvfb and a viewer launched by `start.sh` as `apps` |

Draft expectations reconciled: the chart runs as UID 0 with no read-only rootfs; this image runs as `apps` and works on `--read-only --tmpfs /tmp`, which is a change from the chart. GPU devices are not set in the chart, so CPU rendering is the only path (inferred). Privileged is not required by the draft, but Xvfb may need `/tmp/.X11-unix` (in tmpfs; fine).

## 10. Risks, caveats and open questions

- Blocker: the desktop stack. The draft's linuxserver selkies base is root-based and not reused, so the desktop must be rebuilt on Xvfb and a viewer. That is the bulk of the work and is UNVERIFIED.
- The arm64 Blender version is the Ubuntu package, which is 5.0.1 (confirmed) and not an official build.
- Tarball mirrors: the linuxserver build used third-party mirrors. The plan uses `download.blender.org` directly (confirmed 200).
- GPU: no devices are passed, so rendering is CPU-only and slow (inferred).
- Large image and slow first start (inferred).
- `LICENSE` value is UNVERIFIED.
- Ports 3000 and the selkies base are UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/blender
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name blender-probe --read-only --tmpfs /tmp \
  -v blender-probe-config:/config blender:5.0.1
docker logs -f blender-probe
forgetool containers test --image blender:5.0.1 --config ./apps/blender/container-test.yaml
docker rm -f blender-probe
docker volume rm blender-probe-config
```

Expected readiness signal: the viewer logs that it listens on port 3001 (exact text UNVERIFIED) and the Blender process stays alive. An arm64 build is optional and only needed if the failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-blender`, commit `feat(blender): add new container`, PR title the same, target `main`.
- PR template filled, keeping its sections and checkboxes; only applicable boxes checked.
- Notes section: `🤖 This PR is AI generated.`
- CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign. The `license/cla` check shows status.
- Say what is untested: the desktop stack, the viewer port, GPU, arm64 build, and the `LICENSE` value until confirmed.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
