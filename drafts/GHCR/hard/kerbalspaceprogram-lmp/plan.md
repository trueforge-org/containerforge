# kerbalspaceprogram-lmp — implementation plan
> Source: ./draft.md · Target: apps/kerbalspaceprogram-lmp/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart image | `ghcr.io/ich777/lunamultiplayer-ksp:latest` (draft; unpinned) |
| Latest upstream release | `0.29.2`, published 2026-05-17T02:01:02Z, prerelease false (`gh api repos/LunaMultiplayer/LunaMultiplayer/releases/latest`) |
| Renovate | `datasource=github-releases depName=LunaMultiplayer/LunaMultiplayer versioning=semver` |
| License | MIT (`gh api repos/LunaMultiplayer/LunaMultiplayer`, SPDX `MIT`) |
| Source URL | https://github.com/LunaMultiplayer/LunaMultiplayer |
| Server download (amd64) | `https://github.com/LunaMultiplayer/LunaMultiplayer/releases/download/0.29.2/LunaMultiplayer-Server-linux-x64-Release.zip` (asset name confirmed on the release API) |
| Other server assets | `LunaMultiplayer-Server-linux-x64-Debug.zip` (not used), `LunaMultiplayer-Server-Release.zip` (not linux-x64 specific; UNVERIFIED whether it runs on Linux) |
| arm64 | No arm64 server asset on the release. The draft's arm64 link, `releases/tag/0.29.2`, is a tag page, not a download. arm64 is not available. |
| Checksum source | UNVERIFIED: no checksum file appears in the release asset list. |
| Runtime | The wrapper installs `aspnetcore-runtime-6.0` from Microsoft's Debian 11 repo (`ich777/docker-lunamultiplayer-ksp`). Whether 0.29.2 targets .NET 6 or a newer runtime is UNVERIFIED. |
| Upstream wrapper Dockerfile reviewed | `https://raw.githubusercontent.com/ich777/docker-lunamultiplayer-ksp/master/Dockerfile`. `FROM ich777/debian-baseimage:bullseye_amd64`; apt `wget apt-transport-https`, then `aspnetcore-runtime-6.0 jq unzip`; downloads `https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb`; `ENV DATA_DIR="/lunamultiplayer" LMP_V="latest" GAME_PARAMS="" UMASK=000 UID=99 GID=100 DATA_PERM=770 USER="lmp"`; no `USER` instruction (runs as root); no EXPOSE; no VOLUME; `ENTRYPOINT ["/opt/scripts/start.sh"]`. |
| Wrapper license | None declared (`gh api repos/ich777/docker-lunamultiplayer-ksp`). The plan does not copy the wrapper. |
| Ports | Draft: 8800/udp (inferred). UNVERIFIED: not confirmed on any fetched page. |
| Data path | `/lunamultiplayer` (`DATA_DIR`, wrapper). The server's own write paths are UNVERIFIED. |
| `copy-from` | amd64 `ghcr.io/ich777/lunamultiplayer-ksp:latest` exists per the draft, but it is not used: the rule is to fetch the release zip, not to copy from the wrapper image. |

## 2. Target layout

- `apps/kerbalspaceprogram-lmp/Dockerfile`
- `apps/kerbalspaceprogram-lmp/docker-bake.hcl`
- `apps/kerbalspaceprogram-lmp/settings.yaml`
- `apps/kerbalspaceprogram-lmp/container-test.yaml`
- `apps/kerbalspaceprogram-lmp/start.sh`

No `defaults/`, `etc/` or `health/` unless the server needs a default `Config` file (UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. The draft's "no .NET base" note matches: no ContainerForge java or python base provides .NET, so the .NET runtime is installed with apt on ubuntu. The Fenrus plan (a draft plan, not an existing app) states `aspnetcore-runtime-10.0` and `dotnet-sdk-10.0` exist in the Ubuntu 26.04 archive (amd64 and arm64, packages.ubuntu.com, 2026-11-23). Those package versions are for .NET 10, and the LMP 0.29.2 target version is UNVERIFIED (section 10).

Closest sibling: `apps/webgrabplus` (dotnet runtime on ubuntu, `ENV HOME=/config`, `WORKDIR /config`; it installs .NET with `dotnet-install.sh` into `/app/dotnet`, not apt, so the apt route here is a deviation).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Fail early on arm64, because no arm64 server asset exists:
   ```dockerfile
   RUN if [ "$TARGETARCH" != "amd64" ]; then echo "no arm64 server build" && exit 1; fi
   ```
3. Install the runtime and unpack tool. The exact .NET package is UNVERIFIED until the target framework of 0.29.2 is checked:
   ```dockerfile
   RUN apt-get update && apt-get install -y --no-install-recommends \
       aspnetcore-runtime-<N>.0 unzip && \
     rm -rf /var/lib/apt/lists/*
   ```
   Pin `<N>.0` to the framework the server targets, and check the version against `VERSION` in the comments of the bake file. `libicu` comes from the base; add a `libicu` package only if the server fails without it, as `apps/webgrabplus` does.
4. Download and unpack, with no checksum available (documented risk):
   ```dockerfile
   RUN mkdir -p /app/lmp && \
     curl -fsSL -o /tmp/lmp.zip \
       "https://github.com/LunaMultiplayer/LunaMultiplayer/releases/download/${VERSION}/LunaMultiplayer-Server-linux-x64-Release.zip" && \
     unzip -q /tmp/lmp.zip -d /app/lmp && \
     rm -f /tmp/lmp.zip && \
     chown -R root:root /app && chmod -R 755 /app
   ```
5. Make the server's writable folders point at `/config`. Which folders the server writes to is UNVERIFIED; the symlink targets follow the same pattern as the planned fenrus app (`drafts/Docker Hub/medium/fenrus/plan.md`; `apps/fenrus` does not exist yet) (a build-time symlink to `/config/<dir>`, created dangling and filled by `start.sh`).
6. `ENV HOME=/config DOTNET_CLI_HOME=/tmp DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp`.
7. License: `COPY` the LICENSE from the zip if present (UNVERIFIED that the zip has one), else from the upstream repo to `/usr/share/licenses/kerbalspaceprogram-lmp/LICENSE`.
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8800/udp
   VOLUME /config
   WORKDIR /config
   ```
   `EXPOSE` only after the port is confirmed (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kerbalspaceprogram-lmp"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=LunaMultiplayer/LunaMultiplayer versioning=semver
  default = "0.29.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/LunaMultiplayer/LunaMultiplayer"
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
    "linux/amd64"
  ]
}
```

`image-all` lists only `linux/amd64` because no arm64 server build exists. `VERSION` has no `v` prefix (the tag is `0.29.2`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/LunaMultiplayer/LunaMultiplayer"
ports:
  - port: 8800
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

The port is the draft's inferred 8800/udp and is UNVERIFIED; keep it only until the server's settings file is read. The env list is empty of server settings until the server's own configuration keys are confirmed; do not invent variables. `dependencies` is empty: no database, and the KSP client is not a container dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app/lmp
exec dotnet LunaMultiplayerServer.dll
```

The entry DLL name is UNVERIFIED (the zip layout is not confirmed). The script must seed a default settings file into `/config` only when it is missing (`cp -n`), and must not overwrite existing user state. It must bind to all interfaces (`0.0.0.0`) if the server config has a bind address (UNVERIFIED key). It writes only to `/config` and `/tmp`. Keep the final `exec`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/lmp
runners:
- entrypoint: /usr/bin/dotnet --list-runtimes
```

A UDP probe is not available in the `tcp` and `http` primitives, and the schema for UDP checks is UNVERIFIED. Until a UDP check is confirmed in forgetool's schema, the test covers the runtime and files only. This is a coverage gap for the declared 8800/udp port; list it in the PR as untested. Do not drop the port from `settings.yaml` to hide the gap.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/lunamultiplayer` (wrapper `DATA_DIR`, serverfiles, chart PVC) | `/config` (persistent) |
| Server write folders under `/app/lmp` (UNVERIFIED which) | Build-time symlinks to `/config/<dir>` |
| .NET bundle extraction and CLI home | `/tmp` via `DOTNET_BUNDLE_EXTRACT_BASE_DIR`, `DOTNET_CLI_HOME` |
| Wrapper runs as UID 0 (chart `runAsUser: 0`) | Final stage `USER apps` (UID 568). The wrapper's `UID=99`, `GID=100` defaults are not used. |

Reconciled draft expectations: chart runs as root and `readOnlyRootFilesystem: false`, which ContainerForge does not need; not privileged; the only network need is UDP 8800 (UNVERIFIED). The chart's `/lunamultiplayer` PVC maps to `/config`, so existing users must move their data into `/config`.

## 10. Risks, caveats and open questions

- arm64: no server asset is published. Blocker for `image-all` arm64 and for the ContainerForge multi-arch rule.
- Target .NET version of LMP 0.29.2 is UNVERIFIED. The wrapper's .NET 6 runtime may be wrong for 0.29.2, and the Ubuntu 26.04 archive has .NET 10 packages (verified in the Fenrus plan, not for this app).
- No checksum for the zip. Pin by version and document the risk.
- The `Debug` vs `Release` asset choice follows the wrapper's behavior (not confirmed); use Release.
- Server settings keys, bind address and listening port are UNVERIFIED. Until confirmed, `settings.yaml` port and env lists stay minimal.
- The client needs a matching Kerbal Space Program install with the LMP plugin. The server alone is not a complete game setup. This is a usage caveat, not a build blocker.
- Hard difficulty: .NET runtime is not in any ContainerForge base, and the server runs as root in the wrapper. Not musl-only, GPU-free, not privileged.

## 11. Build and test steps

```sh
cd apps/kerbalspaceprogram-lmp
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name kerbalspaceprogram-lmp-probe --read-only --tmpfs /tmp \
  -v kerbalspaceprogram-lmp-probe-config:/config kerbalspaceprogram-lmp:0.29.2
docker logs -f kerbalspaceprogram-lmp-probe
forgetool containers test --image kerbalspaceprogram-lmp:0.29.2 --config ./apps/kerbalspaceprogram-lmp/container-test.yaml
docker rm -f kerbalspaceprogram-lmp-probe; docker volume rm kerbalspaceprogram-lmp-probe-config
```

Expected readiness signal: UNVERIFIED (server log line not confirmed). Required checks: the process stays up, the UDP port is open (checked by hand with `ss -lun` inside the container, since the test schema may not cover UDP), and the log has no fatal .NET exception. Run once on an empty `/config` and once after a restart.

## 12. PR checklist

- Branch `feat/add-kerbalspaceprogram-lmp`, commit and PR title `feat(kerbalspaceprogram-lmp): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: arm64 (not published upstream), the UDP probe, the .NET version choice, the server's runtime behavior, the no-checksum download, and client connection.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; `image-all` lists amd64 only.
