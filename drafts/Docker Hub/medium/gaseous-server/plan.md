# gaseous-server — implementation plan
> Source: ./draft.md · Target: apps/gaseous-server/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v1.7.14` (GitHub release 2025-07-31, marked Latest). It is the chart's pinned version. Newer pre-releases exist (`v2.0.0-preview.1`, `-preview.2`, `v2.0.0-rc.1` to `rc.5`, latest rc.5 on 2026-09-27). Their pre-release flags are UNVERIFIED. Stay on `v1.7.14` unless the team wants the 2.0 line. |
| Renovate | `// renovate: datasource=github-releases depName=gaseous-project/gaseous-server versioning=semver`. The `v` prefix is handled by semver versioning. |
| License | GNU AGPL-3.0 (`LICENSE` on main). The exact SPDX variant (`AGPL-3.0-only` or `-or-later`) is UNVERIFIED: read the LICENSE text before setting the bake value. Use `AGPL-3.0` until then. |
| Source URL | https://github.com/gaseous-project/gaseous-server |
| Download | No prebuilt binary. Source tag `v1.7.14`: `https://github.com/gaseous-project/gaseous-server/archive/refs/tags/v1.7.14.tar.gz` (tag page confirmed; the archive URL pattern is standard GitHub, not fetched). |
| Checksum source | None published (not found). Plan: compute `sha256sum` of the tarball once and pin it as `ARG SOURCE_SHA256`. |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/gaseous-project/gaseous-server/139459c1e4d989772545ca5da8cf36aaee215a3b/build/Dockerfile`. The facts say the same file exists at v1.7.14. Stage 1: `FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0`, `TARGETARCH`, `dotnet restore`, `dotnet publish --self-contained true -c Release -o out -a $TARGETARCH`, then downloads `https://cdn.emulatorjs.org/releases/4.2.1.7z` (EmulatorJS 4.2.1.7z, checksum UNVERIFIED) and extracts it to `out/wwwroot/emulators/EmulatorJS`. Stage 2: `FROM mcr.microsoft.com/dotnet/aspnet:8.0`, `ENV INDOCKER=1`, `WORKDIR /App`, `curl` via apt, `HEALTHCHECK` on `http://localhost:80/api/v1.1/HealthCheck`, `ENTRYPOINT ["dotnet", "gaseous-server.dll"]`, no `USER` (root). |
| Project | `gaseous-server/gaseous-server.csproj`, target `net8.0` (tag v1.7.14). |
| Port (container) | `80` (upstream HEALTHCHECK, chart `targetPort: 80`). The chart's service port `5198` is the port users connect to. |
| Env vars (upstream) | `INDOCKER=1` only. |
| Env vars (chart) | `dbhost`, `dbuser`, `dbname`, `dbpass`, `dbport=3306`, `igdbclientid`, `igdbclientsecret` (secretKeyRef). These are chart value keys. Whether the app reads these env names is UNVERIFIED (app source not searched). |
| Write paths (chart) | `/root/.gaseous-server` (config), `/root/.gaseous-server/Logs`, `/root/.gaseous-server/Data`. These are root-home paths. |
| Docker Hub tags | `v1.7.14`: amd64 `sha256:a68a0558a8c81de275897806dc373298ccc62939edb7cc397308f3f24ba6bc9b`, arm64 `sha256:1f9f6f1a56edf0e7fbb73a95e8e93c1c166bca8fb4547b8caff2d415140ef6d5` (last updated 2025-07-31). The chart's index digest `sha256:5e506593ff09533f23e742470da2ef37ffe4051f3559dad3b038e81444df75a6` is UNVERIFIED against the tag list. `nightly-embeddeddb` (2026-11-11) is not stable. |
| Chart | `charts/stable/gaseous-server`. `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem: false`, service port 5198, `targetPort: 80`. |

## 2. Target layout

- `apps/gaseous-server/Dockerfile`: build stage (SDK, publish) and runtime stage (ubuntu).
- `apps/gaseous-server/docker-bake.hcl`
- `apps/gaseous-server/settings.yaml`
- `apps/gaseous-server/container-test.yaml`
- `apps/gaseous-server/start.sh`: copied to `/start.sh` by `COPY --chmod=0755 . /`. It sets the listen URL and the DB settings from env (if the app reads a config file, see section 7), then `exec`s the app.

No `defaults/` unless the app needs a template config (UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both the build stage and the final stage.

Why: .NET 8 is not in ContainerForge (no dotnet app in `apps/` uses the 8.0 runtime). The upstream `aspnet:8.0` and `sdk:8.0` images are not used. Instead the SDK is installed with the official `dotnet-install.sh`, the same way `apps/webgrabplus/Dockerfile` installs .NET (`curl https://dot.net/v1/dotnet-install.sh` with `--install-dir`). Closest sibling: `apps/webgrabplus` (dotnet on ubuntu) and `apps/mariadb` (the dependency).

Runtime needs no .NET install: the upstream publish is `--self-contained true`, so the output already carries the runtime. The final stage only needs the app folder and the ICU library (`libicu78` in webgrabplus; whether this app needs it is UNVERIFIED, check `ldd`/startup log).

## 4. Dockerfile

1. `ARG VERSION` (must equal bake VERSION, `v1.7.14`), `ARG SOURCE_SHA256`, `ARG TARGETARCH`.
2. Build stage `FROM <ubuntu> AS build`, `USER root`.
3. Install the SDK to `/tmp` (not the runtime, the publish is self-contained):

```dockerfile
ENV DOTNET_CLI_HOME=/tmp DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 NUGET_PACKAGES=/tmp/nuget
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates libicu78 p7zip-full && \
    curl -fsSL -o /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh -c 8.0 --install-dir /tmp/dotnet-sdk
```

   Package names `libicu78` and `p7zip-full` on 26.04 are UNVERIFIED (`libicu78` is used by `webgrabplus`; `p7zip-full` is the usual 7z package). `curl` may already be in the base; do not reinstall it if present (check `apps/ubuntu`). Pin the SDK with `-c 8.0` only, as the upstream publish needs net8.0.
4. Source:

```dockerfile
RUN mkdir -p /tmp/src && \
    curl -fsSL -o /tmp/src.tar.gz "https://github.com/gaseous-project/gaseous-server/archive/refs/tags/${VERSION}.tar.gz" && \
    echo "${SOURCE_SHA256}  /tmp/src.tar.gz" | sha256sum -c - && \
    tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1
```

5. EmulatorJS, same as upstream, into the source tree before publish so it lands in `wwwroot`:

```dockerfile
RUN curl -fsSL -o /tmp/4.2.1.7z https://cdn.emulatorjs.org/releases/4.2.1.7z && \
    7z x /tmp/4.2.1.7z -o/tmp/src/gaseous-server/wwwroot/emulators/ && \
    rm /tmp/4.2.1.7z
```

   The exact target folder name is UNVERIFIED: upstream extracts to `out/wwwroot/emulators/EmulatorJS` after publish, so the archive root must be checked. Checksum of the 7z: UNVERIFIED, pin if a published value exists. `7z` needs `p7zip-full`.
6. Publish, arch mapping (dotnet RIDs are `x64`, not `amd64`):

```dockerfile
RUN case "${TARGETARCH}" in amd64) RID=linux-x64 ;; arm64) RID=linux-arm64 ;; *) echo "unsupported ${TARGETARCH}"; exit 1 ;; esac && \
    export PATH=/tmp/dotnet-sdk:$PATH && \
    cd /tmp/src/gaseous-server && \
    dotnet publish gaseous-server.csproj -c Release -r "${RID}" --self-contained true -o /tmp/out
```

   `TARGETARCH` in ContainerForge arm64 builds is `arm64`. Only the arch mapping is needed; the upstream `-a $TARGETARCH` is replaced by `-r`. Build time is long (UNVERIFIED on this runner).
7. Runtime stage: `FROM <ubuntu>` again, `USER root`, `apt-get install -y --no-install-recommends libicu78` (only if needed, see section 3), `rm -rf /var/lib/apt/lists/*`.
8. Copy the output and the license:

```dockerfile
RUN mkdir -p /app/gaseous-server /usr/share/licenses/gaseous-server
COPY --from=build /tmp/out/ /app/gaseous-server/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/gaseous-server/LICENSE
RUN chown -R root:root /app/gaseous-server && chmod -R 0755 /app/gaseous-server
```

   Shipping the EmulatorJS license: the EmulatorJS folder has its own license; UNVERIFIED whether it is in the 7z (ship it if it is).
9. Tail:

```dockerfile
ENV INDOCKER=1 \
    HOME=/config \
    ASPNETCORE_URLS=http://+:5198

USER apps
COPY --chmod=0755 . /

EXPOSE 5198
VOLUME ["/config"]
WORKDIR /app/gaseous-server
```

The upstream `HEALTHCHECK` is not carried over (it uses port 80). `container-test.yaml` covers the health path. `ASPNETCORE_URLS` puts the server on 5198, because `apps` cannot bind port 80 without a capability.

## 5. docker-bake.hcl

Same layout as `apps/nzbhydra2/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "gaseous-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gaseous-project/gaseous-server versioning=semver
  default = "v1.7.14"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/gaseous-project/gaseous-server"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Add `SOURCE_SHA256` to `args` once pinned. Validate with `docker buildx bake --print` from `apps/gaseous-server`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/gaseous-project/gaseous-server"
ports:
  - port: 5198
    protocol: tcp
    required: false
env:
  - name: ASPNETCORE_URLS
    default: "http://+:5198"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
  # DB and IGDB entries go here only after the app source confirms the names it reads
volumes:
  - path: /config
    required: true
dependencies:
  - name: mariadb
```

- `dependencies: mariadb` is required: apps/mariadb exists (✅). Hard dependency per the chart.
- The DB env names (`dbhost`, `dbuser`, `dbname`, `dbpass`, `dbport`) and IGDB keys (`igdbclientid`, `igdbclientsecret`) are NOT added yet. The chart names are not proof of the env names the app reads. Grep the app source for the reads (for example `Environment.GetEnvironmentVariable`) and add only confirmed names, with defaults that match `start.sh`. If the app reads these from a config file, they go into `start.sh` instead (section 7).
- `ASPNETCORE_URLS` is read by the ASP.NET runtime. Confirm the app does not override it with `UseUrls` (UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/.gaseous-server/Logs /config/.gaseous-server/Data

export ASPNETCORE_URLS="${ASPNETCORE_URLS:-http://+:5198}"

# DB and IGDB settings: apply from env on every start (protocol rule for databases).
# Exact mechanism UNVERIFIED: env vars, or a config file under /config/.gaseous-server.
# If a config file is used, rewrite it from env each start and keep secrets out of the process list.

cd /app/gaseous-server || exit 1
exec ./gaseous-server
```

- `HOME=/config` (ENV in the Dockerfile) moves the chart's `/root/.gaseous-server` to `/config/.gaseous-server`. That is only true if the app resolves its data folder from the user profile (UNVERIFIED: check the app's data path code). If it does not, set the path in config instead.
- `exec` the apphost (`./gaseous-server`). The self-contained publish creates an apphost; `dotnet gaseous-server.dll` (the upstream entrypoint) is not used because the publish is self-contained (UNVERIFIED that the apphost is produced for this csproj).
- No writes to `/app/gaseous-server`. If the app writes next to the binary (UNVERIFIED), fix the path to `/config` or `/tmp`.
- Idempotent: `mkdir -p` only, no seeding of files.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '5198'
http:
- port: '5198'
  path: /api/v1.1/HealthCheck
filePaths:
- /app/gaseous-server/gaseous-server
- /app/gaseous-server/wwwroot/emulators/EmulatorJS
- /usr/share/licenses/gaseous-server/LICENSE
```

- `http` path `/api/v1.1/HealthCheck` is the upstream HEALTHCHECK path, on port 5198 now instead of 80. It is UNVERIFIED that the endpoint answers without a database. If it needs the DB, the DB-dependency rule applies (below).
- `timeoutSeconds: 240`: the upper end of sibling values, because the .NET app starts slowly.
- DB-dependency exception (protocol). It applies only if ALL hold: (1) hard `dependencies` entry on mariadb: yes. (2) the app will not start or will fail health without the DB in the same network: UNVERIFIED, run the image with no DB and read the log. (3) not feasible to wire a sidecar DB in `container-test.yaml`: the single-container suite has no sidecar primitive used here. If (2) is false, the narrowing does not apply and the tests above must stay full. If it is true, keep the `tcp`/`filePaths` assertions and add the comment near the narrowed assertions: `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`.
- Required-env code paths (DB, IGDB) are not tested by this file. Add them to `filePaths` only when they are in separate files (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/root/.gaseous-server` (config) | `HOME=/config` gives `/config/.gaseous-server` (UNVERIFIED that the app uses HOME). |
| `/root/.gaseous-server/Logs` | `/config/.gaseous-server/Logs` |
| `/root/.gaseous-server/Data` | `/config/.gaseous-server/Data` |
| `/root` (upstream runs as root) | `apps` (568) cannot write there. Not used after the remap. |
| Port 80 (upstream, root) | `5198` via `ASPNETCORE_URLS`. Port 80 needs root or a capability. |
| .NET temp and NuGet (build only) | `/tmp` via `DOTNET_CLI_HOME` and `NUGET_PACKAGES` (build stage). |
| App writes next to the binary (UNVERIFIED) | Check the log on `--read-only --tmpfs /tmp`. Fix the path if any write fails. |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. Our image runs as `apps` and is expected to work with `--read-only --tmpfs /tmp`. Existing chart users must move their `/root/.gaseous-server` content to `/config/.gaseous-server`. Not privileged.

## 10. Risks, caveats and open questions

- .NET 8 end of support: Microsoft's support window for .NET 8 ends in November 2026 (from general knowledge, not fetched: UNVERIFIED). Today is 2026-11-25. The image will run on an unsupported runtime. Decide whether 1.7.14 is acceptable or move to the 2.0 line, which may target a newer .NET (UNVERIFIED, check the csproj at that tag).
- MariaDB is a hard dependency. Without it the app may not start (UNVERIFIED).
- IGDB client id/secret are needed for game metadata (chart keys; whether they are mandatory is UNVERIFIED).
- The EmulatorJS download runs at build time from `cdn.emulatorjs.org`. The build fails if the CDN is down. No checksum is confirmed.
- First build is slow (SDK install, restore, self-contained publish, 7z). UNVERIFIED on the CI runner.
- Port 80 in upstream; port 5198 here. Document it in the PR, because users may reach it through the chart's service port.
- arm64: the Hub image has an arm64 variant and the upstream Dockerfile is `TARGETARCH`-aware, so arm64 is supported upstream. Our arm64 build is UNVERIFIED until built.
- Renovate: a checksum pin needs a manual bump per release.
- No blockers beyond the .NET 8 support date and the DB dependency. Not musl-only, no GPU, not privileged.

## 11. Build and test steps

```sh
cd /workspaces/containers/apps/gaseous-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gaseous-server-probe --read-only --tmpfs /tmp \
  -v gaseous-server-probe-config:/config gaseous-server:v1.7.14
docker logs -f gaseous-server-probe
forgetool containers test --image gaseous-server:v1.7.14 --config ./apps/gaseous-server/container-test.yaml
docker rm -f gaseous-server-probe; docker volume rm gaseous-server-probe-config
```

Readiness signals (UNVERIFIED wording, check the first real run): an ASP.NET Core `Now listening on: http://[::]:5198` line (or the app's own ready line) and `Application started`. If the DB is missing, the log will show the DB connection error; that is a fail unless the narrowing above is justified. Also run the image with `-p 5198:5198` and curl from the host, to prove it is not bound to localhost only. Run the same `/config` volume twice, to check the second start.

## 12. PR checklist

- Branch `feat/add-gaseous-server`, commit `feat(gaseous-server): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Untested to state honestly: the build on amd64 and arm64, the EmulatorJS download, the DB-connected behavior, IGDB metadata, the health endpoint without a DB, the read-only run, and any upgrade from the chart's `/root/.gaseous-server` data.
- Before the commit: `docker buildx bake --print` passes, `VERSION` in bake equals `ARG VERSION`, the source checksum is pinned, and no assertion was weakened.
