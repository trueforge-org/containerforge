# z80pack — implementation plan
> Source: ./draft.md · Target: apps/z80pack/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.38 (GitHub release, published 2024-06-01, https://api.github.com/repos/udo-munk/z80pack/releases). Releases: 1.38, 1.37, 1.36. The chart image (dlandon) builds 1.37 (`Z80PACK_VERS=1.37` in its Dockerfile). |
| Renovate | `datasource=github-releases depName=udo-munk/z80pack versioning=loose` (bare-number tags). |
| License | MIT per GitHub API (`license.spdx_id` = MIT, https://api.github.com/repos/udo-munk/z80pack). The README names no licence (https://raw.githubusercontent.com/udo-munk/z80pack/master/README.md). Treat the repo `LICENSE` file contents as UNVERIFIED. |
| Source URL | https://github.com/udo-munk/z80pack |
| Download | `https://github.com/udo-munk/z80pack/archive/refs/tags/${VERSION}.tar.gz`. UNVERIFIED: the URL pattern is standard for GitHub tags, not fetched in this run. |
| Checksum source | None found. UNVERIFIED. The tag pins the source. |
| Per-arch | Compiled from source on both amd64 and arm64 (no prebuilt binary). |
| Build (upstream README) | X11: `apt install build-essential libglu1-mesa-dev libjpeg9-dev`, then `make`. SDL2: `apt install build-essential libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev`, then `WANT_SDL=YES make`. Both build all MACHINES in the Makefile. |
| Run (upstream README) | `(cd cpmsim; ./cpm22)` for CP/M 2.2; `(cd cpmsim; ./cpm3)` for CP/M 3. |
| Disk images and config | UNVERIFIED: the README does not name the disk image files or config location. |
| Upstream image Dockerfile | `https://raw.githubusercontent.com/dlandon/z80pack/ae67a0f2e18868f5ccc99eff31973183c4965aa6/Dockerfile`: `FROM phusion/baseimage:jammy-1.0.4` (glibc Ubuntu 22.04, not musl); `ENV Z80PACK_VERS=1.37`, `CPMTOOLS_VERS=2.24`, `DISABLE_SSH=true`, `TZ=Etc/UTC`; apt installs `make gcc libncurses5-dev libncursesw5-dev shellinabox`; builds z80pack with `make -f Makefile.linux` and `make install`, and cpmtools with configure/make; `EXPOSE 4200`; `VOLUME ["/config"]`; no ENTRYPOINT; `CMD ["/sbin/my_init"]`; no USER (root). Web terminal is shellinabox on 4200. The Dockerfile sets a fixed password for user `vintage`: do not copy it. |
| Chart values | `https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/z80pack/values.yaml`: image `docker.io/dlandon/z80pack:latest`; runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false; service `main` port 4200/tcp; persistence `config` at `/config`; no env. |
| Ports | 4200/tcp (shellinabox web terminal, from the upstream Dockerfile and chart). The draft's 8080 is not supported by any fetched source; drop it. |
| Dependencies | None. |

## 2. Target layout

- `apps/z80pack/Dockerfile`
- `apps/z80pack/docker-bake.hcl`
- `apps/z80pack/settings.yaml`
- `apps/z80pack/container-test.yaml`
- `apps/z80pack/start.sh`

No `defaults/`, `etc/`, `health/`, `root/`. A web terminal needs a wrapper process; the wrapper is in `start.sh`, not a separate file. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Final stage: the same. Source build on ubuntu, copy the installed emulator tree into the final stage. Closest sibling: `apps/pwndrop` (build stage then runtime stage). The upstream phusion/runit init is dropped.

## 4. Dockerfile

1. `FROM <ubuntu> AS build`, then `ARG VERSION`, `ARG TARGETARCH` (after `FROM`, so they are in scope), `USER root`.
2. Build stage: `apt-get install -y --no-install-recommends build-essential libncurses-dev libncursesw5-dev curl ca-certificates`. The X11 build is not needed for a headless console; use the plain `make` (no `WANT_SDL`; the dlandon 1.37 image used `make -f Makefile.linux`, and whether 1.38 still has that file is UNVERIFIED) and document that the web terminal is the console.
3. Fetch and build:
   ```dockerfile
   RUN curl -fL -o /tmp/z80pack.tar.gz "https://github.com/udo-munk/z80pack/archive/refs/tags/${VERSION}.tar.gz" && \
       mkdir -p /tmp/src && tar xf /tmp/z80pack.tar.gz -C /tmp/src --strip-components=1 && \
       cd /tmp/src && make && make install DESTDIR=/tmp/out
   ```
   UNVERIFIED: `make install` target and `DESTDIR` support. Confirm with `make -n install` in step 2 of the protocol before relying on it.
4. Final stage: `apt-get install -y --no-install-recommends shellinabox ncurses-bin ca-certificates` (runtime only). Build tools are not carried over.
5. `COPY --from=build /tmp/out/ /app/z80pack/`; licence to `/usr/share/licenses/z80pack/` from `/tmp/src/LICENSE` if present, else a note (UNVERIFIED).
6. Mirror the upstream `cpmsim` layout under `/app/z80pack/cpmsim` so the `cpm22`/`cpm3` binaries run from there. Disk images are not copied; they go to `/config` (section 7).
7. `ENV TERM=xterm HOME=/tmp LANG=C.UTF-8`.
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 4200
   VOLUME /config

   WORKDIR /app/z80pack/cpmsim
   ```

Version alignment: `ARG VERSION` must equal `docker-bake.hcl` `VERSION` (`1.38`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "z80pack"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=udo-munk/z80pack versioning=loose
  default = "1.38"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/udo-munk/z80pack"
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

Validate with `cd apps/z80pack && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/udo-munk/z80pack"
ports:
  - port: 4200
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

Rules: list only variables the start script reads. `start.sh` reads no variable beyond `TZ`, so no other env is listed (an earlier `Z80PACK_CONSOLE_USER` was removed: the wrapper runs as the fixed `apps` user). No password env var: the web terminal password must not be a fixed value; see section 10.

## 7. start.sh

- `mkdir -p /config/cpmsim/disks` and `/tmp/shellinabox`.
- Seed `/config/cpmsim/disks` from the packaged disk library only when empty: the upstream image copies a disk library to a backups folder (`cp -p * ../backups`). Copy only when `/config/cpmsim/disks` has no files, never overwrite.
- Symlink `/app/z80pack/cpmsim/disks` to `/config/cpmsim/disks`? No: `/app` is read-only. Instead, the wrapper `cd`s to `/config/cpmsim` and runs `/app/z80pack/cpmsim/cpm22` there (UNVERIFIED: whether the binary finds the disk files relative to cwd).
- Start shellinabox on `0.0.0.0:4200` with `--no-beep` and `-s /:LOGIN` or a wrapper command that runs the emulator. Use `/tmp` for shellinabox state.
- Final `exec shellinaboxd -t -p 4200 --no-beep -s "/:apps:apps:/config/cpmsim:/app/z80pack/cpmsim/cpm22"` (UNVERIFIED flags; check `shellinaboxd --help` in the build step and adjust).
- No writes to `/app`. Ephemeral state under `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '4200'
http:
- port: '4200'
  path: /
filePaths:
- /app/z80pack/cpmsim/cpm22
- /app/z80pack/cpmsim/cpm3
- /usr/bin/shellinaboxd
```

The emulator needs CP/M disk images that the user supplies under `/config`, so the disk-backed run path is not exercised by the test. Add it to `filePaths` only if a required-env path exists (none). Keep the `tcp` and `http` probes on 4200.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/root/z80pack/cpmsim` (disks and state) | `/config/cpmsim` |
| shellinabox state and CSS files | `/tmp/shellinabox` |
| `HOME=/root` | `HOME=/tmp` |
| Upstream root user and `vintage` sudo account | Dropped: the container runs as `apps`. No sudo. |
| Chart security | Chart runs root (runAsUser 0). The plan runs as `apps` on 4200 (no privileged port). |

## 10. Risks, caveats and open questions

- Fixed password in upstream Dockerfile (`vintage:computer`): do not reproduce it. Choose an auth method that is not a fixed password (for example shellinabox with no login, bound to localhost only, or a per-start random password written to the log). UNVERIFIED which is acceptable for the repo; decide in the PR. Binding to 0.0.0.0 with no auth is a risk.
- No arm64 route confirmed: copy-from arm64 is `no` per the draft and the dlandon image platform was not fetched. Build from source on both architectures; arm64 build is UNVERIFIED until built.
- CP/M disk images are not bundled. The emulator is useless without them. Document in the PR.
- The shellinabox flags in section 7 are UNVERIFIED until checked against the installed binary. UNVERIFIED too: `shellinaboxd` started as non-root with a `USER:GROUP` service spec (it normally needs root to switch user); if it fails, use a plain command service. The `shellinabox` package exists on Ubuntu resolute (packages.ubuntu.com).
- The `make install` target and install prefix are UNVERIFIED.
- Upstream image uses phusion/runit; it is dropped. The web terminal is started directly by `start.sh`.
- Blockers: none that prevent a build. Auth design (above) is the main open item.

## 11. Build and test steps

```sh
cd apps/z80pack
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create z80pack-probe-config
docker run --rm -d --name z80pack-probe --read-only --tmpfs /tmp \
  -v z80pack-probe-config:/config z80pack:1.38
docker logs -f z80pack-probe
docker rm -f z80pack-probe; docker volume rm z80pack-probe-config
forgetool containers test --image z80pack:1.38 --config ./apps/z80pack/container-test.yaml
```

Expected readiness signal: shellinabox logs that it is listening on port 4200 (exact text UNVERIFIED; confirm in step 3). The container must stay running.

## 12. PR checklist

- Branch: `feat/add-z80pack`
- Commit: `feat(z80pack): add new container`
- Title: `feat(z80pack): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what was not tested: arm64 build, disk-backed emulator run with real CP/M images, and the web terminal auth decision.
