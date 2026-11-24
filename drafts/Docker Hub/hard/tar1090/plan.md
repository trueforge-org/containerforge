# tar1090 — implementation plan
> Source: ./draft.md · Target: apps/tar1090/ · Difficulty: hard (multi-process, native decoder, optional SDR device) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `3.14.1827` (content of the `version` file on `master`, commit `9e1b6a48dcb7c4104f3f967f808df45e8f53d44c`, 2026-11-21). The repo has no releases and no usable tags (GitHub releases empty). Draft image is `mikenye/tar1090:latest`; its upstream is now `sdr-enthusiasts/docker-tar1090`. |
| Renovate | UNVERIFIED workable option: `datasource=git-refs depName=https://github.com/wiedehopf/tar1090` pinning the commit SHA (renovate tracks the branch head), with the human-readable `3.14.1827` kept in a comment. Alternative: track `sdr-enthusiasts/docker-tar1090` (`datasource=github-releases`, releases 0.1.0 and 0.2.0 were seen, UNVERIFIED which repo owns them). |
| License | tar1090: GPL v2 or later (LICENSE text: "licensed under the GPL, v2 or later"; GitHub reports NOASSERTION) -> `GPL-2.0-or-later`. Decoder `wiedehopf/readsb`: GPL-2.0 per GitHub. |
| Source | https://github.com/wiedehopf/tar1090 |
| Artifacts | No binary releases. `readsb` must be compiled from `wiedehopf/readsb` (draft: compile/compile). UNVERIFIED: readsb tag to pin (no releases found via API). |
| Checksum | Not applicable; source pinned by git commit SHA. |
| Upstream Dockerfile reviewed | `sdr-enthusiasts/docker-tar1090` `Dockerfile` (base `ghcr.io/sdr-enthusiasts/docker-baseimage:wreadsb`, which supplies readsb and s6): installs `nginx-light`, `rrdtool`, `bash-builtins`, `libncurses6`, `jq`, `collectd-core`; runs `tar1090-install.sh`; downloads `aircraft.csv.gz` from tar1090-db; clones graphs1090; `EXPOSE 80/tcp`, no VOLUME, HEALTHCHECK `/healthcheck.sh`. |
| Upstream env vars (from that Dockerfile) | `BEASTPORT=30005`, `MLATPORT=30105`, `TAR1090_NGINX_PORT=80`, `TAR1090_INSTALL_DIR=/usr/local/share/tar1090`, `TAR1090_UPDATE_DIR=/var/globe_history/tar1090-update`, `INTERVAL=8`, `HISTORY_SIZE=450`, `ENABLE_978=no`, `GZIP_LVL=3`, `CHUNK_SIZE=60`, `INT_978=1`, `PTRACKS=8`, `UPDATE_TAR1090=true`, `HTTP_ACCESS_LOG=false`, `HTTP_ERROR_LOG=true`. |
| tar1090 own paths | `/etc/default/tar1090` (interval, history size), `/etc/default/readsb`, `html/config.js`, `/usr/local/share/tar1090` (HTML + `aircraft.csv.gz`), `/var/globe_history` (history, must be writable), `/run/readsb` (aircraft.json). Web server: lighttpd or nginx. |
| Ports | 80/http web UI (upstream; moved to 8080). BEAST 30005 and MLAT 30105 are readsb network outputs, only opened when readsb is configured to. |

## 2. Target layout

```
apps/tar1090/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/nginx/tar1090.conf    # nginx server on 8080 serving html + /data -> /tmp/run
  defaults/config.js        # tar1090 html config seeded to /config when missing
```
No root/. No DOWNSTREAM_CHANGES.md.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (tar1090 is a static HTML app plus JSON served by nginx). Builder: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder` for compiling readsb. Closest sibling: `apps/it-tools` (builder + nginx final) combined with `apps/valkey` for apt package pinning.

## 4. Dockerfile

1. Builder: `ARG VERSION` (3.14.1827 label) and `ARG TAR1090_REF` (commit SHA), `USER root`, apt `build-essential git pkg-config librtlsdr-dev libusb-1.0-0-dev libncurses-dev zlib1g-dev libzstd-dev`. Clone `wiedehopf/readsb` at a pinned ref, `make RTLSDR=yes -j"$(nproc)"`; the exact make flags are UNVERIFIED, check the readsb README.
2. Fetch tar1090: `ADD https://github.com/wiedehopf/tar1090.git#${TAR1090_REF} /src`; download `aircraft.csv.gz` from `wiedehopf/tar1090-db` (branch `csv`) at build time (UNVERIFIED URL; upstream does it with `gzip -t` check) into the html dir.
3. Final: `USER root`, apt `librtlsdr0 libusb-1.0-0 libncurses6 libzstd1 jq` (only those missing in the nginx base; pin none unless version-defining). `COPY --from=builder /src/readsb/readsb /usr/local/bin/readsb`; `COPY --from=builder /src/html /app/tar1090/html`; `COPY --from=builder /src/tar1090.sh /app/tar1090/tar1090.sh`.
4. Licenses: `/usr/share/licenses/tar1090/` with tar1090 `LICENSE` and readsb `LICENSE`.
5. `ENV HOME=/tmp`, `EXPOSE 8080`, `VOLUME /config`, `COPY --chmod=0755 . /`, then final `USER apps` and `COPY --chmod=0755 . /`.
6. Without the s6 base image, process supervision is done by start.sh (see section 7); no s6, collectd, graphs1090 or timelapse1090 in this version.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "tar1090" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/wiedehopf/tar1090 versioning=loose
  default = "9e1b6a48dcb7c4104f3f967f808df45e8f53d44c"
}
variable "LICENSE" { default = "GPL-2.0-or-later" }
variable "SOURCE"  { default = "https://github.com/wiedehopf/tar1090" }
```
Image tag from a SHA is ugly; alternative is `VERSION = "3.14.1827"` with a second variable `TAR1090_REF` carrying the renovate comment and passed as an extra arg. Choose the second if the maintainers want a semver tag. Standard four targets plus `group "default"`. `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`, `upstream_env_url: "https://github.com/wiedehopf/tar1090"`.
- ports: `8080` tcp `required: false` (web UI). Do not list 30005/30105 unless readsb is configured to open them by default (plan: off by default, enabled via `READSB_NET_BEAST_OUTPUT_PORT`-style vars is UNVERIFIED, so not listed).
- env (only those start.sh implements): `TZ` `Etc/UTC`; `INTERVAL` `8`; `HISTORY_SIZE` `450`; `READSB_EXTRA_ARGS` `""`; `READSB_NET_CONNECTOR` `""` (host,port,beast_in of an existing feeder; empty means no input); `READSB_DEVICE_TYPE` `""` (set to `rtlsdr` when a device is passed through). All required false. (`INTERVAL` and `HISTORY_SIZE` names are taken from upstream docker env; `READSB_*` names are plan-local wrappers and must be mapped to real readsb flags `--net-connector`, `--device-type` in start.sh.)
- volumes: `/config` required true.
- dependencies: none.

## 7. start.sh

- `set -euo pipefail`; `mkdir -p /config/globe_history /tmp/run/readsb /tmp/run/tar1090 /tmp/nginx-temp`; seed `/config/config.js` from `/defaults/config.js` only if missing; link or `alias` it in nginx.
- Start `readsb --net --write-json /tmp/run/readsb --write-globe-history /config/globe_history --net-api-port 0` plus `--net-connector "$READSB_NET_CONNECTOR"` or `--device-type "$READSB_DEVICE_TYPE"` when set (flag names UNVERIFIED against the pinned readsb help output). Without input it idles and serves an empty map.
- Start the history writer `tar1090.sh /tmp/run/tar1090 /tmp/run/readsb` in the background (UNVERIFIED argument order; read the script header), with `INTERVAL`, `HISTORY_SIZE` exported.
- Final `exec nginx -c /config/nginx.conf -g 'daemon off;'` listening on `0.0.0.0:8080`; use `trap` to kill background children on exit.
- Everything idempotent; nothing written to `/app`; scratch in `/tmp/run`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
http:
- port: '8080'
  path: /
filePaths:
- /usr/local/bin/readsb
- /app/tar1090/html/index.html
```
8080 is the only port listed in settings. SDR/network-input paths need env or a device and are tested by hand per the protocol.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `/run/readsb`, `/var/globe_history`, `/usr/local/share/tar1090` (install dir, updated at runtime when `UPDATE_TAR1090=true`), nginx and collectd paths, `/etc/default/*`. Remap: run dirs -> `/tmp/run`; globe history -> `/config/globe_history` (persistent); html install dir stays read-only in `/app/tar1090/html` with `config.js` served from `/config`; `UPDATE_TAR1090` is not supported (image is immutable).
- Draft chart: root, writable rootfs, no declared SDR device. Here: `USER apps`, no privileged. SDR use needs `--device /dev/bus/usb` and host udev rules; the `apps` user must be in a group with access to the device (UNVERIFIED how the host maps this).
- No extra persistence beyond `/config` (history optional).

## 10. Risks, caveats and open questions

- Renovate cannot follow versions (no tags/releases); either SHA tracking or a custom regex on `version`.
- Exact readsb build flags, tar1090.sh arguments and readsb option names are UNVERIFIED and must be read from the repos during implementation.
- Aircraft DB download at build time needs network; upstream does it at build and at runtime.
- Without an SDR or feeder the map is empty; tests only prove the web server.
- Multi-process in one container with a hand-rolled supervisor; any child dying should stop the container (trap + `wait -n`).
- graphs1090, timelapse1090 and MLAT/BEAST ports are out of scope for v1.
- No musl or GPU blocker; USB device passthrough is runtime only. arm64 compiles natively.

## 11. Build and test steps

```sh
cd apps/tar1090
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tar1090-probe --read-only --tmpfs /tmp -v tar1090-probe-config:/config tar1090:9e1b6a48dcb7c4104f3f967f808df45e8f53d44c
docker logs -f tar1090-probe
forgetool containers test --image tar1090:<version> --config ./apps/tar1090/container-test.yaml
docker rm -f tar1090-probe; docker volume rm tar1090-probe-config
```
Expected: readsb and nginx both running (no `exited` message), `curl -f localhost:8080/` returns the tar1090 page, `curl -f localhost:8080/data/aircraft.json` returns JSON (path UNVERIFIED).

## 12. PR checklist

- Branch `feat/add-tar1090`; commit and PR title `feat(tar1090): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested (planning only): readsb build, start.sh process handling, SDR access, arm64, renovate tracking. Do not tick "Built container locally" unless done.
