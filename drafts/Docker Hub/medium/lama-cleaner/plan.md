# lama-cleaner — implementation plan
> Source: ./draft.md · Target: apps/lama-cleaner/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | IOPaint `1.6.0` (PyPI `IOPaint`, latest). This is the maintained successor of `lama-cleaner`, whose latest PyPI release is `1.2.5`. The chart pins `0.33.0` (appVersion). Decision in section 10. |
| Draft tag | Draft names no version. Docker Hub `cwq1913/lama-cleaner` newest tags are `cpu-1.2.5` and `gpu-1.2.5` (2023-11-01). Chart uses `cpu-0.33.0`, `gpu-0.33.0`. Those are not built here. |
| Upstream status | `Sanster/lama-cleaner` is archived (`archived: true`, last push 2025-04-29) and redirects to `Sanster/IOPaint`. Latest GitHub release is `iopaint-1.5.3` (2024-11-23, no assets). Docs now live at https://www.iopaint.com. |
| Renovate | `// renovate: datasource=pypi depName=IOPaint versioning=pep440` |
| License | Apache-2.0 (GitHub `Sanster/IOPaint`). The old `lama-cleaner` PyPI license field is empty, so GitHub is the authority. |
| Source URL | https://github.com/Sanster/IOPaint (`SOURCE`). Old name: https://github.com/Sanster/lama-cleaner |
| amd64 download | `pip install IOPaint==<VERSION>` from PyPI. No release asset. Pure Python package, so the same install works on both architectures. |
| arm64 download | Same pip install. UNVERIFIED: the CPU `torch` wheel for arm64 and Python 3.15 is not checked. |
| Checksum source | PyPI publishes a sha256 per file (JSON API). Not fetched for `1.6.0` in this run. UNVERIFIED: hash values. Pinning with `--require-hashes` is possible but not decided. |
| Upstream Dockerfile reviewed | `docker/CPUDockerfile` at commit `5114a46` of `Sanster/lama-cleaner`: base `python:3.7.4-slim-buster`, apt `software-properties-common libsm6 libxext6 ffmpeg libfontconfig1 libxrender1 libgl1-mesa-glx curl`, `pip install torch==1.12.1` from `https://download.pytorch.org/whl/cpu`, then `pip install lama-cleaner==$version`, `EXPOSE 8080`, `CMD ["bash"]`, no `USER`, no `ENTRYPOINT`. This is an old commit. IOPaint's own Dockerfile is UNVERIFIED (not fetched). |
| Port | 8080 (upstream `EXPOSE 8080`). The chart service uses port `10604`. UNVERIFIED: which port the server binds when started without a port flag. |
| Env vars (real) | Not confirmed in this run. The chart sets `model` (`lama`), `input`, `sd_run_local`, `hf_access_token`, `sd_disable_nsfw`, `sd_cpu_text_encoder`, `sd_enable_xformers`, `debug`. These are chart values, not confirmed env vars. UNVERIFIED how the chart maps them. |
| Data and cache paths | Upstream writes models to `/root/.cache/torch` and `/root/.cache/huggingface`. The chart persists both. UNVERIFIED: IOPaint's model directory flag. |
| Docker Hub | `cwq1913/lama-cleaner`, 10 tags, amd64 only. No arm64 image. Third-party image, not an upstream image. |
| Chart | `docker.io/cwq1913/lama-cleaner`, tag `cpu-0.33.0@sha256:5011038046b50882281b418614b55f8f5db4ced31c42c297ede2d513c53ab105`. Security: `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. Service port `10604` (http). |

## 2. Target layout

- `apps/lama-cleaner/Dockerfile`
- `apps/lama-cleaner/docker-bake.hcl`
- `apps/lama-cleaner/settings.yaml`
- `apps/lama-cleaner/container-test.yaml`
- `apps/lama-cleaner/start.sh`

No `defaults/`, `etc/` or `health/`: the app creates its own state under `/config` on first use. No `root/`. No `DOWNSTREAM_CHANGES.md`: nothing uses this image as a `FROM` base.

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```

It fits because the app is a pip package. The base already provides `/app/venv` (created by `python3 -m venv`), `PIP_NO_CACHE_DIR=1`, and `USER apps`. Closest siblings: `apps/changedetection` (python-node, installs into `/app/venv/bin/pip`) for the venv pattern, and `apps/bazarr` for the python base with a runtime-only tree. The `python-node` base is not needed: no Node code.

## 4. Dockerfile

1. `ARG VERSION` only. No `TARGETARCH`: the install is arch-neutral (pip). Add `TARGETARCH` only if the torch step proves arch-specific.
2. `USER root` for installs, then `USER apps` at the end.
3. Install torch CPU first, from the PyTorch CPU index, so pip does not pull the CUDA stack from PyPI. Then install IOPaint, which sees torch already satisfied.

```dockerfile
ARG VERSION
USER root

ENV HOME=/config \
    TORCH_HOME=/config/cache/torch \
    HF_HOME=/config/cache/huggingface

RUN echo "*** Installing CPU PyTorch ***" && \
  /app/venv/bin/pip install --no-cache-dir \
    torch torchvision \
    --index-url https://download.pytorch.org/whl/cpu && \
  echo "*** Installing IOPaint ${VERSION} ***" && \
  /app/venv/bin/pip install --no-cache-dir "IOPaint==${VERSION}" && \
  echo "*** License ***" && \
  install -d /usr/share/licenses/lama-cleaner && \
  cp /app/venv/lib/python3*/site-packages/IOPaint-*.dist-info/LICENSE* /usr/share/licenses/lama-cleaner/ && \
  chown -R root:root /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
```

- The `dist-info` LICENSE path is UNVERIFIED: confirm with `pip show -f IOPaint` in the build. If the wheel does not ship a LICENSE, fetch it from the upstream tag instead.
- `/app` is owned by root and read-only for `apps`, as in `apps/bazarr`.
- `TORCH_HOME` and `HF_HOME` point at `/config` on purpose: the chart persists model caches, so persistence is required. This is the one exception to the "caches in `/tmp`" rule, and it is a decision (section 10).
- `ENV HOME=/config` follows the sibling pattern (`apps/adguardhome-sync`, `apps/docusaurus`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "lama-cleaner"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=IOPaint versioning=pep440
  default = "1.6.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/Sanster/IOPaint"
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
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `docker buildx bake --print` from `apps/lama-cleaner`. The `ARG VERSION` in the Dockerfile must equal `1.6.0`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Sanster/IOPaint"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: MODEL
    default: "lama"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `MODEL` is read by our `start.sh`, not by upstream directly. Keep it only if the CLI flag is confirmed (section 7).
- Chart values such as `sd_run_local`, `hf_access_token`, `sd_*` are Stable Diffusion options. They are out of scope for the CPU LaMa image and are not listed.
- No `dependencies`: standalone.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/cache/torch /config/cache/huggingface

cd /app
exec /app/venv/bin/iopaint start \
  --model="${MODEL:-lama}" \
  --device=cpu \
  --host=0.0.0.0 \
  --port=8080
```

- Idempotent: only creates cache directories. Nothing is seeded, nothing is written to `/app`.
- Binds `0.0.0.0` so other containers can reach it (`--host` flag UNVERIFIED).
- `exec` hands PID 1 to the server.
- The flags `--model`, `--device`, `--host`, `--port` are UNVERIFIED for IOPaint `1.6.0`. Confirm with `/app/venv/bin/iopaint start --help` in the built image before the first run, and correct the script to the real flags. Do not guess.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/venv/bin/iopaint
- /usr/share/licenses/lama-cleaner/LICENSE
```

- `timeoutSeconds: 180` follows `apps/changedetection` (Python app with a slow start).
- `http` path `/` returning 200 is UNVERIFIED. Adjust after the run, but do not remove the probe.
- Test runs with no env vars, so the default `MODEL` path is what gets tested.
- The test may need network if the model downloads at startup. UNVERIFIED whether IOPaint downloads the LaMa model at start or on first request. If it is on first request, the test checks the server only.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this image |
| --- | --- |
| `/root/.cache/torch` (chart PVC) | `TORCH_HOME=/config/cache/torch` (persistent, created by `start.sh`) |
| `/root/.cache/huggingface` (chart PVC) | `HF_HOME=/config/cache/huggingface` (persistent) |
| pip cache, build scratch | Disabled (`PIP_NO_CACHE_DIR=1` from base), `/tmp` cleared in the same layer |
| `/app/venv` (runtime) | Read-only, owned by root. Nothing writes to it at runtime. |
| IOPaint's own cache dir (UNVERIFIED) | Covered by `HOME=/config`; confirm on `--read-only` run and remap if it writes elsewhere |

Chart security expectations, reconciled:
- Chart runs as UID 0, `runAsNonRoot: false`. This image runs as `apps` and needs no root at runtime. The chart override is a downstream change, not part of this app.
- Chart `readOnlyRootFilesystem: false`. The image works with `--read-only --tmpfs /tmp`, to be proven in section 11.
- Chart persists `/root/.cache/*`. This image persists `/config/cache/*` instead. Existing chart users would need a new mount; record that in the PR.
- Not privileged. No extra capabilities. No GPU.

## 10. Risks, caveats and open questions

- **Decision needed: which project.** Upstream `lama-cleaner` is archived and renamed to IOPaint. Options: (a) package `IOPaint==1.6.0` as in this plan, (b) package `lama-cleaner==1.2.5`, the last release under the old name. Plan assumes (a). Keep the app name `lama-cleaner` to match the chart and draft, or rename to `iopaint`. Pick before work starts.
- **Python and torch compatibility.** Upstream CPU Dockerfile uses Python 3.7 and torch 1.12.1. The base here is Python 3.15.2. UNVERIFIED: whether PyTorch CPU wheels exist for this Python and whether IOPaint's pins resolve on 3.15. This is the main blocker and must be checked at `pip install` time.
- **Image size and RAM.** The torch stack is large, and inference is RAM-heavy (draft). UNVERIFIED size.
- **Port mismatch.** Draft and upstream say 8080. The chart service says 10604. UNVERIFIED which one the server binds by default; the chart's target port is not confirmed. Plan uses 8080 and changes the chart separately.
- **Caches in `/config`.** Model caches are in `/config` by design (chart persists them). Deviates from the `/tmp` cache rule; justified by persistence, but it is a choice to confirm.
- **Runtime model download.** Models are fetched from the internet on first use (draft and upstream docs). Slow first start; CI may lack network.
- **arm64 untested.** Docker Hub has amd64 only, so there is no reference arm64 image. Only the pip path exists for arm64.
- **Blockers:** none that stop the build, but the Python/torch pin is the likely failure (see above). No musl-only, no privileged, no mandatory GPU.

## 11. Build and test steps

```sh
cd apps/lama-cleaner
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name lama-cleaner-probe --read-only --tmpfs /tmp \
  -v lama-cleaner-probe-config:/config lama-cleaner:1.6.0
docker logs -f lama-cleaner-probe
forgetool containers test --image lama-cleaner:1.6.0 --config ./apps/lama-cleaner/container-test.yaml
docker rm -f lama-cleaner-probe; docker volume rm lama-cleaner-probe-config
```

Before the run, check the CLI: `docker run --rm --entrypoint /app/venv/bin/iopaint lama-cleaner:1.6.0 start --help`.

Expected readiness signal: a startup line from IOPaint with the bound address and port 8080 (exact text UNVERIFIED), then no traceback. Check `ss -ltn` inside the container for `0.0.0.0:8080`. From the host, `curl http://localhost:<mapped-port>/` should answer, which proves the port is not bound to localhost only.

Also confirm `/config/cache/torch` and `/config/cache/huggingface` exist after start.

## 12. PR checklist

- Branch `feat/add-lama-cleaner`, commit and PR title `feat(lama-cleaner): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what is untested: arm64 (no reference image), the torch CPU wheel on Python 3.15, model download at runtime, the `http /` status code, the `--read-only` run, and the chart mismatch (port and cache paths).
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
