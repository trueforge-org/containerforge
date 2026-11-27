# ollama — implementation plan
> Source: ./draft.md · Target: apps/ollama/ · Difficulty: medium · Role: sidecar (chart `uiImage`, Open WebUI) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Open WebUI latest GitHub release `v0.13.5`, published 2026-11-25, not prerelease. https://github.com/open-webui/open-webui/releases/tag/v0.13.5 . PyPI `open-webui` is also `0.13.5` (https://pypi.org/pypi/open-webui/json). Pin `0.13.5`, not `latest`. |
| Chart image | `ghcr.io/open-webui/open-webui:latest` (draft; unpinned, digest UNVERIFIED). The chart's Ollama server image was not fetched (UNVERIFIED). |
| Renovate | `datasource=pypi depName=open-webui versioning=pep440` for the version. |
| License | Open WebUI License (custom, not OSI-approved, no SPDX id). https://raw.githubusercontent.com/open-webui/open-webui/main/LICENSE . Clause 4 has branding restrictions. See section 10. |
| Source URL | https://github.com/open-webui/open-webui |
| Download | PyPI package `open-webui==0.13.5`. `requires_python` is `>=3.11,<3.13.0a1`, so Python 3.11 or 3.12 only. PyPI `license_expression` is null; the package ships `LICENSE`, `LICENSE_HISTORY`, `LICENSE_NOTICE`. |
| Checksum source | PyPI sha256 per file (files list not read: UNVERIFIED). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/open-webui/open-webui/main/Dockerfile . Stage 1 `FROM --platform=$BUILDPLATFORM node:22-alpine3.20 AS build` builds the frontend. Stage 2 `FROM python:3.12-slim-trixie AS base` is the image: pip installs CPU `torch<=2.9.1` from download.pytorch.org, then `uv pip install --system` of locked requirements, copies the built frontend. `USER $UID:$GID` (defaults 0:0, root). `CMD ["bash","start.sh"]`, no ENTRYPOINT, `EXPOSE 8080`, no VOLUME. |
| Port | `PORT=8080` (upstream ENV, Dockerfile). |
| Env vars (real, from Dockerfile) | `ENV=prod`, `PORT=8080`, `PYTHONUNBUFFERED=1`, `DOCKER=true`, `OLLAMA_BASE_URL` (`/ollama`), `OPENAI_API_BASE_URL`, `OPENAI_API_KEY` (empty), `WEBUI_SECRET_KEY` (empty), `SCARF_NO_ANALYTICS`, `DO_NOT_TRACK`, `ANONYMIZED_TELEMETRY` (disabled), RAG/Whisper/HF cache vars, `UV_LINK_MODE=copy`, `HOME=/root`. `DATA_DIR` and the `open-webui serve` CLI are UNVERIFIED (not in the fetched Dockerfile). |
| Data path | Upstream sets up `/app/backend/data`; no VOLUME. Chart mounts `/app/backend/data` (pvc) and `/root/.ollama` (pvc). Draft says `/config`. |
| Dependencies | Ollama server is a separate service (draft; chart role sidecar). No ContainerForge `dependencies` entry is confirmed. |
| arm64 | PyPI package is arch-independent. Torch CPU wheels are needed only by the upstream image (see section 4). Upstream image multi-arch status: UNVERIFIED. |

## 2. Target layout

- `apps/ollama/Dockerfile`
- `apps/ollama/docker-bake.hcl`
- `apps/ollama/settings.yaml`
- `apps/ollama/container-test.yaml`
- `apps/ollama/start.sh`

No `defaults/`, `etc/` or `health/` needed unless the setup in section 7 needs a seed file. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

**Name check (decision needed):** the app is named `ollama` (draft), but the code it builds is Open WebUI, the chart's UI sidecar. The Ollama server itself is a different image that this draft does not cover. See section 10.

## 3. Base image

Runtime and build base must be a ContainerForge Python base, per the python-runtime rule. The closest sibling is `apps/python` (`ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`, venv at `/app/venv`).

**Blocker:** Open WebUI 0.13.5 needs Python `>=3.11,<3.13`. The `python` base is 3.15.2, which is outside that range. No ContainerForge base with Python 3.11 or 3.12 is confirmed in this plan. Options, to decide before writing the Dockerfile:
- (a) Build `/app/venv` on Ubuntu (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`) with a Python 3.12 interpreter (for example `uv python install 3.12` in the build stage; uv verifies the download). The venv is then a self-contained `/app/venv`, and `python` base is not used. Recommended, but it needs the maintainers to accept a non-base Python.
- (b) Find a ContainerForge Python 3.12 base (none found in the brief's base list; UNVERIFIED for older tags).

Closest sibling for the start script and venv layout: `apps/bazarr` (python, `/app/venv` pattern).

## 4. Dockerfile

Pick option (a) from section 3 unless the maintainers choose (b). Steps for option (a):

1. Build stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build`, `ARG VERSION`, `USER root`.
2. Install a Python 3.12 with uv: `RUN curl -LsSf https://astral.sh/uv/... ` (pin the uv version and its checksum; UNVERIFIED, check the uv release page first), then `uv python install 3.12 --install-dir /opt/python` (uv downloads a standalone build and verifies it).
3. Create the venv under `/app/venv` at build time: `/opt/python/bin/python3.12 -m venv /app/venv`, then `/app/venv/bin/pip install --no-cache-dir "open-webui==${VERSION}"`. Set `PIP_NO_CACHE_DIR=1` and `UV_NO_CACHE=true` and `HOME=/tmp` so no cache lands in `/config`. Torch is NOT installed (see section 10).
4. Remove test and cache artifacts: `find /app/venv -depth -name __pycache__ -exec rm -rf {} +`, `rm -rf /tmp/*`.
5. License: `mkdir -p /usr/share/licenses/ollama && cp /app/venv/lib/python3.12/site-packages/open_webui*/LICENSE* /usr/share/licenses/ollama/` (exact dist-info path UNVERIFIED; locate it in the build).
6. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, `ARG VERSION`, `USER root`.
7. `COPY --from=build /opt/python /opt/python`, `COPY --from=build /app/venv /app/venv`, `COPY --from=build /usr/share/licenses/ollama /usr/share/licenses/ollama`, then `chown -R apps:apps /app && chmod -R 755 /app`. The venv's `python` symlink must resolve inside `/opt/python`, so copy that tree whole (UNVERIFIED that the symlinks are relative).
8. `ENV PORT=8080 PYTHONUNBUFFERED=1 DOCKER=true ENV=prod SCARF_NO_ANALYTICS=true DO_NOT_TRACK=true ANONYMIZED_TELEMETRY=false HOME=/config PATH=/app/venv/bin:/opt/python/bin:$PATH`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

`ARG VERSION` equals the bake `VERSION`. Do not copy the upstream frontend build unless the PyPI wheel lacks it (UNVERIFIED that the wheel ships the built frontend; check the wheel contents in the build).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "ollama"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=open-webui versioning=pep440
  default = "0.13.5"
}

variable "LICENSE" {
  default = "Open WebUI License"
}

variable "SOURCE" {
  default = "https://github.com/open-webui/open-webui"
}
```

Then the `group "default"`, `target "image"`, `target "image-local"` and `target "image-all"` blocks copied verbatim from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/ollama`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/open-webui/open-webui"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "8080"
    required: false
  - name: OLLAMA_BASE_URL
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`OLLAMA_BASE_URL` is the one setting the Ollama sidecar needs (upstream ENV, default `/ollama`): the user points it at the Ollama server. `WEBUI_SECRET_KEY` is not listed with a default; see section 7 for how it is generated. Add `DATA_DIR` only after its name is confirmed (UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

if [[ ! -s /config/webui-secret-key ]]; then
    head -c 32 /dev/urandom | base64 > /config/webui-secret-key
fi
export WEBUI_SECRET_KEY="${WEBUI_SECRET_KEY:-$(cat /config/webui-secret-key)}"
export DATA_DIR=/config/data
export HF_HOME=/tmp/huggingface SENTENCE_TRANSFORMERS_HOME=/tmp/sentence-transformers

cd /app
exec /app/venv/bin/open-webui serve --port "${PORT:-8080}" --host 0.0.0.0
```

Points to check before it is final:
- `DATA_DIR` is the variable Open WebUI reads for its data folder: UNVERIFIED (the fetched Dockerfile only sets up `/app/backend/data`). If it is not read, the data must be redirected another way (symlink created at build time, which is not possible for `/config` because it is empty at build time; use `start.sh` to create `/app/backend/data` as a symlink into `/config`, not a writable `/app`, so this needs a different approach: see section 10).
- `open-webui serve` CLI form is UNVERIFIED; upstream runs `bash start.sh`. Read upstream `backend/start.sh` (not fetched) to copy its real command.
- `WEBUI_SECRET_KEY` is kept in `/config` so the sessions survive restarts. The key is never printed to the log.
- Do not write to `/app`. Caches go to `/tmp`.
- Use `exec` so Open WebUI gets signals.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8080'
http:
- port: '8080'
  path: /health
filePaths:
- /app/venv/bin/open-webui
- /usr/share/licenses/ollama
```

`timeoutSeconds: 300` is a placeholder for a large Python web app; take the family value from `apps/bazarr/container-test.yaml` (it has no timeout line; set it from the first real run). The `/health` path is UNVERIFIED for Open WebUI: confirm it returns 200 on an empty `/config` before keeping it, otherwise probe `/` only. The protocol's database exception does not apply (no hard database dependency).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/backend/data` (`DATA_DIR`, database, uploads, vector data) | `/config/data` (UNVERIFIED variable, see section 7). |
| `/root/.ollama` (chart PVC) | Not used by Open WebUI: the model store belongs to the Ollama server, not this image. Drop it from this app. |
| Hugging Face and sentence-transformers caches | `/tmp` (`HF_HOME`, `SENTENCE_TRANSFORMERS_HOME`). |
| `HOME=/root` (upstream) | `HOME=/config` here, so home-directory writes go to `/config`, not `/root` (run as `apps`, UID 568). |
| Upstream runs as root (`UID=0`) | This image runs as `apps` (568). Chart `runAsUser: 0`. |

Draft expectations reconciled: chart `readOnlyRootFilesystem: false`, but the plan must work with `--read-only --tmpfs /tmp` (section 11). `privileged: false`, no GPU settings in values. The draft's claim that model and cache dirs go to `/config` and `/tmp` is only partly right: models are on the Ollama server, not here.

## 10. Risks, caveats and open questions

- **Python version (blocker, decision needed):** Open WebUI 0.13.5 needs Python `<3.13`. The `python` base is 3.15.2. Option (a) in section 3 builds a venv with uv-managed Python 3.12 on Ubuntu, which is not a ContainerForge base. Choose before the Dockerfile is written.
- **App name:** the draft names the app `ollama`, but it runs Open WebUI, not the Ollama server. The Ollama server (the model runtime, `/root/.ollama`) is not covered by this draft and would be a separate app. Confirm the name with the maintainers.
- **Data redirect (decision needed):** `DATA_DIR` is UNVERIFIED. If Open WebUI has no data-directory variable, the data path needs another approach (a build-time symlink cannot point into the empty `/config`; `start.sh` would need to link `/app/backend/data`, which requires writable `/app`, so this is a blocker under the read-only rule).
- **Torch:** upstream installs CPU torch for local RAG models. This plan does not install torch (size, and it would need the pytorch index). Features that need local embedding models will then fail unless the model is downloaded at runtime to `/tmp` (UNVERIFIED impact).
- **Version pin:** the chart uses `latest` (digest UNVERIFIED). The plan pins `0.13.5`; the chart's tag change is a downstream decision.
- **License:** Open WebUI License is custom and not OSI-approved; clause 4 restricts branding. The bake `LICENSE` label uses the name. Confirm the redistribution terms with the maintainers before a PR.
- Resource: model downloads are large and RAM grows with model size (draft, inferred). Ollama server needs a GPU only on the Ollama side (draft; the chart has no GPU settings).
- `WEBUI_SECRET_KEY`: losing it on a changed `/config` logs users out (inferred). Keep it in `/config`.
- Telemetry: opted out in the upstream ENV; keep it that way.
- No blockers from musl, privilege or GPU in this image.

## 11. Build and test steps

```sh
cd apps/ollama
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ollama-probe --read-only --tmpfs /tmp \
  -v ollama-probe-config:/config ollama:0.13.5
docker logs -f ollama-probe
forgetool containers test --image ollama:0.13.5 --config ./apps/ollama/container-test.yaml
docker rm -f ollama-probe; docker volume rm ollama-probe-config
```

Expected readiness signal: Open WebUI's startup log (`Uvicorn running on http://0.0.0.0:8080` or equivalent, UNVERIFIED wording) and a listening socket on 8080. Restart with the same `/config` volume to confirm the secret key and data persist. Check `/config/data` exists after the first start.

## 12. PR checklist

- Branch `feat/add-ollama`, commit and PR title `feat(ollama): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- CLA notice: the contribution needs a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR what is not tested: the Python 3.12 venv build, the `DATA_DIR` redirect, the `/health` probe, the arm64 build, and any feature that needs local models.
- Resolve the Python version, app name, and license decisions in section 10 before opening the PR.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
