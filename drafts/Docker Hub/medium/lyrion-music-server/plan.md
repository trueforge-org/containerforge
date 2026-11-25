# lyrion-music-server — implementation plan
> Source: ./draft.md · Target: apps/lyrion-music-server/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Decision needed (see section 10). Stable options: `9.1.2` (Docker Hub `stable` and `9.1.2`, last updated 2026-10-24) or `9.1.1` (downloads page, stable). The chart uses `9.2.0`, which is listed only under `nightly/` on lyrion.org. Stable status of 9.2.0: UNVERIFIED (GitHub release page gave no date or pre-release flag). This plan assumes stable `9.1.2`, which needs its deb URL confirmed. |
| Chart tag | Chart runs `docker.io/lmscommunity/lyrionmusicserver:9.2.0`. Docker Hub `9.2.0` was updated 2026-11-25. |
| Renovate | UNVERIFIED. Likely candidate: `// renovate: datasource=docker depName=lmscommunity/lyrionmusicserver versioning=loose`. Check that nightly tags such as `9.2.0` are excluded if they are not stable. |
| License | UNVERIFIED. `LICENSE` on `public/9.2` and `master` returned 404, and the README was not checked for a license statement. Do not fill `LICENSE` in the bake file until verified. |
| Source URL | https://github.com/LMS-Community/slimserver (application); https://github.com/LMS-Community/slimserver-platforms (packaging) |
| Download (amd64) | Stable 9.1.1: `https://downloads.lms-community.org/LyrionMusicServer_v9.1.1/lyrionmusicserver_9.1.1_amd64.deb`. Nightly 9.2.0: `https://downloads.lms-community.org/nightly/lyrionmusicserver_9.2.0~1795554800_amd64.deb`. |
| Download (arm) | Stable 9.1.1: `https://downloads.lms-community.org/LyrionMusicServer_v9.1.1/lyrionmusicserver_9.1.1_arm.deb` (armhf). Nightly 9.2.0: `.../nightly/lyrionmusicserver_9.2.0~1795554800_arm.deb`. |
| Download (arm64) | UNVERIFIED: no arm64 `.deb` is listed on lyrion.org. The page lists `_arm.deb` (armhf) only. Docker Hub does publish an arm64 image (see below). |
| Download (all) | Nightly `lyrionmusicserver_9.2.0~1795554800_all.deb` exists. Whether it contains the native helpers: UNVERIFIED. |
| Checksum source | UNVERIFIED. No `.sha` or `.sha256` file was checked on the downloads server. |
| Upstream Dockerfile reviewed | `slimserver-platforms` commit `d05c757`, `Docker/Dockerfile`. `Docker/start-container.sh` read only in part. |
| Upstream base | `debian:trixie-slim`. The ContainerForge base is Ubuntu 26.04. |
| Upstream apt | procps, psmisc, wget, curl, perl, tzdata, libcrypt-blowfish-perl, libwww-perl, libfont-freetype-perl, liblinux-inotify2-perl, libdata-dump-perl, libio-socket-ssl-perl, libnet-ssleay-perl, libcrypt-ssleay-perl, libcrypt-openssl-rsa-perl, libssl-dev, libgomp1, libasound2t64, lame, opus-tools, libatomic1. |
| Upstream user and remap | Creates `squeezeboxserver` (PUID 499, PGID 100), adds to audio group. `start-container.sh` runs as root and uses `usermod`, `groupmod` and `chown` on `/config` and `/playlist`. |
| Upstream write paths | `/config` (state), `/playlist`, `/music` (VOLUME). |
| Real env vars (upstream) | `PUID=499`, `PGID=100`, `HTTP_PORT=9000`, `LC_ALL=C.UTF-8`, `LANG=en_US.UTF-8`, `LANGUAGE=en_US.UTF-8`, `DEBIAN_FRONTEND=noninteractive`. |
| Ports | 3483/tcp, 3483/udp (SlimProto and discovery), 9000/tcp (`${HTTP_PORT}`, web UI and streaming), 9090/tcp (CLI). |
| Entrypoint | `start-container`, WORKDIR `/config`. |
| Chart | `lyrion-music-server` version 8.0.0, appVersion 9.2.0, common 32.8.5 (`charts/stable/lyrion-music-server/Chart.yaml`). |

## 2. Target layout

- `apps/lyrion-music-server/Dockerfile`
- `apps/lyrion-music-server/docker-bake.hcl`
- `apps/lyrion-music-server/settings.yaml`
- `apps/lyrion-music-server/container-test.yaml`
- `apps/lyrion-music-server/start.sh`

No `defaults/` (the server writes its own prefs on first start; UNVERIFIED). No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md`: the image is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

- The server is a Perl app installed from the vendor `.deb`, so no language runtime image is needed (the draft says the same).
- Closest sibling: `apps/duplicati`, which installs a vendor `.deb` on ubuntu with `gdebi`.
- Upstream uses Debian trixie package names. On Ubuntu 26.04 the names must be checked (for example `libasound2t64` exists on both). Check each one with `apt-cache policy` during the first build.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG LMS_SHA256`, `USER root`.
2. Environment:
   ```dockerfile
   ENV HOME=/config \
       DEBIAN_FRONTEND=noninteractive \
       LC_ALL=C.UTF-8 \
       TMPDIR=/tmp
   ```
   `LANG=en_US.UTF-8` is upstream's value. Keep it only if the locale exists in the base (UNVERIFIED).
3. Install tools and runtime libraries that are not already in the base. Start with `gdebi-core` (as `apps/duplicati` does), `lame` and `opus-tools` (transcoding), and `libgomp1` and `libatomic1` if the `.deb` does not pull them in. Let the `.deb` pull Perl and its modules. Do not add the upstream Perl list by hand.
4. Architecture mapping and download:
   ```dockerfile
   RUN case "${TARGETARCH}" in \
         amd64) deb_arch=amd64 ;; \
         arm64) echo "arm64 .deb is UNVERIFIED" >&2; exit 1 ;; \
         *) echo "unsupported ${TARGETARCH}" >&2; exit 1 ;; \
       esac && \
     curl -fsSL -o /tmp/lms.deb \
       "https://downloads.lms-community.org/LyrionMusicServer_v${VERSION}/lyrionmusicserver_${VERSION}_${deb_arch}.deb" && \
     echo "${LMS_SHA256}  /tmp/lms.deb" | sha256sum -c -
   ```
   The `LyrionMusicServer_v<version>/` folder pattern is confirmed for 9.1.1 only. Confirm it for 9.1.2 before pinning.
5. Install the `.deb` with apt, so its dependencies resolve, then clean up:
   ```dockerfile
   RUN apt-get update && \
     apt-get install -y --no-install-recommends /tmp/lms.deb && \
     apt-get purge -y --auto-remove gdebi-core && \
     rm -rf /var/lib/apt/lists/* /tmp/*
   ```
6. Install layout: run `dpkg -L lyrionmusicserver` to find where the code lands (UNVERIFIED; the upstream image copies it to `/lms`). Move or link the install tree under `/app/lyrion-music-server/` so that `/app` holds the app, as the other apps do. Do not write to `/app` at runtime.
7. Remove the upstream user setup (`squeezeboxserver`, `PUID`, `PGID`, audio group). The app runs as `apps` (568).
8. Ownership and ports. Create `/config` owned by `apps`, so that a new empty named volume gets the right owner:
   ```dockerfile
   RUN mkdir -p /config && chown apps:apps /config && \
     chown -R root:root /app && chmod -R 755 /app
   ```
9. License: copy the license text from the `.deb` to `/usr/share/licenses/lyrion-music-server/` (`/usr/share/doc/lyrionmusicserver/copyright` if present; UNVERIFIED).
10. Tail:
    ```dockerfile
    USER apps
    COPY --chmod=0755 . /

    EXPOSE 3483/tcp 3483/udp 9000/tcp 9090/tcp
    VOLUME /config
    WORKDIR /config
    CMD ["/start.sh"]
    ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "lyrion-music-server"
}

variable "VERSION" {
  // renovate: datasource=docker depName=lmscommunity/lyrionmusicserver versioning=loose
  default = "9.1.2"
}

variable "LMS_SHA256" {
  default = "UNVERIFIED: compute from the downloaded .deb on the first build"
}

variable "LICENSE" {
  default = "UNVERIFIED: set from the verified upstream license"
}

variable "SOURCE" {
  default = "https://github.com/LMS-Community/slimserver"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    LMS_SHA256 = "${LMS_SHA256}"
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
    "linux/amd64"
  ]
}
```

- `image-all` is amd64 only until an arm64 `.deb` is verified (section 10). Do not list `linux/arm64` yet.
- The `armhf` `.deb` is not used: the ContainerForge build targets amd64 and arm64.
- Validate with `docker buildx bake --print` from `apps/lyrion-music-server`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/LMS-Community/slimserver"
ports:
  - port: 3483
    protocol: tcp
    required: false
  - port: 3483
    protocol: udp
    required: false
  - port: 9000
    protocol: tcp
    required: false
  - port: 9090
    protocol: tcp
    required: false
env:
  - name: HTTP_PORT
    default: "9000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /music
    required: false
  - path: /playlist
    required: false
```

- `PUID` and `PGID` are not listed: they belong to the upstream root remap, which is dropped.
- `HTTP_PORT` is only listed if `start.sh` passes it to the server (flag name UNVERIFIED).
- `/music` and `/playlist` are read-mostly bind mounts from the upstream `VOLUME` list.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/prefs /config/logs /config/cache

cd /config
exec /app/lyrion-music-server/<server-entry> \
  --prefsdir /config/prefs \
  --logdir /config/logs \
  --cachedir /config/cache \
  --httpport "${HTTP_PORT:-9000}"
```

- The directory names, the server entry script and all flag names are UNVERIFIED. Take them from the full `start-container.sh` and `slimserver --help` before the first build. The facts only cover part of the script.
- Idempotent: `mkdir -p` only. The server writes its own prefs. No seeding, no overwrites.
- Caches go to `/tmp` (`TMPDIR=/tmp` in the Dockerfile). The `--cachedir` value must point at `/config` only if persistence is needed; otherwise use `/tmp`.
- No `chown` or `usermod` at runtime (rootless).
- `exec` hands PID 1 to the server.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3483'
- port: '9000'
- port: '9090'
http:
- port: '9000'
  path: /
filePaths:
- /usr/share/licenses/lyrion-music-server
```

- `timeoutSeconds: 180` is a starting value for a Perl server that loads many modules (UNVERIFIED; compare sibling apps of the same family).
- Port 3483/udp has no probe here: `tcp` probes cannot test UDP. Check whether forgetool has a UDP probe. Emby (`apps/emby`) has the same gap for its UDP ports and does not probe them, so this is a known pattern, but it is still a gap. Report it.
- The test runs with no env vars, and the server starts without them, so no `filePaths` are needed for required-env paths.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in ContainerForge |
| --- | --- |
| `/config` (prefs, logs, state) | `/config` (single persistent volume, owned by `apps`). |
| `/playlist`, `/music` | Bind-mounted by the user. The server must only read `/music`. Playlist writes go to `/playlist`, which the user must mount writable (UNVERIFIED). |
| Root remap (`usermod`, `groupmod`, `chown` in `start-container.sh`) | Dropped. The image runs as 568 and owns `/config`. |
| Temp files (`TMPDIR`) | `/tmp`. |
| Helper binaries in the install tree | Read-only under `/app`. The server must not write next to them (UNVERIFIED). |

- Draft expectations, reconciled: the chart forces UID 0 and `readOnlyRootFilesystem: false`. The image is intended to run as 568 and to work with `--read-only --tmpfs /tmp`. Verify it in section 11.
- Bind address: the server must listen on all interfaces (`0.0.0.0`), not only localhost. Check the default and test from outside the container (`-p 9000:9000`).
- Discovery (UDP 3483 broadcast) needs host networking or a bridge that forwards broadcasts. This cannot be tested from `container-test.yaml`.

## 10. Risks, caveats and open questions

- Version decision (blocking): pin stable 9.1.2 (needs its deb URL confirmed), stable 9.1.1 (URLs confirmed), or nightly 9.2.0 (matches the chart, but not stable and nightly URLs can disappear). This plan assumes 9.1.2.
- arm64 is blocked: no arm64 `.deb` is listed on lyrion.org. Options: (a) amd64-only image until the user accepts a different source; (b) use `COPY --from=ghcr.io/lmscommunity/lyrionmusicserver:<version>` for arm64, which the draft lists as copy-from and which is Debian/glibc. Option (b) breaks the "fetch the binary ourselves" rule of the draft, so it needs the user's decision.
- License: UNVERIFIED. The bake `LICENSE` must match the image software, so the bake file cannot be finished until it is verified.
- Checksum: UNVERIFIED. No vendor checksum was checked.
- Package names: upstream uses Debian trixie names. Ubuntu 26.04 names are UNVERIFIED.
- Bind address and config flags are UNVERIFIED. These decide whether the probes and `start.sh` work.
- UDP discovery is not testable in a single container, and the UDP port has no probe (section 8).
- Long first library scan on a large `/music` collection can take a long time (inferred).
- No database and no dependency containers.
- No blockers confirmed beyond the arm64 `.deb` gap and the version decision.

## 11. Build and test steps

```sh
cd apps/lyrion-music-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name lyrion-probe --read-only --tmpfs /tmp \
  -v lyrion-probe-config:/config \
  lyrion-music-server:9.1.2
docker logs -f lyrion-probe
forgetool containers test \
  --image lyrion-music-server:9.1.2 \
  --config ./container-test.yaml
docker rm -f lyrion-probe; docker volume rm lyrion-probe-config
```

- Readiness signal: the server's HTTP startup line on port 9000 is UNVERIFIED. Record the first real line. Pass also requires the process to stay up and the TCP ports to answer.
- Check that `/config` is populated after start (prefs) and survives a restart.
- Test from outside the container (`-p 9000:9000 -p 9090:9090 -p 3483:3483`) to confirm it is not bound to localhost.
- The UDP discovery port is only checked by hand.

## 12. PR checklist

- Branch `feat/add-lyrion-music-server`, commit and PR title `feat(lyrion-music-server): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: arm64 (no `.deb`), UDP discovery, read-only runtime, and the chosen version's `.deb` checksum.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
