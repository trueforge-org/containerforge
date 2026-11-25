# terraria-tshock — implementation plan
> Source: ./draft.md · Target: apps/terraria-tshock/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | TShock **6.2.1** for Terraria **1.4.5.8**, released 2026-09-27. Latest and tag `v6.2.1`: https://github.com/Pryaxis/TShock/releases/tag/v6.2.1 (API: `repos/Pryaxis/TShock/releases/tags/v6.2.1`). |
| Upstream image tag | Draft says the chart uses `ghcr.io/ich777/terrariaserver:tshock`. Upstream Dockerfile branch `tshock`: https://github.com/ich777/docker-terraria-server/blob/tshock/Dockerfile |
| Renovate | `datasource=github-releases depName=Pryaxis/TShock` (versioning UNVERIFIED for the `v6.2.1` tag that names Terraria 1.4.5.8). |
| License | GPL-3.0 (GitHub API `license.spdx_id` for https://github.com/Pryaxis/TShock). The Terraria dedicated server itself is not GPL; see section 10. |
| Source URL | https://github.com/Pryaxis/TShock |
| Per-arch download | amd64: https://github.com/Pryaxis/TShock/releases/download/v6.2.1/TShock-6.2.1-for-Terraria-1.4.5.8-linux-x64-Release.zip . arm64: https://github.com/Pryaxis/TShock/releases/download/v6.2.1/TShock-6.2.1-for-Terraria-1.4.5.8-linux-arm64-Release.zip . (also `linux-arm`, `osx-x64`, `win-x64` exist; not used). |
| Checksum source | GitHub release asset digest (API `digest` field). amd64 `sha256:deb9189acbdbd2ee0f0a06fffe15358033859a4ba842b22f79a84bda68600105`. arm64 `sha256:bc97babbff40e4291757b000486a82f9bbc2a0bc1360ec2a4213a84b1b772b98`. |
| Upstream Dockerfile reviewed | ich777 `tshock` branch (WebFetch summary, not verbatim). Base `ich777/mono-baseimage`; apt installs `screen unzip`, and `aspnetcore-runtime-9.0` from the Microsoft Debian 13 feed; downloads gotty v1.0.1 to `/usr/bin`; ENV `DATA_DIR=/serverdata`, `SERVER_DIR=${DATA_DIR}/serverfiles`, `GAME_VERSION`/`GAME_MOD`/`GAME_PARAMS` placeholder `template`, `ENABLE_WEBCONSOLE=true`, `UID=99`, `GID=100`, `USER=terraria`; no USER (runs as root); `ENTRYPOINT ["/opt/scripts/start.sh"]`. The TShock and Terraria download happens in `start.sh`, which the fetch did not retrieve. |
| .NET runtime package | `dotnet-runtime-9.0` and `aspnetcore-runtime-9.0` return **no results** on packages.ubuntu.com (all suites). The draft's apt route is NOT confirmed. Source: https://packages.ubuntu.com/search?keywords=dotnet-runtime-9.0&searchon=names&suite=all&section=all |
| Ports | Game server 7777/tcp (Terraria default). TShock REST port 7878 is UNVERIFIED for this release (draft inferred it). |
| Dependencies | None. |

## 2. Target layout

- `apps/terraria-tshock/Dockerfile`
- `apps/terraria-tshock/docker-bake.hcl`
- `apps/terraria-tshock/settings.yaml`
- `apps/terraria-tshock/container-test.yaml`
- `apps/terraria-tshock/start.sh`
- `defaults/serverconfig.txt` only if a seeded Terraria config is needed (reason: first-start config under `/config`). Decide after the first run.

No `root/` (the ich777 gotty wrapper is dropped). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The .NET runtime is not in the Ubuntu archive, so it is installed by a pinned script or tarball (section 4), not by `apt`. Closest sibling for a .NET install in this repo: `apps/webgrabplus` (`dotnet-install.sh` into `/app/dotnet`). Prebuilt-binary pattern: `apps/adguardhome-sync`.

## 4. Dockerfile

1. `ARG VERSION` (`6.2.1`), `ARG TARGETARCH`, `ARG DOTNET_VERSION` (pinned runtime), `USER root`.
2. **Check first whether the TShock zip is self-contained.** The draft says "self-contained release zip" but the upstream image installs `aspnetcore-runtime-9.0`. Unzip the amd64 asset and inspect for a bundled `dotnet` host or `Microsoft.NETCore.App` folder. If it is self-contained, no .NET runtime install is needed. If not, install the runtime as step 3 (UNVERIFIED which applies).
3. If a runtime is needed: install the .NET 9 ASP.NET Core runtime from the Microsoft release feed, not apt. Pin the version and check the SHA-512 from Microsoft's `releases.json` for that version (UNVERIFIED: the exact URL and hash are not fetched). Install into `/usr/local/dotnet`. `dotnet-install.sh` is used by `apps/webgrabplus`, but it does not verify a checksum, so the tarball route is preferred.
4. Download the arch-specific TShock zip (map `TARGETARCH`: `amd64` to `x64`, `arm64` to `arm64`), verify it against the `sha256` in section 1 with `sha256sum -c`, then `unzip` into `/app/tshock`. Use `curl -fL`.
5. `apt-get install -y --no-install-recommends unzip` only if `unzip` is absent from the base (check with `docker run --rm <base> which unzip`). Drop `screen` and `gotty`.
6. Licence: copy the TShock LICENSE (GPL-3.0) into `/usr/share/licenses/terraria-tshock/`.
7. `chown -R apps:apps /app/tshock && chmod -R 755 /app/tshock`, then `rm -rf /tmp/*`.
8. `ENV DOTNET_ROOT=/usr/local/dotnet DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_EnableDiagnostics=0 HOME=/config PATH=/usr/local/dotnet:$PATH` (only the variables needed after testing).
9. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 7777`, `VOLUME /config`, `CMD ["/start.sh"]`.

Version alignment: `ARG VERSION` must equal the bake `VERSION` (`6.2.1`). The zip name also contains `1.4.5.8`; store it as a second bake variable `TERRARIA_VERSION=1.4.5.8` so both are checked (lines below to verify in the build).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "terraria-tshock" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Pryaxis/TShock versioning=loose
  default = "6.2.1"
}
variable "TERRARIA_VERSION" { default = "1.4.5.8" }
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/Pryaxis/TShock" }
```

`LICENSE` must be the TShock license: GPL-3.0 per the API. Use `GPL-3.0-only` only if the repo LICENSE text says "only"; otherwise `GPL-3.0-or-later` (UNVERIFIED, check the file). Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Pryaxis/TShock"
ports:
  - port: 7777
    protocol: tcp
    required: true
env:
  - name: TERRARIA_WORLD_NAME
    default: "world"
    required: false
  - name: TERRARIA_MAX_PLAYERS
    default: "8"
    required: false
  - name: TERRARIA_WORLD_SIZE
    default: "2"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Env names are ContainerForge names chosen for this plan. Map them to Terraria server flags in `start.sh` (`-world`, `-autocreate`, `-maxplayers`, `-port`). The `-autocreate` size values are UNVERIFIED. Do not list `GAME_VERSION`, `GAME_MOD`, `GAME_PARAMS`, `ENABLE_WEBCONSOLE`, `GOTTY_PARAMS`: they belong to the ich777 wrapper, which is removed. Port 7878 is left out until the REST API port is confirmed in the TShock 6.2.1 config (UNVERIFIED).

## 7. start.sh

- `set -eu`, `cd /config` before launching so TShock and Terraria write their state (`tshock/`, `worlds/`, logs) under `/config`. TShock writes relative to the working directory (UNVERIFIED for 6.2.1), so this must be checked. The binaries stay in `/app/tshock`.
- Create `/config/worlds` and `/config/tshock` only when missing (no overwrite of existing state).
- If the Terraria dedicated server binary is not in the TShock zip, it must be provided. The ich777 start script downloads it (URL and version not fetched; UNVERIFIED). Do this only when `/config/serverfiles` is missing, verify it, and never write it to `/app`. If the Re-Logic license or download rules forbid this, stop and record (section 10).
- On first start there is no world. Use `-autocreate 2 -world /config/worlds/${TERRARIA_WORLD_NAME}.wld` (flags UNVERIFIED). Accept an existing world on later starts.
- `exec dotnet /app/tshock/TShock.Server.dll` (or the Terraria launcher the zip provides; check the zip layout in the build) with `-port 7777 -maxplayers ${TERRARIA_MAX_PLAYERS} -worldpath /config/worlds`, so the process is PID 1.
- The TShock admin account setup is a manual console step (draft caveat). The script must not block on stdin; use non-interactive flags or document the manual step in the PR (UNVERIFIED flag names).
- Never write to `/app`. Temp files in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 600
tcp:
- port: '7777'
filePaths:
- /app/tshock
- /usr/share/licenses/terraria-tshock/LICENSE
```

- `timeoutSeconds` is large because world generation takes minutes on first start (sibling of the same family to check: UNVERIFIED value). Confirm the value against a sibling game server in the repo before merging.
- The test runs without env vars: world name and max players use defaults, so the default path is the tested path.
- Port 7878 probe is not added (see section 6).
- Add an assertion for the TShock DLL to the file check once its exact name is known from the zip listing (UNVERIFIED name).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path / behaviour | ContainerForge remap |
| --- | --- |
| `/serverdata` (`DATA_DIR`) with `serverfiles` and worlds | `/config` (worlds, TShock config, logs). Binaries stay under `/app/tshock`. |
| Runs as root (no USER; `USER=terraria` env only) | `USER apps`. Port 7777 is above 1024, so no root bind is needed. |
| `ulimit -n 2048` in RUN (does not persist) | Not carried over. Test whether needed at runtime. |
| `chmod -R 777` on scripts | Not carried over. Scripts are `COPY --chmod=0755`. |
| gotty web terminal (port 8080 default in the wrapper, UNVERIFIED) | Removed. Web console is not part of the ContainerForge app. |
| `screen` session wrapper | Removed: the container runs the server as PID 1 via `exec`. |

Draft security expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false` and `privileged: false`. This image is rootless and read-only-rootfs compatible only if TShock and Terraria keep all writes in `/config` or `/tmp`; verify with `--read-only --tmpfs /tmp`.

## 10. Risks, caveats and open questions

- **.NET runtime**: the draft's apt package `dotnet-runtime-9.0` is absent from the Ubuntu archive. The runtime route (Microsoft tarball with a checked SHA-512, or a self-contained zip) must be chosen before the Dockerfile is written. This is the main blocker for the build.
- **Terraria server binary**: the TShock zip may need the Terraria dedicated server, downloaded separately by upstream `start.sh`. That server is Re-Logic's and not GPL. Check its terms before automating the download. If it is not allowed, the app cannot be built as planned: record it as a blocker.
- Client and server version must match (TShock 6.2.1 for Terraria 1.4.5.8), from the draft.
- First start is interactive for TShock admin setup (draft caveat). The non-interactive path is UNVERIFIED.
- `TShock` writes to the working directory: a write outside `/config` breaks read-only rootfs (section 7).
- Port 7878 REST API is unverified (section 6).
- arm64: the zip exists, but the runtime and the Terraria server arm64 support are UNVERIFIED.
- Blockers: the runtime install route and Terraria server licensing (above).

## 11. Build and test steps

```sh
cd apps/terraria-tshock
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name terraria-probe --read-only --tmpfs /tmp \
  -v terraria-probe-config:/config terraria-tshock:6.2.1
docker logs -f terraria-probe
forgetool containers test --image terraria-tshock:6.2.1 --config ./apps/terraria-tshock/container-test.yaml
docker rm -f terraria-probe; docker volume rm terraria-probe-config
```

- Expected readiness: the TShock log shows the server listening on 7777 (exact line UNVERIFIED) and the process stays up during world generation.
- Verify the first-start world is created in `/config/worlds`, and a restart reuses it.
- Verify the empty `/config` start, and that no file is written under `/app`.

## 12. PR checklist

- Branch `feat/add-terraria-tshock`, commit and PR title `feat(terraria-tshock): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows status.
- Untested to state honestly: the build, the .NET runtime install, the Terraria server download (if any), arm64, the 7878 port, and the first-start world creation.
- Confirm `docker buildx bake --print` passes and `VERSION` equals the Dockerfile `ARG VERSION`.
