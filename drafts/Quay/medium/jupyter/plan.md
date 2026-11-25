# jupyter — implementation plan
> Source: ./draft.md · Target: apps/jupyter/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `7.6.5` (notebook). Latest stable on PyPI and GitHub `jupyter/notebook` release `v7.6.5` (published 2026-11-06). Source: https://pypi.org/pypi/notebook/json, `gh api repos/jupyter/notebook/releases/latest`. The chart uses `quay.io/jupyter/base-notebook:notebook-7.4.7` (draft), which is older; the ContainerForge image does not reuse that image. |
| JupyterLab version | UNVERIFIED: not read on a fetched page. Pin at implementation time from https://pypi.org/pypi/jupyterlab/json, pick the release that supports notebook 7.6.5. |
| Renovate | `datasource=pypi depName=notebook versioning=pep440` (proposed; no sibling precedent checked) |
| License | BSD-3-Clause for `notebook` (PyPI `license` field) and for `jupyter/docker-stacks` (`gh api repos/jupyter/docker-stacks`). Use `BSD-3-Clause` as `LICENSE`. |
| Source URL | https://github.com/jupyter/notebook |
| Download | pip package from PyPI (pure Python, no per-arch binary). `requires_python >=3.10` (PyPI). Install with `uv pip` into the base image venv, so amd64 and arm64 both work. |
| Checksum source | PyPI wheel hashes (UNVERIFIED: hashes not read on a fetched page). The pip resolver checks them when `--require-hashes` is used. |
| Upstream Dockerfile reviewed | `images/base-notebook/Dockerfile` at commit `fe190c9e10d341558f637d9e7c2e2dff6145ef6b` (https://raw.githubusercontent.com/jupyter/docker-stacks/fe190c9e10d341558f637d9e7c2e2dff6145ef6b/images/base-notebook/Dockerfile). It does `FROM quay.io/jupyter/docker-stacks-foundation`, sets `ENV JUPYTER_PORT=8888`, installs apt `fonts-liberation pandoc run-one`, mamba installs `jupyterhub-singleuser jupyterlab nbclassic notebook>=7.2.2`, `EXPOSE 8888`, `CMD ["start-notebook.py"]`, `WORKDIR ${HOME}`, final user `${NB_UID}`. |
| Port | 8888/tcp (`JUPYTER_PORT=8888`, EXPOSE). |
| Env vars (real) | `JUPYTER_PORT=8888` (upstream Dockerfile). Notebook reads its own env vars (`JUPYTER_CONFIG_DIR`, `JUPYTER_DATA_DIR`, `JUPYTER_RUNTIME_DIR`, `JUPYTER_TOKEN`). Exact names for token and config: UNVERIFIED for the pinned version, confirm with `jupyter server --help` in the build. |
| Data and config paths | Upstream: home `/home/jovyan` (NB_USER jovyan), config in `/etc/jupyter`, work dir `${HOME}`. Upstream startup scripts are in `/usr/local/bin/start-notebook.py` (not read in full). |
| Startup behaviour | Notebook generates an access token on first start and logs it (draft caveat, inferred; token log line not confirmed on a fetched page). |
| Dependencies | None hard. Optional chart images `minimal-notebook`, `r-notebook`, `scipy-notebook`, `tensorflow-notebook`, `datascience-notebook`, `pyspark-notebook`, `all-spark-notebook`: none exist under `apps/` (checked). |
| Blockers | None confirmed. The upstream `docker-stacks` image is a mamba-based image on a foundation image. This port replaces it with pip on the ContainerForge python base. |

## 2. Target layout

- `apps/jupyter/Dockerfile`: build and install into `/app/venv` (build time only).
- `apps/jupyter/docker-bake.hcl`: APP, VERSION (notebook), LICENSE, SOURCE, standard targets.
- `apps/jupyter/settings.yaml`: port 8888, env vars, `/config` volume.
- `apps/jupyter/container-test.yaml`: http probe on 8888.
- `apps/jupyter/start.sh`: sets env and `exec`s `jupyter`.
- Not needed: `defaults/`, `etc/`, `health/`, `root/`. `DOWNSTREAM_CHANGES.md` is not needed (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because JupyterLab and notebook are pure Python packages, and the base ships `/app/venv` and a pip/uv toolchain. Closest sibling: `apps/bazarr` (python base, `uv pip install` of a pinned requirement set, `start.sh` that `exec`s a python app, `CMD [""]`, `USER apps`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

1. `ARG VERSION` and `ARG VENDOR` only, values matching `docker-bake.hcl`.
2. `ENV JUPYTER_PORT=8888` (same name as upstream, for start.sh).
3. `USER root` only for installs, then back to `USER apps`.
4. Install with uv into the base venv, caches in `/tmp`:
   ```
   RUN pip install uv \
    && UV_CACHE_DIR=/tmp/uv-cache uv pip install --python /app/venv/bin/python \
         "notebook==${VERSION}" "jupyterlab==${JUPYTERLAB_VERSION}" \
    && pip uninstall --yes uv \
    && rm -rf /tmp/* /root/.cache
   ```
   `JUPYTERLAB_VERSION` is a second `ARG` with its own renovate annotation (see section 5). Check: the base `python` image may already ship `uv`; if so, skip `pip install uv` and the uninstall (verify at build time).
5. Do not install apt packages. The upstream `pandoc` and `fonts-liberation` are optional; add them only if the notebook needs them (UNVERIFIED need). Adding them increases the image; default is none.
6. Ship license: `COPY` is not needed, install `notebook` license file into `/usr/share/licenses/jupyter/` from the installed dist-info (`cp /app/venv/lib/python*/site-packages/notebook-*.dist-info/licenses/* /usr/share/licenses/jupyter/` or equivalent; verify the path at build time).
7. Freeze the environment: `RUN /app/venv/bin/python -m pip check` as a build-time sanity check.
8. `COPY --chmod=0755 . /` then `EXPOSE 8888`, `VOLUME /config` (only if the settings.yaml declares it; see section 6), `USER apps`, `WORKDIR /config`.

Do not write to `/app/venv` at runtime (python-runtime rule). Pip, uv and build caches go to `/tmp`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "jupyter"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=notebook versioning=pep440
  default = "7.6.5"
}

variable "JUPYTERLAB_VERSION" {
  // renovate: datasource=pypi depName=jupyterlab versioning=pep440
  default = "UNVERIFIED"   // set the real pin at implementation time
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/jupyter/notebook"
}
```
Then `group "default"`, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`), `image-all` (linux/amd64, linux/arm64), with the same args and labels as `apps/bazarr/docker-bake.hcl`. Pass `JUPYTERLAB_VERSION` in `image.args`. Validate with `docker buildx bake --print` from `apps/jupyter/`.

## 6. settings.yaml

- Header and `schema_version: 1` as sibling apps.
- `upstream_env_url: "https://github.com/jupyter/notebook"`
- `ports`: `port: 8888`, `protocol: tcp`, `required: true`
- `env`:
  - `TZ` (default `Etc/UTC`, required false), same as bazarr.
  - `UMASK` (default `002`, required false), same as bazarr.
  - `JUPYTER_TOKEN` (default empty, required false): if empty, notebook generates a token and logs it (see section 10). UNVERIFIED env name for pinned version.
- `volumes`: `/config` (required true).
- `dependencies`: none.

Do not list `JUPYTER_PORT` as a user env var unless start.sh reads it from settings.yaml; keep it as a Dockerfile `ENV`.

## 7. start.sh

Idempotent, no writes to `/app`:
- Set `HOME=/config`, `JUPYTER_CONFIG_DIR=/config/etc/jupyter`, `JUPYTER_DATA_DIR=/config/share/jupyter`, `JUPYTER_RUNTIME_DIR=/tmp/jupyter-runtime`, `IPYTHONDIR=/tmp/ipython`, `XDG_CACHE_HOME=/tmp/cache`.
- `mkdir -p` the `/config` dirs and `/tmp/jupyter-runtime` (no seeding needed; notebook creates its own config on first start).
- Bind all interfaces: `--ServerApp.ip=0.0.0.0 --ServerApp.port=${JUPYTER_PORT:-8888}`.
- Token: pass `--IdentityProvider.token="${JUPYTER_TOKEN}"` only when set (UNVERIFIED flag name for the pinned version). Do not put it in the process list in plain text where avoidable (use env var form if supported).
- `--ServerApp.root_dir=/config` (persistent notebooks), `--no-browser`.
- `exec /app/venv/bin/jupyter lab --no-browser ...` (or `notebook` if the lab UI is not wanted; decide with the user, default `lab`).

## 8. container-test.yaml

- Schema header as `apps/bazarr/container-test.yaml`.
- `http:` probe on port `8888`, path `/api/status` (UNVERIFIED that this endpoint answers without a token on the pinned version; fall back to `/` and check the status code expected by forgetool). `timeoutSeconds` from the python sibling family (choose after reading one python sibling's test file; bazarr uses the default).
- `filePaths`: none needed for the default run. If a token-set code path exists, add it to `filePaths` and run it by hand per the protocol (`container-test.yaml` rule: the test runs with no env vars).
- Every port in settings.yaml has a probe (8888).

## 9. Rootless and read-only-rootfs adaptations

- Upstream: `USER` jovyan (uid 1000), chart `runAsUser 0`, `readOnlyRootFilesystem false`, `extra-persistence /home/jovyan/work` (chart pvc). Port changes these:
  - Runs as `apps` (non-root), `readOnlyRootFilesystem` compatible: writes only to `/config` (notebooks, config, data) and `/tmp` (runtime, cache).
  - Remap upstream `/home/jovyan` to `/config`. The chart's `/home/jovyan/work` mount is not used; users see `/config` instead. Note this for the chart maintainer (section 10).
- `NB_UID`, `NB_GID`, `NB_UMASK`, `PUID`, `fsGroup` from the chart do not apply: ContainerForge uses `UMASK` from settings.yaml and the `apps` user.
- No sudo, no `start-notebook.py` (upstream root-based startup is dropped).
- `privileged`: not needed.

## 10. Risks, caveats and open questions

- **Token**: first-access token must be read from the logs or set via env. Confirm the log line and env name on the pinned version before finalising start.sh.
- **Version drift**: pip packages are unpinned in the draft. This plan pins `notebook` and `jupyterlab`, but transitive dependencies still float at build time. Consider a constraints file if drift is a problem (UNVERIFIED need).
- **Chart mismatch**: the draft notes the chart mounts `/home/jovyan/work`, while this image uses `/config`. The chart must be updated or the mismatch accepted.
- **Upstream image**: the chart uses `quay.io/jupyter/base-notebook:notebook-7.4.7` and optional stack images. This plan does not port the stacks (minimal, scipy, tensorflow, and so on). They are out of scope for this draft (`Rows: 1`).
- **pandoc / fonts**: upstream base installs them. The port does not, so `nbconvert` PDF/HTML export may fail. Decide with the user.
- **Upstream Dockerfile reviewed** is the base-notebook file at a pinned commit, not the image on quay.io. The image digest for `notebook-7.4.7` is UNVERIFIED.
- arm64: the pip path is architecture-neutral, but native wheels in the dependency tree (if any) must have arm64 builds (UNVERIFIED).

## 11. Build and test steps

From `apps/jupyter/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe run with an empty config volume:
   ```
   docker run --rm -d --name jupyter-probe --read-only --tmpfs /tmp \
     -v jupyter-probe-config:/config jupyter:7.6.5
   docker logs -f jupyter-probe
   ```
   Expected readiness signal: a line such as `Jupyter Server ... is running at` with `http://0.0.0.0:8888/` (UNVERIFIED exact wording for the pinned version; confirm from the first run's log).
4. `forgetool containers test --image jupyter:7.6.5 --config ./apps/jupyter/container-test.yaml`
5. Cleanup: `docker rm -f jupyter-probe; docker volume rm jupyter-probe-config`.
6. Optional: arm64 build only if amd64 fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-jupyter`, commit `feat(jupyter): add new container`, PR title the same.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes; tick only what applies.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Say what was not tested: any step not run locally (for example arm64, or the chart update) must be named in the PR.
- Downstream: none (not a `FROM` base).
