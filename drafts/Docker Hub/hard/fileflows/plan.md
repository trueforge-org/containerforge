# fileflows — implementation plan
> Source: ./draft.md · Target: apps/fileflows/ · Difficulty: hard (closed source, self-updating .NET app) · Role: main · Verified on 2026-11-24

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `26.11` (Docker Hub tags `26.11`, `latest`, `modded-26.11`, `modded`, pushed 2026-11-22; amd64 and arm64 images). The tarball at `https://fileflows.com/downloads/tarxz` contains `FileFlows.Server/26.11.1.8831` (read from `Server/FileFlows.Server.deps.json`), matching the draft |
| Renovate | The binary has no versioned URL, so Renovate should track the image tags: `// renovate: datasource=docker depName=revenz/fileflows versioning=loose` on `VERSION` (tag form `26.11`, there are also `preview*`, `modded*` tags, so restrict with `extractVersion`/`allowedVersions=/^[0-9]+\.[0-9]+$/` in the renovate config; UNVERIFIED how this repo configures docker datasource filters). The GitHub `revenz/FileFlows` repo returns 404 for API reads (not public), so no github datasource |
| License | Proprietary (closed source, Reven Software, paid license for more than the free tier; license terms are not on the install pages). SPDX `LicenseRef-Proprietary`. UNVERIFIED whether redistribution of the binary in a public registry is allowed; ask the vendor or the user before publishing |
| Source URL | https://fileflows.com/ (no public repo; the draft's `github.com/revenz/FileFlows` is not accessible) |
| Download | `https://fileflows.com/downloads/tarxz` (HTTP 200, 41,449,472 bytes, one portable `.tar.xz`, framework-dependent .NET 10: `Server/FileFlows.Server.runtimeconfig.json` needs `Microsoft.NETCore.App` and `Microsoft.AspNetCore.App` 10.0.0; ships linux-x64 and linux-arm64 native libs, for example `libe_sqlite3.so`). `/downloads/linux` and `/downloads/linux-arm64` return 404. The URL always serves the latest build, so builds are not reproducible after the next release |
| Checksum | None published. Pin the sha256 of the build seen on 2026-11-24: `44d76c2da29d6705b35953a46109deaca74d615b036deea1afdc5ad898134f42` (26.11.1.8831) |
| Upstream Dockerfile | None public (draft: `-`). The docs (`/docs/installation/docker`) give compose `image: revenz/fileflows`, `ports: 19200:5000`, so the container listens on **5000** (draft matches), host default 19200. Docs list: Data Directory, Logs Directory, Temp Path, Browser Start Directory (default `/media`), Common Directory (DockerMods), PUID/PGID, TZ, OIDC settings, NVIDIA (`NVIDIA_*`), AMD, Intel QSV (`/dev/dri`), Docker siblings (socket plus `TempPathHost`) |
| Entry commands (tarball) | `run-server.sh` starts `cd Server && dotnet FileFlows.Server.dll` in the background (docs: no-GUI form is `dotnet FileFlows.Server.dll`). Agent: `Agent/FileFlows.Agent.dll` with `--server <url>` |
| Env vars found in the binaries | `FF_EULA_ACCEPTED`, `FF_URL`, `FF_AGENT_MODE`, `FF_AUTO_UPDATE_INTERVAL`, `FF_IGNORE_CERT_ERRORS`, `FF_LAUNCHER`, `FF_MODDED`, `FF_NO_ENCRYPT`, `FF_PARTNER_API_KEY`, `TempPathHost` (names found by string search in the Server DLLs; meaning of each UNVERIFIED except those named in the docs) |
| Paths found in the binaries | `/app/DockerMods`, `/app/common`, `/app/startup.log`, default browse root `/media`. Draft chart paths `/app/Data`, `/app/Logs`, `/temp`, `/media` |
| ffmpeg | Not bundled. Docs: the Video plugin needs a variable `ffmpeg` pointing to for example `/usr/bin/ffmpeg`; the official image fetches tools via DockerMods at runtime |
| Ubuntu 26.04 packages | `dotnet10` source 10.0.115 (so `dotnet-runtime-10.0` and `aspnetcore-runtime-10.0` binary packages, names UNVERIFIED), `ffmpeg` 7:8.0.1-3ubuntu2 |

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- No `defaults/` (FileFlows creates its own database and config), no `health/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The base already sets `DOTNET_RUNNING_IN_CONTAINER=true`, `HOME=/config`, and adds user `apps` to groups 44 (video) and 107 etc. (GPU device access groups). Closest siblings: `apps/webgrabplus` (.NET app on ubuntu), `apps/jellyfin` (ffmpeg and media), `apps/adguardhome-sync` (download plus layout). The draft's "ffmpeg comes from a sibling container" is wrong: there is no ffmpeg sidecar; ffmpeg must be inside this image.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG FILEFLOWS_SHA256` (default the hash above); `USER root`.
2. apt (not in base; verify): `dotnet-runtime-10.0 aspnetcore-runtime-10.0 ffmpeg`. Also consider `imagemagick` only if the docs require it (the "Modded" docs say ffmpeg and ImageMagick are the two bundled tools; ImageMagick is optional, UNVERIFIED need). `rm -rf /var/lib/apt/lists/*`.
3. Download (the URL is not versioned) with a hard check:
   ```sh
   curl -fL -o /tmp/ff.tar.xz https://fileflows.com/downloads/tarxz
   echo "${FILEFLOWS_SHA256}  /tmp/ff.tar.xz" | sha256sum -c -
   mkdir -p /app/fileflows && tar -xJf /tmp/ff.tar.xz -C /app/fileflows
   grep -q "FileFlows.Server/${VERSION}\." /app/fileflows/Server/FileFlows.Server.deps.json
   ```
   The `grep` proves the tarball is the tagged version (VERSION `26.11` prefix of `26.11.1.8831`).
4. Licensing notices: `mkdir -p /usr/share/licenses/fileflows && cp /app/fileflows/Server/third-party.txt /usr/share/licenses/fileflows/` (the tarball ships `third-party.txt` listing MKVToolNix GPL and others). The vendor EULA is not in the archive (UNVERIFIED), so add a README note.
5. Writable-path remaps as build-time symlinks (so `/app` stays read-only): `ln -s /config/Data /app/fileflows/Data`, `ln -s /config/Logs /app/fileflows/Logs`, `ln -s /config/DockerMods /app/DockerMods`, `ln -s /config/common /app/common` (only after confirming at runtime which of these the server really uses; see section 9). `ln -s /tmp/startup.log /app/startup.log`.
6. `ENV HOME=/config DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet DOTNET_CLI_HOME=/tmp NUGET_PACKAGES=/tmp/nuget DOTNET_EnableDiagnostics=0 ASPNETCORE_URLS=http://0.0.0.0:5000` (port override UNVERIFIED, see section 10).
7. `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
8. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 5000`; `VOLUME /config`; `WORKDIR /app/fileflows/Server`.

## 5. docker-bake.hcl

`APP="fileflows"`; `VERSION` default `26.11` preceded by `// renovate: datasource=docker depName=revenz/fileflows versioning=loose`; `FILEFLOWS_SHA256` default `44d76c2da29d6705b35953a46109deaca74d615b036deea1afdc5ad898134f42` (a renovate bump must also update it; document in a comment); `LICENSE="LicenseRef-Proprietary"` (UNVERIFIED legal status, see section 1); `SOURCE="https://fileflows.com/"`. Standard targets: `docker-metadata-action`, `image` (args `VERSION`, `FILEFLOWS_SHA256`; labels `org.opencontainers.image.source`, `.licenses`), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default" { targets = ["image-local"] }`. Run `docker buildx bake --print`.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url: "https://fileflows.com/"`.
- ports: `5000/tcp required: false` (docs map host 19200 to 5000).
- env (only those the app or `start.sh` read; defaults match `start.sh`): `TZ` default `Etc/UTC`; `FF_EULA_ACCEPTED` default `""` required false (found in the binary, meaning UNVERIFIED, so leave undefined until read from the first-run logs; remove from settings if it is not what the app reads); `FF_AUTO_UPDATE_INTERVAL` UNVERIFIED (likely disables or sets self-update, see section 10); `TempPathHost` only when Docker siblings are used (not supported, omit); `PORT` default `5000` only if `start.sh` implements it. Do NOT list `PUID`/`PGID`: the container runs as fixed UID 568.
- volumes: `/config` required true; `/temp` required false (transcode scratch, only if a user mounts it; default `/tmp`); `/media` required false.
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/Data /config/Logs /config/DockerMods /config/common /tmp/dotnet /tmp/nuget
# ffmpeg location for the Video plugin: variable named "ffmpeg" must be set in the UI (docs).
# Seed on empty /config only; never overwrite existing state.
cd /app/fileflows/Server
exec dotnet FileFlows.Server.dll
```
Notes: idempotent; nothing is written to `/app` except through the symlinks into `/config` and `/tmp`; binds `0.0.0.0` through `ASPNETCORE_URLS` (verify, section 10); secrets: none in env or files. Optionally call the REST API once after first start to pre-create the `ffmpeg` variable (UNVERIFIED, left out).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '5000'
http:
- port: '5000'
  path: /
filePaths:
- /app/fileflows/Server/FileFlows.Server.dll
- /usr/bin/ffmpeg
```
Timeout is large because the first start creates the SQLite database and may unpack plugins. `http /` should return the web UI; if it redirects (EULA or login), switch to the status endpoint seen in the app (UNVERIFIED path, check the first-run logs). The test runs without env vars, so the EULA and OIDC paths are checked by hand (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/app/Data` (database, config) | `/config/Data` via build-time symlink |
| `/app/Logs` | `/config/Logs` (logs are not critical, `/tmp` is acceptable if persistence is not wanted) |
| `/app/DockerMods`, `/app/common` (DockerMods installs tools such as ffmpeg at runtime with root) | `/config/DockerMods`, `/config/common`; DockerMods that need `apt` as root will not work, document that ffmpeg is built in |
| `/app/startup.log` | symlink to `/tmp/startup.log` |
| Temp path `/temp` (flow working files) | `/tmp` default; users mount a large volume at `/temp` and set it in the UI, or mount on `/tmp` |
| Media `/media` | user mounts, must be writable by UID 568 |
| Self-update (`server-upgrade.sh`, `FF_AUTO_UPDATE_INTERVAL`) rewriting `/app` | must be disabled; upgrades happen by image bump |
| .NET single-file extract dir, NuGet | `/tmp` |

Draft expectations versus this plan: TrueCharts runs root, `privileged: true`, `allowPrivilegeEscalation: true`. This plan runs UID 568, not privileged, read-only rootfs. Hardware transcoding needs devices (`/dev/dri` with the render and video groups, or NVIDIA runtime) passed by the orchestrator, not privilege: the base adds `apps` to groups 44 and 107 (video and render are expected there, verify with `getent group`). VAAPI or Intel QSV driver packages (`intel-media-va-driver-non-free`, `mesa-va-drivers`) are NOT installed by this plan, so only software encoding and device pass-through to a host-compatible stack work by default; add driver packages only if the user needs them.

## 10. Risks, caveats and open questions

- Proprietary and closed source: confirm redistribution rights before publishing to `ghcr.io/trueforge-org/`. Upstream already publishes `revenz/fileflows`; the alternative is not to build and to keep using the vendor image.
- Unversioned download URL: the build is only reproducible while the tarball hash matches; after a vendor release the build fails on `sha256sum`, and Renovate must update `FILEFLOWS_SHA256` (needs a custom Renovate regex manager or manual bump). The vendor tarball may be replaced within the same version.
- Docker image tags (stable at the end of each month, `latest` often daily or weekly per docs): `26.11` is the stable tag at verification time; `latest` can be ahead of what the tarball contains.
- The official image behavior for port selection (container 5000 versus tarball default 19200) is UNVERIFIED: the Docker docs map 19200 to 5000, so some container detection or env sets 5000. If `ASPNETCORE_URLS` is not honored, check the first-run log and the strings `ServerPort` in the Server DLLs (found, meaning UNVERIFIED) and `appsettings.json`.
- Where the server stores its data when not in the official image (relative `Data/` next to the DLL, `~/.fileflows`, or `/app/Data`) is UNVERIFIED; the symlinks in section 4 are provisional and must be confirmed by `strace`-free inspection (run the container with `--read-only` and see which path fails) before finalizing.
- Self-update (`FF_AUTO_UPDATE_INTERVAL`, `server-upgrade.sh`) would try to write under `/app`: find the switch that disables it (UNVERIFIED) or confirm it fails harmlessly on a read-only filesystem.
- EULA gate: `FF_EULA_ACCEPTED` exists; the first-run UI may require EULA acceptance, which the container test cannot pass. Decide whether the image should auto-accept (not recommended without the user's consent).
- Draft says "ffmpeg from sibling" (wrong) and "privileged" (not needed).
- Docker siblings mode (socket mount) is not supported on purpose.
- Transcoding needs a large temp area and significant CPU and RAM.
- arm64: the tarball contains linux-arm64 natives; apt .NET and ffmpeg exist for arm64. Untested.

## 11. Build and test steps

```sh
cd apps/fileflows && docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name fileflows-probe --read-only --tmpfs /tmp -v fileflows-probe-config:/config fileflows:26.11
docker logs -f fileflows-probe
forgetool containers test --image fileflows:26.11 --config ./apps/fileflows/container-test.yaml
docker rm -f fileflows-probe; docker volume rm fileflows-probe-config
```
Readiness signal: UNVERIFIED exact line. Expect ASP.NET output such as `Now listening on: http://0.0.0.0:5000` (only if logging is on; `appsettings.json` sets log level `None`, so the log may be silent: then use `curl -fsS http://localhost:5000/` and `ss -ltn`). Then restart the container with the same volume and confirm that state in `/config/Data` persists, that no write to `/app` fails (watch for `Read-only file system`), and that a flow using `/usr/bin/ffmpeg` runs after setting the `ffmpeg` variable. Run once with `--device /dev/dri` if hardware is available (hardware encoding is untested otherwise).

## 12. PR checklist

- Branch `feat/add-fileflows`; commit and PR title `feat(fileflows): add new container`.
- PR template filled in; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Check: VERSION and `ARG VERSION` aligned, tarball hash pinned, renovate comment, `USER apps`, `COPY --chmod=0755 . /`, empty `/config` start, read-only rootfs.
- Say explicitly: license and redistribution not confirmed, EULA handling not decided, port override and data path unverified, hardware encoding untested, arm64 untested, and the self-update behavior unknown until the container is run.
