# rtorrent-rutorrent — implementation plan
> Source: ./draft.md · Target: apps/rtorrent-rutorrent/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart pins `ghcr.io/crazy-max/rtorrent-rutorrent:4.2.9-0.9.8_2-0.13.8_1`. Upstream Dockerfile (commit `1efb9e087f90f68ed132b3ffd419b29145a1838e`) pins ruTorrent `v4.2.9` at commit `e7c81203eff5d43f6f2757ba4b05573d22f11e35` and GeoIP2 plugin at `4ff2bde530bb8eef13af84e4413cedea97eda148`. rTorrent `0.9.8` comes from the Ubuntu archive (below). |
| Renovate | UNVERIFIED: no renovate config fetched. Proposed: `datasource=git-refs depName=https://github.com/Novik/ruTorrent` (git-refs, since VERSION is a commit SHA; precedent: other apps' git-refs comments). The composite image tag is not a single version. |
| License | rtorrent: GPL-2.0-only (`COPYING`, "Version 2, June 1991", https://raw.githubusercontent.com/rakshasa/rtorrent/master/COPYING). ruTorrent (Novik): UNVERIFIED (source not fetched). Upstream image license: UNVERIFIED. `LICENSE` in bake must be the license of the image as built, so confirm before bake. |
| Source URL | https://github.com/rakshasa/rtorrent (rtorrent), https://github.com/Novik/ruTorrent (ruTorrent web UI), https://github.com/crazy-max/docker-rtorrent-rutorrent (upstream image) |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/crazy-max/docker-rtorrent-rutorrent/1efb9e087f90f68ed132b3ffd419b29145a1838e/Dockerfile. Alpine (`crazymax/alpine-s6:3.19-2.2.0.3`), `apk` packages (nginx, php82 + fpm, ffmpeg, mediainfo, sox, python3, py3-pip), `ENTRYPOINT ["/init"]`, `HEALTHCHECK CMD /usr/local/bin/healthcheck`, `VOLUME ["/data","/downloads","/passwd"]`, no `EXPOSE`, no `USER`, `PUID=1000` / `PGID=1000` create user `rtorrent`. |
| Binary (rTorrent) | `apt:rtorrent` on Ubuntu resolute (26.04): `0.9.8-1.1ubuntu2`, universe, archs amd64, arm64, armhf, ppc64el, riscv64, s390x (https://packages.ubuntu.com/resolute/rtorrent). Confirmed. |
| Binary (nginx, PHP-FPM) | Ubuntu archive packages `nginx` and `php-fpm`: versions for resolute UNVERIFIED (not fetched). Plan pins them against the base release. |
| copy-from | `no` for both arches (musl Alpine upstream image cannot run on glibc Ubuntu, per draft.md). |
| Checksum source | Ubuntu archive packages are verified by apt. ruTorrent tarball: UNVERIFIED (no checksum fetched); pin by commit SHA as the content address. |
| Ports | Upstream image: no `EXPOSE`. Draft ports (80 web, 5000 SCGI, 50000 peer) are inferred, not confirmed on a fetched page. |
| Data paths | Upstream: `/data`, `/downloads`, `/passwd` (VOLUME). ruTorrent at `/var/www/rutorrent` (upstream COPY, chown `nobody:nogroup`). |
| Env vars (upstream) | `PUID=1000`, `PGID=1000`, `TZ=UTC`, `S6_BEHAVIOUR_IF_STAGE2_FAILS=2`, `S6_KILL_GRACETIME=10000`, `PYTHONPATH` |
| Dependencies | `rtorrent_exporter` (`ghcr.io/thde/rtorrent_exporter`), optional sidecar, not in ContainerForge (absent). |
| Blockers | Multiple services (rtorrent, nginx, PHP-FPM) need a supervisor. Upstream s6 `rootfs` overlay not fetched, so its service layout is UNVERIFIED. |

## 2. Target layout

- `apps/rtorrent-rutorrent/Dockerfile`
- `apps/rtorrent-rutorrent/docker-bake.hcl`
- `apps/rtorrent-rutorrent/settings.yaml`
- `apps/rtorrent-rutorrent/container-test.yaml`
- `apps/rtorrent-rutorrent/start.sh` (runs the supervisor and seeds `/config`)
- `apps/rtorrent-rutorrent/etc/` for the nginx site and rtorrent config templates (reason: nginx and rtorrent need config files shipped in the image; `etc/` is on the dockerignore allow-list)
- `apps/rtorrent-rutorrent/root/` is never used.
- No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for build and final stage. rTorrent is an apt package on this base, so the ubuntu base fits (draft.md choice confirmed). The alternative `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` was considered and rejected: it would not give rTorrent or PHP-FPM, so the apt install would still happen on top of it. Closest sibling: `apps/nginx` (web server layout) and `apps/adguardhome-sync` (ubuntu prebuilt layout).

## 4. Dockerfile

1. `ARG VERSION` (the ruTorrent commit SHA) and `ARG RTORRENT_VERSION` (apt pin), `USER root`.
2. Install packages pinned against the base release:
   ```dockerfile
   RUN apt-get update && apt-get install -y --no-install-recommends \
       rtorrent=0.9.8-1.1ubuntu2 \
       nginx=<version UNVERIFIED> \
       php-fpm=<version UNVERIFIED> php-xml php-mbstring php-curl \
       ffmpeg mediainfo sox python3 python3-pip \
     && rm -rf /var/lib/apt/lists/*
   ```
   `rtorrent` pin is confirmed. Other versions must be read from the resolute archive at build time and pinned before the PR. `python3-pip` plus `cfscrape cloudscraper` is optional and only if the ruTorrent plugin needs it (UNVERIFIED).
3. Fetch ruTorrent at the pinned commit and verify it is the expected tree:
   ```sh
   curl -fL -o /tmp/rutorrent.tar.gz \
     "https://github.com/Novik/ruTorrent/archive/${VERSION}.tar.gz"
   mkdir -p /var/www/rutorrent && tar xzf /tmp/rutorrent.tar.gz -C /var/www/rutorrent --strip-components=1
   rm -rf /var/www/rutorrent/conf/users /var/www/rutorrent/share
   ```
   The GeoIP2 plugin is optional; add only if needed, with its own pinned commit. Note: the `archive/<sha>.tar.gz` URL form is the standard GitHub archive URL, but it is UNVERIFIED for this repo until the first download succeeds.
4. License files: `/usr/share/licenses/rtorrent-rutorrent/` gets rtorrent `COPYING` (GPL-2.0-only) and the ruTorrent license (UNVERIFIED which file).
5. Ownership: `chown -R apps:apps /var/www/rutorrent` is wrong for `USER apps` at runtime if nginx needs to read it. Read-only is fine for nginx (served from `/app`). Place the ruTorrent tree at `/app/rutorrent` and keep it read-only; rTorrent writes to `/downloads` and `/config`.
6. `ENV HOME=/config TMPDIR=/tmp`.
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   VOLUME /downloads
   ```
   `EXPOSE` lists only the web port (8080; nginx cannot bind 80 as non-root). SCGI (5000) is internal to the container and is not exposed; peer port 50000 is exposed only if confirmed (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rtorrent-rutorrent"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/Novik/ruTorrent versioning=loose
  default = "e7c81203eff5d43f6f2757ba4b05573d22f11e35"
}

variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rakshasa/rtorrent"
}
```

`LICENSE` is set to rtorrent's GPL-2.0-only. The ruTorrent license is UNVERIFIED, so confirm before the PR. The four standard targets and the `default` group are copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rakshasa/rtorrent"
ports:
  - port: 8080
    protocol: tcp
    required: true
  - port: 50000
    protocol: tcp
    required: false
env:
  - name: PUID
    default: "1000"
    required: false
  - name: PGID
    default: "1000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /downloads
    required: false
dependencies: []
opt_dependencies:
  - rtorrent_exporter (not yet in ContainerForge; add when it exists)
```

Only env vars `start.sh` reads are listed (`PUID`/`PGID` map to the `apps` UID/GID handling, if the design keeps them; if not, drop them, since `USER apps` is fixed). Port 5000 is not listed (internal only). Port 50000 is listed only once the peer port is confirmed.

## 7. start.sh

Seeds `/config` once, then runs the services with a supervisor that `exec`s last:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/rtorrent /config/nginx /config/php /config/rutorrent /downloads /tmp/session
# Seed only missing config from /etc templates (never overwrite user state).
[ -f /config/rtorrent/.rtorrent.rc ] || cp /etc/rtorrent/rtorrent.rc /config/rtorrent/.rtorrent.rc

# Supervisor: UNVERIFIED choice. Options are s6 (as upstream) or a small script.
exec /usr/local/bin/supervise
```

Notes: `/usr/local/bin/supervise` is not defined yet; choosing the supervisor is an open decision (section 10). Nothing writes to `/app`. rTorrent session, nginx temp and PHP sessions go to `/tmp` or `/config` as shown. `/config` is seeded only when missing. The final long-running process must be `exec`ed so signals reach the supervisor.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
  - port: '8080'
http:
  - port: '8080'
    path: /rutorrent/
filePaths:
  - /app/rutorrent/index.php
  - /usr/bin/rtorrent
  - /usr/share/licenses/rtorrent-rutorrent/COPYING
```

Every port in `settings.yaml` needs a probe: port 50000 is not listed in `settings.yaml` yet, so it has no probe until confirmed. The HTTP path `/rutorrent/` is a guess matching the upstream layout; confirm it returns 200 or change it. `tcp` and `http` run inside the container, so they do not prove reachability from another container. `timeoutSeconds: 120` is a judgement for three services starting in order; compare with a sibling.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (chart path, upstream VOLUME) | `/config` (rtorrent session, `.rtorrent.rc`, ruTorrent user config) |
| `/downloads` | `/downloads` volume, owned by the `apps` user (chart path) |
| `/passwd` (upstream VOLUME, for the web UI login file) | `/config/rutorrent/passwd`, seeded only when missing |
| `/var/www/rutorrent` (upstream, owned by `nobody`) | `/app/rutorrent`, read-only at runtime |
| `/var/run`, nginx and PHP-FPM sockets | `/tmp` (sockets and pid files), set in `/etc` templates |
| PHP session and temp | `/tmp` |

Reconciled expectations from draft.md: the chart runs as UID 0 with `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, and extra persistence `/data`, `/downloads`, `/passwd`. This plan uses `USER apps` with `--read-only --tmpfs /tmp`. rTorrent binds 5000 internally with no privilege needed. Port 80 is below 1024 and cannot be bound by `apps`, so nginx listens on 8080 (settings.yaml, EXPOSE and probes use 8080; the chart maps it to 80). Not privileged.

## 10. Risks, caveats and open questions

- Blocker (multi-service): nginx, PHP-FPM and rtorrent need a supervisor. The supervisor choice (s6 as upstream, or a small script) is open and decides the start.sh shape.
- Blocker (port 80 as non-root): decide between nginx on an unprivileged port (8080) and keeping 80 with a capability. The plan picks 8080, as used in sections 4, 6, 8 and 9.
- Ports 50000 (peer) and 5000 (SCGI): both draft inferences, not confirmed on a fetched page. Peer port needs to be reachable from other peers, so a NAT/port forwarding note is required.
- `rtorrent` apt pin is confirmed (`0.9.8-1.1ubuntu2`). nginx and php-fpm versions are UNVERIFIED.
- Alpine-based upstream vs ubuntu: behaviour differences (PHP 8.2 on alpine vs resolute's PHP version) are UNVERIFIED; the web UI must be tested.
- ruTorrent source is cloned by commit; the archive URL form and ruTorrent license are UNVERIFIED.
- `rtorrent_exporter` sidecar is absent from ContainerForge; not required for the main image, tracked as opt dependency.
- arm64: apt rtorrent exists for arm64 (confirmed); the full stack on arm64 is UNVERIFIED.
- Upstream `healthcheck` script is not fetched; the plan uses the TCP and HTTP probes instead.

## 11. Build and test steps

```sh
cd apps/rtorrent-rutorrent
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name rtorrent-probe --read-only --tmpfs /tmp \
  -p 8080:8080 -v rtorrent-probe-config:/config -v rtorrent-probe-downloads:/downloads \
  rtorrent-rutorrent:e7c81203eff5d43f6f2757ba4b05573d22f11e35
docker logs -f rtorrent-probe
curl -fsS http://localhost:8080/rutorrent/ >/dev/null && echo "web UI reachable"
docker rm -f rtorrent-probe; docker volume rm rtorrent-probe-config rtorrent-probe-downloads
forgetool containers test --image rtorrent-rutorrent:e7c81203eff5d43f6f2757ba4b05573d22f11e35 --config ./apps/rtorrent-rutorrent/container-test.yaml
```

Readiness signals: nginx and PHP-FPM start lines, rtorrent start line (exact text UNVERIFIED), the process tree stays up, and `/rutorrent/` returns 200 from the host. Test a restart with the same `/config` volume.

## 12. PR checklist

- Branch `feat/add-rtorrent-rutorrent`, commit `feat(rtorrent-rutorrent): add new container`, target `main`, PR title matches the commit.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Untested and to state honestly: nginx and PHP versions, the supervisor, the port 80 as non-root decision, peer port reachability, arm64 full stack, and the ruTorrent license.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`.
