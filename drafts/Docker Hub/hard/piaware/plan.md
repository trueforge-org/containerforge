# piaware — implementation plan
> Source: ./draft.md · Target: apps/piaware/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | v11.1 (latest tag of flightaware/piaware, 2026-07-01; draft says v10.0, outdated). dump1090-fa also v11.1 (2026-07-01). No GitHub Releases exist (releases/latest returns 404): tags only. |
| Renovate | datasource=github-tags, depName=flightaware/piaware, versioning=loose (tags are `vX.Y`; use `extractVersion=^v(?<version>.+)$` if needed) |
| License | BSD-2-Clause (piaware README). dump1090-fa is GPL-2.0-or-later (UNVERIFIED) and is installed in the same image, so the combined image license needs review; use `BSD-2-Clause` for APP and document dump1090 separately. |
| Source URL | https://github.com/flightaware/piaware/ |
| Download | Source only. Upstream (sdr-enthusiasts Dockerfile) builds from tags: piaware (`make install`), tcllauncher, piaware-web, dump1090 (`RTLSDR=yes`, outputs dump1090, view1090, faup1090), mlat-client (pip), beast-splitter. Per-arch: compile on the build host, no per-arch URLs. |
| Checksum | None (git tags). |
| Upstream Dockerfile reviewed | https://github.com/sdr-enthusiasts/docker-piaware/blob/main/Dockerfile : base `ghcr.io/sdr-enthusiasts/docker-baseimage:dump978-full` (s6-overlay), EXPOSE 80, 30003, 30005, 30105, 30978, 30979; ENV `S6_BEHAVIOUR_IF_STAGE2_FAILS=2`, `VERBOSE_LOGGING`; no USER set; healthcheck `/scripts/healthcheck.sh`. |
| Ports (upstream image) | 80 web, 30003 SBS, 30005 Beast, 30105 (MLAT), 30978/30979 (UAT). The draft's 8080 is UNVERIFIED and not in upstream. |
| Env vars | UNVERIFIED: the sdr-enthusiasts README env list (FEEDER_ID, LAT, LONG, RECEIVER_TYPE, ...) was not fetched. Do not put any in settings.yaml until read. |

## 2. Target layout

- `apps/piaware/Dockerfile` (multi-stage build)
- `apps/piaware/docker-bake.hcl`
- `apps/piaware/settings.yaml`
- `apps/piaware/container-test.yaml`
- `apps/piaware/start.sh`
- `apps/piaware/etc/` only for generated lighttpd/nginx web config and `piaware.conf` template; `defaults/` for the seeded `piaware.conf`.
No `root/`; no DOWNSTREAM_CHANGES.md.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage; build stage also ubuntu with build-essential. No s6: replace with `start.sh` running a small supervisor (bash `wait -n`). Closest sibling for multi-process: `apps/bookstack` (start.sh with background processes); for compiled-from-source: none exact.

## 4. Dockerfile

1. Build stage `build`: `ARG VERSION`, `apt-get install -y build-essential git tcl-dev tclx8.4-dev itcl3-dev libssl-dev libusb-1.0-0-dev librtlsdr-dev libbladerf-dev libhackrf-dev liblimesuite-dev pkg-config python3-dev python3-venv` (UNVERIFIED exact list; copy from piaware_builder / upstream Dockerfile). Clone tags `v${VERSION}` of piaware, dump1090 (same tag), tcllauncher, piaware-web, mlat-client. Build with `make install DESTDIR=/out`. Set `CCACHE`/caches to /tmp.
2. Final stage: `ARG VERSION`, `ARG TARGETARCH`, `USER root`, apt runtime packages only (tcl, tclx, itcl3, tcl-tls, librtlsdr0, libusb-1.0-0, lighttpd or nginx, python3, netcat-openbsd), pinned where a package equals the app version (none; piaware is built, not apt).
3. `COPY --from=build /out/ /` ; mlat-client into `/app/venv` style location; piaware-web static files to `/app/www`.
4. Licenses: copy piaware LICENSE, dump1090 COPYING and `MLAT-RESULTS-LICENSE.md` to `/usr/share/licenses/piaware/`.
5. `ENV HOME=/config`; `chown -R apps:apps /app`.
6. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8080 30003 30005`; `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "piaware" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=flightaware/piaware versioning=loose
  default = "11.1"
}
variable "LICENSE" { default = "BSD-2-Clause" }
variable "SOURCE" { default = "https://github.com/flightaware/piaware/" }
```
`VERSION` has no `v` prefix; Dockerfile uses `v${VERSION}` in the clone URL. Plus the four standard targets and `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url: "https://github.com/flightaware/piaware/"`.
- ports: `8080` tcp (web UI, our choice, non-root cannot use 80; UNVERIFIED upstream default), `30003` tcp (SBS output, required false), `30005` tcp (Beast, required false).
- env: `TZ` default `Etc/UTC`. Further feeder vars (location, feeder-id, receiver type) UNVERIFIED: add only after reading the upstream README and make start.sh map them to `piaware-config` keys.
- volumes: `/config` required true.
- dependencies: none.

## 7. start.sh

`mkdir -p /config/piaware /tmp/piaware /tmp/run`; `cp -n /defaults/piaware.conf /config/piaware/piaware.conf`; point piaware at the config with `-configfile` (UNVERIFIED flag; upstream writes /etc/piaware.conf which is read-only); start dump1090-fa (`--net --write-json /tmp/run/dump1090`) and the web server on 0.0.0.0:8080, run piaware, supervise with `wait -n`; final `exec` of piaware (`exec piaware -p /tmp/run/piaware.pid -plainlog`; flags UNVERIFIED). With no RTL-SDR device present dump1090 logs errors; start.sh must not crash-loop: if no `/dev/bus/usb` device and no `RECEIVER_HOST`, run only the web server and log that clearly (open question). Feeder claiming is manual after first start.

## 8. container-test.yaml

Schema header; `timeoutSeconds: 120`; `tcp` probes for `8080`, `30003`, `30005` (30003/30005 only open when dump1090 runs, which needs the dongle: UNVERIFIED; if they cannot open without hardware, narrow with a documented reason and keep `http` on 8080); `http: - port: '8080' path: /`; `filePaths`: `/usr/local/bin/dump1090-fa` (UNVERIFIED install path), `/usr/share/licenses/piaware`. Required-env paths are not testable. This is a hardware-dependent app, not a DB one, so the protocol's DB exception does not apply: needs an open decision on hardware-less ports.

## 9. Rootless and read-only-rootfs adaptations

- Draft: root, writable rootfs (TrueCharts). Rootless USB access needs the device group/permissions on the host (`--device /dev/bus/usb`); `apps` user must be able to open it (UNVERIFIED; may need udev rule on host).
- Upstream writes: `/etc/piaware.conf` (-> /config), `/var/cache/piaware` and `/var/run` pid/json (-> /tmp), `/var/log/piaware.log` (-> stdout), lighttpd runtime (-> /tmp), mlat sockets (-> /tmp). piaware normally uses `sudo`/systemd helpers and `piaware-config`; these must be removed or wrapped.

## 10. Risks, caveats and open questions

- Hardware-bound: RTL-SDR USB passthrough required; no hardware means no meaningful run.
- Version drift: draft v10.0 vs latest v11.1; piaware, dump1090, tcllauncher and mlat-client versions must be aligned (UNVERIFIED compatibility matrix).
- Multi-process image without s6; needs a minimal supervisor.
- piaware assumes root/systemd; porting rootless is the largest risk. arm64 claim `yes*` unconfirmed.
- Feeder claiming requires a FlightAware account (manual).
- Multiple licenses (BSD-2, GPL-2+) in one image.
- Env var contract entirely UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/piaware
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name piaware-probe --read-only --tmpfs /tmp \
  -v piaware-probe-config:/config piaware:11.1
docker logs -f piaware-probe
forgetool containers test --image piaware:11.1 --config ./apps/piaware/container-test.yaml
docker rm -f piaware-probe; docker volume rm piaware-probe-config
```
Expected readiness: web server listening on 8080 and piaware logging that it started (exact text UNVERIFIED). Repeat once with `--device /dev/bus/usb` on a host with a dongle.

## 12. PR checklist

- Branch `feat/add-piaware`; commit `feat(piaware): add new container`; PR template filled; Notes contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: whole build, arm64, USB hardware, FlightAware connection/claiming, env contract.
