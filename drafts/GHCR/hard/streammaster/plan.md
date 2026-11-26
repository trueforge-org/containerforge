# streammaster — implementation plan
> Source: ./draft.md · Target: apps/streammaster/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest GitHub release v0.15.0, published 2025-05-24, source-only (https://api.github.com/repos/carlreid/StreamMaster/releases/latest). Chart pins `ghcr.io/carlreid/streammaster:0.15.0`. |
| Renovate | `datasource=github-releases depName=carlreid/StreamMaster versioning=semver`. The tag has a `v` prefix. |
| License | MIT (GitHub API, https://api.github.com/repos/carlreid/StreamMaster). |
| Source URL | https://github.com/carlreid/StreamMaster |
| Download | No release binary (only `CHANGELOG.md` is a release asset). Build from the source tarball `https://github.com/carlreid/StreamMaster/archive/refs/tags/${VERSION}.tar.gz`, compiled per architecture with `dotnet publish -a $TARGETARCH`. |
| Checksum source | None published. The tarball is pinned by tag; record the tag's commit SHA in the PR and check it with `git ls-remote` or the API. |
| Upstream Dockerfile reviewed | `Dockerfile.template` (at a8f8f6cda65138226ea2cfe73c5dd0db3a040c88, via gh api): `WORKDIR /app`, `RUN mkdir /config`, `ENV PUID=0 PGID=0`, copies `docker-entrypoint.sh`, `docker-ensure-initdb.sh`, `backup.sh`, `restore.sh`, `yt.sh`, `entrypoint.sh`, `env.sh`, `COPY --from=sm /app/publish .`, `ENTRYPOINT ["/entrypoint.sh","dotnet","StreamMaster.API.dll"]`, `EXPOSE 7095` and `5432`, `STOPSIGNAL SIGINT`, no USER. `Dockerfile.base`: `FROM mcr.microsoft.com/dotnet/aspnet:9.0`, apt `xz-utils fuse libgdiplus vlc-bin gosu postgresql postgresql-common curl gnupg lsb-release iputils-ping pipx`, mesa VA drivers on amd64 only, static ffmpeg from BtbN (GPL for amd64, LGPL for arm64), `pipx install streamlink yt-dlp`. `Dockerfile.sm.template`: npm frontend build in `src/StreamMaster.WebUI`, then `dotnet restore` and `dotnet publish -c Debug -o /app/publish /p:UseAppHost=false -a $TARGETARCH`. |
| Env vars | Upstream sets `PUID=0`, `PGID=0` only (Dockerfile.template). Others from the scripts are UNVERIFIED (scripts `entrypoint.sh`, `env.sh` not fetched). |
| Ports | 7095 (ASP.NET, EXPOSE), 5432 (embedded Postgres, EXPOSE). Port 8080 in the draft is UNVERIFIED and must not be listed without evidence. |
| Volumes (README) | `~/streammaster:/config`, `~/streammaster/tv-logos:/config/tv-logos`. |
| Postgres | Upstream image runs its own Postgres (`postgresql`, `gosu`, `docker-entrypoint-initdb.d`). It is not a hard dependency in the chart, and the chart lists `postgresql` as an optional dependency (draft). |
| Draft claim: nginx | Not supported. No nginx package or config appears in `Dockerfile.base` or `Dockerfile.template`. Treat "nginx + ffmpeg" in the draft as UNVERIFIED. |
| arm64 | Build uses `-a $TARGETARCH`, and the base has an arm64 ffmpeg build. Published arm64 image is UNVERIFIED (ghcr manifest not fetched). |

## 2. Target layout

- `apps/streammaster/Dockerfile`
- `apps/streammaster/docker-bake.hcl`
- `apps/streammaster/settings.yaml`
- `apps/streammaster/container-test.yaml`
- `apps/streammaster/start.sh` (replaces upstream `entrypoint.sh`; the rootless version of its job)
- `apps/streammaster/defaults/` only if the app needs a seed config (decide in section 7)

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base). No `etc/` or `health/` unless a probe script is needed.

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. ContainerForge has no .NET runtime base, so the app runtime is installed with apt on ubuntu.
- Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build` with the .NET 9 SDK and Node.js from apt (UNVERIFIED that the ubuntu 26.04 archive carries `dotnet-sdk-9.0`; if not, use the Microsoft apt repo, which needs a pinned key).
- Closest sibling: `apps/webgrabplus` (dotnet 9 runtime on ubuntu, installed with `dotnet-install.sh -c 9.0 --runtime dotnet` into `/app/dotnet`, not apt; also an option here if apt packages are missing). `apps/fenrus` does not exist in `apps/` yet (only a plan), so it is not a precedent.

## 4. Dockerfile

1. `ARG VERSION` (tag, for example `v0.15.0`) and `ARG TARGETARCH`. Default must match `docker-bake.hcl`.
2. Build stage, `USER root`: install `dotnet-sdk-9.0` and `nodejs` plus `npm` (UNVERIFIED availability in the 26.04 archive for both amd64 and arm64).
3. Download the source tarball, extract to `/tmp/src`, run `npm install && npm run build` in `src/StreamMaster.WebUI`, copy `dist/*` to `src/StreamMaster.API/wwwroot/`, then `dotnet restore -a $TARGETARCH` and `dotnet publish -c Release -o /tmp/publish /p:UseAppHost=false -a $TARGETARCH`. Set `DOTNET_CLI_HOME=/tmp`, `NUGET_PACKAGES=/tmp/nuget`, `DOTNET_CLI_TELEMETRY_OPTOUT=1`. Upstream used `-c Debug`; a Release build is a deviation to note in the PR.
4. Runtime stage, `USER root` for installs: `apt-get install -y --no-install-recommends aspnetcore-runtime-9.0 ffmpeg` (UNVERIFIED package names and ffmpeg version on 26.04; upstream uses a static BtbN ffmpeg, so consider that instead if apt ffmpeg lacks a needed codec). Add `streamlink` and `yt-dlp` through pip in a venv under `/usr/local/lib/streammaster-tools` if the app calls them (UNVERIFIED that they are required at runtime).
5. Copy `/tmp/publish` to `/app` (read-only at runtime, owned by root). Ship license: `install -Dm644 LICENSE /usr/share/licenses/streammaster/LICENSE`.
6. `ENV DOTNET_RUNNING_IN_CONTAINER=true`, `ASPNETCORE_URLS=http://0.0.0.0:7095`, `HOME=/tmp`. Do not set `PUID`/`PGID`.
7. `EXPOSE 7095`, `VOLUME ["/config"]`, `WORKDIR /app`, `STOPSIGNAL SIGINT`.
8. `USER apps`, then `COPY --chmod=0755 . /`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "streammaster"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=carlreid/StreamMaster versioning=semver
  default = "v0.15.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/carlreid/StreamMaster"
}
```

Then the default group (`image-local`), `image` (args `VERSION`, labels `source` and `licenses`), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), and `image-all` (`linux/amd64`, `linux/arm64`). Run `docker buildx bake --print` before any build.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/carlreid/StreamMaster"
ports:
  - port: 7095
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - postgresql
```

Only list env names the app really reads (none verified beyond `PUID`/`PGID`, which we drop). The 5432 port is not listed because the plan does not run the embedded Postgres in this image (see section 9). `postgresql` is in `opt_dependencies` (optional in the draft), and `apps/postgresql` exists (✅).

## 7. start.sh

- `#!/bin/sh`, `set -eu`. Create `/config` and `/config/tv-logos` with `mkdir -p` on every start (idempotent; `tv-logos` is the README volume).
- Never write to `/app`. Export `HOME=/tmp` if the app writes under `$HOME`; otherwise nothing.
- Seed nothing unless upstream expects a default config file in `/config` (UNVERIFIED, scripts not fetched).
- `exec dotnet /app/StreamMaster.API.dll` so signals reach the runtime (STOPSIGNAL is SIGINT).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '7095'
  path: /
```

- One probe per port in `settings.yaml` (7095). The path `/` is a placeholder until a health path is confirmed from the app (UNVERIFIED; check the StreamMaster API routes).
- `timeoutSeconds`: check `apps/webgrabplus/container-test.yaml`, the only dotnet sibling (UNVERIFIED value).
- Test runs with no env vars, so any code path that needs a DB or playlist config goes to `filePaths`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behavior | ContainerForge handling |
| --- | --- |
| Runs as root (`PUID=0`, `PGID=0`, no USER) | Runs as `apps`. Any file the app writes must be under `/config` or `/tmp`. |
| Embedded Postgres (`gosu`, `postgresql`, `initdb`) | Not run in this image. Postgres needs root for `gosu` and a writable data dir. Use the `postgresql` app as an external dependency. This is a **blocker** for a faithful port: the app may need a DB URL that we cannot set without the upstream env names (UNVERIFIED). |
| `/config` (mkdir in Dockerfile) | `/config` volume, same path. |
| `/config/tv-logos` (README) | Same path under `/config`. |
| Writes to `/app` (unverified) | Fix at build (`/app` owned by root, read-only) or point the app at `/config`. |
| ffmpeg/yt-dlp/streamlink temp | `/tmp` (set `TMPDIR=/tmp`). Draft caveat: transcoding needs a fast scratch path, so `/tmp` size matters (document in PR). |

Security expectations from the draft (runAsUser 0, readOnlyRootFilesystem false) are TrueCharts defaults and are **not** adopted. The target is `--read-only --tmpfs /tmp` with an empty `/config`, no privileged mode.

## 10. Risks, caveats and open questions

- **Blocker, Postgres:** upstream bundles Postgres and expects root. Decide between an external `postgresql` dependency (needs DB env names, UNVERIFIED) or dropping the feature. Do not ship a half-working DB.
- **Blocker, .NET 9 on ubuntu 26.04:** confirm `dotnet-sdk-9.0` and `aspnetcore-runtime-9.0` in the archive, for both arches, before writing the Dockerfile.
- **Build time:** source build with npm and dotnet is slow (draft, inferred). Keep the build cache in `/tmp` and do not commit build output.
- **Manual setup:** IPTV playlists and EPG are added in the web UI (draft, inferred). Not a blocker.
- **Draft nginx claim:** unconfirmed; the Dockerfile shows no nginx. Correct the draft in the PR.
- **Debug vs Release:** upstream publishes `-c Debug`. The plan uses Release, a deviation to call out.
- **License:** MIT confirmed by the GitHub API. The LICENSE file itself was not fetched (UNVERIFIED wording only).

## 11. Build and test steps

Run from `apps/streammaster/`, per `.github/instructions/build-test-protocol.instructions.md`.

1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker volume create streammaster-probe-config`, then `docker run --rm -d --name streammaster-probe --read-only --tmpfs /tmp -v streammaster-probe-config:/config streammaster:v0.15.0`. Readiness: process stays up, port 7095 open (`ss -ltn`), and a startup line in the log (UNVERIFIED wording).
4. `forgetool containers test --image streammaster:v0.15.0 --config ./container-test.yaml`.
5. Cleanup: `docker rm -f streammaster-probe; docker volume rm streammaster-probe-config`.

Expected: image builds, dotnet starts, port 7095 answers. Anything more is UNVERIFIED until the first run.

## 12. PR checklist

- Branch `feat/add-streammaster`; commit `feat(streammaster): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only the boxes that apply.
- Notes: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what was not built or run. Do not check "Built container locally" unless it was.
- List the Postgres decision and the UNVERIFIED items as open questions in the PR.
