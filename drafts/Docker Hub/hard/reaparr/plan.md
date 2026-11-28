# reaparr — implementation plan
> Source: ./draft.md · Target: apps/reaparr/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `v0.40.0` (GitHub release published 2026-10-01); draft tag `0.40.0` matches. |
| Renovate | `datasource=github-releases depName=Reaparr/Reaparr versioning=semver` (tag has a `v` prefix; Renovate strips it) |
| License | GPL-3.0 (shown on the repository page). Use `GPL-3.0-only` unless the LICENSE header says "or later" (UNVERIFIED). |
| Source URL | https://github.com/Reaparr/Reaparr/ |
| Download URLs | Source tarball: `https://github.com/Reaparr/Reaparr/archive/refs/tags/v${VERSION}.tar.gz` (compiled from source, same for both arches). Release assets (Velopack `.nupkg`, `.AppImage`, Windows/macOS) are desktop packages and are not used. |
| Checksum source | None for the tarball. UNVERIFIED: pin a sha256 `ARG` at port time. |
| Upstream Dockerfile | Reviewed `Reaparr/Reaparr` @1e32ea5 `docker/Dockerfile`. Stages: `oven/bun:1.4.0-alpine` (Nuxt: `bun install --frozen-lockfile`, `bun run generate --fail-on-error`); `mcr.microsoft.com/dotnet/sdk:10.0` (`dotnet restore --locked-mode`, `dotnet publish AppHost.csproj -c Release -r linux-x64|linux-arm64 -p:ReaparrRuntimeMode=docker -p:UseAppHost=false -p:CSharpier_Bypass=true -o /app/publish`); `dotnet/aspnet:10.0-alpine3.22` runtime donor; ubuntu 24.04 donor for glibc 2.39 (for `dash-mpd-cli`); `alpine:3.22` builds static MP4Box from GPAC; final `ghcr.io/linuxserver/baseimage-alpine:3.22` with s6-overlay 3.2.1.0. Runtime apk: bash icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib ffmpeg mkvtoolnix. |
| Upstream env | `PORT` (build arg, default 7000), `DOTNET_URLS=http://+:${PORT}`, `DOTNET_ENVIRONMENT=Production`, `REAPARR_PLATFORM=docker`, `UMASK=002`, `S6_SERVICES_GRACETIME`. Build-only: `VERSION`, `INFORMATIONAL_VERSION`, `NUXT_*`. |
| Ports | 7000/tcp (EXPOSE `${PORT}`). The draft guessed 8080. |
| Volumes | `/Config`, `/Downloads`, `/Movies`, `/TvShows` (capitalised). |
| Not verified | Whether `dash-mpd-cli` is bundled in the repo or downloaded; any health endpoint; whether paths `/Config` etc. are hard-coded by `ReaparrRuntimeMode=docker` (UNVERIFIED). |

## 2. Target layout

```
apps/reaparr/
  Dockerfile        # multi-stage: bun, dotnet sdk, ubuntu runtime
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh          # creates dirs, exec dotnet
```
No `defaults/` unless a seed config is needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Build stages use upstream's own build images (frontend `oven/bun:1.4.0` Debian variant not Alpine, backend `mcr.microsoft.com/dotnet/sdk:10.0`) pinned by digest at port time (UNVERIFIED digests and the existence of the non-alpine bun tag). Fits because the final image only needs the ASP.NET runtime and media tools, and ubuntu is glibc, which removes upstream's glibc-donor hack. Closest siblings: `apps/jackett` (dotnet binary on ubuntu), `apps/kasmvnc` (multi-stage with a node build).

## 4. Dockerfile

1. Stage `client`: `FROM oven/bun:<1.4.0 glibc tag>@sha256:<digest> AS client`; download and extract the source tarball (checksum verified); `cd` to the client dir, `bun install --frozen-lockfile`, `NUXT_PUBLIC_PLATFORM=docker NUXT_PUBLIC_VERSION=${VERSION} bun run generate --fail-on-error` (UNVERIFIED client dir name and full env; copy from upstream Dockerfile when porting).
2. Stage `server`: `FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:<digest> AS server`; `ARG TARGETARCH`; map `amd64 -> linux-x64`, `arm64 -> linux-arm64`; `dotnet restore --locked-mode`; `dotnet publish AppHost.csproj -c Release -r "$RID" -p:ReaparrRuntimeMode=docker -p:UseAppHost=false -p:CSharpier_Bypass=true -p:Version=${VERSION} -o /out`; copy the generated client into `/out/wwwroot`.
3. Runtime stage `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
4. .NET runtime: `COPY --from=mcr.microsoft.com/dotnet/aspnet:10.0@sha256:<digest> /usr/share/dotnet /usr/share/dotnet` plus `ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet` (UNVERIFIED alternative: apt `aspnetcore-runtime-10.0` on 26.04; choose apt if present and version matches the SDK used).
5. apt (verify names with `apt-cache` on 26.04, pin not required for helpers): `ffmpeg mkvtoolnix gpac libicu-dev` (use the exact libicu runtime package name; UNVERIFIED) `libssl3t64 libkrb5-3`. `gpac` provides `MP4Box`; this replaces upstream's static GPAC build. Do not install `bash`/`ca-certificates` if the base already has them.
6. `COPY --from=server /out /app` and `chmod -R a+rX /app`.
7. `dash-mpd-cli`: if upstream bundles or downloads it, replicate with its own checksum (UNVERIFIED; check the publish output and Dockerfile `RUN` steps).
8. Licence: `mkdir -p /usr/share/licenses/reaparr && cp /app/LICENSE* ...` (copy LICENSE from the source tarball in the `server` stage).
9. Compatibility symlinks (root): `ln -s /config /Config` and create `/Downloads`, `/Movies`, `/TvShows` as symlinks to `/config/Downloads` etc. only if the app hard-codes them (UNVERIFIED); prefer a start.sh `ln` where the rootfs is writable? It is not, so create the links in the image.
10. `ENV DOTNET_ENVIRONMENT=Production REAPARR_PLATFORM=docker DOTNET_URLS=http://+:7000 DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet DOTNET_CLI_HOME=/tmp HOME=/config DOTNET_gcServer=0`.
11. `USER apps`
12. `COPY --chmod=0755 . /`
13. `EXPOSE 7000`, `VOLUME /config`, `WORKDIR /app`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "reaparr" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Reaparr/Reaparr versioning=semver
  default = "0.40.0"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/Reaparr/Reaparr/" }
```
Standard `docker-metadata-action`, `image` (args `VERSION`, OCI labels), `image-local`, `image-all` (amd64+arm64) and `group "default"`, as in `apps/adguardhome-sync`. Also add `// renovate:` comments for bun and the dotnet image if they are parameterised via `ARG` (e.g. `datasource=docker depName=oven/bun`). `docker buildx bake --print` before commit.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Reaparr/Reaparr/"
ports:
  - port: 7000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: DOTNET_URLS
    default: "http://+:7000"
    required: false
volumes:
  - path: /config
    required: true
  - path: /Downloads
    required: false
  - path: /Movies
    required: false
  - path: /TvShows
    required: false
dependencies: []
```
The media volumes keep upstream's capitalised paths so existing mounts keep working; if `start.sh` links `/Config` to `/config`, only `/config` is the persistent volume. Optional peers (plex, sonarr, radarr exist in `apps/`) are configured in the UI.

## 7. start.sh

- `set -euo pipefail`.
- `mkdir -p /config/{logs,db}` (UNVERIFIED subfolders; create only what the app expects, determined by a run with `/Config` empty).
- Never write to `/app` (read-only). Temp, `DOTNET_*` caches to `/tmp`.
- If `/Downloads`, `/Movies`, `/TvShows` mounts are absent, create under `/config` fallback links only when not present (skip if writable rootfs unavailable, rely on image symlinks).
- Env defaults: `export DOTNET_URLS="${DOTNET_URLS:-http://+:7000}"`, `export ASPNETCORE_URLS` is not set. Listen on all interfaces (`+`).
- `cd /app && exec dotnet /app/AppHost.dll` (UNVERIFIED entrypoint DLL name; read the publish output).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '7000'
filePaths:
- /start.sh
- /app/AppHost.dll
- /usr/bin/ffmpeg
- /usr/bin/MP4Box
- /usr/bin/mkvmerge
- /usr/share/licenses/reaparr
```
Upgrade the 7000 probe to `http` on `/` only after confirming a 200 response; no health endpoint was verified. No env var is required.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Remap |
|---|---|
| s6-overlay init as root, app as `abc` via `s6-setuidgid`, `UMASK=002` | Removed; run as `apps`, `umask 002` in start.sh. |
| `/Config` (capital C) | `/config` canonical, `/Config` compatibility symlink in the image. UNVERIFIED that the app honours the link. |
| `/Downloads`, `/Movies`, `/TvShows` | Optional mounts, same paths. |
| .NET single-file extraction/temp, NuGet | `DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet`, `DOTNET_CLI_HOME=/tmp`. |
| Draft: UID 0, writable rootfs | Not followed; non-root, read-only rootfs. Mounted media dirs must be writable by the `apps` UID. |

## 10. Risks, caveats and open questions

- Large build: bun + dotnet restore in `--locked-mode`, per-arch RID; expect long builds and several build/fix rounds.
- `dash-mpd-cli` and the glibc 2.39 donor: Ubuntu 26.04 has glibc 2.43 so the donor should be unnecessary, but `dash-mpd-cli` origin is UNVERIFIED.
- Lockfile or .NET SDK 10 tag drift: pin SDK and runtime by digest.
- No release asset or checksum for the source tarball.
- Capitalised paths may be hard-coded in `ReaparrRuntimeMode=docker`.
- Draft port guess 8080 is wrong (7000).
- UNVERIFIED count: 10.

## 11. Build and test steps

```sh
cd apps/reaparr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create reaparr-probe-config
docker run --rm -d --name reaparr-probe --read-only --tmpfs /tmp \
  -v reaparr-probe-config:/config reaparr:<version>
docker logs -f reaparr-probe   # expect an ASP.NET "Now listening on: http://[::]:7000" line and "Application started"
docker rm -f reaparr-probe; docker volume rm reaparr-probe-config
forgetool containers test --image reaparr:<version> --config ./apps/reaparr/container-test.yaml
```
Then `curl` the UI from another container, restart on the same volume and confirm settings persist. Try arm64 only if the amd64 loop is clean.

## 12. PR checklist

- Branch `feat/add-reaparr`; commit and PR title `feat(reaparr): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: anything not actually run, in particular both arch builds, the `/Config` path behaviour, media helper tools and the dash-mpd-cli path.
