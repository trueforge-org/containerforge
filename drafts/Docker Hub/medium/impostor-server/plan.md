# impostor-server — implementation plan
> Source: ./draft.md · Target: apps/impostor-server/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.10.10` (latest stable release of `AeonLucid/Impostor`, published 2026-11-16, not a prerelease). Matches the draft's `v1.10.10`; the draft's chart also lists `nightly`, which this plan ignores (stable only). |
| Renovate | `datasource=github-releases depName=AeonLucid/Impostor versioning=semver` |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`; use `GPL-3.0-only` unless the `LICENSE` header says "or later", UNVERIFIED which) |
| Source URL | https://github.com/AeonLucid/Impostor |
| Per-arch download | amd64: `https://github.com/AeonLucid/Impostor/releases/download/v1.10.10/Impostor-Server_1.10.10_linux-x64.tar.gz`; arm64: `.../Impostor-Server_1.10.10_linux-arm64.tar.gz` |
| Checksum source | GitHub release asset digests: linux-x64 `sha256:39362bc4fe5f09098fb60140be8ea55ca05a4c020a06a2a6e594269b71b0905d`, linux-arm64 `sha256:9af6f001135fb5b94746f8131fa4eba8d0dc80cfa19d593d743c96a7efeb4b0a` (read through the releases API; no `.sha256` file is published). |
| Upstream Dockerfile reviewed | Yes (tag `v1.10.10`/master): `dotnet/sdk:10.0` build, `dotnet publish -r linux-<arch>`, final `mcr.microsoft.com/dotnet/aspnet:10.0`, `WORKDIR /app`, `ENV ASPNETCORE_URLS=`, `EXPOSE 22023/tcp 22023/udp`, `ENTRYPOINT ["./Impostor.Server"]`. |

Findings from the release tarball (downloaded and listed): 7 files only: `Impostor.Server` (1.2 MB ELF), `config.json`, `Impostor.Server.pdb`, `Impostor.Server.staticwebassets.endpoints.json`, `Impostor.Api.pdb`, `Impostor.Api.xml`, `Impostor.Server.xml`. There is no `.dll` and no `runtimeconfig.json`, so it is a framework-dependent single-file bundle: it needs the .NET 10 ASP.NET Core runtime installed (upstream docs: "Install .NET 10.0 ... ASP.NET Core Runtime"). UNVERIFIED: that the bundle runs with `DOTNET_ROOT` alone (to be confirmed by the first run).

Behaviour (from `Program.cs`, docs):
- Config sources, in order: `config.json` in the **current working directory**, `config.Development.json`, env vars with prefix `IMPOSTOR_` (pattern `IMPOSTOR_Section__Key`, for example `IMPOSTOR_Server__PublicIp`), then command-line args.
- Default `config.json`: `Server.PublicIp 127.0.0.1`, `PublicPort 22023`, `ListenIp 0.0.0.0`, `ListenPort 22023`; `HttpServer.Enabled true` on `0.0.0.0:22023`; `AntiCheat`, `Timeout`, `Compatibility`, `Debug.GameRecorder*` sections.
- Port 22023 is used on both TCP (HTTP matchmaking, open `http://localhost:22023` to test) and UDP (game traffic).
- Plugins and libraries come from `PluginLoader.Paths` / `LibraryPaths` (both empty by default).

## 2. Target layout

```
apps/impostor-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.json    # not committed: copied out of the release tarball at build time (see section 4); no file needed here
```
Only `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh` are committed. The default `config.json` is saved into `/defaults/` inside the image by the Dockerfile from the tarball, so `defaults/` is not created in the app folder. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The .NET runtime comes from the Ubuntu 26.04 archive (`aspnetcore-runtime-10.0` exists for resolute per Launchpad and USN-9042-1; Microsoft's repo no longer carries Ubuntu packages). Closest siblings: `apps/sonarr` (.NET app on ubuntu, `/app/bin`, `--data=/config`) and `apps/adguardhome-sync` (tarball per arch). `apps/webgrabplus` installs .NET with `dotnet-install.sh`; prefer apt here.

## 4. Dockerfile

1. `FROM` the ubuntu line above, `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `WORKDIR /app`.
2. Env: `ENV DOTNET_ROOT=/usr/lib/dotnet DOTNET_EnableDiagnostics=0 DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet-bundle DOTNET_CLI_HOME=/tmp ASPNETCORE_URLS=` (as upstream blanks `ASPNETCORE_URLS`). UNVERIFIED: the install dir of the Ubuntu package (`/usr/lib/dotnet` expected; check with `dpkg -L aspnetcore-runtime-10.0`).
3. `apt-get update && apt-get install -y --no-install-recommends aspnetcore-runtime-10.0 && rm -rf /var/lib/apt/lists/*`. The package version tracks the .NET runtime (10.0.x), not the Impostor version, so it cannot be pinned against `VERSION`; keep the series in the package name (`-10.0`) and state this exception in the PR. Add `libicu`-based packages only if the first run reports an ICU error (UNVERIFIED), or set `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1`.
4. Download and verify (both arches):
   ```sh
   case "${TARGETARCH}" in amd64) A=x64; SHA=39362bc4fe5f09098fb60140be8ea55ca05a4c020a06a2a6e594269b71b0905d;; arm64) A=arm64; SHA=9af6f001135fb5b94746f8131fa4eba8d0dc80cfa19d593d743c96a7efeb4b0a;; esac
   curl -fsSL -o /tmp/impostor.tar.gz "https://github.com/AeonLucid/Impostor/releases/download/v${VERSION}/Impostor-Server_${VERSION}_linux-${A}.tar.gz"
   echo "${SHA}  /tmp/impostor.tar.gz" | sha256sum -c -
   ```
   The hashes belong to 1.10.10; when Renovate bumps `VERSION` they must be refreshed (fetch `assets[].digest` from the releases API instead if the maintainers want it fully automatic; rate limits make that UNVERIFIED for CI).
5. `mkdir -p /app /defaults && tar xzf /tmp/impostor.tar.gz -C /app`, `mv /app/config.json /defaults/config.json`, `chmod 755 /app/Impostor.Server`, `chown -R root:root /app /defaults && chmod -R 755 /app /defaults`, `rm /tmp/impostor.tar.gz`.
6. License: `curl -fsSL -o /usr/share/licenses/impostor-server/LICENSE "https://raw.githubusercontent.com/AeonLucid/Impostor/v${VERSION}/LICENSE"` (after `mkdir -p`), because the tarball ships none.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 22023/tcp 22023/udp`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "impostor-server" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=AeonLucid/Impostor versioning=semver
  default = "1.10.10"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/AeonLucid/Impostor" }
```
Plus the four standard targets and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/AeonLucid/Impostor"
ports:
  - { port: 22023, protocol: tcp, required: true }
  - { port: 22023, protocol: udp, required: true }
env:
  - { name: TZ, default: "Etc/UTC", required: false }
  - { name: IMPOSTOR_Server__PublicIp, default: "127.0.0.1", required: false }
  - { name: IMPOSTOR_Server__PublicPort, default: "22023", required: false }
  - { name: IMPOSTOR_Server__ListenIp, default: "0.0.0.0", required: false }
  - { name: IMPOSTOR_Server__ListenPort, default: "22023", required: false }
  - { name: IMPOSTOR_AntiCheat__Enabled, default: "true", required: false }
volumes:
  - path: /config
    required: true
dependencies: []
```
Use the sibling block style in the real file. All `IMPOSTOR_*` names are the real ones from the upstream docs (read by ASP.NET configuration, not by `start.sh`). Further sections can be set through the same pattern; they are not listed individually. `PublicIp` must be set to the address clients connect to (upstream docs).

## 7. start.sh

1. `set -eu`; `cd /config`; `mkdir -p /config`.
2. Seed on an empty `/config`: `[[ -f /config/config.json ]] || cp /defaults/config.json /config/config.json` (never overwrite; env vars still take precedence over the file).
3. Optional plugin dirs: `mkdir -p /config/plugins /config/libraries`, and export `IMPOSTOR_PluginLoader__Paths__0=/config/plugins` and `IMPOSTOR_PluginLoader__LibraryPaths__0=/config/libraries` only if the user did not set them (UNVERIFIED: array-key env binding for these lists; verify by loading a dummy plugin).
4. Ensure `/tmp/dotnet-bundle` exists, then `exec /app/Impostor.Server "$@"`. The server listens on `0.0.0.0:22023` by default, and the working directory is `/config` so `config.json` is read from there.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
  - port: '22023'
http:
  - port: '22023'
    path: /
filePaths:
  - /app/Impostor.Server
  - /defaults/config.json
  - /config/config.json
  - /usr/share/licenses/impostor-server/LICENSE
```
settings.yaml lists 22023 on tcp and udp; the tcp entry covers the TCP listener. forgetool has no UDP probe, so UDP 22023 is not tested automatically (check by hand, section 11). The HTTP path `/` returning 200 is UNVERIFIED (upstream says opening `http://localhost:22023` tests the server); drop the `http` block and keep `tcp` if it returns another status. No env vars are required.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `config.json` read from cwd | cwd `/config`, seeded from `/defaults/config.json` |
| Single-file bundle extraction (`~/.net`) | `DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet-bundle` |
| .NET CLI/telemetry home | `DOTNET_CLI_HOME=/tmp` |
| Plugins and libraries (`/app/plugins`, `/app/libraries` in upstream docker) | `/config/plugins`, `/config/libraries` |
| Game recorder (`Debug.GameRecorderPath`, off by default) | set a path under `/config` if enabled |

Draft expectations match: chart UID 568, read-only rootfs true, state only in `/config`. Not privileged. The draft's "UDP game port only" is accurate, but the same port number is also used for TCP/HTTP matchmaking.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: UDP 22023 must be reachable and the host mapping must forward UDP as well as TCP; `PublicIp` has to be the externally reachable address or clients cannot join.
- Draft caveat about the runtime resolved: the tarball is framework-dependent, so the apt runtime is required (not self-contained).
- UNVERIFIED: Ubuntu package install path and whether the apphost finds the runtime via `DOTNET_ROOT`; ICU requirement.
- HTTPS is not terminated by Impostor; a reverse proxy is needed for non-local clients (upstream docs).
- No GPL source-offer files are shipped with the binary tarball; the PR should link the source URL (done via `SOURCE`).
- Blockers: none (glibc, arm64 asset exists, no privileges needed).

## 11. Build and test steps

```sh
cd apps/impostor-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create impostor-server-probe-config
docker run --rm -d --name impostor-server-probe --read-only --tmpfs /tmp -v impostor-server-probe-config:/config -p 22023:22023/tcp -p 22023:22023/udp impostor-server:1.10.10
docker logs -f impostor-server-probe     # expect "Starting Impostor v1.10.10" and a listening line for 22023
curl -fsS localhost:22023/ ; (command -v nc && nc -zu localhost 22023)
forgetool containers test --image impostor-server:1.10.10 --config ./apps/impostor-server/container-test.yaml
docker rm -f impostor-server-probe; docker volume rm impostor-server-probe-config
```
Readiness signal: the Serilog line `Starting Impostor v1.10.10` (from `Program.cs`) followed by listener start messages (exact wording UNVERIFIED) and the process staying up. Re-run once with `-e IMPOSTOR_Server__PublicIp=<ip>` to confirm env overrides work.

## 12. PR checklist

- Branch `feat/add-impostor-server`; commit and PR title `feat(impostor-server): add new container`; target `main`; use `.github/PULL_REQUEST_TEMPLATE.md`, only true boxes checked.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Checklist: bake `--print` ok, `ARG VERSION` equals bake `VERSION`, checksums match the version, final `USER apps`, `COPY --chmod=0755 . /`, empty `/config` start.
- Untested until run: the apt .NET runtime with the single-file bundle, ICU needs, arm64, UDP reachability, plugin loading, real Among Us client join.
