# nextpvr — implementation plan
> Source: ./draft.md · Target: apps/nextpvr/ · Difficulty: hard (proprietary, redistribution blocked, tuner hardware) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Docker Hub tag `stable` and `7.1.1.260616` (both pushed 2026-06-15, amd64 only). The download `NPVR.zip` is dated 2026-06-16 and carries no version in its name. UNVERIFIED mapping of `7.1.1.260616` to the zip content (the zip's `NextPVRServer.dll` is built 2026-06-16, so they are very likely the same build). |
| Renovate | Not possible for the vendor zip: no tag, no release feed, and the URL is unversioned. The only versioned source is Docker Hub (`datasource=docker depName=nextpvr/nextpvr_amd64`), which is not our download. Use a manual bump, or a Docker datasource comment that tracks the Hub tag only as a version signal. UNVERIFIED which of these the maintainers accept. |
| License | Proprietary (`LICENSE.txt` inside the zip, Pinstripe Limited). Free for personal, non-commercial use only. The terms say you may not "distribute copies of the Software" and may not use it commercially without written permission. SPDX: `LicenseRef-NextPVR-Proprietary`. |
| Source | Closed source. Website https://nextpvr.com, wiki https://github.com/sub3/NextPVR/wiki |
| Download (amd64 and arm64) | `http://nextpvr.com/stable/linux/NPVR.zip` (55,713,392 bytes, last modified 2026-06-15). It is a framework-dependent .NET 8 build (`NextPVRServer.runtimeconfig.json`: `Microsoft.NETCore.App` and `Microsoft.AspNetCore.App` 8.0.0, server GC). The zip includes `DeviceHost/{x64,arm64,arm32}` and `runtimes/*` native libs, so arm64 is technically possible. The draft's "no arm64" is therefore not confirmed by the zip, and has not been tested. UNVERIFIED. sha256 of the file fetched today: `dc3fabfac0135702037298f4320a046c7c2960921bba33329f33f1f93e2ad97d`. Because the URL is unversioned, this value changes on every upstream release. |
| Checksum source | None published. Pin the sha256 in the Dockerfile as an `ARG`, and bump it manually. |
| Upstream Dockerfile | None public. A forum post shows a community Dockerfile on `debian:bullseye` that unpacks `nextpvr-helper.deb` and runs `/opt/dotnet/dotnet /opt/nextpvr/system/NextPVRServer.dll`. The helper deb (v3.2, 4 KB) only depends on `mediainfo libgdiplus ffmpeg libcurl4 libssl3 unzip acl libmediainfo-dev` and recommends `hdhomerun-config dtv-scan-tables libdvbv5-0 dvb-tools`. Its postinst installs a systemd service and `/var/opt/nextpvr` config (not used in Docker). |
| Ports | 8866/tcp (web UI, default login `admin` / `password`). Docker Hub docs also publish `16891/udp` (and `8026/udp` for legacy HDHomeRun with env `HOST_IP`). The chart has a separate UDP service. |
| Official image | `nextpvr/nextpvr_amd64:stable`. Volumes: `/config`, `/recordings`, `/buffer`. |

## 2. Target layout

```
apps/nextpvr/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` is needed unless the first-run config must be pre-seeded (see section 7). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, plus the .NET 8 ASP.NET Core runtime. The apt package `dotnet8` was not found for Ubuntu 26.04 (the Launchpad listing stops at 25.10), so the runtime source is UNVERIFIED: use `aspnetcore-runtime-8.0` from Ubuntu if it exists, or install the runtime from Microsoft's `dotnet-install.sh` into `/usr/share/dotnet` with a verified checksum. There is no `apps/dotnet*` image to reuse. Closest sibling: `apps/tvheadend` (PVR, tuners, ubuntu) and `apps/emby` or `apps/jellyfin` for large vendor installs and `/config`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG NPVR_SHA256`, `USER root`.
2. `apt-get install -y --no-install-recommends ffmpeg mediainfo libmediainfo0v5 libgdiplus libcurl4t64 libssl3t64 unzip acl ca-certificates curl dvb-tools libdvbv5-0 dtv-scan-tables` (dependencies of the helper deb; names on 26.04 are UNVERIFIED, and `libdvbv5-0` and `dvb-tools` are only needed for DVB tuners).
3. Install the .NET 8 `aspnetcore-runtime` into `/usr/share/dotnet` and `ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet`. Set `DOTNET_EnableDiagnostics=0` (avoids writes to `/tmp` pipes) and `DOTNET_gcServer=0` if memory is tight (the app sets `System.GC.Server: true`).
4. `curl -fL -o /tmp/NPVR.zip http://nextpvr.com/stable/linux/NPVR.zip && echo "${NPVR_SHA256}  /tmp/NPVR.zip" | sha256sum -c - && mkdir -p /app/nextpvr && unzip -q /tmp/NPVR.zip -d /app/nextpvr && rm /tmp/NPVR.zip`.
5. License: `install -D /app/nextpvr/LICENSE.txt /usr/share/licenses/nextpvr/LICENSE.txt`.
6. `chown -R apps:apps /app`, `ENV HOME=/config DOTNET_CLI_HOME=/tmp/dotnet DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet-bundle`.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8866`, `EXPOSE 16891/udp`, `VOLUME /config`.

## 5. docker-bake.hcl

- `APP=nextpvr`, `SOURCE=https://nextpvr.com`.
- `LICENSE=LicenseRef-NextPVR-Proprietary`. The `LICENSE` must be the license of the software in the image, so do not claim an open license.
- `VERSION` = `7.1.1.260616` (the Docker Hub tag, see section 1) with `// renovate: datasource=docker depName=nextpvr/nextpvr_amd64 versioning=loose`. Add `NPVR_SHA256`. Both are manual in practice, because the zip is unversioned. Say so in the PR. UNVERIFIED that the Docker tag and the zip stay in sync.
- Standard four targets plus `group "default"`. For `image-all`, drop `linux/arm64` unless the arm64 test in section 10 succeeds. Check with `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://nextpvr.com"`.
- `ports`: `8866` tcp, required false; `16891` udp, required false (from the official run docs; UNVERIFIED which feature uses it).
- `env`: `TZ` (`Etc/UTC`). `HOST_IP` (empty, required false) only for legacy HDHomeRun, as in the official Docker Hub docs. UNVERIFIED that the image reads `TZ`. No other env vars are documented, so do not invent any.
- `volumes`: `/config` required; `/recordings` and `/buffer` `required: false` (from the chart PVCs and the Hub docs).
- `dependencies`: none.

## 7. start.sh

1. `mkdir -p /config /recordings /buffer` where writable, and `export HOME=/config`.
2. UNVERIFIED: how the server finds its data directory (the helper deb uses `/var/opt/nextpvr` and `/etc/nextpvr-server.conf`, the official image uses `/config`). At implementation time, read `NextPVRServer.dll` options and the helper's `nextpvr-server.service` for the real data-dir switch (command line, env or `appsettings.json`) and use that. Do not guess a switch name.
3. Seed `/config` only when empty: copy the zip's `data/` folder (`Config-master-dont-edit.xml`, `empty.db3`, skins, tuning files) from `/app/nextpvr/data` to `/config`, since `/app` is read-only.
4. Server is bound by the app on 8866 (UNVERIFIED that it listens on all interfaces by default; test from outside the container).
5. `cd /app/nextpvr && exec dotnet NextPVRServer.dll` (final command from the community Dockerfile in section 1, with the data-dir switch from step 2 added).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8866'
filePaths:
- /app/nextpvr/NextPVRServer.dll
- /app/nextpvr/NextPVRServer.runtimeconfig.json
- /usr/share/licenses/nextpvr/LICENSE.txt
runners:
- entrypoint: dotnet --list-runtimes
- entrypoint: test -x /usr/bin/ffmpeg
```
The UDP port 16891 has no `tcp` probe type. State this in the file as a comment and keep UDP out of the probes, but the 8866 `tcp` and the file checks cover the app. No DB dependency, so no narrowing. `http` on `/index.html` can be added if it answers 200 without login (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/var/opt/nextpvr` (service config and DB) | `/config` |
| `/home/<user>/recordings`, `/recordings` | `/recordings` volume (user mount, writable by 568) |
| Live TV buffer | `/buffer` volume (large, user mount). Never `/tmp`, because `/tmp` is RAM. |
| .NET extract and diagnostics dirs | `/tmp/dotnet*` |
| `/app/nextpvr/data` (shipped defaults) | read-only source, copied to `/config` once |

Draft expectation: "needs root, TV tuner hardware access". Reconcile: UID 568 (`apps`) with a read-only rootfs is the target. The chart keeps the common default (runAsUser 568, read-only). Network tuners (IPTV, HDHomeRun) work without privilege. Local DVB or ATSC tuners need `/dev/dvb` passed in and the `video` group, which is a deployment setting (`--device /dev/dvb`, supplemental group), not `privileged`. UNVERIFIED: whether the image needs more than that.

## 10. Risks, caveats and open questions

- **Blocker for publishing.** The license forbids distributing copies of the software and commercial use. A public GHCR image would redistribute it. Get the maintainers' written decision (or a permission from Pinstripe Limited) before opening a PR. The upstream project does distribute its own Docker Hub image, so a permission is plausible, but it has not been verified.
- The zip URL is unversioned and changes under us. A fixed checksum makes builds fail after each upstream release until someone bumps `NPVR_SHA256`.
- `http://` (not https) download URL: UNVERIFIED that https works, check before using it. The checksum check protects the integrity either way.
- The .NET 8 runtime source on Ubuntu 26.04 is unresolved.
- arm64: the zip has arm64 device-host code but no one has tested it. Ship amd64 only first, as the draft says.
- Tuner hardware, plus the setup in the web UI (default `admin` / `password` must be changed), are user tasks.
- Recording and buffer volumes can be big. Document.

## 11. Build and test steps

```sh
cd apps/nextpvr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create nextpvr-probe-config
docker run --rm -d --name nextpvr-probe --read-only --tmpfs /tmp -v nextpvr-probe-config:/config nextpvr:7.1.1.260616
docker logs -f nextpvr-probe     # expect the server started and listening on 8866, no repeated crashes
docker rm -f nextpvr-probe; docker volume rm nextpvr-probe-config
forgetool containers test --image nextpvr:7.1.1.260616 --config ./apps/nextpvr/container-test.yaml
```
Check by hand: `curl -I http://localhost:8866/index.html` from another container, and a restart on the same volume keeps the settings.

## 12. PR checklist

- Do not open the PR until the license question in section 10 is answered by the maintainers.
- Branch `feat/add-nextpvr`, commit and PR title `feat(nextpvr): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Put `🤖 This PR is AI generated.` in Notes. Mention the proprietary license there.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- List what is untested: arm64, DVB and ATSC tuner access, the data-dir switch, UDP 16891 behaviour, .NET runtime install on 26.04, and the manual version and checksum bump flow.
- Confirm `bake --print`, version and checksum aligned between bake and Dockerfile, the license file shipped, `USER apps`, and an empty `/config` start.
