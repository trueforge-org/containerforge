# nvidia-gpu-exporter — implementation plan
> Source: ./draft.md · Target: apps/nvidia-gpu-exporter/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | v1.19.0, published 2026-11-15 (draft matches) | https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/expanded_assets/v1.19.0 |
| Renovate | `datasource=github-releases depName=utkuozdemir/nvidia_gpu_exporter versioning=semver` (v-prefixed semver tags; versioning inferred from the tag format) | release page above |
| License (SPDX) | UNVERIFIED: README links a LICENSE file but names no SPDX id. Fetch `LICENSE` before writing `docker-bake.hcl` | https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/master/README.md |
| amd64 | `https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.19.0/nvidia_gpu_exporter_1.19.0_linux_x86_64.tar.gz` (asset name confirmed; the `_x86_64` name is used for the tarball) | release page above |
| arm64 | `https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.19.0/nvidia_gpu_exporter_1.19.0_linux_arm64.tar.gz` (asset name confirmed) | release page above |
| Alternative packages | `.deb` (`nvidia-gpu-exporter_1.19.0_linux_{amd64,arm64}.deb`) and an NVML tarball variant (`nvidia_gpu_exporter-nvml_1.19.0_linux_{x86_64,arm64}.tar.gz`). Not chosen: the plain tarball keeps the binary in `/app` | release page above |
| Checksum source | `checksums.txt` in the same release (confirmed to exist). Its hashes are UNVERIFIED (not fetched). `checksums.txt.sigstore.json` also exists | release page above |
| Upstream Dockerfile | Reviewed at commit a6712afbab9ad620e7cc7897e11cd084147b5e96. `FROM gcr.io/distroless/base-nossl-debian13:latest@sha256:3a2dbf10c2fdafe5865e2b03a4a3b9b23f2e280229a81730415379b76dc70592`; `ARG TARGETPLATFORM`; `COPY ${TARGETPLATFORM}/nvidia_gpu_exporter /usr/bin/`; `ENTRYPOINT ["/usr/bin/nvidia_gpu_exporter"]`; no CMD; `USER 65534:65534`; `EXPOSE 9835`; no VOLUME, no ENV, no LABEL | https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/a6712afbab9ad620e7cc7897e11cd084147b5e96/Dockerfile |
| Ports | 9835/tcp, metrics at `/metrics` (docker example scrapes `localhost:9835/metrics`) | README |
| Env vars | Only `NVIDIA_DRIVER_CAPABILITIES=utility` appears (a Docker run setting, not read by the app). No env var is documented for the app | README |
| Flags | `--collect.backend` with `nvml` (default on Linux), `exec`, `demo`. `--web.listen-address` is not named on the README; its default is UNVERIFIED (docs/CONFIGURE.md not fetched) | README |
| nvidia-smi | The `exec` backend runs `nvidia-smi` as a subprocess (CSV query; `-q -d PIDS` and `pmon -c 1` when per-process collection is on). Its install path is UNVERIFIED | README |
| Data/config write paths | None documented. No VOLUME in upstream | Dockerfile |
| arm64 availability | Yes: arm64 tarball and `.deb` assets exist for v1.19.0 | release page |
| Dependencies | None in the container. Runtime needs the host NVIDIA driver and a GPU, exposed by the NVIDIA Container Toolkit (`--gpus all`) | README |

Draft correction: the draft says the image is built on ubuntu. The upstream image is built on distroless `base-nossl-debian13` with a numeric user (`65534`). The plan uses ubuntu as ContainerForge requires, and it does not inherit the distroless base.

## 2. Target layout

Files in `apps/nvidia-gpu-exporter/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required, because the binary needs flags from env and the script must `exec` it.
- `defaults/`, `etc/`, `scripts/`, `health/`: not needed. No seeded config and no healthcheck script is required.
- `root/`: never used.
- `DOWNSTREAM_CHANGES.md`: not applicable. Nothing uses this image as `FROM`.

Sibling for the pattern: `apps/adguardhome-sync` (prebuilt Go binary on ubuntu, `/app` binary, `start.sh`).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (copied from the brief).
- Why: the binary is a static-ish Go build but it shells out to `nvidia-smi`, and the exec backend expects a normal userland. The ubuntu base is the ContainerForge default for a prebuilt binary.
- Go build stage: not needed. The binary is downloaded and checksum-verified, not compiled.
- Closest sibling: `apps/adguardhome-sync`.

## 4. Dockerfile

Steps, in order:
1. `ARG VERSION=1.19.0` (must equal the `VERSION` default in `docker-bake.hcl`). `ARG TARGETARCH`.
2. Map the arch to the asset name: `amd64` to `x86_64`, `arm64` to `arm64`. Example: `case "${TARGETARCH}" in amd64) ARCH=x86_64 ;; arm64) ARCH=arm64 ;; *) exit 1 ;; esac`.
3. Install `ca-certificates` and `curl` only if the base does not provide them (check the base first, per the Dockerfile rules). Installs run under `USER root`, then switch back.
4. Download `checksums.txt` and the tarball from the v1.19.0 release. Verify with `sha256sum -c --ignore-missing`. Fail the build on a mismatch.
5. Extract only the `nvidia_gpu_exporter` binary to `/app/nvidia_gpu_exporter`, and `chmod 0755` it. Remove the download and the extraction leftovers in the same `RUN`.
6. Ship the license to `/usr/share/licenses/nvidia-gpu-exporter/` (LICENSE from the source archive, which the tarball does not include, so fetch it from the source tag `v1.19.0`). Required because only part of the upstream archive is extracted.
7. `ENV` moves any HOME/cache to `/tmp` (the exporter does not need a cache; set `HOME=/tmp` for safety).
8. `COPY --chmod=0755 . /` (required).
9. `EXPOSE 9835`.
10. `VOLUME /config` is not needed (no persistent state). Skip the volume and say so in settings.yaml.
11. Final line `USER apps`.

Snippet for the checksum step (verify the hash from checksums.txt, do not hard-code it):
```dockerfile
RUN set -eux; \
    curl -fsSL -o /tmp/checksums.txt "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${VERSION}/checksums.txt"; \
    curl -fsSL -o /tmp/exporter.tar.gz "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${VERSION}/nvidia_gpu_exporter_${VERSION}_linux_${ARCH}.tar.gz"; \
    cd /tmp && grep " nvidia_gpu_exporter_${VERSION}_linux_${ARCH}.tar.gz$" checksums.txt | sha256sum -c -; \
    tar -xzf /tmp/exporter.tar.gz -C /tmp nvidia_gpu_exporter; \
    install -m 0755 /tmp/nvidia_gpu_exporter /app/nvidia_gpu_exporter; \
    rm -f /tmp/checksums.txt /tmp/exporter.tar.gz /tmp/nvidia_gpu_exporter
```
Note the `curl` installs run under `USER root`. The `/tmp` paths are scratch and are wiped in the same layer.

## 5. docker-bake.hcl

- `variable "APP" { default = "nvidia-gpu-exporter" }`
- `variable "VERSION"` with the renovate annotation:
  ```hcl
  // renovate: datasource=github-releases depName=utkuozdemir/nvidia_gpu_exporter versioning=semver
  default = "1.19.0"
  ```
- `variable "LICENSE"`: pending the license check (step 1). Do not guess the SPDX id.
- `variable "SOURCE" { default = "https://github.com/utkuozdemir/nvidia_gpu_exporter" }`
- Targets: `docker-metadata-action`, `image` (args `VERSION`, OCI labels `org.opencontainers.image.source` and `.licenses`), `image-local` (inherits `image`, `output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (inherits `image`, platforms `linux/amd64`, `linux/arm64`), and `group "default" { targets = ["image-local"] }`.
- Validate with `cd apps/nvidia-gpu-exporter && docker buildx bake --print`.

## 6. settings.yaml

- Header: the schema comment and `schema_version: 1` from the settings-yaml instructions.
- `upstream_env_url: https://github.com/utkuozdemir/nvidia_gpu_exporter`
- `ports`: `port: 9835`, `protocol: tcp` (the schema field is tcp/udp as in sibling settings; http is covered by the probe), `required: true`.
- `env`: only the vars `start.sh` maps to app flags. Pending the flag names, which are UNVERIFIED. Expected: a backend selector (for example `COLLECT_BACKEND`, default `nvml`) and a listen address (default `0.0.0.0:9835`). Do not list `NVIDIA_DRIVER_CAPABILITIES`, because the app does not read it.
- `volumes`: none. Write this as an explicit reason in the PR, because the exporter has no persistent state.
- `dependencies`: none.

## 7. start.sh

- Idempotent. Creates nothing under `/app`. Nothing to seed in `/config`.
- Reads the backend and listen address from env, with defaults matching settings.yaml.
- Builds the argument list and ends with `exec /app/nvidia_gpu_exporter "$@"` so signals reach the process.
- Binds `0.0.0.0` (the port must be reachable from other containers). Confirm with `--help`, since the default bind address is UNVERIFIED.

## 8. container-test.yaml

- Header: the forgetool schema comment, as in sibling apps.
- `tcp` probe on 9835 and an `http` probe on `/metrics` (required for every port in settings.yaml).
- `timeoutSeconds` taken from `apps/adguardhome-sync/container-test.yaml`.
- Open risk: the test runs with no GPU and no `nvidia-smi`. The exporter may exit at startup without a GPU. If so, do not weaken the test and do not add a fake backend as the default. Surface it to the user, and decide between (a) a documented demo-backend path run only through `filePaths`/a dedicated check, or (b) a narrowed test with a comment. The DB-dependency exception does not apply here (no database).

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as `65534:65534`. ContainerForge requires `USER apps`. The exporter needs read access to `nvidia-smi` and the GPU device nodes. Confirm that `apps` can read them on a host with the toolkit.
- Upstream writes nothing. Run with `--read-only --tmpfs /tmp`; nothing writes to `/app` or `/config`.
- Reconciling the draft's security expectations: the draft says `privileged: yes` and `runAsUser 0`. The upstream image documents only `--gpus all` (NVIDIA Container Toolkit) and `--pid=host` for per-process data. Privileged mode and root are not inherent to the app. The chart's hostPath device mounts are the chart's choice, not a requirement of the image. Target: non-root, read-only rootfs, no privileged mode. The chart mounts are a separate TrueCharts concern, not part of this app.
- `--pid=host` is needed only for per-process attribution, so it is documented as optional.

## 10. Risks, caveats and open questions

- Hard difficulty: the exporter needs a real NVIDIA GPU and driver to produce data. Without one, it may exit or serve nothing (see section 8).
- Flag names and `--web.listen-address` default: UNVERIFIED. Check with `nvidia_gpu_exporter --help` from the tarball before writing `start.sh`.
- `nvidia-smi` location in the image: UNVERIFIED. The exec backend needs it on `PATH`. The NVIDIA runtime injects it, so the image may not need it.
- License: UNVERIFIED. This blocks the `LICENSE` bake variable and the `.licenses` label.
- Checksum values: UNVERIFIED (checksums.txt not fetched). The Dockerfile must read it at build time, not hard-code it.
- Upstream Dockerfile is distroless; the ContainerForge build does not reuse it. The plan does not copy its base.
- No arm64 test hardware assumed. Validate amd64 first; arm64 is only attempted if the failure is arm64-specific.

## 11. Build and test steps

1. `cd apps/nvidia-gpu-exporter && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with an empty config volume and no GPU, plus `--read-only --tmpfs /tmp`:
   ```sh
   docker volume create nvidia-gpu-exporter-probe-config
   docker run --rm -d --name nvidia-gpu-exporter-probe --read-only --tmpfs /tmp \
     -v nvidia-gpu-exporter-probe-config:/config nvidia-gpu-exporter:1.19.0
   docker logs -f nvidia-gpu-exporter-probe
   ```
   Expected readiness signal: a log line showing the listen address on 9835. Expect a GPU-related error without a GPU. Record it as the known limit in the PR.
4. `forgetool containers test --image nvidia-gpu-exporter:1.19.0 --config ./apps/nvidia-gpu-exporter/container-test.yaml`. If forgetool is not available, check the probes by hand.
5. Clean up: `docker rm -f nvidia-gpu-exporter-probe; docker volume rm nvidia-gpu-exporter-probe-config`.

## 12. PR checklist

- Branch: `feat/add-nvidia-gpu-exporter`. Commit: `feat(nvidia-gpu-exporter): add new container`. Target `main`.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Check only the boxes that apply.
- Say what was not tested: GPU-backed functional test (no GPU), arm64 build, and the UNVERIFIED items above.
- Do not check "Built container locally" unless the image was built and run.
