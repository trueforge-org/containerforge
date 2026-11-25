# kubernetes-reflector — implementation plan
> Source: ./draft.md · Target: apps/kubernetes-reflector/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v10.0.81 (latest GitHub release, published 2026-11-20). Draft and TrueCharts chart pin image `10.0.80`; v10.0.81 is newer. Source: https://api.github.com/repos/emberstack/kubernetes-reflector/releases/latest and https://github.com/emberstack/kubernetes-reflector/releases/tag/v10.0.81 |
| Renovate | `datasource=github-releases depName=emberstack/kubernetes-reflector versioning=semver` (UNVERIFIED against upstream renovate config; the tag is `v`-prefixed, so strip it when used as `VERSION`) |
| License | MIT (GitHub SPDX `MIT`): https://api.github.com/repos/emberstack/kubernetes-reflector |
| Source URL | https://github.com/emberstack/kubernetes-reflector |
| Download | No prebuilt binary. Only release asset is `reflector.yaml` (Kubernetes manifest, not used). Build from source: `https://github.com/emberstack/kubernetes-reflector/archive/refs/tags/v${VERSION}.tar.gz` (standard GitHub tag archive, UNVERIFIED that the URL is fetched in this run). |
| Per-arch download URLs | None; compile per arch with `dotnet publish` (upstream Dockerfile uses `--platform=$BUILDPLATFORM` on the SDK stage). |
| Checksum source | None for the source archive. Pin by tag and verify by commit if a tag-to-SHA mapping is fetched (UNVERIFIED how). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/emberstack/kubernetes-reflector/b26ca679e185e5da9c2ae100ea049e251701c606/src/ES.Kubernetes.Reflector/Dockerfile. Stages: `mcr.microsoft.com/dotnet/aspnet:10.0` (base), `--platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0` (build). `dotnet build` then `dotnet publish -c $BUILD_CONFIGURATION -o /app/publish --no-build /p:UseAppHost=false`. `WORKDIR /app`, `USER app`, `EXPOSE 8080`, `ENTRYPOINT ["dotnet", "ES.Kubernetes.Reflector.dll"]`. No VOLUME, no ENV, no arch logic. |
| Ports | 8080 (EXPOSE, confirmed) |
| Env vars | None defined upstream (confirmed in Dockerfile). Runtime env vars from the app source are UNVERIFIED: not fetched in this run. |
| Data and config write paths | None in the Dockerfile; the app runs from `/app`. Runtime writes UNVERIFIED. |
| Dependencies | Kubernetes API with a service account that can read and watch secrets and configmaps cluster-wide (from draft and chart ClusterRole). No database. |
| Apt on Ubuntu 26.04 | `dotnet-sdk-10.0` and `aspnetcore-runtime-10.0` exist in the Ubuntu archive for amd64 and arm64 (verified in the sibling plan `drafts/Docker Hub/medium/fenrus/plan.md`: 10.0.114 SDK and 10.0.14 aspnetcore, `-0ubuntu1~26.04.1`, from packages.ubuntu.com; re-check versions before pinning). |

## 2. Target layout

- `apps/kubernetes-reflector/Dockerfile`
- `apps/kubernetes-reflector/docker-bake.hcl`
- `apps/kubernetes-reflector/settings.yaml`
- `apps/kubernetes-reflector/container-test.yaml`
- No `start.sh`: the upstream entrypoint is a plain `dotnet` call, so the Dockerfile `ENTRYPOINT` runs it directly. Add `start.sh` only if env-to-config mapping turns out to be needed (UNVERIFIED).
- No `defaults/`, `etc/`, `health/`, `root/`: nothing to seed.
- No `DOWNSTREAM_CHANGES.md`: not used as a `FROM` base.

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Build stage: the same ubuntu image (so the SDK comes from the Ubuntu archive, not from MCR).
- Why: ubuntu is the ContainerForge base for "generic" runtimes, and there is no .NET base in ContainerForge. The .NET 10 runtime is installed from apt in the final stage.
- Closest sibling: `apps/webgrabplus` (dotnet on ubuntu). It installs dotnet by `dotnet-install.sh` into `/app/dotnet`, which is not used here because apt packages are pinned and reproducible (decision noted in section 10).

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends dotnet-sdk-10.0=<pinned>` (pin the 10.0.x version seen on packages.ubuntu.com for 26.04; the SDK is toolchain, not runtime, so it is discarded). Clean apt lists.
3. `ENV DOTNET_CLI_HOME=/tmp DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 NUGET_PACKAGES=/tmp/nuget`.
4. Fetch and extract the source for `VERSION` into `/tmp/src` with checksum or tag pin noted in section 1 (use `curl -fL ... | tar xz --strip-components=1`).
5. `cd /tmp/src && dotnet publish src/ES.Kubernetes.Reflector/ES.Kubernetes.Reflector.csproj -c Release -o /tmp/publish /p:UseAppHost=false` (skip the separate `dotnet build` step; publish restores and builds).
6. Final stage: `FROM <ubuntu>`, `USER root`, `apt-get install -y --no-install-recommends aspnetcore-runtime-10.0=<pinned>`, clean apt lists.
7. `COPY --from=build /tmp/publish/ /app/`; license: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/kubernetes-reflector/LICENSE` (UNVERIFIED that the file is named `LICENSE` upstream; check in the extracted tree).
8. `chown -R apps:apps /app && chmod -R 755 /app`.
9. `ENV HOME=/tmp TZ=Etc/UTC` (ASP.NET data protection key storage defaults to the home directory, so keep it on `/tmp`, not `/config`).
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
WORKDIR /app
ENTRYPOINT ["dotnet", "ES.Kubernetes.Reflector.dll"]
```

`COPY --chmod=0755 . /` is required for the container test (see dockerfile rules). The allow-list `.dockerignore` means `start.sh`/`defaults/` are only copied if present; none are needed here.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kubernetes-reflector"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=emberstack/kubernetes-reflector versioning=semver
  default = "10.0.81"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/emberstack/kubernetes-reflector"
}
```

Plus the four standard targets (`image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/kubernetes-reflector/`. Note: the `VERSION` in bake has no `v` prefix; the Dockerfile must build the tag as `v${VERSION}`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/emberstack/kubernetes-reflector"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

- Env: only `TZ`. No app env is listed because none is verified (rules: do not invent env vars). Add any real reflector env vars only after they are confirmed from source (UNVERIFIED).
- Volumes: empty. The reflector keeps no state. The rule "`/config` MUST be listed when the app persists state" does not apply, and no `VOLUME /config` is declared. Note this differs from sibling apps (decision in section 10).
- Dependencies: none in ContainerForge terms. The Kubernetes API is external to the image, so it is not a `dependencies:` entry.

## 7. start.sh

Not needed. The ENTRYPOINT is `dotnet ES.Kubernetes.Reflector.dll` and it runs as `apps` with no seeding or env mapping. If a `start.sh` becomes necessary, it must `exec` the dotnet process and must not write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
filePaths:
- /app/ES.Kubernetes.Reflector.dll
- /usr/share/licenses/kubernetes-reflector/LICENSE
```

- Every settings port (8080) has a `tcp` probe.
- No `http` probe: the health path is inferred only (draft), so it stays out until verified. Add one only with a confirmed path.
- The test runs with no cluster and no env. The controller may exit or refuse to start without a Kubernetes API connection (see section 10). If it does, do NOT weaken the test: fix the real defect, or record the blocker. This app is not database-dependent, so the DB-narrowing exception in the protocol does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app` (publish output) | Read-only at runtime. Nothing written there. |
| NuGet and CLI home (build only) | `/tmp` via `DOTNET_CLI_HOME` and `NUGET_PACKAGES` (build stage). |
| ASP.NET data protection keys (default under the home directory on Linux) | `HOME=/tmp`, so keys are ephemeral. Persistence is not needed for a controller. |
| `/config` | Not used. No state. |

Security expectations from the chart, to reconcile:
- non-root: expected yes (chart `runAsNonRoot: true`, uid 568). Image runs as `apps` via `USER apps`. Match the chart uid to the ContainerForge `apps` uid only when the chart is consumed (UNVERIFIED value).
- read-only-rootfs: expected yes. The plan above supports it (all writes to `/tmp`).
- privileged: no. No host capabilities.
- automountServiceAccountToken: true in chart (needed for API access). Not a container setting for this image.

## 10. Risks, caveats and open questions

- Cluster dependency (blocker for full test): the reflector only works in a cluster with a service account and RBAC. Local test can prove only that the process starts and listens on 8080. Whether it starts and listens without a cluster is UNVERIFIED; check the logs in step 11.
- Idle by design: nothing is mirrored until source secrets/configmaps carry reflection annotations. A default install looks idle, so "no logs" is not an error signal.
- Version: plan uses v10.0.81 (newer than the chart's 10.0.80). Confirm the chart bump is acceptable and whether the image tag `ghcr.io/emberstack/kubernetes-reflector` exists for 10.0.81 (UNVERIFIED; the image was not inspected).
- Build from source: decision to build from source (not `COPY --from` the upstream image) because there is no published binary for ContainerForge to reuse and the MCR runtime is not in ContainerForge. Arm64 build depends on the upstream Dockerfile staying maintained (draft caveat).
- apt pinning: the exact 10.0.x package versions for 26.04 amd64 and arm64 must be re-checked on packages.ubuntu.com before pinning (UNVERIFIED for the current run).
- Blocker candidates: none confirmed. Musl-only, GPU, privileged are all absent. The main blocker is the cluster dependency above.
- Draft difficulty `hard` is kept: a new .NET stack is required.

## 11. Build and test steps

From `apps/kubernetes-reflector/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe with an empty config volume, read-only rootfs and tmpfs:
   `docker run --rm -d --name kubernetes-reflector-probe --read-only --tmpfs /tmp -v kubernetes-reflector-probe-config:/config kubernetes-reflector:10.0.81`, then `docker logs -f kubernetes-reflector-probe`.
   Expected readiness signal: a log line from the ASP.NET host, such as `Now listening on: http://[::]:8080` (UNVERIFIED wording; confirm from the first real run). Process must still be running.
   Cleanup: `docker rm -f kubernetes-reflector-probe; docker volume rm kubernetes-reflector-probe-config`.
4. `forgetool containers test --image kubernetes-reflector:10.0.81 --config ./container-test.yaml`.
5. Optional arm64: only if an arm64 failure is suspected (`image-all` build needs a builder).

## 12. PR checklist

- Branch: `feat/add-kubernetes-reflector`. Commit: `feat(kubernetes-reflector): add new container`.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Downstream: not used as a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
- Honest untested list: the image is not built or run in this plan; the cluster-dependent behaviour and arm64 are untested until the steps above run.
