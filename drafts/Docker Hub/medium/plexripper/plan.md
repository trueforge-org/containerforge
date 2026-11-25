# plexripper — implementation plan
> Source: ./draft.md · Target: apps/plexripper/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable release is `v0.40.0`, published 2026-10-01 (https://api.github.com/repos/PlexRipper/PlexRipper/releases/latest, same tag at https://api.github.com/repos/Reaparr/Reaparr/releases/latest). The draft's chart image is `0.32.0` (Docker Hub `plexripper/plexripper:0.32.0`, amd64 and arm64 published, https://hub.docker.com/v2/repositories/plexripper/plexripper/tags/0.32.0). The 0.32.0 upstream Dockerfile was fetched and used below; whether v0.40.0 keeps the same Dockerfile is UNVERIFIED. |
| Repository | Draft lists the source as `Reaparr/Reaparr`, but the Dockerfile and the Docker Hub image come from `PlexRipper/PlexRipper`. Both repos return identical v0.40.0 release assets and both are GPL-3.0, not archived (https://api.github.com/repos/PlexRipper/PlexRipper, https://api.github.com/repos/Reaparr/Reaparr). The project appears renamed to Reaparr. Confirm the canonical repo before pinning. |
| Renovate | `datasource=github-releases depName=PlexRipper/PlexRipper versioning=semver` (tags are `v`-prefixed, so `extractVersion` may need `^v(?<version>.*)$`). UNVERIFIED: which of the two repos Renovate should follow. |
| License | GPL-3.0 (GitHub SPDX, https://api.github.com/repos/PlexRipper/PlexRipper). |
| Source URL | https://github.com/PlexRipper/PlexRipper (draft says https://github.com/Reaparr/Reaparr; see above). |
| Binary | None usable. Release assets are desktop bundles only: `Reaparr-linux-x64-stable.AppImage`, `Reaparr-linux-arm64-stable.AppImage`, `.nupkg` for Velopack, and Windows/macOS packages. No server tarball. Build from source. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/PlexRipper/PlexRipper/20248f10085e6c99a83d8329ac271e7e1b31bb23/docker/Dockerfile (summary via WebFetch, byte-for-byte not confirmed). |
| Upstream build stages | `client-build`: `FROM --platform=$BUILDPLATFORM oven/bun:1.1.45-alpine`, `RUN bun install --frozen-lockfile`, `RUN bun run generate --fail-on-error`, env `NUXT_HOST=0.0.0.0`, `NUXT_PORT=${PORT}`, `NUXT_PUBLIC_API_PORT=${PORT}`, `NUXT_PUBLIC_IS_DOCKER=true`. `back-end`: `FROM mcr.microsoft.com/dotnet/sdk:8.0`, `dotnet restore "src/WebAPI/WebAPI.csproj" --locked-mode`, `dotnet build ... -c Release -o /app/build /p:AssemblyVersion=$VERSION /p:InformationalVersion=$INFORMATIONAL_VERSION --no-restore`, `dotnet publish ... -c Release -o /app/publish`. |
| Upstream final stage | `FROM ghcr.io/linuxserver/baseimage-alpine:3.20` (alpine, not usable here). Installs `bash icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib` and ASP.NET Core runtime 8.0.10 via `dotnet-install.sh` into `/usr/share/dotnet`. `ENTRYPOINT ["/init"]` (s6-overlay). |
| .NET version | SDK image `8.0`, runtime `8.0.10`. So the app targets .NET 8 (UNVERIFIED: csproj target framework, not read in this run). |
| Port | `ARG PORT=7000`; `EXPOSE ${PORT}`; `ASPNETCORE_URLS=http://+:${PORT}`, `DOTNET_URLS=http://+:${PORT}`. Draft's 8000 guess is not supported by the Dockerfile. |
| Env vars (from the Dockerfile) | `PORT`, `VERSION`, `INFORMATIONAL_VERSION`, `DOTNET_ENVIRONMENT=Production`, `DOTNET_URLS`, `ASPNETCORE_URLS`, `S6_SERVICES_GRACETIME=15000`, `PATH` addition `/usr/share/dotnet`. Runtime app settings: UNVERIFIED (not in fetched pages). |
| Volumes | `VOLUME /Config /Downloads /Movies /TvShows` (upstream). Our image uses `/config` only, see section 9. |
| Data/config write paths | UNVERIFIED: the in-app config, SQLite/DB and download paths. Upstream only declares the volumes above. |
| User | None in upstream (runs as root). |
| Dependencies | No database service in the upstream Dockerfile. The Plex server connection needs a user-supplied Plex token at runtime (UNVERIFIED in fetched sources; draft inference). |
| apt on Ubuntu 26.04 | UNVERIFIED: whether `dotnet-sdk-8.0` and `aspnetcore-runtime-8.0` exist in the 26.04 archive. `apps/webgrabplus` installs dotnet from the same archive, but 8.0 availability was not checked. |

## 2. Target layout

- `apps/plexripper/Dockerfile`
- `apps/plexripper/docker-bake.hcl`
- `apps/plexripper/settings.yaml`
- `apps/plexripper/container-test.yaml`
- `apps/plexripper/start.sh`

No `defaults/`, `etc/`, `health/`, `root/` needed (the app creates its own state on first start). No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base). Keep the `# yaml-language-server` schema header in `settings.yaml` and `container-test.yaml` as sibling apps do.

## 3. Base image

Build stages and final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Ubuntu base is glibc, which .NET needs, and upstream's alpine base is not used. Closest siblings: `apps/sonarr` (dotnet app on the ubuntu base, `/config` as WORKDIR) and `apps/webgrabplus` (dotnet on the ubuntu base).

Frontend build (bun): upstream uses `oven/bun:1.1.45-alpine` (musl). Use a bun binary on the ubuntu build stage instead, or a glibc bun image (UNVERIFIED: which tag; check it exists before pinning). Node is not needed in the final image.

## 4. Dockerfile

1. Stage `frontend`: `FROM <ubuntu> AS frontend`. Install bun (pinned to `1.1.45` to match upstream; source of the binary and its checksum UNVERIFIED). Copy the repo's frontend subtree, `bun install --frozen-lockfile`, `bun run generate --fail-on-error`. Set `NUXT_HOST=0.0.0.0`, `NUXT_PUBLIC_IS_DOCKER=true`.
2. Stage `backend`: `FROM <ubuntu> AS backend`, `ARG VERSION`, `ARG INFORMATIONAL_VERSION`, `USER root`. Install the .NET 8 SDK (`apt-get install dotnet-sdk-8.0` if the archive has it, otherwise `dotnet-install.sh --channel 8.0` with its checksum or pinned SDK UNVERIFIED). Then `DOTNET_CLI_HOME=/tmp`, `DOTNET_CLI_TELEMETRY_OPTOUT=1`, `DOTNET_NOLOGO=1`, `NUGET_PACKAGES=/tmp/nuget`.
3. Source: `curl -fL https://github.com/PlexRipper/PlexRipper/archive/refs/tags/v${VERSION}.tar.gz`, where `VERSION` is the tag without `v` (bake `0.40.0`, tag `v0.40.0`; confirm the tarball name). Extract with `--strip-components=1` to `/tmp/src`. Put the frontend output where the backend expects it (UNVERIFIED: the upstream Dockerfile copies it, the exact path was not visible in the summary; check the Dockerfile at the pinned tag).
4. `cd /tmp/src && dotnet restore "src/WebAPI/WebAPI.csproj" --locked-mode`, then `dotnet publish "src/WebAPI/WebAPI.csproj" -c Release -o /tmp/publish /p:AssemblyVersion=${VERSION} /p:InformationalVersion=${INFORMATIONAL_VERSION}`.
5. Stage `final`: `FROM <ubuntu>`, `USER root`. Install the ASP.NET Core 8 runtime (`aspnetcore-runtime-8.0` from apt if available, or `dotnet-install.sh --runtime aspnetcore --channel 8.0` into `/usr/local/share/dotnet`, with checksums). Install only packages missing from the base (`libicu-dev` is already there). Clean apt lists.
6. `mkdir -p /app/plexripper`, `COPY --from=backend /tmp/publish/ /app/plexripper/`, copy the frontend build output to the path the backend serves (see step 3). License: `COPY --from=backend /tmp/src/LICENSE /usr/share/licenses/plexripper/LICENSE` (path UNVERIFIED).
7. Remove the Windows/macOS runtime folders if present, as upstream `docker.sh` does for other platforms (UNVERIFIED for PlexRipper).
8. `chown -R root:root /app/plexripper && chmod -R 755 /app/plexripper` (read-only at runtime).
9. `ENV PORT=7000 DOTNET_ENVIRONMENT=Production ASPNETCORE_URLS=http://+:${PORT} DOTNET_URLS=http://+:${PORT} DOTNET_EnableDiagnostics=0 DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp HOME=/config`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 7000
VOLUME /config
WORKDIR /config
```

`ARG VERSION` must equal `docker-bake.hcl` `VERSION` (section 5).

## 5. docker-bake.hcl

- `variable "APP" { default = "plexripper" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=PlexRipper/PlexRipper versioning=semver` and `default = "0.40.0"`. Renovate's `extractVersion` must strip the `v` prefix (see section 1).
- `variable "LICENSE" { default = "GPL-3.0-only" }`. Check the repo's LICENSE file, since GitHub reports `GPL-3.0` (UNVERIFIED: `-only` vs `-or-later`).
- `variable "SOURCE" { default = "https://github.com/PlexRipper/PlexRipper" }`
- `docker-metadata-action`, `group "default"` (targets `image-local`), `image` (args `VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Mirror `apps/sonarr/docker-bake.hcl`.
- Validate with `docker buildx bake --print` from `apps/plexripper`.

## 6. settings.yaml

- Schema header from siblings, `schema_version: 1`, `upstream_env_url: https://github.com/PlexRipper/PlexRipper`.
- `ports`: `port: 7000`, `protocol: tcp` (HTTP UI and API; `http` as the protocol name if the schema uses it, match siblings), `required: true`.
- `env`: `PORT` (default `7000`, required false), `DOTNET_ENVIRONMENT` (default `Production`). Add no other variables until they are confirmed in the app source (section 1 says they are UNVERIFIED).
- `volumes`: `/config` (persistent state; the Dockerfile sets `HOME=/config`).
- `dependencies`: none. Plex is an external service the user configures in the UI.

## 7. start.sh

- `#!/bin/bash` (or sh, matching siblings), `set -euo pipefail`.
- Create `/config/data` (or the path confirmed for the app's DB, UNVERIFIED) only if missing. Do not overwrite existing files.
- Point the app's data directory at `/config` via the config mechanism confirmed for the app (UNVERIFIED). Never write under `/app`.
- Export `ASPNETCORE_URLS` from `PORT` with a default of `7000` so the port matches `settings.yaml`.
- Use `/tmp` for scratch and DOTNET bundle extraction.
- Bind `0.0.0.0` (`http://+:${PORT}` binds all interfaces).
- Final line: `exec dotnet /app/plexripper/PlexRipper.WebAPI.dll` (the assembly name is UNVERIFIED; check the publish output and use its real name).

## 8. container-test.yaml

- Schema header from siblings.
- `tcp` probe on `7000` (every port in `settings.yaml` needs a probe).
- `http` probe on `7000` at `/` (the UI). Use a path confirmed to return 200 after the first start; `/` if unsure (UNVERIFIED).
- `filePaths`: `/app/plexripper/<assembly>.dll` and the frontend entry file, to prove the build ran.
- `timeoutSeconds`: `apps/sonarr/container-test.yaml` sets none, so pick 180 (the most common repo value). A first start may compile or migrate data, so allow headroom.
- The test runs without env vars. The Plex token and server settings are not required to start, so no `filePaths` for required-env paths are expected. Verify in step 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | This plan |
| --- | --- |
| Runs as root (`runAsUser 0`, chart values) | `USER apps`. Chart values are not reused. |
| `readOnlyRootFilesystem: false` | Read-only root works: `/app` is read-only, state under `/config`, scratch under `/tmp` (`DOTNET_BUNDLE_EXTRACT_BASE_DIR`, NuGet, DOTNET_CLI_HOME are build-only). |
| Volumes `/Config /Downloads /Movies /TvShows` | Only `/config`. Downloads and media are external. Use a `/config/downloads` only if the app's setting needs one (UNVERIFIED). Do not add `/Movies`, `/TvShows`. |
| `S6_SERVICES_GRACETIME` and `/init` | Dropped. Use `exec dotnet ...` as PID 1 handoff. |
| linuxserver alpine base | Replaced by `ghcr.io/trueforge-org/ubuntu` (glibc, required by .NET). |

Downloads inside the chart's `/Downloads` PVC are a user concern; they need a writable path the app is told about, not `/app`.

## 10. Risks, caveats and open questions

- Repo mismatch: draft links Reaparr/Reaparr, Dockerfile and image come from PlexRipper/PlexRipper, and the project seems renamed. Confirm the canonical repo before writing `SOURCE`.
- Version gap: chart pins 0.32.0 while latest is v0.40.0. The Dockerfile was reviewed at commit `20248f10085e6c99a83d8329ac271e7e1b31bb23` (for 0.32.0). Re-read the Dockerfile at the v0.40.0 tag before building.
- .NET 8 apt availability on Ubuntu 26.04 is UNVERIFIED. If absent, use `dotnet-install.sh` with a pinned channel and checksum.
- Frontend bun: upstream uses the alpine bun image. A glibc bun is needed for the ubuntu build stage (UNVERIFIED tag and checksum).
- Data path and config keys: upstream does not show where the app writes its DB, config and downloads. Must be confirmed from source (`appsettings`, data directory code) before `start.sh` is final.
- Plex token: needed at runtime, not at start. The test does not cover it.
- arm64: Docker Hub 0.32.0 is published for arm64, but a source build for arm64 is not tested. Use `image-all` only after the amd64 loop is green.
- Build time: .NET restore, bun install and publish make this a slow build (draft caveat, accepted).
- Blockers: none known. No musl-only dependency, no GPU, no privileged need in the upstream Dockerfile.

## 11. Build and test steps

From `apps/plexripper`, per `.github/instructions/build-test-protocol.instructions.md`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run on an empty config volume:
   `docker run --rm -d --name plexripper-probe --read-only --tmpfs /tmp -v plexripper-probe-config:/config plexripper:0.40.0` (the `image-local` tag), then `docker logs -f plexripper-probe`.
   Expected readiness signal: `Now listening on: http://[::]:7000` (or the .NET default line, UNVERIFIED) and the process still running.
4. Cleanup: `docker rm -f plexripper-probe; docker volume rm plexripper-probe-config`.
5. `forgetool containers test --image plexripper:0.40.0 --config ./apps/plexripper/container-test.yaml`.
6. Only if amd64 is green: `image-all` arm64 build (`docker buildx bake --set image-all.platform=linux/arm64 image-all`), noting it as a separate check.

Not run in this planning step.

## 12. PR checklist

- Branch: `feat/add-plexripper`.
- Commit: `feat(plexripper): add new container`.
- PR title: `feat(plexripper): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice: the contributor must sign the CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Honest list of what is untested: anything not built or run locally must be said in the PR, and the arm64 build must be marked untested until it runs.
- Check the chart target (`charts/stable/plexripper`) and its `0.32.0` vs `0.40.0` gap when raising the PR.
