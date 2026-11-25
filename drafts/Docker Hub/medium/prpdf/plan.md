# prpdf — implementation plan
> Source: ./draft.md · Target: apps/prpdf/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest release tag `1.0.2` (published 2026-09-09), https://api.github.com/repos/maschhoff/prpdf/releases/latest. No release assets. Source is `maschhoff/pdfscanexplorer` (draft also lists `maschhoff/prpdf`). Pin the tag `1.0.2` as VERSION, or a commit SHA if the source differs. |
| Renovate | UNVERIFIED: no release assets. Use `datasource=github-tags depName=maschhoff/pdfscanexplorer versioning=loose` if tags are used. Check at build time. |
| License | MIT (GitHub SPDX, https://api.github.com/repos/maschhoff/prpdf). Same MIT for `pdfscanexplorer` (https://api.github.com/repos/maschhoff/pdfscanexplorer). |
| Source URL | https://github.com/maschhoff/pdfscanexplorer (application source), https://github.com/maschhoff/prpdf (draft's Dockerfile source). |
| Download | Source archive `https://github.com/maschhoff/pdfscanexplorer/archive/refs/tags/1.0.2.tar.gz` (URL form standard for GitHub tags; UNVERIFIED that it resolves). No prebuilt binary. |
| Checksum source | None published. Tag pinning only. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/maschhoff/prpdf/main/Dockerfile (draft pins commit `132fcad`, not checked). Two stages, both `python:3.11-slim-bookworm`. Builder: builds `jbig2enc` from git with no pin to `/usr/local/bin/jbig2enc`; builds Ghostscript 10.03.1 from an ArtifexSoftware GitHub release tarball and runs `make install`. Final stage: `WORKDIR /source`, `ENV WORKDIR=/source FLASK_APP=prpdf.py FLASK_RUN_HOST=0.0.0.0 FLASK_RUN_PORT=80`, apt installs tesseract-ocr with German data, poppler-utils, qpdf and image libs, copies `jbig2enc` and `gs`, `pip install -r requirements.txt`, `CMD ["flask", "run"]`. No EXPOSE, VOLUME, USER or ENTRYPOINT. |
| Python requirements | https://raw.githubusercontent.com/maschhoff/pdfscanexplorer/main/requirements.txt (read from main, the draft's link is the same owner's repo). All unpinned: flask, Pillow, pytesseract, pdf2image, PyPDF2, ocrmypdf, pycryptodome, openai, google-generativeai, anthropic. `pdfsplit==0.4.2` is commented out. |
| Port | Upstream `FLASK_RUN_PORT=80`. The draft's `5000` is an inference and is not what upstream sets. Port 80 is privileged, so see section 9. |
| Data/write paths | Upstream's own paths under `/source` (static PDF output and archive folders). The app's exact write locations are UNVERIFIED: the app source (`prpdf.py`, static paths) was not read. The chart's `/Archiv` and `/source/static/pdf` mounts suggest these paths. |
| Docker Hub | `knex666/prpdf:latest` is a third-party build. amd64 only, last pushed 2026-09-06 (https://hub.docker.com/v2/repositories/knex666/prpdf/tags). arm64 not published, so `copy-from arm64` is `no`. Not used as a source. |
| Dependencies | None as a container. Local apt packages only (tesseract, poppler, qpdf, ghostscript, jbig2enc). |

## 2. Target layout

- `apps/prpdf/Dockerfile`
- `apps/prpdf/docker-bake.hcl`
- `apps/prpdf/settings.yaml`
- `apps/prpdf/container-test.yaml`
- `apps/prpdf/start.sh` (runs flask on the app with the port and paths from env)
- `apps/prpdf/defaults/` only if a pinned `constraints.txt` is needed (see section 4 step 6). Reason: the allow-list in `include/.dockerignore` only copies `defaults/`, not a loose file.

Do not use `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Matches the draft's runtime choice, and the base provides `/app/venv` and pip.
- The upstream `python:3.11` image is replaced by the ContainerForge python base. The python base version (3.15.2) differs from upstream 3.11: this is an intended change; tests must confirm the app runs on it (flagged in section 10).
- Alternative: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` if python base proves wrong.
- Closest siblings: `apps/bazarr` (python on `/app` with `start.sh`), `apps/python` (base definition).

## 4. Dockerfile

1. `ARG VERSION=1.0.2` (matches `docker-bake.hcl`), `ARG PIP_...` only if pinned constraints are used.
2. `USER root` for apt installs only.
3. `apt-get install -y --no-install-recommends tesseract-ocr tesseract-ocr-deu poppler-utils qpdf ghostscript jbig2enc`, then `rm -rf /var/lib/apt/lists/*`. Replaces the upstream builder stage (no source compile). Versions: ghostscript and jbig2enc from apt will differ from upstream 10.03.1 and the git HEAD jbig2enc; pin the apt versions where apt provides them and check against the output (see section 10).
4. Download the source: `curl -fL https://github.com/maschhoff/pdfscanexplorer/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`. Verify the tag's commit SHA is recorded in the bake file.
5. Install Python deps into `/app/venv` at build time (not at runtime): `/app/venv/bin/pip install -r /tmp/src/requirements.txt`. Pip cache is `/tmp` (base sets `PIP_NO_CACHE_DIR=1`). Python-runtime rule: `/app/venv` read-only at runtime, no runtime writes.
6. Pin Python versions. The requirements file is unpinned. Either pin exact versions in a `constraints.txt` under `defaults/` and pass `-c`, or keep unpinned and record the resolved list in the PR. Preferred: constraints file (renovate can bump it). Decision in section 10.
7. `mkdir -p /app/prpdf`, copy the source to `/app/prpdf/` (`prpdf.py`, templates, static). Write only at build time.
8. `chown -R apps:apps /app/prpdf` is NOT needed; the directory is read-only at runtime. Verify `apps` can read it.
9. Add the upstream MIT `LICENSE` to `/usr/share/licenses/prpdf/`.
10. `ENV FLASK_APP=prpdf.py FLASK_RUN_HOST=0.0.0.0 FLASK_RUN_PORT=5000` (see section 9 for port). `ENV WORKDIR=/app/prpdf`.
11. `USER apps`, `COPY --chmod=0755 . /`, `COPY --chmod=0755 start.sh /start.sh`.
12. `EXPOSE` the port from settings.yaml only after the port is confirmed.

## 5. docker-bake.hcl

- `variable "APP" { default = "prpdf" }`
- `variable "VERSION"` with `// renovate: datasource=github-tags depName=maschhoff/pdfscanexplorer versioning=loose` (UNVERIFIED datasource choice, confirm at build time) and default `1.0.2`.
- `variable "LICENSE" { default = "MIT" }`
- `variable "SOURCE" { default = "https://github.com/maschhoff/pdfscanexplorer" }`
- Standard targets: `docker-metadata-action`, `image` (args `VERSION`, OCI labels), `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), default group `image-local`.
- Validate: `cd apps/prpdf && docker buildx bake --print`.

## 6. settings.yaml

- Header: schema line and `schema_version: 1`, as in `apps/bazarr/settings.yaml`.
- `upstream_env_url: "https://github.com/maschhoff/pdfscanexplorer"`
- `ports`: `5000/tcp` (`required: false`) once the port decision in section 9 is final. Upstream default is 80 (not verified as used by the app beyond `FLASK_RUN_PORT`).
- `env`:
  - `TZ`, default `Etc/UTC`, `required: false`.
  - `UMASK`, default `002`, `required: false`.
  - `FLASK_RUN_PORT`, default `5000`, `required: false` (matches the port above).
  - Any app-specific env var (for example an OCR language or AI API key): UNVERIFIED, not read from the app source. The requirements include `openai`, `google-generativeai` and `anthropic`, so API key env vars are likely but unconfirmed. Do not add them until read from source.
- `volumes`: `/config` (required: true) if the app keeps its config there; paths for uploaded/output PDFs must map to `/config` (decision in section 9).
- `dependencies`: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -eu`.
- Create `/config/<dirs>` for the app's output (`/config/Archiv`, `/config/pdf` or similar, UNVERIFIED names) only when missing. Never overwrite existing files.
- Export the upstream env vars (`WORKDIR`, `FLASK_APP`, `FLASK_RUN_HOST`, `FLASK_RUN_PORT`) from the settings defaults.
- Scratch and caches in `/tmp`.
- Final line: `exec /app/venv/bin/flask run --host=0.0.0.0 --port="${FLASK_RUN_PORT}"` from the app folder, so signals reach flask.
- Do not write to `/app/prpdf`.

## 8. container-test.yaml

- Header: forgetool schema line, as in `apps/bazarr/container-test.yaml`.
- `http` probe on `/` for the declared port (the app's root page is UNVERIFIED; use the nearest path the app serves, for example the index page), with `timeoutSeconds` from the python sibling (`apps/bazarr`).
- `filePaths`: `/app/prpdf/prpdf.py`, `/app/venv/bin/flask`, `/usr/bin/gs` or the ghostscript binary path (verify), `/usr/bin/tesseract`, `/usr/bin/jbig2`/`jbig2enc` path (verify).
- Test runs without env vars. The app must start with defaults. Required-env code paths go to filePaths.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (no USER). Port 80 is privileged and cannot be bound as `apps`. Set `FLASK_RUN_PORT=5000` (non-privileged) and document the change. This is a deliberate deviation from upstream.
- Upstream writes to `/source/...` (static PDF output, archive). Under ContainerForge, `/app` is read-only, so output must go to `/config` (for example `/config/Archiv`, `/config/static/pdf`) through an app setting or a symlink in `start.sh` if the app has no setting. Symlinks from `/app` to `/config` are not allowed in the `/config/venv` rule, but output symlinks are not venv; decide after reading `prpdf.py` (UNVERIFIED).
- Hostpath mount `hostpath2` at `/source/static/pdf` in the chart: the container path must map to `/config/...` in our layout. Host ownership and permission constraints apply (chart side, not our image).
- `/tmp` for flask temp and OCR scratch (tesseract, ghostscript temp files).

## 10. Risks, caveats and open questions

- **Ghostscript and jbig2enc versions.** Upstream builds Ghostscript 10.03.1 and jbig2enc from git HEAD. apt versions on ubuntu 26.04 will differ. Output must be compared with upstream before the PR is opened. Pin apt versions and state the versions in the PR.
- **Python base version change.** Upstream runs Python 3.11, ContainerForge base is 3.15.2. Check that every pip package (including `ocrmypdf`, `pdf2image`) installs and runs on 3.15.
- **Unpinned requirements.** The requirements file pins nothing. Decide: constraints file under `defaults/` (preferred), or resolved list in PR.
- **Port.** Upstream 80, draft 5000 (inferred). We use 5000 for rootless. Confirm the app serves on `FLASK_RUN_PORT`.
- **Write paths.** The app's write locations are UNVERIFIED (app source not read). Read `prpdf.py` before writing start.sh.
- **Third-party image.** `knex666/prpdf` is not the upstream project. We build from source, not from that image.
- **AI API keys.** `openai`, `google-generativeai`, `anthropic` in requirements suggest API keys are read from env. UNVERIFIED. Do not invent env vars.
- **Hostpath permissions.** The chart's hostPath mount may fail on host ownership, a chart concern.
- **arm64.** Source requirements are pure Python plus apt packages, so arm64 is expected to work. Untested.

No hard blockers found. Port and write-path decisions must be made before the bake and tests are written.

## 11. Build and test steps

Per `.github/instructions/build-test-protocol.instructions.md`, `<app>` = prpdf:

1. `cd apps/prpdf && docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name prpdf-probe --read-only --tmpfs /tmp -v prpdf-probe-config:/config prpdf:<version>`, then `docker logs -f prpdf-probe`. Expected readiness signal: flask's `Running on http://0.0.0.0:5000` line (standard flask output). Cleanup: `docker rm -f prpdf-probe; docker volume rm prpdf-probe-config`.
4. `forgetool containers test --image prpdf:<version> --config ./apps/prpdf/container-test.yaml`. If forgetool is unavailable, check by hand.
5. arm64 only after amd64 is green, or if the failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-prpdf`, commit `feat(prpdf): add new container`, PR title the same, target `main`.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept, only applicable boxes checked.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. Tell the user.
- State the Ghostscript/jbig2enc version differences from upstream, the port change (80 to 5000), and whether output matches upstream.
- Report what was not tested (arm64, OCR quality, AI features) and the build and test results honestly.
