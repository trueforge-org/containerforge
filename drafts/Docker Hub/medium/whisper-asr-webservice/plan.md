# whisper-asr-webservice — implementation plan
> Source: ./draft.md · Target: apps/whisper-asr-webservice/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins `v1.10.0` (published 2026-08-09T20:35:06Z, not a prerelease). Latest stable is `v1.11.0` (published 2026-11-22T22:49:28Z). This plan keeps `1.10.0` as the draft asks; bumping is a renovate change. |
| Renovate | `// renovate: datasource=github-releases depName=ahmetoner/whisper-asr-webservice versioning=semver` (UNVERIFIED that the strict semver match works for `v`-prefixed tags; the `v` is stripped where needed). |
| License | MIT (GitHub API `license.spdx_id`) |
| Source URL | https://github.com/ahmetoner/whisper-asr-webservice |
| Download | Source archive `https://github.com/ahmetoner/whisper-asr-webservice/archive/refs/tags/v${VERSION}.tar.gz` (tag-based; URL form is standard GitHub, not fetched in this run, so UNVERIFIED for the exact name). No prebuilt binary; the app is Python (poetry). Same for amd64 and arm64. |
| Checksum source | None published on the release page. The archive is pinned by tag. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ahmetoner/whisper-asr-webservice/v1.10.0/Dockerfile: `FROM onerahmet/ffmpeg:n7.1 AS ffmpeg`, `FROM swaggerapi/swagger-ui:v5.9.1 AS swagger-ui`, `FROM python:3.12-bookworm`; `ENV POETRY_VENV=/app/.venv`; `python3 -m venv $POETRY_VENV`; `pip install poetry==2.1.3`; `poetry config virtualenvs.in-project true`; `poetry install --extras cpu`; `COPY --from=ffmpeg /usr/local/bin/ffmpeg`; `COPY --from=swagger-ui` assets into `swagger-ui-assets/`; `EXPOSE 9000`; `ENTRYPOINT ["whisper-asr-webservice"]`. No apt step, no VOLUME, no USER, no CMD. |
| Port | 9000/tcp (EXPOSE 9000). |
| Python requirement | `pyproject.toml` at v1.10.0: `requires-python = ">=3.10,<3.14"`. Console script `whisper-asr-webservice = "app.webservice:start"` (click options `-h/--host` default `0.0.0.0`, `-p/--port` default 9000). Optional `cpu` extra: `torch==2.7.1`, `torchaudio==2.7.1`; poetry sources `pytorch-cpu` (https://download.pytorch.org/whl/cpu) for x86_64, PyPI for aarch64. |
| Env vars (real) | Dockerfile sets only `POETRY_VENV` and `PATH`. `app/config.py` at v1.10.0 reads `ASR_ENGINE` (default `openai_whisper`), `ASR_MODEL` (default `base`), `ASR_MODEL_PATH` (default `~/.cache/whisper`), `ASR_DEVICE`, `ASR_QUANTIZATION`, `HF_TOKEN`, `MODEL_IDLE_TIMEOUT`, `SAMPLE_RATE`, `SUBTITLE_*`. |
| Models | Downloaded at first run from the internet. Size UNVERIFIED (draft says several GB; upstream image size is about 7.6 GB amd64 for the newest tag, per Docker Hub listing). |
| ffmpeg | Upstream does NOT install ffmpeg with apt; it copies `/usr/local/bin/ffmpeg` from `onerahmet/ffmpeg:n7.1`. The draft says apt `ffmpeg`. Use apt `ffmpeg` on the ContainerForge base (no third-party `COPY --from`), and verify the package version works with the app (UNVERIFIED). |
| Docker Hub | `onerahmet/openai-whisper-asr-webservice` has 67 tags; the newest tag has amd64 and arm64 images (listing checked; arm64 for `v1.10.0` itself UNVERIFIED). |

## 2. Target layout

- `apps/whisper-asr-webservice/Dockerfile`
- `apps/whisper-asr-webservice/docker-bake.hcl`
- `apps/whisper-asr-webservice/settings.yaml`
- `apps/whisper-asr-webservice/container-test.yaml`
- `apps/whisper-asr-webservice/start.sh`

No `defaults/` or `etc/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` for both stages (the python base already provides `/app/venv` via `VENV_FOLDER`, and `PIP_*` cache settings; see `apps/python`). BLOCKER (needs a human decision): upstream `requires-python` is `>=3.10,<3.14` (section 1), so Python 3.15.2 is NOT supported. The only python bases in this repo are `python:3.15.2` and `python:3.14.8` (and `python-node` at the same versions); both are outside the range. Options: add a Python 3.13 (or 3.12) base image as a separate task first, or install an older Python via apt on `ubuntu` (UNVERIFIED availability on 26.04). Do not build on 3.15 as written here; the `FROM` line above is a placeholder until that is decided.

Closest sibling: `apps/bazarr` (python app that installs ffmpeg via apt on the python base, pip/venv, `/config` data).

## 4. Dockerfile

Follow `.github/instructions/python-runtime.instructions.md`: `/app/venv` is read-only at runtime, so the venv is built at build time and not modified by `start.sh`. Caches go to `/tmp`.

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends ffmpeg` (pin the package version against the Ubuntu archive; check whether the base already has ffmpeg, do not reinstall). Then `apt-get clean && rm -rf /var/lib/apt/lists/*`.
3. Fetch the source to `/app`:
   `mkdir -p /app && curl -fL "https://github.com/ahmetoner/whisper-asr-webservice/archive/refs/tags/v${VERSION}.tar.gz" -o /tmp/src.tar.gz && tar xzf /tmp/src.tar.gz -C /app --strip-components=1 && rm /tmp/src.tar.gz`
4. Build the venv under `/app/venv` (base already sets `VENV_FOLDER=/app/venv`; use the existing venv if the base has one, do not overwrite the base venv):
   - Install poetry into a temp venv under `/tmp`, not into the final venv: `pip install poetry==2.1.3`.
   - Export and install the CPU variant: `poetry export --extras cpu --without-hashes -f requirements.txt -o /tmp/req.txt` (poetry-plugin-export is needed; UNVERIFIED that it is available by default in poetry 2.1.3, install it if not), then `/app/venv/bin/pip install -r /tmp/req.txt` with the CPU torch index taken from `pyproject.toml` (`https://download.pytorch.org/whl/cpu` for x86_64; aarch64 uses PyPI, per `pyproject.toml`).
   - Alternative if export is unsuitable: `POETRY_VIRTUALENVS_CREATE=false poetry install --extras cpu` against the base python (no in-project venv). Pick one and record it.
   - Set `PIP_CACHE_DIR=/tmp/pip-cache` (base already sets `PIP_NO_CACHE_DIR=1`, so no cache is written at all).
5. Copy the upstream swagger-ui assets: `curl` the `swagger-ui-dist` assets pinned to `v5.9.1` from npm or GitHub (UNVERIFIED URL), or use the upstream's `swagger-ui-assets` directory as shipped in the source (check the repo first; prefer what the source tree already contains).
6. License: `install -D /app/LICENSE /usr/share/licenses/whisper-asr-webservice/LICENSE`.
7. `chown -R apps:apps /app && chmod -R 755 /app` (so `/app` stays read-only at runtime and is owned consistently; same as `apps/adguardhome-sync`).
8. `ENV HOME=/config XDG_CACHE_HOME=/config/cache ASR_MODEL=base ASR_ENGINE=openai_whisper` (only the names confirmed in section 6; UNVERIFIED names are removed). The model cache must persist, so it lives in `/config` (justified by persistence, otherwise `/tmp`). Upstream reads the cache from `ASR_MODEL_PATH` (default `~/.cache/whisper`), not `XDG_CACHE_HOME`, so set `ASR_MODEL_PATH=/config/cache/whisper` in the Dockerfile ENV and `start.sh` (`HOME=/config` gives the same result by default; `XDG_CACHE_HOME` alone is UNVERIFIED to move it).
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 9000
VOLUME /config
WORKDIR /app
```

`ENTRYPOINT` and `CMD` are set in `start.sh` (exec), not in the Dockerfile.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "whisper-asr-webservice" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=ahmetoner/whisper-asr-webservice versioning=semver
  default = "1.10.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/ahmetoner/whisper-asr-webservice" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print` in `apps/whisper-asr-webservice`. `ARG VERSION` must equal `1.10.0`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ahmetoner/whisper-asr-webservice"
ports:
  - port: 9000
    protocol: tcp
    required: false
env:
  - name: ASR_MODEL
    default: "base"
    required: false
  - name: ASR_ENGINE
    default: "openai_whisper"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`ASR_MODEL` and `ASR_ENGINE` are read by upstream `app/config.py` with these defaults. Consider adding `ASR_MODEL_PATH` (set to `/config/cache/whisper`). Port 9000 is confirmed. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Models and other persistent state live in /config; create only when missing.
mkdir -p /config/cache
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/config/cache}"
export ASR_MODEL="${ASR_MODEL:-base}"
export ASR_ENGINE="${ASR_ENGINE:-openai_whisper}"

cd /app
exec /app/venv/bin/whisper-asr-webservice --host 0.0.0.0 --port 9000
```

- Upstream's `ENTRYPOINT ["whisper-asr-webservice"]` is the console script `app.webservice:start` with click options `--host` (default 0.0.0.0) and `--port` (default 9000), confirmed at v1.10.0. Check `/app/venv/bin/whisper-asr-webservice` exists after build.
- `exec` for signal handoff.
- Nothing writes to `/app`. The temporary model download path must be `/config`, not `/app`.
- Bind `0.0.0.0` (ContainerForge rule for servers used from other containers); verify with an external curl during the probe.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 600
tcp:
- port: '9000'
http:
- port: '9000'
  path: /docs
filePaths:
- /app/venv/bin/whisper-asr-webservice
- /usr/share/licenses/whisper-asr-webservice/LICENSE
```

- Swagger docs at `/docs` is the expected HTTP path (UNVERIFIED: confirm the route exists; if not, use `/` and keep the probe). The 600 second timeout is for first-run startup only if the server preloads the model; sibling apps use 180 to 300 (confirm), so use the smallest value that passes.
- Do not download the model in the test. If the server loads the model at startup, the test will wait for the download, which is slow. If that is too slow for CI, record it as a blocker, do not remove the probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/root/.cache/pip`, `/root/.cache/poetry` (draft extra-persistence) | Build time only: `/tmp` (pip cache disabled by base). None at runtime. |
| `/root/.cache/whisper` (model cache, draft extra-persistence) | `/config/cache` via `XDG_CACHE_HOME` (persistent, justified because models are large and must survive restarts). |
| `/root` (upstream runs as root) | `HOME=/config`. Runtime runs as `apps` (568). |
| ffmpeg temp files | `/tmp` (tmpfs in the probe). |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`; this image runs as `apps`, `--read-only --tmpfs /tmp`, so the chart's `/root/.cache/*` persistence maps to `/config/cache` (existing model caches must be moved; note in PR). Not privileged.

## 10. Risks, caveats and open questions

- Python version: upstream requires `>=3.10,<3.14` (upstream image uses 3.12); the ContainerForge python bases are 3.14.8 and 3.15.2, both unsupported. This blocks the build until a compatible base exists (section 3).
- CPU torch: the draft uses the upstream `cpu` extra. Confirm the index in `pyproject.toml`. The image size is large (upstream listing about 7.6 GB amd64); the build may hit disk limits in CI.
- Models: first start downloads several GB into `/config/cache`; the probe with an empty `/config` will download. Use a small model (`ASR_MODEL=tiny` or `base`) in tests, not the default large one, if the app allows it (UNVERIFIED).
- arm64: the upstream is a Python build, so arm64 is a rebuild (no copy-from). Torch CPU wheels for arm64 availability are UNVERIFIED. Draft says "yes" for arm64; confirm during build.
- GPU: the CUDA variant is out of scope (draft).
- Blockers: none confirmed. No musl issue (glibc Ubuntu). Not privileged.

## 11. Build and test steps

```sh
cd apps/whisper-asr-webservice
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name whisper-probe --read-only --tmpfs /tmp \
  -e ASR_MODEL=tiny -v whisper-probe-config:/config whisper-asr-webservice:1.10.0
docker logs -f whisper-probe
forgetool containers test --image whisper-asr-webservice:1.10.0 --config ./apps/whisper-asr-webservice/container-test.yaml
docker rm -f whisper-probe; docker volume rm whisper-probe-config
```

The `-e ASR_MODEL=tiny` is only for the manual probe; the CI test runs with no env vars, as the protocol requires. Readiness signal: the uvicorn "Uvicorn running on http://0.0.0.0:9000" line (UNVERIFIED until run). Also confirm `/config/cache` holds the model after a restart.

## 12. PR checklist

- Branch `feat/add-whisper-asr-webservice`, commit `feat(whisper-asr-webservice): add new container`, PR title `feat(whisper-asr-webservice): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what is untested: the build on each arch, the model download path, the Python 3.15 compatibility, and the arm64 build.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
