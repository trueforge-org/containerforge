# jupyter — implementation plan
> Source: ./draft.md · Target: apps/jupyter/ (or one app per row, see section 2) · Difficulty: hard · Role: sidecar (7 rows, chart `allsparkImage`, `datascienceImage`, `minimalImage`, `pysparkImage`, `rImage`, `scipyImage`, `tensorflowImage`) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins `notebook-7.4.7` on all seven rows. **Tag not confirmed**: the Quay tag listing for `jupyter/minimal-notebook` showed `notebook-7.6.3`, `7.6.4`, `7.6.5` and no `7.4.7` in the first 100 tags. UNVERIFIED that `notebook-7.4.7` exists. Latest seen: `notebook-7.6.5`. Source: https://quay.io/api/v1/repository/jupyter/minimal-notebook/tag/ |
| Renovate | `datasource=docker depName=quay.io/jupyter/minimal-notebook versioning=loose` per row (tag form `notebook-X.Y.Z`) |
| License | BSD-3-Clause (GitHub SPDX, https://api.github.com/repos/jupyter/docker-stacks) |
| Source URL | https://github.com/jupyter/docker-stacks |
| Releases | No GitHub releases (`releases/latest` returns 404). Version is the image tag only. |
| Download | No standalone binary. The app is a conda/micromamba environment built by the upstream Dockerfiles. `pip:notebook` is the Python package, not a binary. |
| Checksum source | Image digest only. Micromamba base is pinned by digest in upstream: `mambaorg/micromamba:2.10.0@sha256:e1476182cd40eb1f7c0cfae4adec9bfd78f3d7f05c61368306abfdc8939c1198` |
| Upstream chain (confirmed) | `docker-stacks-foundation` (FROM micromamba, `ARG NB_USER=jovyan`, `NB_UID=1000`, `NB_GID=100`, `ENV CONDA_DIR=/opt/conda`, apt `tini`, `ENTRYPOINT ["tini","-g","--","start.sh"]`, python and mamba via micromamba) → `base-notebook` (`ENV JUPYTER_PORT=8888`, texlive-xetex, texlive-fonts-recommended, texlive-plain-generic) → `minimal-notebook` (apt: curl, git, nano-tiny, tzdata, unzip, vim-tiny, openssh-client, less, xclip) → `scipy-notebook`, `datascience-notebook`, `pyspark-notebook`, `r-notebook`, `tensorflow-notebook`, `all-spark-notebook`. Sources: raw.githubusercontent.com `jupyter/docker-stacks` `images/*/Dockerfile` on `main`. |
| Per-row Dockerfiles | The draft pins different commits per row. Only `main` was read for `minimal-notebook`, `base-notebook`, `docker-stacks-foundation`. Scipy, datascience, pyspark, r, tensorflow, all-spark Dockerfiles: UNVERIFIED (not fetched). |
| Ports | 8888/tcp (`JUPYTER_PORT=8888`, confirmed). 4040 (Spark UI, pyspark row): UNVERIFIED. |
| Env vars (confirmed) | `NB_USER`, `NB_UID`, `NB_GID`, `CONDA_DIR`, `JUPYTER_PORT`. Other env names (token/password, `NB_UMASK`, `GRANT_SUDO`, `CHOWN_*`) are UNVERIFIED on this run. |
| arm64 | Upstream publishes multi-arch images (UNVERIFIED: the release workflow was not read). Draft says yes. |
| Dependencies | None (draft: none). |

## 2. Target layout

Seven rows, one per image. The protocol says one app per `apps/<app>/`, so the plan recommends **seven apps** (`jupyter-all-spark`, `jupyter-datascience`, `jupyter-minimal`, `jupyter-pyspark`, `jupyter-r`, `jupyter-scipy`, `jupyter-tensorflow`) rather than one. Decide with the user before work starts. For each app:

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- `defaults/` only if a default config is needed (e.g. `jupyter_server_config.py` seeded into `/config`)

`DOWNSTREAM_CHANGES.md` is not needed unless an app is used as a `FROM` base. `minimal-notebook` is the natural base for the others in this plan; if so, document it.

## 3. Base image

- **Ubuntu base** (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`) is the default. Build the chain on it or copy from upstream (`COPY --from=quay.io/jupyter/minimal-notebook:notebook-X.Y.Z`).
- **Option A (recommended for a first app, `jupyter-minimal`):** `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` and install the Notebook package with pip into `/tmp`-safe paths. Simpler than conda and matches the protocol's Python rules (`/app/venv` read-only). The draft's "python base" matches this option.
- **Option B:** Copy the conda prefix from upstream with `COPY --from`. Heavier, and the copy-from images are the full upstream images with conda inside.
- Closest siblings: `apps/bazarr` and `apps/changedetection` (python base); `apps/python-node` (for any Node kernel).

## 4. Dockerfile

Written for option A (`jupyter-minimal`), extended per row.

1. `ARG VERSION`, `ARG TARGETARCH`. Bake default `notebook-X.Y.Z` (confirmed existing tag, see section 1).
2. `USER root`. `apt-get install --no-install-recommends curl git nano-tiny tzdata unzip vim-tiny openssh-client less xclip`. Skip anything already in the python base (check with `dpkg -l`). `rm -rf /var/lib/apt/lists/*`.
3. Python packages: `pip install --no-cache-dir notebook==<pinned>` with versions pinned to the upstream tag's `pip` set. Set `PIP_CACHE_DIR=/tmp/pip`.
4. Rows with extras:
   - `scipy`: numpy, pandas, matplotlib, scipy (pins UNVERIFIED).
   - `datascience`: adds Julia and R kernels (UNVERIFIED install method).
   - `pyspark`: Apache Spark tarball and Java 17+ (`java17` base `ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`). Spark download URL and checksum UNVERIFIED.
   - `r`: R with IRkernel (UNVERIFIED).
   - `tensorflow`: `pip install tensorflow` (large wheel, CPU only, GPU out of scope).
   - `all-spark`: pyspark plus Scala/Toree (UNVERIFIED).
5. Home dir: `ENV HOME=/config`. Jupyter's default `/home/jovyan` is not writable under read-only rootfs and is not the chart mount. Point `JUPYTER_CONFIG_DIR` and `JUPYTER_DATA_DIR` to `/config`, runtime and cache to `/tmp`.
6. `ENV JUPYTER_PORT=8888` (confirmed upstream name).
7. Licence: copy BSD-3-Clause text to `/usr/share/licenses/jupyter/LICENSE` (upstream `LICENSE` file, to be copied from the repo).
8. `COPY --chmod=0755 . /`, `EXPOSE 8888`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

- `APP = "jupyter-minimal"` (one per row), `VERSION = "notebook-X.Y.Z"` with `// renovate: datasource=docker depName=quay.io/jupyter/minimal-notebook versioning=loose`.
- `LICENSE = "BSD-3-Clause"`, `SOURCE = "https://github.com/jupyter/docker-stacks"`.
- Standard targets and default group from `apps/adguardhome-sync/docker-bake.hcl`.
- Validate: `docker buildx bake --print` in the app folder.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jupyter/docker-stacks"
ports:
  - port: 8888
    protocol: tcp
    required: true
env:
  - name: JUPYTER_PORT
    default: "8888"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- No `dependencies:` (none).
- Add `NB_UID`, `NB_GID` (default 1000/100) only if `start.sh` reads them. Do not list the chart's `PUID`/`fsGroup`.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Seed `/config` only when missing: create `/config/.jupyter` and copy a default `jupyter_server_config.py` from `/defaults` if absent.
- Export `JUPYTER_CONFIG_DIR=/config/.jupyter`, `JUPYTER_DATA_DIR=/config/.local/share/jupyter`, `JUPYTER_RUNTIME_DIR=/tmp/jupyter-runtime`, `HOME=/config`.
- Server: `exec jupyter lab --ip=0.0.0.0 --port="${JUPYTER_PORT:-8888}" --no-browser --ServerApp.root_dir=/config` (exact flags UNVERIFIED against the pinned version).
- Token: the server token must be retrieved on first access. Do not bake a token. Either set `IdentityProvider.token` from an env var or leave it to Jupyter's default and document the log line. This is the draft's manual-setup caveat; decide before writing `start.sh`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8888'
```

- `timeoutSeconds`: copy from `apps/bazarr` or `apps/changedetection` (python family). Larger rows (tensorflow, pyspark) may need more; UNVERIFIED value.
- Protocol: no DB dependency, so the narrowed exception does not apply. Add an `http` probe for `/api` if the server exposes it without a token (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes to `/home/jovyan` (work dir, `.jupyter`, `.local`, `.cache`). Redirect to `/config` (persistent) and `/tmp` (cache, runtime). Nothing in `/app`.
- Upstream UID 1000 (`jovyan`); ContainerForge `apps` user. Confirm UID in base; note the difference.
- Chart sets `runAsUser 0`, `readOnlyRootFilesystem false`. Target: `USER apps`, read-only rootfs true.
- Chart adds `/home/jovyan/work` as a PVC. Map to `/config/work` and note the path change in the plan's PR.
- `privileged`: false.

## 10. Risks, caveats and open questions

- **Tag `notebook-7.4.7` is not confirmed.** Ask the user whether to pin `notebook-7.6.5` (latest seen) or find 7.4.7 first.
- **Seven large images.** TensorFlow and Spark rows are multi-gigabyte. Build time and storage are high. The `all-spark` row layers Spark, R and Toree: very heavy.
- **Base mismatch.** Upstream images are built on micromamba, not ContainerForge ubuntu. The plan does not inherit upstream's conda stack unless option B is chosen.
- **Spark and Java** (pyspark, all-spark): the Spark tarball and Java version are UNVERIFIED. Spark download at build time needs a checksum from the Apache site (UNVERIFIED).
- **GPU** (tensorflow): out of scope. CPU build only.
- **Token/password** on first access: manual setup (draft caveat, confirmed in draft). Design needed in `start.sh`.
- arm64: upstream claims multi-arch (UNVERIFIED); TensorFlow arm64 wheels UNVERIFIED.
- Blockers: none confirmed. The decision on splitting into seven apps and the tag question are the real blockers.

## 11. Build and test steps

From `apps/jupyter-minimal/` (repeat per row):

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run and log check (empty `/config`, read-only):
   ```sh
   docker run --rm -d --name jupyter-probe --read-only --tmpfs /tmp \
     -v jupyter-probe-config:/config jupyter-minimal:notebook-X.Y.Z
   docker logs -f jupyter-probe
   ```
   Expected readiness signal: the Jupyter Server "is running at" / "Jupyter Server ... is running" line (UNVERIFIED for the pinned version). Check the token line is printed once.
   Clean up: `docker rm -f jupyter-probe; docker volume rm jupyter-probe-config`.
4. `forgetool containers test --image jupyter-minimal:notebook-X.Y.Z --config ./apps/jupyter-minimal/container-test.yaml`
5. Repeat steps 1 to 4 per row, one at a time.

## 12. PR checklist

- Branch: `feat/add-jupyter` (or `feat/add-jupyter-<row>` if split)
- Commit: `feat(jupyter): add new container` (or `feat(jupyter-<row>): add new container`)
- PR title: matches the commit.
- PR body: `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say what was not tested: the six rows not built, arm64, Spark and GPU paths, and the `notebook-7.4.7` tag if it does not exist.
- Do not check "Built container locally" unless the build was run.
