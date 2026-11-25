# airdcpp-webclient — implementation plan
> Source: ./draft.md · Target: apps/airdcpp-webclient/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **2.14.0** (tag `2.14.0`, released 2025-09-07; matches the draft image tag `gangefors/airdcpp-webclient:2.14.0`). Newer tags `2.14.1b` / `2.14.0b` exist but are beta; ignored. |
| Renovate | `datasource=github-tags`, `depName=airdcpp-web/airdcpp-webclient`, `versioning=loose` (GitHub releases API returns the 2.14.0 tag but tags are bare numbers, with `b` suffix betas) |
| License | GPL-2.0-or-later (file headers in `airdcppd/main.cpp`: "version 2 of the License, or (at your option) any later version"). The repo has no LICENSE file and GitHub reports none, so also ship a note. |
| Source | https://github.com/airdcpp-web/airdcpp-webclient |
| amd64 URL (pinned) | https://web-builds.airdcpp.net/stable/airdcpp_2.14.0_webui-2.14.0_64-bit_portable.tar.gz (the draft's `airdcpp_latest_master_64-bit_portable.tar.gz` is byte-identical, 15766706 bytes, but unpinned) |
| arm64 | **No arm64 tarball** (only `32-bit` and `armhf` builds on web-builds.airdcpp.net). Must be compiled with CMake. |
| Checksum | None published. sha256 computed from the download on 2026-11-23: `fe89c40d1bbb11350e5e175f60ca9de325dbc6e5a778024429ba1bdf633bad1a` (amd64 2.14.0 tarball). Pin it in the Dockerfile and update it on every renovate bump. |
| Tarball layout | `airdcpp-webclient/airdcppd`, `airdcpp-webclient/dcppboot.xml` (LocalMode=1, `ConfigPath ./config/`), `airdcpp-webclient/web-resources/` |
| CLI (main.cpp) | `-c=PATH` config dir, `-p=PATH` pid file (default `<cfg>/.airdcppd.pid`), `-d` daemon, `--web-resources=PATH`, `--no-autoconnect`, `--configure`, `--add-user`, `--remove-user` |
| Upstream Dockerfile reviewed | gangefors/docker-airdcpp-webclient: debian + nodejs 24 (nodesource) + the `latest` tarball, `/.airdcpp` config, `/Downloads`, `/Share`, EXPOSE 5600 5601 21248 21249, entrypoint seeds `DCPlusPlus.xml`, `web-server.json`, `web-users.json` when missing |
| Ports | 5600 web UI (http), 5601 web UI (https, needs a certificate), 21248 tcp+udp (ADC transfers / search), 21249 tcp (ADC over TLS) |
| Env vars | None read by airdcppd. Upstream wrapper uses `PUID`, `PGID`, `UMASK`, `LOG_STARTUP`; none apply (UID is fixed to 568). |

## 2. Target layout

```
apps/airdcpp-webclient/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/DCPlusPlus.xml      # first-run settings (ports, download/share dirs)
  defaults/web-server.json     # first-run web server settings
  defaults/web-users.json      # first-run admin user
```
`defaults/` is on the `.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: extensions need Node and upstream uses Node 24; the `python-node` base provides Node (budge's Dockerfile comment indicates Node 24; UNVERIFIED for this tag, check `node --version` at build). The draft's primary base is plain ubuntu with nodejs from apt; if `python-node` is judged too heavy, switch to `ubuntu:26.04@sha256:19cb2cee...6454` and `apt-get install nodejs` (Ubuntu 26.04 nodejs version UNVERIFIED). Closest sibling: `apps/budge` (python-node, prebuilt tarball).

## 4. Dockerfile

Two stages so the arm64 compile does not pollute the runtime layer.

1. `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2cee...6454 AS build-arm64` (only used when `TARGETARCH=arm64`): `apt-get install -y build-essential cmake git nodejs npm libboost-all-dev libssl-dev libcurl4-openssl-dev libsqlite3-dev libbz2-dev zlib1g-dev libicu-dev libminiupnpc-dev libnatpmp-dev libmaxminddb-dev libtbb-dev` (package list inferred from the draft; UNVERIFIED against `CMakeLists.txt`), then `git clone --depth 1 --branch ${VERSION} --recurse-submodules https://github.com/airdcpp-web/airdcpp-webclient /src`, `cmake -DCMAKE_BUILD_TYPE=Release -DINSTALL_WEB_UI=ON -DCMAKE_INSTALL_PREFIX=/out .. && make -j"$(nproc)" && make install`. `INSTALL_WEB_UI` is a real CMake option (default ON; needs npm). UNVERIFIED: submodule layout, exact install layout, build time. Skip the stage on amd64 with a multi-arch-friendly pattern (build the amd64 branch in the final stage via `curl`). UNVERIFIED: a `COPY --from=build-arm64` in the final stage makes BuildKit build that stage on amd64 as well; use a per-arch stage selected through `ARG TARGETARCH` (e.g. `FROM build-${TARGETARCH} AS payload`, with an amd64 stage that downloads the tarball) so amd64 never compiles.
2. Final stage `FROM python-node...`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
3. amd64: `curl -fsSL -o /tmp/airdcpp.tar.gz "https://web-builds.airdcpp.net/stable/airdcpp_${VERSION}_webui-${VERSION}_64-bit_portable.tar.gz"`; `echo "<sha256>  /tmp/airdcpp.tar.gz" | sha256sum -c -`; `mkdir -p /app && tar xzf /tmp/airdcpp.tar.gz -C /app` giving `/app/airdcpp-webclient/`. arm64: `COPY --from=build-arm64 /out/ /app/airdcpp-webclient/` (same final layout: `airdcppd` and `web-resources/`).
4. `mkdir -p /usr/share/licenses/airdcpp-webclient`; write a short NOTICE pointing at the GPL-2.0-or-later headers (no license file exists in the tarball or repo root; UNVERIFIED whether `airdcpp-core` carries a COPYING).
5. `chown -R apps:apps /app && chmod -R 755 /app`; remove `/tmp/*`.
6. `ENV HOME=/config` (comes from base; keep).
7. `USER apps`
8. `COPY --chmod=0755 . /`
9. `EXPOSE 5600 5601 21248 21249`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "airdcpp-webclient" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=airdcpp-web/airdcpp-webclient versioning=loose
  default = "2.14.0"
}
variable "LICENSE" { default = "GPL-2.0-or-later" }
variable "SOURCE"  { default = "https://github.com/airdcpp-web/airdcpp-webclient" }
```
Standard 4 targets + default group as in `apps/adguardhome-sync`. If arm64 compile is dropped, `image-all` platforms must list only `linux/amd64`. Validate with `docker buildx bake --print`. The Dockerfile's checksum ARG must change with every version bump; note this in the Dockerfile as a comment next to the pin.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/airdcpp-web/airdcpp-webclient"`.
- ports: `5600/tcp required: false`. 5601, 21248 and 21249 are not listed: whether they listen at start (and without a TLS certificate for 5601) is UNVERIFIED; add them here together with a probe if `ss -ltn` shows them open in the run step.
- env: `TZ` default `"Etc/UTC"` required false (only var; airdcppd reads none of its own).
- volumes: `/config` required true (settings, queue, share cache). Optional `/downloads` and `/share` are plain mount points; defaults point at `/config/Downloads` and `/config/Share`, so they are not required.
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config /config/Downloads /config/Share
for f in DCPlusPlus.xml web-server.json web-users.json; do
  [[ -s /config/$f ]] || cp /defaults/$f /config/$f
done
exec /app/airdcpp-webclient/airdcppd -c=/config \
  --web-resources=/app/airdcpp-webclient/web-resources
```
- Seeds only missing files; never overwrites user state.
- `defaults/DCPlusPlus.xml` (modelled on the upstream seed): `DownloadDirectory /config/Downloads/`, `InPort`/`UDPPort` 21248, `TLSPort` 21249, `AutoDetectIncomingConnection 0`, share `Default` pointing at `/config/Share/`. `defaults/web-server.json`: `{"settings": null, "version": 1}` as upstream (web server then defaults to 5600/5601, UNVERIFIED which interface it binds; check it listens on 0.0.0.0).
- `defaults/web-users.json`: seed the upstream default admin user (hash taken from the upstream repo). Document that the default credentials are weak and must be changed immediately; users can run `airdcppd --add-user` against `/config` (flag verified in `main.cpp`).
- `airdcppd` stays in the foreground (no `-d`), `exec` so signals propagate. No writes to `/app`; pid file lands in `/config/.airdcppd.pid`.
- Because the tarball ships `dcppboot.xml` with LocalMode=1 and `ConfigPath ./config/`, `-c=/config` must override it. UNVERIFIED: if temp/cache paths still resolve under `/app/airdcpp-webclient/`, delete `dcppboot.xml` in the Dockerfile and rely on `HOME=/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240

http:
- port: '5600'
  path: /

filePaths:
- /app/airdcpp-webclient/airdcppd
- /defaults/DCPlusPlus.xml
```
One probe per port in section 6 (5600). The root path may redirect to a login page, adjust `statusCode` if the run step shows something other than 200 (UNVERIFIED). Add tcp probes for 21248/21249 if they are added to `settings.yaml`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/.airdcpp` (config, queue, hashes) | `/config` (`-c=/config`) |
| `/Downloads`, `/Share` | `/config/Downloads`, `/config/Share`; users may mount over them |
| `<app>/config/` from `dcppboot.xml` (portable mode) | overridden by `-c=/config`; fallback: delete `dcppboot.xml` |
| temp/share cache | UNVERIFIED; expect under the config dir; if not, set `TempPath` to `/tmp` through `dcppboot.xml` |
| `chown`/`runuser` from the upstream entrypoint | not needed, container already runs as UID 568 |

Draft expectations (non-root 568, read-only rootfs, config volume `/.airdcpp`) hold: persistent data only in `/config`.

## 10. Risks, caveats and open questions

- arm64 has no vendor tarball; CMake compile is slow, needs Boost and many dev libs, and is UNVERIFIED end to end. Fallback: ship amd64 only and restrict `image-all` to `linux/amd64`. Decide before implementation.
- No published checksum; the sha256 in the Dockerfile is self-computed and must be refreshed on each bump (renovate cannot do this automatically).
- The portable tarball ships the web UI together with the daemon; the `latest` URL is unpinned, so this plan uses the versioned URL.
- Default admin credentials must be changed; the web UI listens without TLS unless a certificate is configured (port 5601).
- Active-mode transfers need 21248 tcp/udp and 21249 forwarded by the user; not testable in CI.
- Node for extensions: version of Node in `python-node` unverified against what airdcpp expects (upstream uses Node 24).
- No license file in the artifacts; license taken from source headers.

## 11. Build and test steps

```sh
cd apps/airdcpp-webclient
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name airdcpp-webclient-probe --read-only --tmpfs /tmp \
  -v airdcpp-webclient-probe-config:/config airdcpp-webclient:2.14.0
docker logs -f airdcpp-webclient-probe
forgetool containers test --image airdcpp-webclient:2.14.0 --config ./apps/airdcpp-webclient/container-test.yaml
docker rm -f airdcpp-webclient-probe; docker volume rm airdcpp-webclient-probe-config
```
Also run `docker exec airdcpp-webclient-probe ss -ltn` to see which ports listen. Expected readiness: daemon log lines about the web server starting and port 5600 open. Only attempt arm64 if the compile stage is kept.

## 12. PR checklist

- Branch `feat/add-airdcpp-webclient`; commit and PR title `feat(airdcpp-webclient): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; Notes contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: arm64 compile, default admin login, active transfers, extensions, whether 21248/21249 listen at start.
- Check "Built container locally" only if it was built.
