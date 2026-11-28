# twonky-server — implementation plan
> Source: ./draft.md · Target: apps/twonky-server/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 8.5.2 (draft pins the same). `twonkyserver-version.txt` inside the zip says `version=8.5.2`. `download.twonky.com` also lists an 8.5.3 directory, but I only found a macOS pkg and Synology builds there; the plain `x86-64-glibc` zip for 8.5.3 returns 403, so 8.5.2 stays (newer Linux build: UNVERIFIED) |
| Renovate | No supported datasource (no release feed or API). Manual bump; comment line in bake documents this. Optional later: `datasource=custom` regex over `http://download.twonky.com/` directory listing (UNVERIFIED) |
| License | Proprietary closed source (zip ships "Terms of Use - Privacy Policy" PDFs, `NOTICES-Server.txt`, `twonky.license`). Use `LICENSE = "LicenseRef-Proprietary"`. Redistribution of the binary in a public image: UNVERIFIED, flag for the maintainers |
| Source URL | https://www.twonky.com/download/ (helper repo: https://github.com/H2CK/twonkyserver, Dockerfile only) |
| amd64 download | `http://download.twonky.com/8.5.2/twonky-x86-64-glibc-2.22-8.5.2.zip` (HEAD returns 200, 4563574 bytes) |
| arm64 download | None (vendor lists no aarch64 glibc zip for 8.5.2; probe returned 403) |
| Checksum source | None published. I downloaded the zip: sha256 `d8cc1785aa4498b95564ee1bce02851b7e66372b93f7ff249bb4568cecd7b58b`; pin this in the Dockerfile and recompute on every bump |
| Zip layout | `twonkyserver` (ELF x86-64, dynamic, interpreter `/lib64/ld-linux-x86-64.so.2`), `twonkystarter`, `cgi-bin/` (`ffmpeg.location` contains `/usr/bin/ffmpeg`, `convert.location` contains `/usr/bin/convert`), `plugins/`, `resources/`, `twonky.license`, `twonky.dat`, `NOTICES-Server.txt`, Terms PDFs, `Linux-HowTo.txt` |
| Runtime facts | `Linux-HowTo.txt`: appdata folder set with `-appdata "/<abs path>"` (default `/var/twonky` for root, `$HOME/.twonky` otherwise); web config at `http://127.0.0.1:9000/webconfig` |
| Upstream Dockerfile reviewed | H2CK/twonkyserver at a4d34f5: ubuntu:20.04, supervisor + cron + sudo, unzips to `/usr/local/twonky`, static ffmpeg 4.3.2 copied into `cgi-bin`, `supervisord.conf` runs `/usr/local/twonky/twonkyserver -appdata "/config"` as root, `EXPOSE 1030/udp 1900/udp 9000/tcp`, `VOLUME /config`, `VOLUME /data`. Entry scripts only handle `GROUP_ID` (groupmod) and `UPDATE_ON_START` (apt upgrade) |

## 2. Target layout

```
apps/twonky-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/`, `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Reason: closed glibc binary, no runtime language. Closest sibling: `apps/adguardhome-sync` (download, extract to `/app`, `COPY . /`). The upstream used ubuntu 20.04 and glibc 2.22 baseline, so 26.04 is newer and fine for glibc; legacy shared-library needs: UNVERIFIED (`ldd /app/twonky/twonkyserver` during the build must show no "not found").

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG TWONKY_SHA256`, `USER root`.
2. Guard: `RUN test "${TARGETARCH}" = "amd64"` (fail clearly on arm64; `image-all` in bake limited to amd64).
3. apt (not in base: `unzip` and `curl` already are): `ffmpeg` (provides `/usr/bin/ffmpeg`, matching `cgi-bin/ffmpeg.location`; replaces the upstream static ffmpeg 4.3.2 download), `imagemagick` only if `convert.location` features are wanted (optional, skip by default; UNVERIFIED need). Pinning: not applicable to ffmpeg here since the pinned version is Twonky's, not ffmpeg's.
4. Download and verify:
```dockerfile
RUN set -eux; \
    curl -fsSL -o /tmp/twonky.zip "http://download.twonky.com/${VERSION}/twonky-x86-64-glibc-2.22-${VERSION}.zip"; \
    echo "${TWONKY_SHA256}  /tmp/twonky.zip" | sha256sum -c -; \
    mkdir -p /app/twonky /usr/share/licenses/twonky-server; \
    unzip -q /tmp/twonky.zip -d /app/twonky; \
    cp /app/twonky/NOTICES-Server.txt /app/twonky/twonky.license /usr/share/licenses/twonky-server/; \
    cp /app/twonky/Terms*English* /usr/share/licenses/twonky-server/ 2>/dev/null || cp "/app/twonky/Terms of Use - Privacy Policy-ENx.pdf" /usr/share/licenses/twonky-server/; \
    chmod 0755 /app/twonky/twonkyserver /app/twonky/twonkystarter /app/twonky/cgi-bin/* /app/twonky/plugins/*; \
    chown -R root:root /app/twonky && chmod -R a+rX /app/twonky; \
    rm -f /tmp/twonky.zip
```
The URL is plain `http`; the sha256 check is therefore mandatory.
5. `ENV HOME=/config`.
6. `USER apps` (final user directive), `COPY --chmod=0755 . /`.
7. `EXPOSE 9000 1900/udp`, `VOLUME /config`, `WORKDIR /config`. Upstream also exposed `1030/udp`; unverified whether the server opens it (see section 6).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "twonky-server" }

variable "VERSION" {
  // renovate: none (closed source, no registry or release feed); bump VERSION and TWONKY_SHA256 together by hand
  default = "8.5.2"
}

variable "TWONKY_SHA256" {
  default = "d8cc1785aa4498b95564ee1bce02851b7e66372b93f7ff249bb4568cecd7b58b"
}

variable "LICENSE" { default = "LicenseRef-Proprietary" }
variable "SOURCE"  { default = "https://www.twonky.com/download/" }
```
`image.args` gets `VERSION` and `TWONKY_SHA256`; targets `docker-metadata-action`, `image`, `image-local`, `image-all` (platforms `linux/amd64` only, since no arm64 exists), `group "default" { targets = ["image-local"] }`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.twonky.com/download/"
ports:
  - port: 9000
    protocol: tcp
    required: false
  - port: 1900
    protocol: udp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
```
The upstream wrapper env `GROUP_ID` and `UPDATE_ON_START` belong to the H2CK scripts, not to Twonky, so they are omitted. Port 1030/udp is in upstream's EXPOSE but I could not verify that Twonky binds it, so it is not listed. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e
mkdir -p /config
export HOME=/config
exec /app/twonky/twonkyserver -appdata /config
```
- `-appdata` is the documented flag; the path is absolute. State (database, `twonkyserver.ini`, logs) lands in `/config`; media is browsed from `/data` (set in the web UI under content locations).
- Binding to all interfaces: UNVERIFIED (the HowTo only shows `127.0.0.1:9000` for local access); verify from outside the container.
- Idempotent and no writes to `/app`. Whether the server writes to its install dir (for example `cgi-bin`, `plugins`): UNVERIFIED; if so, symlink those paths into `/tmp` in start.sh.
- No env var mapping needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '9000'
filePaths:
- /app/twonky/twonkyserver
- /usr/bin/ffmpeg
- /usr/share/licenses/twonky-server/NOTICES-Server.txt
```
UDP 1900 (SSDP): forgetool's `tcp`/`http` checks cannot probe UDP (UNVERIFIED that any UDP probe exists), so the 1900/udp port from settings.yaml has no automatic probe; check it manually with `docker exec ... ss -lun | grep 1900` in section 11 and keep the gap documented in the PR. TCP 9000 is covered above.

## 9. Rootless and read-only-rootfs adaptations

- Draft/upstream runs as root with supervisor and cron; we run as `apps` (568) with a single `exec` process and no supervisor/cron/sudo.
- Writes: appdata -> `/config` via `-appdata`; nothing else known. Remap candidates if found: any write into `/app/twonky` -> `/tmp`.
- SSDP/UPnP on UDP 1900 uses multicast: needs host networking (or macvlan) on the LAN; no privileged mode required for ports above 1024, but binding UDP 1900 for multicast is allowed unprivileged (1900 > 1024).
- Draft's `/data` PVC (media) stays an optional volume `/data`, read-only mount is fine.

## 10. Risks, caveats and open questions

- Closed-source, amd64 only; no arm64 (use `platforms = ["linux/amd64"]`).
- Plain-http vendor download that may move; checksum pinned from my download. If `download.twonky.com` removes 8.5.2 the build breaks.
- Redistribution/EULA of Twonky binary in a public image: UNVERIFIED; maintainers should confirm. `twonky.license`/`twonky.dat` in the zip may be a trial/limited license; behavior without a purchased license (feature limits, nag): UNVERIFIED.
- Discovery needs host network; behind bridge networking clients will not see the server.
- First scan of a large `/data` is slow.
- Whether 8.5.3 supersedes 8.5.2 on Linux: UNVERIFIED.
- UNVERIFIED count for this plan: 8 (newer Linux build, renovate feed, redistribution terms, license behaviour, ldd needs, bind address, install-dir writes, UDP probe/1030 port).

## 11. Build and test steps

```sh
cd apps/twonky-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create twonky-server-probe-config
docker run --rm -d --name twonky-server-probe --read-only --tmpfs /tmp \
  -v twonky-server-probe-config:/config twonky-server:8.5.2
docker logs -f twonky-server-probe
docker exec twonky-server-probe ss -lntu | grep -E '9000|1900'
```
Success signal: process stays up, port 9000 open (and `curl -s http://localhost:9000/webconfig` from outside the container returns HTML), `/config` populated (ini/db) with no repeated errors in the logs. Then:
```sh
forgetool containers test --image twonky-server:8.5.2 --config ./apps/twonky-server/container-test.yaml
docker rm -f twonky-server-probe; docker volume rm twonky-server-probe-config
```

## 12. PR checklist

- Branch `feat/add-twonky-server`; commit and PR title `feat(twonky-server): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- Pre-completion: bake print ok; `VERSION` and `TWONKY_SHA256` aligned with the Dockerfile ARGs; final `USER apps`; `COPY --chmod=0755 . /`; licenses in `/usr/share/licenses/twonky-server/`.
- State untested: arm64 (unsupported), UDP 1900 discovery, bind address, license/trial behaviour, redistribution terms.
