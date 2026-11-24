# local-ai — implementation plan
> Source: ./draft.md · Target: apps/local-ai/ · Difficulty: hard (reduced to medium for a CPU-only prebuilt binary) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `5.0.1` (latest GitHub release, published 2026-11-20). The draft says `v5.0.0`, so use 5.0.1. The chart still runs v2.28.0 images, so the chart needs a rework when it moves to this image. |
| Renovate | `datasource=github-releases depName=mudler/LocalAI versioning=semver`. Tags are `v`-prefixed, so the Dockerfile adds `v` in the URL, as `apps/adguardhome-sync` does. |
| License | MIT (SPDX `MIT`, LICENSE in repo root) |
| Source | https://github.com/mudler/LocalAI |
| amd64 URL | `https://github.com/mudler/LocalAI/releases/download/v5.0.1/local-ai-v5.0.1-linux-amd64` |
| arm64 URL | `https://github.com/mudler/LocalAI/releases/download/v5.0.1/local-ai-v5.0.1-linux-arm64` |
| Checksums | `https://github.com/mudler/LocalAI/releases/download/v5.0.1/LocalAI-v5.0.1-checksums.txt` (sha256 per asset). At the time of writing: amd64 `cd1e3eb7...6a5b`, arm64 `ec899de8...36c7`. Do not hard-code them, verify against the downloaded file. |
| Upstream Dockerfile | Reviewed `v5.0.1/Dockerfile` and `entrypoint.sh`. It is a large CUDA/ROCm/Vulkan matrix. It exposes 8080, uses `VOLUME /models /backends /configuration /data` and has `HEALTHCHECK /healthcheck.sh`. The upstream entrypoint starts as root and drops to uid 10001, which we do not need. |
| Port | 8080/tcp. `LOCALAI_ADDRESS` or `ADDRESS` defaults to `:8080`, so it already listens on all interfaces. |
| Env vars (verified in `core/cli/run.go`) | `LOCALAI_ADDRESS`, `LOCALAI_MODELS_PATH`, `LOCALAI_BACKENDS_PATH`, `LOCALAI_DATA_PATH`, `LOCALAI_CONFIG_DIR`, `LOCALAI_GENERATED_CONTENT_PATH`, `LOCALAI_UPLOAD_PATH`, `LOCALAI_DOWNLOAD_STAGING_PATH`, `LOCALAI_PRELOAD_MODELS`, `LOCALAI_MODELS`, `HF_TOKEN`, `LOCALAI_AUTH_DATABASE_URL` (default `{DataPath}/database.db`) |
| Health endpoints | `/healthz` (liveness) and `/readyz` (readiness), from `core/http/routes/health.go` |
| Runtime layout | The binary is only the Go server. Backends (llama.cpp and others) are fetched at runtime into `LOCALAI_BACKENDS_PATH` from the backend library, so the first start needs internet. UNVERIFIED: that the CPU backends run on Ubuntu 26.04 glibc. They are published as OCI images. |

## 2. Target layout

```
apps/local-ai/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/` or `health/` are needed. `DOWNSTREAM_CHANGES.md` is not needed because nothing builds `FROM` this image. Do not create `root/`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

A Go release binary only needs glibc, so plain ubuntu fits. The binary is prebuilt upstream, so the Go-in-build-stage rule is not triggered (no compile, no `go.mod` change). Closest sibling: `apps/adguardhome-sync` (a single prebuilt Go binary in `/app`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV HOME=/config` plus `LOCALAI_*` paths:
   `LOCALAI_MODELS_PATH=/config/models`, `LOCALAI_BACKENDS_PATH=/config/backends`, `LOCALAI_DATA_PATH=/config/data`, `LOCALAI_CONFIG_DIR=/config/configuration`, `LOCALAI_GENERATED_CONTENT_PATH=/config/generated`, `LOCALAI_DOWNLOAD_STAGING_PATH=/config/downloading`, `LOCALAI_UPLOAD_PATH=/tmp/upload`, `LOCALAI_ADDRESS=0.0.0.0:8080`.
   The staging path stays on disk because multi-GB downloads would fill the RAM-backed `/tmp`. This is a deliberate exception to "caches to /tmp".
3. Packages: `apt-get install -y --no-install-recommends ca-certificates curl libgomp1 espeak-ng` (the first two are probably in the base, so check first). The list is taken from the upstream Dockerfile line 22. They are runtime libraries, so they are not pinned. Then `rm -rf /var/lib/apt/lists/*`.
4. Download and verify. The arch name matches `TARGETARCH` directly (`amd64`, `arm64`):
   ```sh
   cd /tmp && \
   curl -fsSL -o local-ai "https://github.com/mudler/LocalAI/releases/download/v${VERSION}/local-ai-v${VERSION}-linux-${TARGETARCH}" && \
   curl -fsSL -o sums.txt "https://github.com/mudler/LocalAI/releases/download/v${VERSION}/LocalAI-v${VERSION}-checksums.txt" && \
   grep " local-ai-v${VERSION}-linux-${TARGETARCH}\$" sums.txt | sed 's/local-ai-v[^ ]*$/local-ai/' | sha256sum -c - && \
   install -m 0755 local-ai /app/local-ai && chown -R apps:apps /app && rm -f /tmp/local-ai /tmp/sums.txt
   ```
5. License: fetch `https://raw.githubusercontent.com/mudler/LocalAI/v${VERSION}/LICENSE` to `/usr/share/licenses/local-ai/LICENSE`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`.

## 5. docker-bake.hcl

- `APP=local-ai`
- `VERSION` default `5.0.1`, preceded by `// renovate: datasource=github-releases depName=mudler/LocalAI versioning=semver`
- `LICENSE=MIT`, `SOURCE=https://github.com/mudler/LocalAI`
- Targets: `docker-metadata-action`, `image` (args VERSION plus the two OCI labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64 and linux/arm64), `group "default" { targets = ["image-local"] }`.
- Check with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/mudler/LocalAI"`.
- `ports`: 8080 tcp, required false.
- `env` (names verified in `run.go`, defaults equal to `start.sh`):
  `TZ` (`Etc/UTC`), `LOCALAI_ADDRESS` (`0.0.0.0:8080`), `LOCALAI_MODELS_PATH` (`/config/models`), `LOCALAI_BACKENDS_PATH` (`/config/backends`), `LOCALAI_DATA_PATH` (`/config/data`), `LOCALAI_PRELOAD_MODELS` (empty, optional), `HF_TOKEN` (empty, optional).
- `volumes`: `/config` required. The chart's extra `/models` and `/images` PVCs map to `/config/models` and `/config/generated`. Either keep one volume, or the chart mounts subpaths. Decide when the chart is rewritten.
- `dependencies`: none. `opt_dependencies`: none. (Optional external PostgreSQL via `LOCALAI_AUTH_DATABASE_URL` is out of scope.)

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/{models,backends,data,configuration,generated,downloading} /tmp/upload
export HOME=/config
cd /config
exec /app/local-ai run
```
Everything is idempotent, it writes nothing to `/app`, and the bind address comes from `LOCALAI_ADDRESS`. Do not pass `--address` on the command line, so the env var stays authoritative.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /healthz
filePaths:
- /app/local-ai
- /usr/share/licenses/local-ai/LICENSE
```
No DB dependency, so there is no narrowing. `/healthz` is liveness, so it should answer even while backends are not yet downloaded. UNVERIFIED: that it returns 200 with an empty `/config` and no internet. Fall back to `tcp` only if it does not, and say so.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/models`, `/backends`, `/data`, `/configuration` | `/config/models`, `/config/backends`, `/config/data`, `/config/configuration` via env |
| Generated images or audio | `/config/generated` (the draft's `/images` PVC) |
| In-flight downloads | `/config/downloading` (large) |
| Uploads | `/tmp/upload` |
| `HOME` (`/home/localai`) | `/config` |

Draft expectation of root (UID 0, readOnlyRootFilesystem false) is rejected. We run as `apps` (568) with a read-only rootfs. Upstream itself drops to uid 10001, so root is not required. No privileged mode. GPU and CUDA are out of scope.

## 10. Risks, caveats and open questions

- Version mismatch: the chart runs v2.28.0, this image is 5.0.1, so v5 config and API changes need a chart review.
- First start downloads backends and models (GB), needs internet, and `/readyz` may stay not-ready for a long time. Tests use `/healthz` for that reason.
- CPU only. No GPU, so the CUDA, ROCm and Vulkan variants are not covered. Add a note in settings or the README.
- UNVERIFIED: backend OCI images run on Ubuntu 26.04 with this userland. Possible missing libs (libgomp1 and espeak-ng were added from the upstream list).
- Upstream's sandbox add-on refuses to run as root. Not a problem for us.
- Disk use on `/config` can be very large. Document it.

## 11. Build and test steps

```sh
cd apps/local-ai
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create local-ai-probe-config
docker run --rm -d --name local-ai-probe --read-only --tmpfs /tmp -v local-ai-probe-config:/config local-ai:5.0.1
docker logs -f local-ai-probe     # expect an API server listening on :8080 line, no fatal errors
curl -fsS http://localhost:8080/healthz   # from inside the network or via -p 8080:8080
docker rm -f local-ai-probe; docker volume rm local-ai-probe-config
forgetool containers test --image local-ai:5.0.1 --config ./apps/local-ai/container-test.yaml
```
Try arm64 only if the amd64 build fails in an arch-specific way. Max 10 rounds.

## 12. PR checklist

- Branch `feat/add-local-ai`, commit and PR title `feat(local-ai): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections. Put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Tick only the boxes that apply. Say honestly what was not tested: the arm64 build, backend download on a real model, GPU, and `/healthz` behaviour offline. Do not tick "Built container locally" unless it was.
- Checklist: bake print passes, `VERSION` is aligned in Dockerfile and bake, the checksum is verified, license files are shipped, `USER apps`, an empty `/config` starts.
