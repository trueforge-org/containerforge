# ollama — implementation plan
> Source: ./draft.md · Target: apps/ollama/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.40.18` (latest release, published 2026-11-24). Chart appVersion `0.40.18`. Draft pins `0.40.16` (published 2026-11-09). The draft's "0.40.16 is an old release" caveat is wrong: it is 16 days old, and 0.40.18 is current. |
| Docker Hub | `ollama/ollama`: `0.40.18` (amd64, arm64, last_updated 2026-11-24); `0.40.18-rocm` (amd64 only); `0.40.17` (amd64, arm64). `0.40.16` is not on the first page of `name=0.40` (not fully checked). Chart: `docker.io/ollama/ollama:0.40.18@sha256:1cabd20e...`. |
| Renovate | UNVERIFIED in repo config. Recommended: `datasource=github-releases depName=ollama/ollama versioning=semver`. |
| License | MIT (GitHub API SPDX). |
| Source URL | https://github.com/ollama/ollama (docs https://docs.ollama.com) |
| Download (v0.40.16, asset names confirmed via release API) | `https://github.com/ollama/ollama/releases/download/v${VERSION}/ollama-linux-amd64.tar.zst` (CPU). Other assets: `ollama-linux-amd64-mlx.tar.zst`, `ollama-linux-amd64-rocm.tar.zst`, `ollama-linux-arm64.tar.zst` (generic arm64), `ollama-linux-arm64-jetpack5.tar.zst`, `ollama-linux-arm64-jetpack6.tar.zst`. |
| Checksum source | `https://github.com/ollama/ollama/releases/download/v${VERSION}/sha256sum.txt`. Confirmed for v0.40.16 (for example amd64 CPU `87bfafb2...`, arm64 generic `e45b8e6d...`). v0.40.18 values were not fetched and are UNVERIFIED until read from its `sha256sum.txt`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ollama/ollama/v0.40.16/Dockerfile (v0.40.16, not 0.40.18). Build stage on almalinux/rocm (Go build of `/bin/ollama`). Final stage `ubuntu:24.04`: ca-certificates, libvulkan1, libopenblas0; copies `/bin` to `/usr/bin` and `/lib/ollama` to `/usr/lib/ollama`. `ENTRYPOINT ["/bin/ollama"]`, `CMD ["serve"]`, `EXPOSE 11434`, no USER (root), no VOLUME. |
| Port | 11434 (Dockerfile EXPOSE). Chart UI port 10686 is for the optional sidecar. |
| Env vars (real) | `OLLAMA_HOST=0.0.0.0:11434` (Dockerfile ENV). `NVIDIA_VISIBLE_DEVICES=all`, `NVIDIA_DRIVER_CAPABILITIES=compute,utility`, `LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64` (Dockerfile ENV, for GPU variants only). |
| Model/data path | Not stated in the Dockerfile. Ollama's default is `~/.ollama`; with `HOME=/config` that is `/config/.ollama`. The default for 0.40.x is UNVERIFIED. The chart mounts `/root/.ollama`. |
| Dependencies | `open-webui` is an optional UI sidecar (`ghcr.io/open-webui/open-webui`), a separate Python stack. ❌ No `apps/open-webui` exists. |
| Chart | TrueCharts `charts/stable/ollama` 11.0.2, appVersion 0.40.18. Security: `runAsUser 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`. |

## 2. Target layout

- `apps/ollama/Dockerfile`
- `apps/ollama/docker-bake.hcl`
- `apps/ollama/settings.yaml`
- `apps/ollama/container-test.yaml`
- `apps/ollama/start.sh`

No `defaults/`, `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The open-webui UI and the ROCm and CUDA variants are out of scope for this plan.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because the upstream binary ships with its own bundled libraries (`lib/ollama`), so no compile is needed. The upstream final image is `ubuntu:24.04`, and 26.04 is the ContainerForge base. Closest sibling: `apps/adguardhome-sync` (prebuilt release tarball on ubuntu, `USER apps`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

Single stage (no compile).

1. `ARG VERSION` (`0.40.18`), `ARG TARGETARCH`, `USER root`.
2. Map the architecture to the asset name:

```dockerfile
RUN case "${TARGETARCH}" in amd64) ollama_arch=amd64 ;; arm64) ollama_arch=arm64 ;; *) echo "unsupported ${TARGETARCH}" >&2; exit 1 ;; esac \
```

   Use the generic arm64 asset, not `jetpack5`/`jetpack6` (those are Jetson builds). The CPU amd64 asset, not `-mlx` or `-rocm`, is the plain default. Renovate and bake stay on one version.

3. Install `zstd`. It is not in the ubuntu base package list (`apps/ubuntu/Dockerfile`), and `tar --zstd` needs it. `apt-get install -y --no-install-recommends zstd`, then `rm -rf /var/lib/apt/lists/*`.
4. Download and verify against the upstream sha256 list:

```dockerfile
RUN set -eux; \
    base="https://github.com/ollama/ollama/releases/download/v${VERSION}"; \
    curl -fL -o /tmp/sha256sum.txt "${base}/sha256sum.txt"; \
    curl -fL -o /tmp/ollama-linux-${ollama_arch}.tar.zst "${base}/ollama-linux-${ollama_arch}.tar.zst"; \
    cd /tmp && grep " ollama-linux-${ollama_arch}.tar.zst\$" sha256sum.txt | sha256sum -c -
```

   The file is downloaded under its upstream name, so `sha256sum -c` matches the list entry. Then extract from `/tmp/ollama-linux-${ollama_arch}.tar.zst` in step 5.

5. Extract to `/app/ollama` (keeps the upstream `bin/` and `lib/` sibling layout, so the bundled libraries resolve relative to the binary; the relative lookup is inferred from the upstream `/bin` + `/lib/ollama` layout, and the tarball's internal layout is UNVERIFIED):

```dockerfile
RUN mkdir -p /app/ollama \
 && tar --zstd -xf /tmp/ollama.tar.zst -C /app/ollama \
 && rm -f /tmp/ollama.tar.zst /tmp/sha256sum.txt \
 && chmod -R 755 /app/ollama
```

6. Licence: the tarball's contents are UNVERIFIED for a LICENSE file. Fetch `https://raw.githubusercontent.com/ollama/ollama/v${VERSION}/LICENSE` (path UNVERIFIED) to `/usr/share/licenses/ollama/LICENSE`.
7. Tail:

```dockerfile
ENV OLLAMA_HOST=0.0.0.0:11434 \
    HOME=/config \
    TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 11434
VOLUME /config
```

   The base image entrypoint runs `/start.sh`, as in `apps/adguardhome-sync`. `HOME=/config` is already set by the ubuntu base; repeat it only if needed.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "ollama"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ollama/ollama versioning=semver
  default = "0.40.18"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ollama/ollama"
}
```

Then the default group and the four standard targets copied from `apps/adguardhome-sync/docker-bake.hcl`. `ARG VERSION` in the Dockerfile must equal this value. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ollama/ollama"
ports:
  - port: 11434
    protocol: tcp
    required: false
env:
  - name: OLLAMA_HOST
    default: "0.0.0.0:11434"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`OLLAMA_HOST` is read by the binary itself (verified in the Dockerfile `ENV`). No dependencies: the open-webui sidecar is optional and has no ContainerForge app.

## 7. start.sh

```bash
#!/usr/bin/env bash

# Models are stored under $HOME/.ollama, and HOME=/config (default location UNVERIFIED for 0.40.x).
mkdir -p /config/.ollama

exec /app/ollama/bin/ollama serve
```

- Idempotent: creates a directory only, seeds nothing, and does not write to `/app`.
- `exec` hands PID 1 to ollama.
- `OLLAMA_HOST` is read by the binary, so `start.sh` does not need to pass it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
runners:
- entrypoint: /app/ollama/bin/ollama --version
tcp:
- port: '11434'
filePaths:
- /app/ollama/bin/ollama
- /app/ollama/lib/ollama
- /usr/share/licenses/ollama/LICENSE
```

- Every settings port has a probe (11434 tcp).
- `runners` checks the binary runs on the ubuntu base (the `java -version` pattern from `apps/java8/container-test.yaml`).
- `/app/ollama/lib/ollama` path is UNVERIFIED until the tarball layout is checked at build time. An http probe on `/` (the default ollama reply) is UNVERIFIED for 0.40.x; add it only after it is observed.
- No env vars are needed to start, so no required-env path needs a file entry.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `~/.ollama` (models, root = `/root/.ollama`) | `$HOME/.ollama` = `/config/.ollama` (`HOME=/config`) |
| Temporary files (runner extraction, if any) | `/tmp` (`TMPDIR=/tmp`). Write paths for 0.40.x are UNVERIFIED; check with `--read-only` in step 11. |
| `/app/ollama` (binary and bundled libs, read-only) | Not written at runtime. |

Draft expectations reconciled: the chart runs as root with `readOnlyRootFilesystem false`. This image runs as `apps` (568) and should work with `--read-only --tmpfs /tmp`, to be proven. Not privileged. GPU device access is not in the chart values and is out of scope for the CPU image.

## 10. Risks, caveats and open questions

- Version: the draft pins `0.40.16`, but `0.40.18` is current. Pin `0.40.18` and read its `sha256sum.txt` (values not fetched here).
- Checksum: `sha256sum.txt` is the upstream list. Verifying against it in the same release is weaker than pinning per arch. Option: pin the hashes as `ARG`s. Decide before the build.
- Asset choice: the draft uses the MLX amd64 build and the jetpack5 arm64 build. This plan uses the CPU amd64 build and the generic arm64 build. The MLX and jetpack builds are not verified for this use. The choice is the author's; the reason for it is in section 4.
- Tarball internal layout (`bin/`, `lib/ollama/`) and the relative library lookup are UNVERIFIED. Check with `tar --zstd -tf` in the build step.
- Default model directory for 0.40.x is UNVERIFIED (`~/.ollama` assumed).
- Model downloads are multi-GB and need network and disk under `/config` on first pull.
- GPU variants (ROCm, CUDA) need device passthrough that the chart values do not show. Out of scope.
- The draft's Docker Hub tag line (`0.40.16, 0.40.16-rocm`) must be updated to `0.40.18`.
- The open-webui sidecar is a separate Python stack and has no ContainerForge app. Not in this plan.
- No blockers beyond the checks above: arm64 is published for 0.40.18.

## 11. Build and test steps

```sh
cd apps/ollama
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ollama-probe --read-only --tmpfs /tmp \
  -v ollama-probe-config:/config ollama:0.40.18
docker logs -f ollama-probe
forgetool containers test \
  --image ollama:0.40.18 \
  --config ./apps/ollama/container-test.yaml
docker rm -f ollama-probe; docker volume rm ollama-probe-config
```

Expected readiness signal: the ollama server log line that it is listening on `0.0.0.0:11434` (exact text UNVERIFIED for 0.40.18; read it from the first run). Confirm that `/config/.ollama` exists after start, and test from outside the container (`-p 11434:11434`) to prove it does not bind only to localhost.

## 12. PR checklist

- Branch `feat/add-ollama`, commit and PR title `feat(ollama): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say honestly what is untested: the tarball layout, the read-only run, the model directory, the arm64 build (not run here), the GPU variants (not built), and the v0.40.18 checksums.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
