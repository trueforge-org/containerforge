# remotely — implementation plan
> Source: ./draft.md · Target: apps/remotely/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2024.08.07.0819` (latest GitHub release, published 2024-08-12). The draft's value is correct. Docker Hub `immybot/remotely:latest` was last pushed 2024-08-12. Repo last pushed 2024-12-17, so upstream is effectively stale. |
| Renovate | `// renovate: datasource=github-releases depName=immense/Remotely versioning=loose` (tags are `vYYYY.MM.DD.NNNN`, not semver) |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`, https://api.github.com/repos/immense/Remotely) |
| Source URL | https://github.com/immense/Remotely |
| amd64 download | https://github.com/immense/Remotely/releases/download/v2024.08.07.0819/Remotely_Server_Linux-x64.zip (asset confirmed, 776,050,714 bytes) |
| arm64 download | None published. Source build required. |
| Checksum source | UNVERIFIED: the release lists no checksum file. The GitHub asset `digest` field was not checked; check it before relying on it. |
| Upstream Dockerfile reviewed | https://github.com/immense/Remotely/blob/ec0d45d/Server/Dockerfile: `FROM mcr.microsoft.com/dotnet/aspnet:8.0`, `EXPOSE ${ASPNETCORE_HTTP_PORTS}`, `COPY Server/bin/publish /app`, `WORKDIR /app`, `ENTRYPOINT ["dotnet", "Remotely_Server.dll"]`, HEALTHCHECK `curl -f http://localhost:${ASPNETCORE_HTTP_PORTS}/api/healthcheck`. No ENV, VOLUME, USER. |
| Upstream rootless Dockerfile reviewed | `Server/Dockerfile.rootless` at ec0d45d: `FROM ubuntu:jammy`, `ENV ASPNETCORE_URLS=http://*:5000`, installs `aspnetcore-runtime-8.0`, unpacks the zip to `/var/www/remotely`, rewrites the SQLite path to `/remotely-data`, `VOLUME "/remotely-data"`, `USER remotely` (uid 2001). Do not copy its uid or `/var/www` layout; it is the reference for the runtime shape only. |
| Port | `ASPNETCORE_HTTP_PORTS=5000` (compose `ports: "5000:5000"`). The 5001 TLS port in the draft is UNVERIFIED and not in upstream compose. |
| Env vars (real, from the release compose file) | `ASPNETCORE_ENVIRONMENT=Production`, `ASPNETCORE_HTTP_PORTS=5000`, `Remotely_ApplicationOptions__DbProvider=SQLite` (SQLite, SQLServer, PostgreSQL), `Remotely_ConnectionStrings__SQLite=Data Source=/app/AppData/Remotely.db` (compose path, we change it), `Serilog__MinimumLevel__Override__Microsoft.AspNetCore=Warning`, `Serilog__MinimumLevel__Override__System=Warning`, `Remotely_ApplicationOptions__DockerGateway` (compose-only, needed only for forwarded headers behind the compose bridge). Source: https://github.com/immense/Remotely/releases/download/v2024.08.07.0819/docker-compose.yml |
| Default config | `Server/appsettings.json`: `DbProvider` = `SQLite`, default SQLite data source is the relative `Remotely.db` (lands in the working directory `/app`). |
| Data paths | Compose mounts a volume at `/app/AppData`. Rootless variant uses `/remotely-data`. Data Protection key location: UNVERIFIED (not found in `Program.cs`). |
| Health endpoint | `/api/healthcheck` (from the upstream HEALTHCHECK) |
| Dependencies | None required. SQL Server and PostgreSQL are optional providers, not used here. |
| Docker Hub `immybot/remotely` | `latest` is amd64 only (WebFetch of hub.docker.com/v2 tags, 31 tags total). No arm64 image, so `copy-from arm64` = no. The amd64 image is not used for COPY (we use the release zip). |

## 2. Target layout

Files under `apps/remotely/`:

- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh` (reads env, sets the SQLite path to `/config`, `exec`s the server)

No `defaults/` (the app writes its own DB on first start). No `etc/`, `health/`, `root/` needed. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The `docker-compose.yml` from the release is reference only and is not shipped.

## 3. Base image

- Final and build stages: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The app is a .NET 8 ASP.NET Core server; ContainerForge has no .NET sibling. The ubuntu base is the same choice as `apps/adguardhome-sync` and the draft's Base container section.
- Runtime: `aspnetcore-runtime-8.0` from the Ubuntu archive is UNVERIFIED for `resolute` (26.04). If it is absent, use Microsoft's `dotnet-install.sh` with a pinned version and verify the download, or install the runtime in a build stage and copy it. Do not use `COPY --from=mcr.microsoft.com/dotnet/aspnet:8.0` (not a ContainerForge base).
- Closest siblings: `apps/adguardhome-sync` (prebuilt tarball on ubuntu, `USER apps`, `HOME=/config`). No .NET sibling exists.

## 4. Dockerfile

1. Pre-check (one-off, before writing): run `apt-cache policy aspnetcore-runtime-8.0 dotnet-sdk-8.0` inside the ubuntu base to confirm the packages exist. Record the result in section 10.
2. `FROM <ubuntu> AS build`: `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
3. amd64 path (`TARGETARCH=amd64`):
   - `curl -fL -o /tmp/remotely.zip "https://github.com/immense/Remotely/releases/download/${VERSION}/Remotely_Server_Linux-x64.zip"`.
   - Extract with `unzip` into `/app` (install `unzip` in the build stage only, then purge).
   - The zip may be self-contained (776 MB). If it is not self-contained, install the aspnet 8 runtime (step 4). Whether it is self-contained is UNVERIFIED; check `Remotely_Server.runtimeconfig.json` after extraction for `includedFrameworks`.
4. arm64 path (`TARGETARCH=arm64`): no release asset. Build from source at the tag `${VERSION}` with the .NET 8 SDK: `dotnet publish Server/Server.csproj -c Release -r linux-arm64 --self-contained false -o /app`. Requires `dotnet-sdk-8.0` (UNVERIFIED availability on 26.04) or dotnet-install. This is a separate build path; mark arm64 as `compile` in the bake notes and test it separately.
5. License: copy `LICENSE` from the source tree to `/usr/share/licenses/remotely/LICENSE`.
6. Permissions: `chown -R apps:apps /app && chmod -R 755 /app` (same as adguardhome-sync).
7. Final stage (same ubuntu base, `USER root` to install only what runtime needs, then `USER apps`):
   - `apt-get install -y --no-install-recommends aspnetcore-runtime-8.0 curl` (only if not self-contained; `curl` is needed by the upstream HEALTHCHECK, which we skip, so drop it unless used).
   - `apt-get clean && rm -rf /var/lib/apt/lists/*`.
8. `ENV ASPNETCORE_ENVIRONMENT=Production ASPNETCORE_HTTP_PORTS=5000 HOME=/config DOTNET_CLI_TELEMETRY_OPTOUT=1`. `HOME=/config` keeps Data Protection keys (default `~/.aspnet/DataProtection-Keys` on Linux) persistent, if the app uses that default (UNVERIFIED).
9. `COPY --from=build /app /app` and `COPY --from=build /usr/share/licenses/remotely /usr/share/licenses/remotely`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME /config
WORKDIR /app
```

`WORKDIR /app` keeps the upstream working directory, so relative paths in the app (wwwroot, Content) still resolve.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "remotely"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=immense/Remotely versioning=loose
  default = "v2024.08.07.0819"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/immense/Remotely"
}
```

Then the four standard targets (`image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` keeps the leading `v`, which matches the release tag and the Dockerfile download URL (`releases/download/${VERSION}/...`). Validate with `docker buildx bake --print` from `apps/remotely/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/immense/Remotely"
ports:
  - port: 5000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: ASPNETCORE_HTTP_PORTS
    default: "5000"
    required: false
  - name: Remotely_ApplicationOptions__DbProvider
    default: "SQLite"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Notes:
- Do not list `Remotely_ConnectionStrings__SQLite` here unless `start.sh` sets it from a value the user may change. It is set in `start.sh` (step 7).
- `Remotely_ApplicationOptions__DockerGateway` is compose-only: do not add it.
- Serilog overrides are optional logging knobs, not required. Leave them out (the discipline rule: do not invent env vars the app is not known to read; these are read by the app per the compose file, so they could be listed as optional if wanted).
- `dependencies: []` because nothing is required.

## 7. start.sh

Requirements:
- Idempotent. Creates `/config` data on first start only; never writes to `/app`.
- Pin the SQLite data source to `/config`:
  ```bash
  export Remotely_ConnectionStrings__SQLite="Data Source=/config/Remotely.db"
  ```
  (Overrides the relative default in `appsettings.json`, which would write into `/app`.)
- `mkdir -p /config` if missing. Do not seed a config file (none is required).
- Bind all interfaces: `ASPNETCORE_URLS` is not set in the upstream compose (only `ASPNETCORE_HTTP_PORTS`), and ASP.NET Core defaults to `http://*:<port>` when the port env is set. Confirm with a `curl` from outside the container in step 11 (UNVERIFIED binding behaviour).
- `exec dotnet Remotely_Server.dll` (PID 1 handoff). Run from `/app`.

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
export Remotely_ConnectionStrings__SQLite="Data Source=/config/Remotely.db"

cd /app
exec dotnet Remotely_Server.dll
```

For the arm64 source build, the binary name may differ (`Remotely_Server` vs `Remotely_Server.dll`); verify after the build and adjust.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '5000'

http:
- port: '5000'
  path: /api/healthcheck
```

- Every `settings.yaml` port has a probe (`5000`).
- The `http` probe path `/api/healthcheck` comes from upstream HEALTHCHECK. Confirm that forgetool's `http` schema accepts `path` (UNVERIFIED against the schema file, which was not fetched).
- Test runs with no env vars. `ASPNETCORE_HTTP_PORTS=5000` is baked into the Dockerfile `ENV`, so the default start works without env. Nothing in `start.sh` depends on a required env var, so no `filePaths` entry is needed.
- `timeoutSeconds`: use the value of a .NET sibling if one exists (none); start with 120 for the first DB migration, then tune in step 11.

## 9. Rootless and read-only-rootfs adaptations

Upstream write paths and their remap:

| Upstream write | Upstream path | ContainerForge path |
| --- | --- | --- |
| SQLite DB (`Remotely.db`) | relative, so `/app` in the publish layout; compose uses `/app/AppData` | `/config/Remotely.db` via `start.sh` (env override) |
| Data Protection keys | default `~/.aspnet` (UNVERIFIED) | `HOME=/config` |
| Logs | UNVERIFIED (Serilog sink config not checked) | Confirm in step 11; if a file sink exists, point it at `/config/logs` or `/tmp` |
| Temp/caches | none documented | `/tmp` (the test uses `--tmpfs /tmp`) |

Security expectations from the draft, reconciled:
- non-root: upstream `runAsUser 0` (chart). Our image uses `USER apps` (uid from the ubuntu base). Not the rootless uid 2001 from upstream.
- read-only rootfs: the app runs with `--read-only --tmpfs /tmp` in the protocol. It must not write to `/app`. Confirmed by the `start.sh` override and the `HOME=/config` setting above.
- privileged: not required.
- persistence: `/config` only. The chart's `/app/AppData` is replaced by `/config`.

## 10. Risks, caveats and open questions

- Upstream is stale: latest release 2024-08-12, repo last pushed 2024-12-17. Security patches are not coming. Decide whether to ship with a warning.
- arm64 has no release binary. It needs a .NET 8 SDK build path (step 4), which is untested. Expect a longer build and a separate test.
- Zip size (776 MB) makes the amd64 image large. Check whether the zip is self-contained (step 3) so the apt runtime install can be dropped.
- Checksum: none published (see section 1). Not blocking, but state it in the bake notes and the PR.
- Draft caveats, confirmed or noted:
  - Agents must reach the server at a public URL. Not a build issue, but document it in the PR.
  - Chart and draft disagree on the data path (`/app/AppData` vs `/config`). Resolved here: `/config`.
  - The first admin account is created by the setup wizard on first login (not testable by the container test).
- Blockers to check before coding: `aspnetcore-runtime-8.0` availability on ubuntu 26.04 (section 4 step 1); Remotely requires an SDK for arm64 (not verified).
- Unverified: data-protection key location, Serilog file sink, binding behaviour without `ASPNETCORE_URLS`, forgetool `http.path` schema support, the GitHub asset checksum digest.

## 11. Build and test steps

From `apps/remotely/` (per the build-test protocol):

1. `docker buildx bake --print`: must exit 0.
2. Build: `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with an empty `/config`:
   ```sh
   docker volume rm remotely-probe-config 2>/dev/null || true
   docker run --rm -d --name remotely-probe --read-only --tmpfs /tmp \
     -v remotely-probe-config:/config remotely:v2024.08.07.0819
   docker logs -f remotely-probe   # until idle or a readiness line
   ```
   Expected readiness signal: `Now listening on: http://[::]:5000` (ASP.NET Core default log line; UNVERIFIED exact text) and a 200 from `curl -f http://localhost:5000/api/healthcheck` run inside the container.
4. Check that `/config/Remotely.db` was created and that nothing was written to `/app`.
5. Test: `forgetool containers test --image remotely:v2024.08.07.0819 --config ./apps/remotely/container-test.yaml`.
6. Cleanup: `docker rm -f remotely-probe; docker volume rm remotely-probe-config`.
7. arm64: only if the amd64 path is green; build with `--set image-local.platform=linux/arm64`.

## 12. PR checklist

- Branch: `feat/add-remotely`.
- Commit: `feat(remotely): add new container`.
- PR title: `feat(remotely): add new container`.
- PR description: the PR template at `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- Say what was not tested: arm64 build (if not run), forgetool run (if not run), any UNVERIFIED item above.
- Downstream: none (not a `FROM` base), so no `DOWNSTREAM_CHANGES.md`.
