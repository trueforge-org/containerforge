# feedcord — implementation plan
> Source: ./draft.md · Target: apps/feedcord/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.1.0` (GitHub release `v3.1.0`, published 2025-02-20). Draft names no version; its Dockerfile link is master commit `c9568b96` (2025-07-01, unreleased, `net9.0`). |
| Difference from draft | The `v3.1.0` tag targets `net7.0` (EOL) with `Microsoft.Extensions.* 8.0.0`. Master moved to `net9.0` (commit `9520e08f`, 2025-06-23) without a new tag. This plan builds the `v3.1.0` source with `-p:TargetFramework=net9.0` (UNVERIFIED: not built; Microsoft.Extensions 8.0.0 packages are expected to run on net9). Fallback: pin master commit `c9568b96` and use `datasource=git-refs` (see section 10). |
| Renovate | `datasource=github-releases depName=Qolors/FeedCord versioning=semver` (strip `v` via the download URL, as `adguardhome-sync` does) |
| License | MIT (GitHub SPDX `MIT`) |
| Source URL | https://github.com/Qolors/FeedCord |
| Download (amd64 and arm64) | No binary release. Source tarball `https://github.com/Qolors/FeedCord/archive/refs/tags/v${VERSION}.tar.gz`, compiled per architecture with `dotnet publish` |
| Checksum source | None published by upstream (UNVERIFIED that none exists; the Releases page lists no assets). dotnet-install.sh verifies the .NET download against Microsoft's feed checksum. |
| Upstream Dockerfile reviewed | `FeedCord/Dockerfile` at `v3.1.0` (sdk:7.0 build, aspnet:7.0 final, `ENTRYPOINT dotnet FeedCord.dll`) and at master (sdk:9.0 / aspnet:9.0). Draft commit link `c9568b96` matches the master form. |
| Ports | None. A Discord webhook client and RSS poller; no listener (`Startup.cs` only builds a generic `Host`). |
| Config | `Startup.cs` `AddJsonFile(args.Length == 1 ? args[0] : "config/appsettings.json", optional: false, reloadOnChange: true)` relative to `AppDomain.CurrentDomain.BaseDirectory`. One CLI argument = config path. Docker docs mount to `/app/config/appsettings.json`. |
| Env vars | None read by the app (README and `docs/reference.md` define only `appsettings.json` keys). Empty `Instances` is valid (`?? new List<Config>()`), it only logs `Number of configurations loaded: 0`. |
| Writes | `FeedWorker.cs`: when an instance sets `PersistenceOnShutdown`, appends `feed_dump.csv` under `AppContext.BaseDirectory` (the app dir). |
| Runtime packages | Ubuntu 26.04 (resolute) apt has `dotnet-sdk-10.0` and `aspnetcore-runtime-10.0` but no `dotnet-*-9.0` (packages.ubuntu.com search, no results). .NET 9 must come from `dotnet-install.sh` (same approach as `apps/webgrabplus`). |

## 2. Target layout

- `apps/feedcord/Dockerfile` (two stages: SDK build, runtime)
- `apps/feedcord/docker-bake.hcl`
- `apps/feedcord/settings.yaml`
- `apps/feedcord/container-test.yaml`
- `apps/feedcord/start.sh`
- `apps/feedcord/defaults/appsettings.json` (seed `{"Instances": []}`, reason: app exits if the file is missing; `defaults/` is on the `.dockerignore` allow-list)

No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both stages. Fits the draft (ubuntu alone) and the ubuntu base already ships `libicu-dev`, curl, tar and `HOME=/config`. Closest siblings: `apps/webgrabplus` (dotnet via dotnet-install.sh on ubuntu) and `apps/pwndrop` (build stage then runtime stage).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `ARG DOTNET_CHANNEL=9.0`, `USER root`.
2. Install SDK without apt: download `https://dot.net/v1/dotnet-install.sh`, run `--channel ${DOTNET_CHANNEL} --install-dir /tmp/dotnet-sdk`. Set `DOTNET_CLI_HOME=/tmp`, `NUGET_PACKAGES=/tmp/nuget`, `DOTNET_CLI_TELEMETRY_OPTOUT=1`, `DOTNET_NOLOGO=1`.
3. Fetch `https://github.com/Qolors/FeedCord/archive/refs/tags/v${VERSION}.tar.gz` (fallback without `v`, as `apps/budge` does), extract to `/tmp/src --strip-components=1`.
4. `cd /tmp/src/FeedCord && /tmp/dotnet-sdk/dotnet publish FeedCord.csproj -c Release -p:TargetFramework=net9.0 -o /tmp/publish`. The csproj copies `config/appsettings.json` only if present; ignore it.
5. Runtime stage `FROM <ubuntu>`, `ARG TARGETARCH`, `USER root`. Install the .NET 9 runtime: `dotnet-install.sh --channel 9.0 --runtime dotnet --install-dir /app/dotnet` (Microsoft.NETCore.App only; the app uses `Microsoft.Extensions.Hosting`, not ASP.NET). `libicu` is already in the base (`libicu-dev`); do not add it.
6. `mkdir -p /app/feedcord`, `COPY --from=build /tmp/publish/ /app/feedcord/`. Licenses: `mkdir -p /usr/share/licenses/feedcord && cp /tmp/src/LICENSE ...` must be done in the build stage and copied with `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/feedcord/LICENSE`.
7. Make `/app/feedcord/feed_dump.csv` a symlink to `/config/feed_dump.csv` (dangling until first write; `StreamWriter(append:true)` creates the target). `chown -R apps:apps /app`, `chmod -R 755 /app`.
8. `ENV DOTNET_ROOT=/app/dotnet DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp DOTNET_CLI_HOME=/tmp DOTNET_gcServer=0 DOTNET_EnableDiagnostics=0` (`DOTNET_EnableDiagnostics=0` avoids the diagnostics IPC socket in `/tmp`, as `apps/sonarr` does).
9. Cleanup: `rm -rf /tmp/*`. No apt packages added, so nothing to pin.
10. End with the required tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

VOLUME /config
WORKDIR /config
```

No `EXPOSE` (no ports). The final instruction before the tail is `USER apps`; keep `COPY --chmod=0755 . /` after it as in sibling apps.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "feedcord" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Qolors/FeedCord versioning=semver
  default = "3.1.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/Qolors/FeedCord" }
```

Standard `docker-metadata-action`, `image` (args VERSION, OCI source and licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64) and `group "default"` copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Qolors/FeedCord"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No upstream env vars exist, so only `TZ` (honoured by .NET via tzdata in the base). `ports: []` because no port is opened. Dependencies: none (the Discord webhook is an external service, not a ContainerForge app).

## 7. start.sh

```bash
#!/usr/bin/env bash

# seed config only when missing
if [[ ! -f /config/appsettings.json ]]; then
    cp /defaults/appsettings.json /config/appsettings.json
fi

cd /app/feedcord
exec /app/dotnet/dotnet /app/feedcord/FeedCord.dll "${CONFIGFILE:-/config/appsettings.json}"
```

Idempotent, seeds only when missing, no writes to `/app`. `CONFIGFILE` is the same optional override that `adguardhome-sync/start.sh` uses; if kept, add it to settings.yaml `env` (default `/config/appsettings.json`, required false). The single CLI argument is the documented path override (`args.Length == 1`). No port to bind. With the seeded empty `Instances` the app starts and idles (hosted services only registered per instance); verify it does not exit (see section 10).

## 8. container-test.yaml

No port exists, so no tcp or http probe is required. Use real process and file assertions:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
runners:
- entrypoint: /app/dotnet/dotnet --info
filePaths:
- /app/feedcord/FeedCord.dll
- /app/dotnet/dotnet
- /usr/share/licenses/feedcord/LICENSE
```

`runners` mirrors `apps/webgrabplus`. The test runs without env vars; the empty-`Instances` seed makes the default start path valid. A functional Discord post cannot be tested (needs a real webhook).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/feedcord/feed_dump.csv` (`AppContext.BaseDirectory`, only with `PersistenceOnShutdown: true`) | symlink to `/config/feed_dump.csv` created at build time |
| `/app/config/appsettings.json` (upstream mount point, read-only in chart) | config lives at `/config/appsettings.json`, passed as the CLI argument |
| .NET bundle extraction, NuGet, CLI home | `DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp`, `DOTNET_CLI_HOME=/tmp` (runtime only needs `/tmp`) |

Draft expectations: non-root yes (runs as `apps` UID 568, matching the chart default 568), read-only rootfs "no" in the chart but this image is compatible with `--read-only --tmpfs /tmp`, privileged no. The chart's ConfigMap mount at `/app/config/appsettings.json` is replaced by `/config/appsettings.json`; chart users must remap the mount to `/config`. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- Retargeting `v3.1.0` from net7.0 to net9.0 is UNVERIFIED. If it fails, switch `VERSION` to master commit `c9568b96...` (full SHA to be copied from GitHub) with `// renovate: datasource=git-refs depName=https://github.com/Qolors/FeedCord currentValue=master` (precedent: `apps/tvheadend`).
- Docker Hub `qolors/feedcord:latest` was last pushed 2025-07-01 (= master `c9568b96`), so it differs from the `v3.1.0` release (master also has GitLab label filtering). Decide which one is wanted.
- .NET 9 is STS and EOL since 2026-05; .NET 10 (apt `dotnet-sdk-10.0`, `aspnetcore-runtime-10.0` available on 26.04) would remove `dotnet-install.sh` but needs a retarget to `net10.0` (UNVERIFIED).
- `dotnet-install.sh` is downloaded unpinned from `dot.net` at build time.
- Needs a Discord webhook and RSS URLs before it does anything. `Id`, `RssUrls`, `YoutubeUrls`, `DiscordWebhookUrl`, `RssCheckIntervalMinutes`, `DescriptionLimit`, `Forum`, `MarkdownFormat`, `PersistenceOnShutdown` are all required per instance (`Config.cs`).
- Config is `reloadOnChange: true`; a ConfigMap-style symlinked file may not trigger reload (UNVERIFIED).
- No blockers for arm64 (managed code compiled per arch).

## 11. Build and test steps

```sh
cd apps/feedcord
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name feedcord-probe --read-only --tmpfs /tmp \
  -v feedcord-probe-config:/config feedcord:3.1.0
docker logs -f feedcord-probe
forgetool containers test --image feedcord:3.1.0 --config ./apps/feedcord/container-test.yaml
docker rm -f feedcord-probe; docker volume rm feedcord-probe-config
```

Readiness signal: log line `Number of configurations loaded: 0` followed by the host staying up (`Application started` from `Microsoft.Hosting.Lifetime`; the `Microsoft.Hosting` filter is `Warning`, so rely on the container staying running instead). Manually also run once with a real `appsettings.json` and a dummy webhook to confirm `Validating & Registering Background Service` and that `feed_dump.csv` lands in `/config` with `PersistenceOnShutdown: true`. Try arm64 only if the amd64 build passes.

## 12. PR checklist

- Branch `feat/add-feedcord`, commit and PR title `feat(feedcord): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- CLA notice: tell the user a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- State honestly what is untested: the net9 retarget build, arm64 build, a real Discord webhook run, `PersistenceOnShutdown` symlink behaviour, and unchecked "Built container locally" until it is actually built.
- `docker buildx bake --print` run, `VERSION` in bake equals Dockerfile `ARG VERSION`, no weakened assertions.
