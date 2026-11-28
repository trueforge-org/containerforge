# fenrus — implementation plan
> Source: ./draft.md · Target: apps/fenrus/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream has no tags and no GitHub releases (API returns none). Docker Hub `revenz/fenrus` tags are CalVer `yy.MM` (`26.10`, `latest`, both pushed 2026-10-10). This plan pins a master commit: `c52d4966e3e657b5d38415101985c2f4c10d36c7` (2026-11-20). It is newer than Docker Hub `26.10`; the commit behind `26.10` is UNVERIFIED. |
| Difference from draft | Draft names no version. Draft says "Dockerfile copies a prebuilt build folder": confirmed, upstream `Dockerfile` does `COPY ./build ./`, and `docker.sh` + `DockerfileBuild` produce `build/` with `dotnet publish` first (`DockerfileBuild` still says `sdk:7.0`, stale; `Fenrus.csproj` is `net10.0`). |
| Renovate | `datasource=git-refs depName=https://github.com/revenz/Fenrus currentValue=master` (precedent `apps/tvheadend`) |
| License | MIT (`license` file in repo, GitHub SPDX `MIT`) |
| Source URL | https://github.com/revenz/Fenrus |
| Download | Source tarball `https://github.com/revenz/Fenrus/archive/${VERSION}.tar.gz` (VERSION = commit SHA), compiled for amd64 and arm64 with `dotnet publish`. No prebuilt binary. |
| Checksum source | None published. The tarball is pinned by commit SHA (content-addressed). |
| Upstream Dockerfile reviewed | `Dockerfile` (aspnet:10.0 base, `COPY ./build ./`, `COPY /Apps /app/Apps`, `ENV Docker=1`, entrypoint `docker-entrypoint.sh`), `DockerfileBuild`, `docker.sh`, `setversion.sh`, `docker-entrypoint.sh`, `reset.sh`. |
| Port | `PORT` env, default 3000; `PROTOCOL` env, default `http`. Entrypoint: `dotnet Fenrus.dll --urls=${protocol}://+:${port}`. |
| Env vars (real) | `PORT`, `PROTOCOL`, `Docker=1` (set by image, `Globals.IsDocker`), `DetailedErrors=1`, `ReverseProxySettings__UseForwardedHeaders`, `ReverseProxySettings__DebugPrintRequestHeaders`, `ReverseProxySettings__KnownProxies`, `ReverseProxySettings__KnownIPv4Network__{Enabled,IpAddress,PrefixLength}`, `ReverseProxySettings__KnownIPv6Network__{Enabled,IpAddress,PrefixLength}` (README table; `AddEnvironmentVariables()` in `Program.cs`). |
| Data path | Hard-coded: `DirectoryHelper.GetDataDirectory()` = `<AppContext.BaseDirectory>/data` (`Fenrus.db` LiteDB, `encryptionkey.txt`, logs in `data/logs`, data-protection keys, drive files). No env override. |
| Reset | `/app/reset.sh` runs `dotnet Fenrus.dll --init-config` (deletes system settings, then `kill 1`). |
| apt on Ubuntu 26.04 (resolute) | `dotnet-sdk-10.0` 10.0.114-0ubuntu1~26.04.1 and `aspnetcore-runtime-10.0` 10.0.14-0ubuntu1~26.04.1, amd64 and arm64 (packages.ubuntu.com). |

## 2. Target layout

- `apps/fenrus/Dockerfile`
- `apps/fenrus/docker-bake.hcl`
- `apps/fenrus/settings.yaml`
- `apps/fenrus/container-test.yaml`
- `apps/fenrus/start.sh` (replaces upstream `docker-entrypoint.sh`)

No `defaults/`, `etc/`, `health/` needed (the app creates its own data on first start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the build stage and the final stage. Fits because both .NET 10 packages exist in the 26.04 archive and the base already carries `libicu-dev`, curl, tar. Closest sibling: `apps/webgrabplus` (dotnet on ubuntu) and `apps/pwndrop` (build stage then runtime stage).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends dotnet-sdk-10.0` (no extra packages; `curl` and `tar` are in the base). The apt packages are the toolchain, not the app, so no pin is required against `VERSION`.
3. `ENV DOTNET_CLI_HOME=/tmp DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 NUGET_PACKAGES=/tmp/nuget`.
4. `curl -fL https://github.com/revenz/Fenrus/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
5. Mimic `setversion.sh`: upstream sets `Globals.cs` `BuildNumber` (git commit count) and `VersionNumber` (`yy.MM.week`). The tarball has no git history, so `sed` `VersionNumber`/`BuildNumber` in `Globals.cs` with a numeric `ARG FENRUS_VERSION_NUMBER` (e.g. `26.11.1`) and `BuildNumber="0"`; the value must stay parsable by `System.Version` because `StartUpHelper` calls `Version.TryParse` for upgrades (UNVERIFIED which value is best, see section 10).
6. `cd /tmp/src && dotnet restore && dotnet publish Fenrus.csproj -c Release -o /tmp/build`, then drop what upstream `docker.sh` drops: `rm -rf /tmp/build/runtimes/win* /tmp/build/runtimes/osx* /tmp/build/ru-*`.
7. Final stage `FROM <ubuntu>`, `USER root`, `apt-get install -y --no-install-recommends aspnetcore-runtime-10.0` and clean apt lists. Check that `libicu-dev` from the base is enough (it is what `apps/webgrabplus` relies on; add `libicu78` only if missing, as `webgrabplus` does).
8. `mkdir -p /app/fenrus`, `COPY --from=build /tmp/build/ /app/fenrus/`, `COPY --from=build /tmp/src/Apps /app/fenrus/Apps`, `COPY --from=build /tmp/src/reset.sh /app/fenrus/reset.sh`. License: `COPY --from=build /tmp/src/license /usr/share/licenses/fenrus/LICENSE`.
9. Data redirect: `ln -s /config/data /app/fenrus/data` (dangling until `start.sh` creates `/config/data`). `chown -R apps:apps /app/fenrus` and `chmod -R 755 /app/fenrus`.
10. `ENV Docker=1 DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp DOTNET_EnableDiagnostics=0 HOME=/config PORT=3000 PROTOCOL=http`.
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app/fenrus
```

`WORKDIR /app/fenrus` is needed because the app resolves `Apps`, `wwwroot` and `data` from `AppContext.BaseDirectory` (the directory of `Fenrus.dll`) and `reset.sh` uses relative `Fenrus.dll`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "fenrus" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/revenz/Fenrus currentValue=master
  default = "c52d4966e3e657b5d38415101985c2f4c10d36c7"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/revenz/Fenrus" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`; run `docker buildx bake --print`. The `Dockerfile` consumes the same value through `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/revenz/Fenrus"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3000"
    required: false
  - name: PROTOCOL
    default: "http"
    required: false
  - name: ReverseProxySettings__UseForwardedHeaders
    default: "false"
    required: false
  - name: ReverseProxySettings__KnownProxies
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

The `KnownProxies` default is empty (UNVERIFIED which list syntax the app accepts; an empty value is not passed on). Only the README-documented variables that matter most are listed; the `KnownIPv4Network`/`IPv6Network` variants are read the same way and may be added. Dependencies: none (embedded LiteDB). Draft port 3000 is confirmed by upstream `docker-entrypoint.sh`.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

port="${PORT:-3000}"
protocol="${PROTOCOL:-http}"

cd /app/fenrus
echo "Starting Fenrus at ${protocol}://+:${port}"
exec dotnet Fenrus.dll --urls="${protocol}://+:${port}"
```

`+` binds all interfaces. Idempotent, seeds nothing (Fenrus initialises `Fenrus.db` and the encryption key itself in `data/`), no writes to `/app`. `dotnet` must be on `PATH` (apt installs `/usr/bin/dotnet`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/fenrus/Fenrus.dll
- /app/fenrus/Apps
- /usr/share/licenses/fenrus/LICENSE
```

Port 3000 has both a tcp and an http probe. The first-run initial-config redirect (`InitialConfigMiddleware`) may answer `/` with a redirect or a non-200; confirm which status the http probe sees and use the path that returns 200 (UNVERIFIED). No required env code paths exist (no secrets are needed to start).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (Fenrus.db, encryption key, logs, drive, data-protection keys; hard-coded, no env) | build-time symlink `/app/fenrus/data` -> `/config/data` |
| `/app/wwwroot/images` (chart PVC "images") | Only read by `IconPickerDialog` (`wwwroot/images/icons/*.svg`) in the code reviewed; no write found (UNVERIFIED for every code path). Users may bind-mount custom SVGs read-only at `/app/fenrus/wwwroot/images/icons`; not part of `/config`. |
| .NET bundle extraction, CLI home | `/tmp` via `DOTNET_BUNDLE_EXTRACT_BASE_DIR`, `DOTNET_CLI_HOME` |
| Razor runtime compilation, WebOptimizer bundles | in memory (UNVERIFIED that nothing writes next to the DLL; check logs on `--read-only`) |

Draft expectations reconciled: chart runs as UID 0 (this image runs as `apps` 568, and `/config/data` is created by that user), chart `readOnlyRootFilesystem: false` (image is compatible with `--read-only --tmpfs /tmp`), not privileged. The chart persists `/app/data`; this image uses `/config` (with `data/` inside), so existing users must mount their old `/app/data` content at `/config/data`, or mount `/config` with a `data/` subfolder.

## 10. Risks, caveats and open questions

- No upstream tags: the version is a commit SHA, so Renovate bumps every master push (noisy). Alternative: pin the commit and add `versioning` or schedule-limit in renovate config.
- `Globals.Version` numeric string and `Upgrade_*` steps (run by `StartUpHelper` when the DB records an older version) may misbehave if the baked version is lower than the one in an upstream-created database. UNVERIFIED.
- Clean build required (draft caveat): the tarball build must not reuse upstream `./build`. Done by compiling in the build stage.
- .NET 10 SDK build needs RAM and disk (draft); arm64 compiled natively through buildx.
- `Docker.DotNet` and the terminal/NoVNC features expect docker socket or SSH access; not used by default.
- `reset.sh` runs `kill 1`; with `tini` as PID 1 that stops the container (matches upstream intent).
- `InitConfig` is done through the web UI on first visit (manual setup).
- No blockers (not musl-only, no GPU, no privileged, arm64 supported by .NET 10).

## 11. Build and test steps

```sh
cd apps/fenrus
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name fenrus-probe --read-only --tmpfs /tmp \
  -v fenrus-probe-config:/config fenrus:c52d4966e3e657b5d38415101985c2f4c10d36c7
docker logs -f fenrus-probe
forgetool containers test --image fenrus:c52d4966e3e657b5d38415101985c2f4c10d36c7 --config ./apps/fenrus/container-test.yaml
docker rm -f fenrus-probe; docker volume rm fenrus-probe-config
```

Readiness signals: `Starting Fenrus...`, then ASP.NET `Now listening on: http://[::]:3000` (or `http://0.0.0.0:3000`) and `Application started`. Confirm `/config/data/Fenrus.db` exists after start and that restarting the container keeps it. Also curl from outside the container (`-p 3000:3000`) to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-fenrus`, commit and PR title `feat(fenrus): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: signed CLA required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign, `license/cla` shows status.
- Untested to state honestly: the net10 build on both architectures, runtime on `--read-only`, the `Version` handling and upgrade from an upstream `/app/data`, the http probe status code, and arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
