# damselfly — implementation plan
> Source: ./draft.md · Target: apps/damselfly/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `4.5.3` is the newest GitHub release and the only recent one with assets (`Server-Dist-linux.zip`, `Server-Dist-windows.zip`; checked via the releases API). `4.6.0` exists only as a tag with no release or assets, and the repo `VERSION` file on master reads `4.5.3`. Plan pins `4.5.3`. No `mcr.microsoft.com` FROM exists in `apps/` yet, so the SDK image digest is UNVERIFIED. |
| Renovate | `datasource=github-releases depName=Webreaper/Damselfly versioning=loose` |
| License | `GPL-3.0-only`. LICENSE is "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007". UNVERIFIED whether "or later" applies; use `GPL-3.0-only` unless a source header says otherwise. |
| Source | https://github.com/Webreaper/Damselfly |
| amd64 asset | `https://github.com/Webreaper/Damselfly/releases/download/4.5.3/Server-Dist-linux.zip` (about 342 MB; built by `scripts/makeserver.sh linux`: `dotnet publish Damselfly.Web.Server -r linux-x64 -f net10.0 -c Release --self-contained true /p:PublishTrimmed=false`). So it is self-contained .NET 10, no separate runtime needed. Contents were not listed (download timed out). |
| arm64 asset | None. The upstream workflow only builds `linux` (= `linux-x64`) server zips, so arm64 must be compiled from source with `-r linux-arm64`. |
| Checksum | None published. Compute and pin `sha256` of the zip at implementation time. |
| Upstream Dockerfile | `Dockerfile` at the draft's commit `e110926` reviewed: `ARG BASE_IMAGE=webreaper/damselfly-base:2.0.1`, WORKDIR `/app`, copies `Models`, `wwwroot/desktop`, `publish/`, `chmod +x Damselfly.Web.Server`, `/damselfly-entrypoint.sh`, `EXPOSE 6363`. The base image's Dockerfile is not in the repo. `Dockerfile-non-alpine` (older .NET 6 file) shows base needs: `procps`, `exiftool`, `libgomp1`, `libgdiplus`, `libc6-dev`, `fontconfig`, MS core fonts (watermarks). |
| Entrypoint (`damselfly-entrypoint.sh`) | `cd /app; ./Damselfly.Web.Server /pictures --config=/config --thumbs=/thumbs ${cmdlineargs}`. Env read by the script: `SYNO_THUMBS` (adds `--syno`), `ONDEMAND_THUMBS` (adds `--nothumbs`), `DAMSELFLY_BLAZORSERVER` (runs `Damselfly.Web` instead). Exports `DOTNET_TieredPGO=1`, `COMPlus_EnableWriteXorExecute=0`. |
| Ports / volumes | `6363` (web UI). Volumes `/config` (database, config), `/thumbs`, `/pictures` (library). |
| Database | Default is SQLite in `/config` (`Damselfly.Migrations.Sqlite` project; official docs mention no external DB or DB env vars). The draft's "needs a PostgreSQL sidecar" is NOT supported by upstream docs. UNVERIFIED whether a Postgres option exists in the settings UI. |
| inotify | Docs: raise `fs.inotify.max_user_instances` on the host for large libraries. |

## 2. Target layout

```
apps/damselfly/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```
Why: self-contained .NET binary only needs native libs (libicu, libssl already in base). Add the image/ML libs listed in section 4. For the arm64 source build use a separate build stage from the .NET SDK image (Microsoft sdk 10.0; copy the exact `FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:...` line from an existing apps/ Dockerfile if one exists, otherwise UNVERIFIED digest: resolve with `docker buildx imagetools inspect`). Closest sibling: `apps/webgrabplus` (.NET on ubuntu) and `apps/adguardhome-sync` (download pattern).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`.
2. Build stage (arm64 only, but declare for both so `COPY --from` works): `FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build`; `ARG VERSION`; download `https://github.com/Webreaper/Damselfly/archive/refs/tags/${VERSION}.tar.gz`, extract, `dotnet workload install wasm-tools` (CI does it for the Blazor WASM client), `dotnet publish Damselfly.Web.Server -r linux-arm64 -f net10.0 -c Release --self-contained true /p:Version=${VERSION} /p:PublishTrimmed=false -o /out`; remove `onnxruntime_providers*.dll`. Set `DOTNET_CLI_HOME=/tmp`, `NUGET_PACKAGES=/tmp/nuget`. For amd64 skip the compile (`if [ "$TARGETARCH" = "amd64" ]; then mkdir /out; fi`) to avoid a slow build.
3. Final stage `FROM` ubuntu above; `USER root`; `ENV HOME=/config DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet DOTNET_TieredPGO=1 COMPlus_EnableWriteXorExecute=0 DOTNET_gcServer=0`.
4. `apt-get install -y --no-install-recommends libgdiplus libgomp1 exiftool procps fontconfig fonts-liberation` (not in base; versions come from the Ubuntu release, not tied to `VERSION`, so no pin needed). UNVERIFIED: whether `libgdiplus` still exists in 26.04; drop it if apt cannot find it and the app does not need it (.NET 10 server uses ImageSharp/Skia; check logs).
5. amd64: `curl -fsSL -o /tmp/damselfly.zip https://github.com/Webreaper/Damselfly/releases/download/${VERSION}/Server-Dist-linux.zip`, verify pinned sha256, `unzip -q /tmp/damselfly.zip -d /app`. arm64: `COPY --from=build /out/ /app/`. Combine in one `RUN` with an `if [ "$TARGETARCH" = "amd64" ]` branch (a `COPY --from` cannot be conditional, so the amd64 build copies the empty `/out`).
6. `chmod +x /app/Damselfly.Web.Server`; ship license: `/usr/share/licenses/damselfly/LICENSE` (from the source tarball or the zip, whichever has it; UNVERIFIED zip contents).
7. `mkdir -p /thumbs /pictures && chown apps:apps /thumbs /pictures`, `rm -rf /tmp/*`, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6363`, `VOLUME /config`, `VOLUME /thumbs`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "damselfly" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Webreaper/Damselfly versioning=loose
  default = "4.5.3"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/Webreaper/Damselfly" }
```
Standard targets as in `apps/adguardhome-sync/docker-bake.hcl` (`docker-metadata-action`, `image` with `args.VERSION`, `image-local`, `image-all` amd64+arm64, `group "default"`). Run `docker buildx bake --print`.

## 6. settings.yaml

Schema header + `schema_version: 1`, `upstream_env_url: "https://github.com/Webreaper/Damselfly"`.
- ports: `6363` tcp, `required: true`.
- env: `SYNO_THUMBS` (default `""`, not required), `ONDEMAND_THUMBS` (default `""`), `DAMSELFLY_BLAZORSERVER` (default `""`), `TZ` (`Etc/UTC`). Only these are read by the upstream entrypoint; `start.sh` must test them the same way (non-empty).
- volumes: `/config` (required), `/thumbs` (required: false), `/pictures` (required: false; the library, can be mounted read-only).
- dependencies: none (no database sidecar needed; SQLite in `/config`).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e
args=()
[ -n "${SYNO_THUMBS:-}" ] && args+=(--syno)
[ -n "${ONDEMAND_THUMBS:-}" ] && args+=(--nothumbs)
mkdir -p /config /thumbs
cd /app
bin=./Damselfly.Web.Server
[ -n "${DAMSELFLY_BLAZORSERVER:-}" ] && bin=./Damselfly.Web
exec "${bin}" /pictures --config=/config --thumbs=/thumbs "${args[@]}"
```
Idempotent; never writes to `/app`. UNVERIFIED: the server binds `0.0.0.0:6363` (default ASP.NET `ASPNETCORE_URLS` set in Dockerfile as `ENV ASPNETCORE_URLS=http://0.0.0.0:6363` if logs show localhost only). The entrypoint also needs `/pictures` to exist; create it in the image so an unmounted start works.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '6363'
http:
- port: '6363'
  path: /
filePaths:
- /app/Damselfly.Web.Server
- /usr/share/licenses/damselfly
```
Use a generous `timeoutSeconds` (copy the largest value from `apps/webgrabplus` or `apps/jellyfin`, .NET siblings), as EF migrations and the ML model load run on first start.

## 9. Rootless and read-only-rootfs adaptations

- Writes: database, logs and settings go to `/config` (`--config=/config`); thumbnails to `/thumbs`; .NET single-file extraction to `/tmp` via `DOTNET_BUNDLE_EXTRACT_BASE_DIR`; NuGet/CLI only at build time.
- Draft expected root (UID 0), no read-only rootfs and persistence `/pictures`, `/thumbs`. Reconcile: run as `apps` (568); `/pictures` is user-mounted and must be readable (writable only if the user wants to edit metadata/keyword writes, which Damselfly can do via exiftool); `/thumbs` needs write access.
- `COMPlus_EnableWriteXorExecute=0` is kept (upstream workaround), which weakens W^X but is needed by their runtime issue.
- No privileged mode, no GPU requirement (ML runs on CPU through ONNX Runtime).

## 10. Risks, caveats and open questions

- Version choice 4.5.3 vs 4.6.0 and the 4.6.0 asset list are UNVERIFIED (assets list failed to load, CI targets .NET 10). The asset name `Server-Dist-linux.zip` conflicts with `scripts/makeserver.sh`, which produces `damselfly-server-linux-<version>.zip`; confirm the 4.5.3 asset name before writing the URL (see context/github-webreaper-damselfly.md).
- arm64 needs a source compile with the .NET 10 SDK plus `wasm-tools` workload; slow, and the native ML dependency (ONNX Runtime, face detection) for linux-arm64 is UNVERIFIED. If it fails, ship amd64 only and set `image-all` to amd64 (document in the PR).
- The 342 MB zip contains `Models`; contents (and whether `wwwroot/desktop` is in the server zip or separate `Desktop-Dist-*.zip`) not inspected. The Docker image adds `wwwroot/desktop` from the desktop zips; optional.
- Upstream's published Docker image is rolling (`latest`); here we pin releases.
- inotify limits are a host sysctl and cannot be fixed inside the container.
- `Damselfly.Web` (Blazor Server variant) selection via `DAMSELFLY_BLAZORSERVER` may not exist in the zip; test or drop the env.

## 11. Build and test steps

```sh
cd apps/damselfly
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name damselfly-probe --read-only --tmpfs /tmp \
  -v damselfly-probe-config:/config -v damselfly-probe-thumbs:/thumbs damselfly:4.5.3
docker logs -f damselfly-probe   # expect "Now listening on: http://[::]:6363" / "Application started", no crash from missing /pictures
forgetool containers test --image damselfly:4.5.3 --config ./apps/damselfly/container-test.yaml
docker rm -f damselfly-probe; docker volume rm damselfly-probe-config damselfly-probe-thumbs
```
Then try arm64 (`--set image-local.platform=linux/arm64`) because it is the risky path.

## 12. PR checklist

- Branch `feat/add-damselfly`; commit and PR title `feat(damselfly): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: arm64 source build, 4.6.0 asset names, libgdiplus availability, read-only rootfs, bind address, ML/face-detection features, real photo scan.
