# intel-gpu-plugin — implementation plan
> Source: ./draft.md · Target: apps/intel-gpu-plugin/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `0.37.1` (GitHub release `v0.37.1`, published 2026-10-02; matches the draft tag). The release has no attached assets, so the binary must be built from source. |
| Renovate | `// renovate: datasource=github-releases depName=intel/intel-device-plugins-for-kubernetes versioning=semver` (tags are `v0.37.1`; confirm the `v` prefix is stripped by renovate, as in `apps/adguardhome-sync`). |
| License | `Apache-2.0` (file header of the upstream Dockerfile and repo `LICENSE`, 11357 bytes). |
| Source URL | https://github.com/intel/intel-device-plugins-for-kubernetes |
| Download | Source tarball `https://github.com/intel/intel-device-plugins-for-kubernetes/archive/refs/tags/v${VERSION}.tar.gz` (same for both arches; compile per `TARGETARCH`). No upstream checksum; verify by pinning the tag and, if wanted, a `sha256sum` constant recorded at implementation time (UNVERIFIED value). |
| Go | `go.mod` at v0.37.1 says `go 1.27.0`; the upstream builder is `golang:1.27-trixie`. Whether the ContainerForge ubuntu base ships Go 1.27: UNVERIFIED (`hishtory-server` builds Go in the ubuntu base stage, so Go exists there). |
| Upstream Dockerfile reviewed | `build/docker/intel-gpu-plugin.Dockerfile` (generated from a template): builder `golang:1.27-trixie`, `CGO_ENABLED=0 go install` in `cmd/gpu_plugin` with `-trimpath`, ldflags `all=-w -s`, `-gcflags all=-spectre=all`, `-asmflags all=-spectre=all`; binary installed at `/usr/local/bin/intel_gpu_device_plugin`; licences copied to `/licenses/...` (generated with `go-licenses` or copied from `licenses/gpu_plugin`); final `ubi9-micro` (or distroless static); `ENTRYPOINT ["/usr/local/bin/intel_gpu_device_plugin"]`; no `USER`. |
| Flags (README) | `-enable-monitoring`, `-monitoring-mode` (single/split), `-health-management`, `-xpumd-endpoint`, `-xpumd-unhealthy-severity`, `-wsl`, `-shared-dev-num` (default 1), `-allow-ids`, `-deny-ids`, `-allocation-policy` (none/balanced/packed), `-bypath` (single/none/all). No env vars, no ports documented. |
| Ports | None (talks to kubelet over unix sockets). |

## 2. Target layout

```
apps/intel-gpu-plugin/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No defaults/ (no config files). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Build stage: the same ubuntu image (Go is available there, as in `apps/hishtory-server`) `AS builder`; if Go 1.27 is not present, install it from the official tarball with checksum in the builder only (UNVERIFIED: version availability). Closest sibling: `apps/hishtory-server` (Go build stage then copy). Draft says ubuntu alone suffices; the binary is static (`CGO_ENABLED=0`).

## 4. Dockerfile

Builder stage (`USER root`):
1. `ARG VERSION`, `ARG TARGETARCH`; `ENV GOCACHE=/tmp/go-build GOPATH=/tmp/go GOFLAGS=-trimpath CGO_ENABLED=0`.
2. Download `v${VERSION}.tar.gz` with `curl -fsSL`, extract to `/build/src --strip-components=1`.
3. `cd /build/src/cmd/gpu_plugin && go build -ldflags "-w -s" -gcflags "all=-spectre=all" -asmflags "all=-spectre=all" -o /out/intel_gpu_device_plugin .` (upstream uses `go install` with these flags; either is fine). `unset GOPATH` pattern from hishtory is only needed if the base sets one.
4. Collect licences: `/src/LICENSE` and `/src/licenses/gpu_plugin` if present, else note that third-party notices are generated upstream with `go-licenses` (UNVERIFIED whether the directory exists at v0.37.1).

Final stage:
1. `ARG VERSION`, `USER root` only if needed for `mkdir`/`chown`.
2. `COPY --from=builder /out/intel_gpu_device_plugin /app/intel_gpu_device_plugin` and licences to `/usr/share/licenses/intel-gpu-plugin/`; `chown -R apps:apps /app && chmod -R 755 /app` (as `adguardhome-sync`).
3. `ENV HOME=/config`.
4. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, no `EXPOSE` (no ports). Draft says "ports: none"; honour it.

## 5. docker-bake.hcl

`APP = "intel-gpu-plugin"`, `VERSION = "0.37.1"` with the renovate comment from section 1, `LICENSE = "Apache-2.0"`, `SOURCE = "https://github.com/intel/intel-device-plugins-for-kubernetes"`. Targets: `docker-metadata-action`, `image` (args `VERSION`, OCI labels), `image-local`, `image-all` (amd64, arm64; the plugin is Intel-GPU/x86 hardware oriented but compiles for arm64), `group "default"`. `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/intel/intel-device-plugins-for-kubernetes"
ports: []
env:
  - {name: GPU_PLUGIN_ARGS, default: "", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: false}
dependencies: []
```
`GPU_PLUGIN_ARGS` is a ContainerForge wrapper variable (not read by the app) holding extra flags such as `-shared-dev-num 2`; only keep it if `start.sh` consumes it. Also note the runtime host paths `/var/lib/kubelet/device-plugins`, `/dev/dri`, `/sys/class/drm` are host mounts, not volumes of ours; document them in the PR (settings schema has no field for hostPath).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
# GPU_PLUGIN_ARGS is split on whitespace on purpose
# shellcheck disable=SC2086
exec /app/intel_gpu_device_plugin ${GPU_PLUGIN_ARGS:-}
```
No `/config` seeding needed. No config file, nothing written to `/app`. UNVERIFIED: whether the plugin logs and stays alive when `/var/lib/kubelet/device-plugins` is missing or exits with an error (see section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /app/intel_gpu_device_plugin
- /usr/share/licenses/intel-gpu-plugin/LICENSE
runners:
- entrypoint: /app/intel_gpu_device_plugin -h
```
No ports exist, so no tcp/http probes. The `runners` entry form is copied from `apps/xvfb` (`- entrypoint: test -x /start.sh`); UNVERIFIED that `-h` exits 0 (Go `flag` exits with 2 on `-h`); if so use `test -x /app/intel_gpu_device_plugin` instead. This is not a DB app, so no narrowing comment is needed.

## 9. Rootless and read-only-rootfs adaptations

- Chart expects `runAsUser 568`, read-only rootfs, not privileged, with hostPath mounts. Upstream image runs as root by default; the README says non-root is possible given node DAC rules (socket creation in `/var/lib/kubelet/device-plugins` and reading `/dev/dri` nodes). We run `USER apps`; the Kubernetes manifest must set `runAsUser/runAsGroup/supplementalGroups` to match kubelet directory and render-group ownership (UNVERIFIED which). Document this in the PR; it is a deployment concern, not an image fix.
- Writes: the plugin writes its socket into the kubelet directory (host mount). Go cache -> `/tmp` only at build time. Nothing under `/app` or `/config`.
- Read-only rootfs is compatible: all writable paths are host mounts.

## 10. Risks, caveats and open questions

- Only useful in a Kubernetes DaemonSet with kubelet device-plugin socket and Intel GPU hardware (draft caveats). In a plain `docker run`, the plugin probably cannot register and may exit; step "container stays running" of the protocol may not hold. Capture the actual behaviour; if it exits cleanly with a clear log (e.g. cannot reach kubelet), record it in the PR and adjust the readiness signal rather than faking a server.
- Go 1.27 availability in the ubuntu build stage: UNVERIFIED.
- No arm64 hardware relevance; arm64 compile only.
- Third-party licence bundle at `licenses/gpu_plugin`: UNVERIFIED.
- The draft says `/dev/dri` access usually needs root or a matching group: mapped via `supplementalGroups` in the chart.
- Upstream pins FINAL_BASE distroless/ubi; ours is larger (ubuntu), acceptable per repo convention.

## 11. Build and test steps

```sh
cd apps/intel-gpu-plugin
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name intel-gpu-plugin-probe --read-only --tmpfs /tmp \
  -v intel-gpu-plugin-probe-config:/config intel-gpu-plugin:0.37.1
docker logs intel-gpu-plugin-probe
forgetool containers test --image intel-gpu-plugin:0.37.1 --config ./apps/intel-gpu-plugin/container-test.yaml
docker rm -f intel-gpu-plugin-probe; docker volume rm intel-gpu-plugin-probe-config
```
Expected readiness signal: UNVERIFIED (plugin startup log line, likely a "GPU device plugin" / device scan message). For a fuller check, run with `-v /var/lib/kubelet/device-plugins:/var/lib/kubelet/device-plugins --device /dev/dri` on a node with an Intel GPU, or in a kind/k3s cluster.

## 12. PR checklist

- Branch `feat/add-intel-gpu-plugin`; commit/PR title `feat(intel-gpu-plugin): add new container`; target `main`.
- PR template filled in, only applicable boxes checked; Notes contain `🤖 This PR is AI generated.`
- CLA reminder to the user: https://cla-assistant.io/trueforge-org/containerforge (only they can sign).
- `bake --print` passes; Go build stage copies into the ubuntu final stage; `GOCACHE` in `/tmp`; final `USER apps`.
- Untested unless run: the build, Go version, behaviour outside Kubernetes, arm64, any run on real Intel GPU hardware. State this in the PR.
