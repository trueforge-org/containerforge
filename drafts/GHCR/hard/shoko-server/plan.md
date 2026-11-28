# shoko-server — implementation plan
> Source: ./draft.md · Target: apps/shoko-server/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `5.3.3` (tag `v5.3.3`, published 2026-03-27, the latest stable release). TrueCharts pins `ghcr.io/shokoanime/server:v5.3.3@sha256:b841f8249c9edfba102e4072e2b2a3eae4179e5dd553f29e11b9898a44f1e836` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shoko-server/values.yaml). Latest release: https://api.github.com/repos/ShokoAnime/ShokoServer/releases/latest (via `gh api`). Release notes warn that dev builds after 5.3.3 may break the web UI until client changes merge. |
| Renovate | `datasource=github-releases depName=ShokoAnime/ShokoServer versioning=semver`. |
| License | MIT (https://raw.githubusercontent.com/ShokoAnime/ShokoServer/v5.3.3/LICENSE, "MIT License, Copyright (c) 2019 Shoko"). Bake `LICENSE` = `MIT`. |
| Source URL | https://github.com/ShokoAnime/ShokoServer |
| Binary (amd64) | `Shoko.CLI_Framework_any-x64.zip`, https://github.com/ShokoAnime/ShokoServer/releases/download/v5.3.3/Shoko.CLI_Framework_any-x64.zip. Framework-dependent, needs the .NET 8 runtime. |
| Binary (arm64) | None. Release assets are `Shoko.CLI_Framework_any-x64.zip`, `Shoko.Setup.exe`, `Shoko.TrayService_Framework_win-x64.zip`, `Shoko.TrayService_Standalone_win-x64.zip`. No linux-arm64 asset. Upstream Dockerfile builds only `-r linux-x64`, so arm64 requires a source `dotnet publish -r linux-arm64` (UNVERIFIED that it builds). |
| Checksum source | None published in the release. UNVERIFIED. Plan: pin sha256 on first download as `ARG SHOKO_SHA256`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ShokoAnime/ShokoServer/v5.3.3/Dockerfile. Stage 1 `mcr.microsoft.com/dotnet/sdk:8.0` runs `dotnet build -c=Release -r linux-x64 -f net8.0 -o=/usr/src/app/build/ Shoko.CLI/Shoko.CLI.csproj`. Stage 2 `mcr.microsoft.com/dotnet/aspnet:8.0` (Debian bookworm) installs gosu, jq, unzip, mediainfo, librhash-dev from the MediaArea apt repo, downloads the Shoko-WebUI release zip at build time from the GitHub API, `VOLUME /home/shoko/.shoko/`, `HEALTHCHECK` on `http://localhost:8111/api/v3/Init/Status` with `--start-period=5m`, `EXPOSE 8111`, `ENTRYPOINT ["/bin/bash", "/dockerentry.sh"]`, no `USER` (root). |
| Upstream entrypoint | https://raw.githubusercontent.com/ShokoAnime/ShokoServer/v5.3.3/dockerentry.sh: creates or updates user `shoko` and group from `PUID` (default 1000) and `PGID` (default 100); refuses `PUID=0` without a custom `SHOKO_HOME`; default `SHOKO_HOME=/home/shoko/.shoko/Shoko.CLI`; chowns `/home/shoko` and `/usr/src/app/build`; applies `UMASK` if set; then `exec gosu $USER:$GROUP /usr/src/app/build/Shoko.CLI`. Exits if `/root/.shoko` exists (old install). |
| Env vars (real) | `PUID` (1000), `PGID` (100), `SHOKO_HOME`, `UMASK`, `LANG`, `LC_CTYPE`, `LC_ALL` (C.UTF-8). Chart sets none. Whether the Shoko app itself reads `SHOKO_HOME` is UNVERIFIED (only the entrypoint uses it). |
| Port | 8111/http (EXPOSE, chart service `main` port 8111 targetPort 8111, protocol http). Whether the app binds 0.0.0.0 by default is UNVERIFIED. |
| Data write paths | `/home/shoko/.shoko/` (Dockerfile VOLUME; chart persistence `appdata` mountPath `/home/shoko/.shoko/`). Default SHOKO_HOME is `/home/shoko/.shoko/Shoko.CLI`. |
| Arm64 image | Yes for the image. GHCR manifest for `ghcr.io/shokoanime/server:v5.3.3` lists linux/amd64 and linux/arm64 (https://ghcr.io/v2/shokoanime/server/manifests/v5.3.3). The arm64 image is built upstream; ContainerForge would build its own (see section 10). |
| Chart security | `runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`. |
| Dependencies | None in the chart (common only). Upstream image needs mediainfo (MediaArea repo, bookworm). Shoko-WebUI is a separate project (ShokoAnime/Shoko-WebUI), not fetched: its license and asset are UNVERIFIED. |

## 2. Target layout

- `apps/shoko-server/Dockerfile`: build stage fetches and verifies the CLI zip (amd64) and, if needed, publishes for arm64; final stage on ubuntu installs the .NET 8 runtime and mediainfo, then copies the app to `/app/shoko-server`.
- `apps/shoko-server/docker-bake.hcl`
- `apps/shoko-server/settings.yaml`
- `apps/shoko-server/container-test.yaml`
- `apps/shoko-server/start.sh`: replaces `dockerentry.sh`. No user switching (the image runs as `apps`); sets `SHOKO_HOME` under `/config`, seeds nothing, then `exec`s the CLI.

No `defaults/` needed unless the Shoko-WebUI is vendored (see section 10). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the build and final stages.

Why: the base already has `libicu-dev`, `curl` and `tar`. The .NET runtime is not on this base, so it is installed (see section 4). Closest siblings: `apps/webgrabplus` (the only .NET app on ubuntu; it installs the runtime with Microsoft's `dotnet-install.sh` into `/app/dotnet`, lines 17 to 24 of its Dockerfile) and `apps/sonarr`/`apps/radarr` (the Servarr .NET pattern). The `apps/ubuntu` base sets `DOTNET_RUNNING_IN_CONTAINER=true`.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG SHOKO_SHA256`, `USER root`.
2. `curl -fL -o /tmp/shoko.zip https://github.com/ShokoAnime/ShokoServer/releases/download/v${VERSION}/Shoko.CLI_Framework_any-x64.zip`, then `echo "${SHOKO_SHA256}  /tmp/shoko.zip" | sha256sum -c -`, then `unzip -q /tmp/shoko.zip -d /tmp/shoko`. Fail if `/tmp/shoko/Shoko.CLI` is missing.
3. Final stage `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
4. .NET 8 runtime: use the `webgrabplus` pattern, `curl -o /tmp/dotnet-install.sh -L https://dot.net/v1/dotnet-install.sh`, then `/tmp/dotnet-install.sh -c 8.0 --install-dir /app/dotnet --runtime dotnet` (no apt version exists for .NET 8 on ubuntu 26.04: UNVERIFIED). Set `ENV DOTNET_ROOT=/app/dotnet PATH=/app/dotnet:$PATH`. Checksum for the install script: UNVERIFIED (Microsoft publishes none alongside it; record as a risk, section 10).
5. `apt-get install -y --no-install-recommends mediainfo librhash0 ca-certificates` (mediainfo is in the ubuntu archive; the MediaArea repo used upstream is not needed). `librhash-dev` upstream is a build dependency for the upstream build; check whether the runtime needs `librhash0` (UNVERIFIED). Clean `/var/lib/apt/lists/*`.
6. `mkdir -p /app/shoko-server && unzip -q /tmp/shoko.zip -d /app/shoko-server`. Verify `Shoko.CLI` is executable (`chmod +x`).
7. Shoko-WebUI: upstream downloads the latest Shoko-WebUI release at build time. For this plan, pin the WebUI release zip the same way (`ARG WEBUI_VERSION` with an `ARG WEBUI_SHA256`), download into `/app/shoko-server/webui/`, and unzip. The WebUI project, its release asset name and license are UNVERIFIED (not fetched); this is a blocker to resolve before the first build (section 10).
8. License: `install -D` of the MIT LICENSE into `/usr/share/licenses/shoko-server/LICENSE` (fetched from the tag, or from the zip if it ships it; UNVERIFIED).
9. Do not set PUID/PGID: the image runs as `apps` (568). `ENV SHOKO_HOME=/config/Shoko.CLI LANG=C.UTF-8 LC_ALL=C.UTF-8 DOTNET_ROOT=/app/dotnet DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_EnableDiagnostics=0`.
10. Cleanup: `rm -rf /tmp/* /var/lib/apt/lists/*`.
11. `chown -R apps:apps /app/shoko-server /app/dotnet`, `chmod -R 755 /app/shoko-server /app/dotnet`.
12. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8111
VOLUME /config
WORKDIR /app/shoko-server
```

arm64 (open decision, section 10): the amd64 build uses the release zip. For arm64, either (a) a second build stage running `dotnet publish -r linux-arm64` from the source tarball pinned to the tag, or (b) ship amd64 only and do not claim arm64 in the PR. Choose (b) first; add (a) as a follow-up after the amd64 test passes.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "shoko-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ShokoAnime/ShokoServer versioning=semver
  default = "5.3.3"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ShokoAnime/ShokoServer"
}
```

Then `image`, `image-local`, `image-all` and `group "default"` as in `apps/bookstack/docker-bake.hcl`. `image` passes `VERSION`, `SHOKO_SHA256`, and the WebUI pins as build args. If (b) above is chosen, `image-all` must not claim arm64 until it is validated; keep the four standard targets but note it in the PR. Validate with `docker buildx bake --print` from `apps/shoko-server/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ShokoAnime/ShokoServer"
ports:
  - port: 8111
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: SHOKO_HOME
    default: "/config/Shoko.CLI"
    required: false
  - name: UMASK
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`dependencies: []`: no other ContainerForge app is needed. `PUID`/`PGID` are not listed: they are not read (the image runs as `apps`). `SHOKO_HOME` is listed because the start script sets it and the entrypoint reads it upstream; whether Shoko reads it itself is UNVERIFIED (section 10).

## 7. start.sh

```bash
#!/usr/bin/env bash

export SHOKO_HOME="${SHOKO_HOME:-/config/Shoko.CLI}"

mkdir -p "${SHOKO_HOME}"

if [[ -n "${UMASK}" ]]; then
    umask "${UMASK}"
fi

cd /app/shoko-server

exec ./Shoko.CLI
```

Notes:
- Idempotent: `mkdir -p` only. Existing state under `/config` is never touched.
- Empty `/config` works: Shoko creates its settings on first start under `SHOKO_HOME` (UNVERIFIED for the first-run path; confirmed by the probe in section 11).
- Nothing is written to `/app`: the WebUI is read-only under `/app/shoko-server/webui`. Shoko's own writes must go to `SHOKO_HOME`, which is a `/config` path. If Shoko writes next to its binary, the probe will fail and this must be addressed (section 10).
- No `chown` and no user switching: the image already runs as `apps`.
- `exec` hands PID 1 to the server.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8111'
http:
- port: '8111'
  path: /api/v3/Init/Status
filePaths:
- /app/shoko-server/Shoko.CLI
- /app/dotnet/dotnet
- /usr/bin/mediainfo
- /usr/share/licenses/shoko-server/LICENSE
```

- `timeoutSeconds: 300` matches the upstream `HEALTHCHECK` `--start-period=5m`. UNVERIFIED: no sibling sets a comparable timeout (`apps/sonarr/container-test.yaml` sets none); tune on the first run.
- The tcp and http probes cover the one settings.yaml port (8111). The probe path is the upstream healthcheck endpoint, so it is a real assertion.
- No env-gated code paths: the test runs without env vars, and `SHOKO_HOME` falls back to `/config/Shoko.CLI`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/home/shoko/.shoko/` (VOLUME, chart appdata) | `SHOKO_HOME=/config/Shoko.CLI` (default; the entrypoint path is replaced) |
| `/home/shoko` ownership and `useradd` | removed; image runs as `apps` (568) |
| `/usr/src/app/build` (chown'd at runtime) | `/app/shoko-server` (read-only at runtime, no chown) |
| `/root/.shoko` old-install check | dropped (no root user in this image) |
| `PUID`/`PGID`/`gosu` privilege drop | removed; `USER apps` |
| `UMASK` | kept, applied in `start.sh` |
| .NET temp and cache (`/tmp`) | `DOTNET_CLI_HOME=/tmp` (and `DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp` if needed) |
| Chart `runAsUser 0`, `readOnlyRootFilesystem false` | not carried over: must run as `apps` on read-only rootfs |

## 10. Risks, caveats and open questions

- Draft caveats confirmed: arm64 has no release binary (confirmed: only x64 CLI zip and Windows assets). Media library paths are mounted and added in the Shoko UI (manual, UNVERIFIED). AniDB access may need a client or account (UNVERIFIED, no fetch of AniDB docs).
- Blocker, WebUI: Shoko-WebUI is downloaded at build time upstream. The plan pins a release zip, but the WebUI repo, release asset and license were not fetched. Resolve before the first build; if it cannot be pinned, the image cannot match upstream and the PR must say so.
- Blocker, .NET 8 on ubuntu 26.04: apt provides no .NET 8 runtime in this plan (UNVERIFIED). The `dotnet-install.sh` path (webgrabplus pattern) is used; its trust model is the Microsoft script over HTTPS with no published checksum.
- Checksum: no upstream checksum for the zip or the WebUI. Trust-on-first-use pins.
- Shoko writes: whether Shoko writes only to `SHOKO_HOME` or also beside its binary is UNVERIFIED. The read-only rootfs probe decides.
- Whether Shoko honours `SHOKO_HOME` directly is UNVERIFIED (the upstream entrypoint sets it, not the app).
- arm64: no release binary. Plan ships amd64 first. arm64 needs a `dotnet publish -r linux-arm64` build stage (UNVERIFIED that it builds); it is slow, as the draft warns.
- `librhash` runtime library: UNVERIFIED whether the runtime needs it (upstream installs `librhash-dev`).
- Not a blocker: no musl-only dependency, no GPU, no privileged mode. Upstream root and chown behaviour is removed, not reproduced.

## 11. Build and test steps

From `apps/shoko-server/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe with an empty config volume:
   ```sh
   docker volume create shoko-probe-config
   docker run --rm -d --name shoko-probe --read-only --tmpfs /tmp \
     -v shoko-probe-config:/config shoko-server:5.3.3
   docker logs -f shoko-probe
   ```
   Expected readiness signal: the server logs that it is listening on port 8111 (exact line to be recorded on first run), `curl -s http://localhost:8111/api/v3/Init/Status` returns JSON, and no fatal or repeated stack traces. Clean up with `docker rm -f shoko-probe; docker volume rm shoko-probe-config`.
4. `forgetool containers test --image shoko-server:5.3.3 --config ./apps/shoko-server/container-test.yaml`
5. Repeat step 3 with the volume kept to confirm a restart with existing `/config/Shoko.CLI` works.

## 12. PR checklist

- Branch `feat/add-shoko-server`, commit `feat(shoko-server): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what was done.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what was not tested: arm64 (not built, amd64-only first), the WebUI pin, the checksum trust-on-first-use, the .NET install script trust, and any path not run locally.
- Do not check "Built container locally" unless the build and the probe in section 11 actually ran.
- `DOWNSTREAM_CHANGES.md`: not needed (no downstream FROM use).
