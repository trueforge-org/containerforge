# rdtclient — implementation plan
> Source: ./draft.md · Target: apps/rdtclient/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest pinned release (chart) | v2.0.143, published 2026-10-18 | https://api.github.com/repos/rogerfar/rdt-client/releases/tags/v2.0.143 |
| Chart image | `ghcr.io/rogerfar/rdtclient:2.0.143@sha256:68523637d09ec8a120bd272756d58b393448a656b5967bd45622c4891c65ff36` | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rdtclient/values.yaml |
| Renovate | `datasource=github-releases depName=rogerfar/rdt-client versioning=semver` (app-level version from the release tag) | judgement from the release tag format |
| SPDX license | MIT | https://api.github.com/repos/rogerfar/rdt-client |
| Source | https://github.com/rogerfar/rdt-client | draft.md |
| Release asset | `RealDebridClient.zip` (23 779 639 bytes): https://github.com/rogerfar/rdt-client/releases/download/v2.0.143/RealDebridClient.zip | api.github.com release metadata |
| Checksum source | None attached to the release. `UNVERIFIED: no upstream SHA256 published`; pin a self-computed SHA256 and say so in the Dockerfile comment | release metadata |
| Architectures | Asset is a framework-dependent .NET zip, so it is arch-neutral. `UNVERIFIED: GHCR arch list not fetched`; the chart pins one digest only | release metadata, chart values |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/rogerfar/rdt-client/a669bd3/Dockerfile | fetched |
| Upstream base images | `node:lts-alpine` (client build), `mcr.microsoft.com/dotnet/sdk:10.0-alpine` (publish), `ghcr.io/linuxserver/baseimage-alpine:3.20` (runtime) | same Dockerfile |
| Upstream runtime install | ASP.NET Core runtime 10.0.0, **musl** tarball to `/usr/share/dotnet` (`aspnetcore-runtime-10.0.0-linux-musl-{x64,arm64,arm}.tar.gz`) | same Dockerfile |
| EXPOSE / HEALTHCHECK | `6500`; `curl --fail http://localhost:6500` | same Dockerfile |
| Env vars (upstream image) | `XDG_CONFIG_HOME=/config/xdg`, `RDTCLIENT_BRANCH=main` | same Dockerfile |
| Data paths (upstream) | `/data/db`, `/data/downloads` (created with `mkdir -p`) | same Dockerfile, chart `db` mount `/data/db` |
| Ports (chart) | 6500 http (web UI); aria2 RPC 6800; torrent 6888 TCP and UDP (sidecar only) | chart values |
| Dependencies (chart) | `aria2Image: ghcr.io/p3terx/aria2-pro:latest@sha256:086d1a37c586edb07ec0fb956bf9edd89d1d38d138ad5309ff96d510c8c9a011`, runs as root with writable rootfs | chart values |
| Chart security | main: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false | chart values |
| Blockers | Upstream runtime is musl-only; no .NET base in ContainerForge; aria2 sidecar not packaged | Dockerfile, repo listing (`apps/` has no `aria2` or dotnet app) |

Not verified: the real environment variable names for config and data paths in rdt-client (`/data/db` remap), the bind address (ASP.NET `ASPNETCORE_URLS`), the entry DLL name and whether the zip already contains the built `wwwroot`. Each must be read from the zip or the source at tag `v2.0.143` before the Dockerfile is written.

## 2. Target layout

Files under `apps/rdtclient/`:

- `Dockerfile`: required
- `docker-bake.hcl`: required
- `settings.yaml`: required
- `container-test.yaml`: required
- `start.sh`: required, since it seeds `/config` and `exec`s the server
- `defaults/`, `etc/`, `health/`: not needed. `defaults/` is only needed if a seed config file is shipped (not verified as needed)
- `root/`: never used
- `DOWNSTREAM_CHANGES.md`: not needed, the app is not a `FROM` base

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (copy exactly from the brief)
- Reason: the app is .NET, so the final stage is glibc ubuntu. The upstream Alpine and musl runtime cannot be reused. There is no `ghcr.io/trueforge-org/dotnet` base in this repo (checked `apps/`).
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary tarball on ubuntu, `USER apps`, `/config` volume). Its Dockerfile is the template for the download and copy steps.
- The .NET runtime has to be added on top of ubuntu. `UNVERIFIED:` the glibc runtime package name and availability on Ubuntu 26.04 (Microsoft package feed or the `dotnet-runtime-10.0` package). Check before writing the `RUN`; if neither works, stop and report as `blocked`.

## 4. Dockerfile

Step list:

1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Install the .NET ASP.NET Core runtime (glibc) and `unzip` with pinned versions (per the dockerfile rules, pin apt versions and check against `VERSION` where they relate to the app). Do not re-install anything already in the ubuntu base (check first). Cleanup `rm -rf /var/lib/apt/lists/*`.
3. Download the release asset: `curl -fsSL -o /tmp/RealDebridClient.zip "https://github.com/rogerfar/rdt-client/releases/download/v${VERSION}/RealDebridClient.zip"`.
4. Verify: `echo "<sha256>  /tmp/RealDebridClient.zip" | sha256sum -c -`. The hash is self-computed by us, since upstream publishes none. Note that in a comment next to the line.
5. Extract to `/app`: `unzip -q /tmp/RealDebridClient.zip -d /app`, then `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -f /tmp/RealDebridClient.zip`.
6. License: fetch the upstream `LICENSE` at tag `v${VERSION}` (or add it from the source tarball) into `/usr/share/licenses/rdtclient/LICENSE`. `UNVERIFIED:` the release zip itself contains no LICENSE file.
7. `ENV XDG_CONFIG_HOME=/config/xdg` (matches upstream). `ENV ASPNETCORE_URLS=http://0.0.0.0:6500` only if the app binds to localhost by default (UNVERIFIED, check `appsettings.json`/`Program.cs` at the tag).
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6500`, `VOLUME /config`, `CMD ["/start.sh"]` (or rely on the `start.sh` `exec`; follow the valkey sibling pattern).

Keep the frontend build out of the image. The release zip is expected to contain `wwwroot` (`UNVERIFIED`); if it does not, the fallback is a `node:lts` build stage that copies `client/out` to `/app/wwwroot`, not a runtime npm install.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rdtclient"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rogerfar/rdt-client versioning=semver
  default = "2.0.143"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/rogerfar/rdt-client"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate with `cd apps/rdtclient && docker buildx bake --print`.

## 6. settings.yaml

- Header: the schema comment and `schema_version: 1` as in the adguardhome-sync sibling.
- `upstream_env_url: "https://github.com/rogerfar/rdt-client"`
- `ports`: `6500` tcp, `required: true`
- `env`: `XDG_CONFIG_HOME` default `/config/xdg`, `TZ` default `Etc/UTC`, plus any config or data path variable found in step 1 (for example a DB path that replaces `/data/db`). Only list variables the app really reads.
- `volumes`: `/config` `required: true`. `/data` is not listed unless the app is pointed there by an env var that is verified.
- `dependencies`: none required. Put the aria2 sidecar under `opt_dependencies` only after it exists in ContainerForge; today it is missing (`apps/aria2` absent), so record it as a note, not a dependency.

## 7. start.sh

- Idempotent. Create `/config/xdg` and the db folder only when missing (`mkdir -p`).
- Do not write to `/app`.
- Seed nothing unless a default config is shipped (not needed by default).
- Final line `cd /app` then `exec dotnet /app/<EntryDll>.dll` (or the self-contained executable name), with `--urls` or the env var from step 4. Entry name `UNVERIFIED` until read from the zip.
- Bind address: `0.0.0.0:6500`, because other containers connect to it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '6500'
http:
- port: '6500'
  path: /
timeoutSeconds: 120  # UNVERIFIED: no .NET sibling to copy from; tune after the first run
```

Schema fields are to be checked against the forgetool schema before commit. Do not add `filePaths` for the default run. If a code path only runs with a Real-Debrid token, add it to `filePaths` and test it by hand per the protocol.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (uid set by base). Port 6500 is above 1024, so no root is needed.
- Writes: only `/config` (XDG config and DB) and `/tmp`. The upstream `/data/db` and `/data/downloads` must be remapped to `/config` or a user-mounted path via the env var from step 1. `UNVERIFIED` until the env name is confirmed.
- `/app` must be read-only: no file writes under `/app`, and the ASP.NET temp dir goes to `/tmp`.
- Chart security (root, non-readonly) is not carried over. Document the chart-vs-image difference in the PR.
- The aria2 sidecar runs as root with a writable rootfs. It is out of scope for this app and must not be merged into it.

## 10. Risks, caveats and open questions

- Blocker: no glibc .NET runtime path is confirmed for ubuntu 26.04 (see section 3). Without it, the app cannot be built.
- Real-Debrid account and API token must be entered in the web UI before the app does anything (inferred, not on a fetched page). Test must not depend on it.
- Download and data paths need disk space (inferred).
- aria2 is an optional dependency of the chart. `UNVERIFIED:` whether the app works without it. If it needs aria2 to download, the app is only partly usable until that sibling exists.
- No upstream checksum, so the pinned SHA256 is only as trustworthy as the first download.
- The GHCR image arch list is not confirmed; arm64 is best-effort.

## 11. Build and test steps

```sh
cd apps/rdtclient
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name rdtclient-probe --read-only --tmpfs /tmp \
  -v rdtclient-probe-config:/config rdtclient:2.0.143
docker logs -f rdtclient-probe
docker rm -f rdtclient-probe; docker volume rm rdtclient-probe-config

forgetool containers test --image rdtclient:2.0.143 --config ./apps/rdtclient/container-test.yaml
```

Expected readiness signal: an ASP.NET line such as `Now listening on: http://0.0.0.0:6500` `UNVERIFIED` until the first run. The process must stay alive. Run with an empty `/config` volume each round. Build on amd64 only, unless the failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-rdtclient`, commit `feat(rdtclient): add new container`, target `main`.
- PR title matches the commit (Conventional Commits, app as scope).
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`. Notes section includes `🤖 This PR is AI generated.`
- CLA notice: sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign). The `license/cla` check shows status.
- State what was not tested: arm64 build, aria2 interaction, Real-Debrid flow. Do not tick "Built container locally" unless the build ran.
- Confirm `docker buildx bake --print` ran and the scratch container and volume were removed.
