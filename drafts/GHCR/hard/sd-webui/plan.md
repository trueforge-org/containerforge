# sd-webui — implementation plan
> Source: ./draft.md · Target: apps/sd-webui/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest upstream release | AUTOMATIC1111 stable-diffusion-webui v1.10.1, published 2025-02-09. No release assets: the web UI is a git source checkout. | https://api.github.com/repos/AUTOMATIC1111/stable-diffusion-webui/releases/latest |
| License | AGPL-3.0 | https://api.github.com/repos/AUTOMATIC1111/stable-diffusion-webui/license |
| Renovate | `datasource=github-tags depName=AUTOMATIC1111/stable-diffusion-webui` (proposed; not checked against repo config). Pin the git ref, not `HEAD`. | GitHub API |
| Checksum | None published. Pin by git commit ref in build args (`SD_WEBUI_REF` etc.). | upstream Dockerfile |
| Container image (TrueCharts) | `ghcr.io/neggles/sd-webui-docker:latest, vlad` | draft.md |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/neggles/sd-webui-docker/8d163826a402/docker/Dockerfile.auto | fetched |

Upstream Dockerfile summary (Dockerfile.auto):
- Stage 1: `FROM alpine/git:2.36.2 as download`. Clones at pinned refs: Stability-AI/stablediffusion, salesforce/BLIP, crowsonkb/k-diffusion, Stability-AI/generative-models, AUTOMATIC1111/stable-diffusion-webui-assets, and `${SD_WEBUI_REPO}` at `${SD_WEBUI_REF}`.
- Stage 2: `FROM base AS webui`. `base` is not defined in the file (UNVERIFIED: supplied by build context).
- No apt-get. pip installs CLIP and open_clip from git refs; xformers from pip.
- `ENV ROOT_DIR=/stable-diffusion-webui`, `DATA_DIR=/data`, `WEBUI_PORT=7860`, `UID=1000`, `GID=1000`, `CLI_ARGS=""`, plus CUDA and NVIDIA env (`NVIDIA_REQUIRE_CUDA="cuda>=12.1 driver>=500"`, `CUDA_MODULE_LOADING=LAZY`).
- `EXPOSE ${WEBUI_PORT}` (7860, confirmed). No VOLUME. No USER (root).
- `ENTRYPOINT ["/docker/entrypoint.sh"]`, `CMD python -u webui.py --listen --port ${WEBUI_PORT} --skip-version-check ${CLI_ARGS}`.
- Writes: `/stable-diffusion-webui`, `/docker`, `/root/.cache/pip`, and an in-place sed patch of `/usr/local/lib/python3.10/site-packages/gradio/routes.py`.

Ports: 7860 http (confirmed by EXPOSE).
Data: `DATA_DIR=/data` (env only; the file does not create it). Draft's `/data` and `/output` are chart paths.
Arm64: UNVERIFIED. The draft says `yes`, but the upstream image has no confirmed arm64 copy source and generation requires CUDA.
Copy-from amd64: `ghcr.io/neggles/sd-webui-docker:latest` (draft). Availability and musl status UNVERIFIED.

## 2. Target layout

Files in `apps/sd-webui/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.
- `defaults/` only if a default `config.json` is shipped (reason: seeding empty `/config`).
- No `etc/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Draft: `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`.
- Reason: Python web UI with pip deps. Closest siblings: `apps/bazarr` (python).
- Concern: upstream uses Python 3.10 paths (`/usr/local/lib/python3.10/...`). The ContainerForge python 3.15 base changes the site-packages path, so the gradio patch must be path-independent or removed (see section 4).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Clone the web UI at a pinned commit ref (`ARG SD_WEBUI_REF`) into `/app/stable-diffusion-webui` at build time. Do not clone at first start.
3. Install pip deps into `/app/venv` (python runtime rule: `/app/venv` read-only at runtime). Caches go to `/tmp` with `PIP_CACHE_DIR=/tmp/pip`.
4. CLIP and open_clip: pinned git refs (`CLIP_PKG_REF`, `OPENCLIP_PKG_REF`).
5. Gradio patch: do not apply the upstream `sed` to `/usr/local/lib/...`; re-check it against the Gradio version installed in the venv. If the patch is still needed, apply it inside `/app/venv` at build time only.
6. apt: none expected (UNVERIFIED: `git` may be needed at build; use the build stage, not the runtime image).
7. Ship AGPL-3.0 license to `/usr/share/licenses/sd-webui/`.
8. `COPY --chmod=0755 . /`, `EXPOSE 7860`, `VOLUME /config`, `USER apps`.
9. ENV: `PYTHONUNBUFFERED=1`, `PIP_ROOT_USER_ACTION=ignore`, `DATA_DIR=/config/data`, `WEBUI_PORT=7860`.

## 5. docker-bake.hcl

- `variable "APP" { default = "sd-webui" }`
- `variable "VERSION" { // renovate: datasource=github-tags depName=AUTOMATIC1111/stable-diffusion-webui versioning=loose` then `default = "1.10.1"`. Pin a tag; keep the commit ref as a separate build arg.
- `variable "LICENSE" { default = "AGPL-3.0-only" }` (SPDX: AGPL-3.0 per GitHub API; confirm `-only` vs `-or-later` against the repo LICENSE).
- `variable "SOURCE" { default = "https://github.com/AUTOMATIC1111/stable-diffusion-webui" }`
- Standard targets and default group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: https://github.com/AUTOMATIC1111/stable-diffusion-webui`.
- `ports`: `7860` http, `required: true`.
- `env`: `WEBUI_PORT` (default `7860`), `CLI_ARGS` (default empty), `DATA_DIR` (default `/config/data`). Only add more after start.sh uses them.
- `volumes`: `/config` (persistent). Models and outputs go under `/config`.
- `dependencies`: none.

## 7. start.sh

- Idempotent. Create `/config/data` and `/config/output` only when missing.
- Symlink-free: pass `--data-dir /config/data` and `--output-dir /config/output` explicitly (flag names UNVERIFIED against the pinned commit).
- Bind `0.0.0.0` (`--listen` is in upstream CMD).
- Caches to `/tmp`. Never write to `/app`.
- `exec python -u webui.py --listen --port ${WEBUI_PORT} --skip-version-check ${CLI_ARGS}` from `/app/venv/bin/python`.

## 8. container-test.yaml

- forgetool schema header.
- `tcp` probe on 7860 with a `timeoutSeconds` from a sibling Python app (e.g. bazarr).
- `filePaths`: `/app/stable-diffusion-webui/webui.py`, `/app/venv/bin/python`.
- The test starts without a GPU and without models. The web UI must still start and listen on 7860 (CPU mode). If it fails without CUDA, that is a blocker (section 10), not a reason to weaken the test.

## 9. Rootless and read-only-rootfs adaptations

- Upstream: root, no USER. Chart: `runAsUser 0`, `readOnlyRootFilesystem false`, privileged not set (common default false). ContainerForge: `USER apps` and read-only rootfs.
- Writes: models, outputs and config to `/config`; pip and torch caches to `/tmp`; the web UI git clone is build-time only.
- GPU: CUDA passthrough is a runtime hardware requirement (not in chart values). Document it; do not add `privileged`.
- Expected: non-root yes (target), read-only yes (target), privileged no.

## 10. Risks, caveats and open questions

- CUDA GPU required for generation. CPU-only hosts run very slowly or fail (inferred).
- Torch and model weights: several GB. Do NOT download at build time (image size) and do NOT download in the test. Download on first run only if the user asks (UNVERIFIED that the pinned web UI supports this without a git clone).
- No arm64 copy source; arm64 needs a build from git source (inferred). Confirm before claiming arm64 in bake.
- The upstream image uses Python 3.10; ContainerForge python base is 3.15. Compatibility of pinned torch and xformers with 3.15 is UNVERIFIED and may block the build.
- Blockers: CUDA requirement; Python version mismatch; large stack; arm64 unverified.

## 11. Build and test steps

1. `cd apps/sd-webui && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name sd-webui-probe --read-only --tmpfs /tmp -v sd-webui-probe-config:/config sd-webui:<version>`, then `docker logs -f sd-webui-probe`.
4. Readiness: the web UI's startup line on port 7860 (UNVERIFIED wording; capture on first run) with the process alive and no fatal errors.
5. `forgetool containers test --image sd-webui:<version> --config ./apps/sd-webui/container-test.yaml`.
6. Cleanup: `docker rm -f sd-webui-probe; docker volume rm sd-webui-probe-config`.
- Not run here: no docker build was run for this plan.

## 12. PR checklist

- Branch `feat/add-sd-webui`, commit `feat(sd-webui): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes: `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; tell the user).
- Say what is untested: CUDA runtime, arm64, model downloads, Python 3.15 compatibility.
