# codeproject-ai-server — implementation plan
> Source: ./draft.md · Target: apps/codeproject-ai-server/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Docker Hub newest is `2.9.7` (2024-12-16, amd64 CPU, cuda11_8/cuda12_2, arm64, rpi64). The draft chart uses `cpu-2.6.5`. GitHub releases newest is `v2.9.5`. The project looks inactive since Dec 2024. Native installers on the CDN: x64 `2.9.5` exists, x64 `2.9.7` returns 404, arm64 `2.9.5` and `2.9.7` exist. So the x64 and arm64 versions cannot be aligned at 2.9.7. Plan pins `2.9.5` (both arches exist). |
| Renovate | `datasource=github-releases depName=codeproject/CodeProject.AI-Server versioning=loose` (tags are `v2.9.5`; strip the `v` when downloading). |
| License | `SSPL-1.0` (Server Side Public License v1, `LICENCE.md` inside the deb and the README SSPL badge). It is not an OSI license; note in the PR. |
| Source | https://github.com/codeproject/CodeProject.AI-Server |
| Download URLs | amd64: `https://codeproject-ai-bunny.b-cdn.net/server/installers/linux/codeproject.ai-server_${VERSION}_Ubuntu_x64.zip` (28,664,456 bytes for 2.9.5); arm64: `.../codeproject.ai-server_${VERSION}_Ubuntu_arm64.zip` (26,154,732 bytes for 2.9.5). Each zip holds one `codeproject.ai-server_${VERSION}_Ubuntu_<arch>.deb` (control `Architecture: all`, so the deb is the same managed .NET payload; only the arch differs by the zip). The docs page gives no direct URLs: these are the CDN URLs from the vendor downloads page (forum-confirmed pattern), verified with HTTP 200 on 2026-11-23. |
| Checksum | None published. Pin a sha256 of each zip at implementation time (UNVERIFIED value). |
| Deb contents (inspected for 2.9.5 x64) | `/usr/bin/codeproject.ai-server-2.9.5/{server,SDK,devops,scripts,runtimes,modules,models,downloads,setup.sh,start.sh,uninstall.sh,.env,LICENCE.md,codeproject.ai-server.service}`. `server/CodeProject.AI.Server.dll` targets `net9.0` (runtimeconfig: `Microsoft.NETCore.App` and `Microsoft.AspNetCore.App` 9.0.0). `start.sh` runs `dotnet CodeProject.AI.Server.dll`. `postinst` runs setup. |
| Upstream Dockerfile | None found in the repo (draft `-`). Docker docs reviewed instead: run `docker run -d -p 32168:32168 codeproject/ai-server`; volumes `/etc/codeproject/ai` (settings) and `/app/modules` (downloaded modules); pre-installed modules at `/app/preinstalled-modules`; custom YOLO models at `/app/preinstalled-modules/ObjectDetectionYolo/custom-models`; no env var is documented on the Docker Hub page or the docs pages fetched (`TZ` is not found in them). |
| Port | `32168` (web dashboard, API, `/explorer.html`). The legacy port 5000 is also opened unless `ServerOptions.DisableLegacyPort` is true (default false in `appsettings.json`). |
| Paths in `appsettings.json` | `ModulesDirPath`, `RuntimesDirPath`, `PreInstalledModulesDirPath`, `DownloadedModulePackagesDirPath` (`%ROOT_PATH%/downloads/modules/packages`), `DownloadedModelsPackagesDirPath` (`%ROOT_PATH%/downloads/models`), logs `logs/` under root. `appsettings.json` marks `InstallPassword` null, `AllowInternetAccess` true. |

## 2. Target layout

```
apps/codeproject-ai-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` needed. Never `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```
Why: the vendor payload is a .NET 9 app plus Python modules that install their own venv/runtimes at runtime; the base has curl, unzip, tar, libicu, libssl. Closest sibling: `apps/webgrabplus` (installs the .NET 9 runtime with `dotnet-install.sh` into `/app/dotnet`). The draft's alternative `python` base is not needed because the server downloads its own python runtimes. If module installs prove to need system Python, add `python3 python3-venv python3-pip` via apt.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. `ENV HOME=/config DOTNET_ROOT=/app/dotnet PATH=/app/dotnet:$PATH DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_RUNNING_IN_CONTAINER=true`, plus the writable-path overrides from section 9.
3. `apt-get install -y --no-install-recommends libicu-dev libgomp1 libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 ffmpeg` (inferred: needed by the vision modules' OpenCV/torch wheels; drop whatever the first run does not need; `libicu`, `libssl3`, `unzip`, `curl` are in the base). No pin because these are not tied to `VERSION`.
4. .NET runtime: `curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && bash /tmp/dotnet-install.sh -c 9.0 --install-dir /app/dotnet --runtime aspnetcore` (the server needs `Microsoft.AspNetCore.App`, which the `--runtime dotnet` used by webgrabplus does NOT include).
5. Server: `case "$TARGETARCH" in amd64) ARCH=x64;; arm64) ARCH=arm64;; esac`; download the zip for `Ubuntu_${ARCH}`, verify the pinned sha256, `unzip`, `dpkg-deb -x *.deb /tmp/cpai`, `mkdir -p /app/server && cp -a /tmp/cpai/usr/bin/codeproject.ai-server-${VERSION}/. /app/server/` (do NOT `dpkg -i`: its postinst runs `setup.sh` which downloads runtimes into `/usr/bin` and expects systemd). Keep `modules/`, `runtimes/`, `downloads/` directories.
6. Licenses: copy `/app/server/LICENCE.md` to `/usr/share/licenses/codeproject-ai-server/LICENCE.md` (SSPL text).
7. Settings dir symlink: `mkdir -p /etc/codeproject && ln -s /config/settings /etc/codeproject/ai` (the symlink target is created by `start.sh`; the link itself is baked into the image so a read-only rootfs is fine).
8. `chown -R apps:apps /app`, cleanup `rm -rf /tmp/* /var/lib/apt/lists/*`; `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 32168`; `VOLUME /config`; `WORKDIR /app/server`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "codeproject-ai-server" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=codeproject/CodeProject.AI-Server versioning=loose
  default = "2.9.5"
}
variable "LICENSE" { default = "SSPL-1.0" }
variable "SOURCE"  { default = "https://github.com/codeproject/CodeProject.AI-Server" }
```
Standard targets as in `apps/adguardhome-sync/docker-bake.hcl` (`image` passes `args.VERSION`; `image-all` amd64 + arm64). Run `docker buildx bake --print`. If `v` prefix leaks into `VERSION` via renovate, strip it in the Dockerfile with `${VERSION#v}`.

## 6. settings.yaml

Header + `schema_version: 1`; `upstream_env_url: "https://github.com/codeproject/CodeProject.AI-Server"`.
- ports: `32168` tcp required; `5000` tcp required: false only if the legacy port is kept open (UNVERIFIED that it listens inside the container; omit it unless confirmed).
- env: no env var is documented upstream (Docker Hub and docs checked); `TZ` (`Etc/UTC`) is kept as a common default, not a documented one. Config can also be overridden with ASP.NET Core env vars (`ModuleOptions__ModulesDirPath`, etc.); list those that `start.sh` sets as defaults: `ASPNETCORE_URLS` (`http://0.0.0.0:32168`), `CPAI_MODULES_DIR` NOT included (invented names are forbidden; only add `ModuleOptions__*` after the run test proves they apply).
- volumes: `/config` required (settings, modules, runtimes, downloads, logs).
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e
mkdir -p /config/settings /config/modules /config/runtimes /config/downloads/modules/packages /config/downloads/models /config/logs
[ -d /config/preinstalled-modules ] || cp -a /app/preinstalled-modules /config/preinstalled-modules 2>/dev/null || true
export ASPNETCORE_URLS="${ASPNETCORE_URLS:-http://0.0.0.0:32168}"
export ModuleOptions__ModulesDirPath=/config/modules
export ModuleOptions__RuntimesDirPath=/config/runtimes
export ModuleOptions__DownloadedModulePackagesDirPath=/config/downloads/modules/packages
export ModuleOptions__DownloadedModelsPackagesDirPath=/config/downloads/models
export TMPDIR=/tmp
cd /app/server
exec /app/dotnet/dotnet CodeProject.AI.Server.dll
```
Idempotent. UNVERIFIED: the `/app/preinstalled-modules` source path (the deb installs modules under `/app/server/modules`; the docs only name `/app/preinstalled-modules` for the Docker image); that the server reads the `ModuleOptions__*` env overrides (standard ASP.NET configuration, `appsettings.json` keys confirmed) and where the logs directory is resolved (`LoggingDir: "logs"` relative to the root). If env overrides are ignored, fall back to a seeded `/config/appsettings.override.json`... only if the server loads it; otherwise this app is blocked for read-only `/app`. Do not use `start.sh` shipped by the vendor (it runs `open` and sleeps).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '32168'
http:
- port: '32168'
  path: /
filePaths:
- /app/server/CodeProject.AI.Server.dll
- /app/dotnet/dotnet
- /usr/share/licenses/codeproject-ai-server/LICENCE.md
```
Use a large `timeoutSeconds` (the server starts modules after a 3 s delay; compare `apps/jellyfin`). No env vars needed. No DB, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

- Upstream write paths: modules, runtimes (python venvs), `downloads/`, `logs/` under the install root (`/app`), settings in `/etc/codeproject/ai` (also `/app/modules` for docker). Remap all to `/config/...` through the `ModuleOptions__*` env overrides and the `/etc/codeproject/ai` symlink; temp to `/tmp`; pip and nuget caches `PIP_CACHE_DIR=/tmp/pip`, `HOME=/config`.
- Module installers run `setup.sh` (which may call `apt`/`sudo`); non-root cannot install OS packages, so only modules that need pip/venv/downloads will work. Pre-bake the default modules' system libs in the Dockerfile.
- Draft: root (UID 0), `readOnlyRootFilesystem false`, extra persistence `/etc/codeproject/ai`, `/app/modules`. Reconcile: UID 568, read-only rootfs, one `/config` volume with symlinks replacing both persistence paths.
- No privileged mode. GPU tags (cuda11_7/cuda12_2) and `rpi64` (privileged, USB Coral) are out of scope.

## 10. Risks, caveats and open questions

- Blocker candidates: (1) whether the server honors path overrides so it never writes to `/app`; (2) module installers needing root/apt; (3) the first start needs internet to download modules (several hundred MB), so the container test (no network guarantees) only proves the server starts.
- Version skew with Docker Hub (`2.9.7` for amd64 only in Docker, native x64 zip only at `2.9.5`). Alternative: copy the app out of `codeproject/ai-server:2.9.7` with `COPY --from=` — rejected because that image is root-based and the Dockerfile is not public.
- SSPL-1.0 is restrictive; call it out in the PR.
- Project appears unmaintained since Dec 2024 (last GitHub release v2.9.5); Python modules pull third-party wheels that age.
- amd64 zip download URL is a vendor CDN, not GitHub; availability risk. No checksum published.
- `dotnet-install.sh` is unpinned downloaded software; pin `--version`/channel (`-c 9.0`) and consider mirroring in the Dockerfile with a checksum.
- Large process tree (server + one process per module) in one container.

## 11. Build and test steps

```sh
cd apps/codeproject-ai-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name codeproject-ai-server-probe --read-only --tmpfs /tmp \
  -v codeproject-ai-server-probe-config:/config codeproject-ai-server:2.9.5
docker logs -f codeproject-ai-server-probe   # expect Kestrel "Now listening on: http://0.0.0.0:32168", "Application started"; module install errors are expected only if offline
forgetool containers test --image codeproject-ai-server:2.9.5 --config ./apps/codeproject-ai-server/container-test.yaml
docker rm -f codeproject-ai-server-probe; docker volume rm codeproject-ai-server-probe-config
```
Confirm in the log that no path under `/app` is written (no "Read-only file system" errors) and that `/config/modules` exists afterwards.

## 12. PR checklist

- Branch `feat/add-codeproject-ai-server`; commit and PR title `feat(codeproject-ai-server): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested list: arm64, env-based path overrides, module install flow (needs internet), GPU variants (not supported), read-only rootfs with module installs, SSPL license suitability.
