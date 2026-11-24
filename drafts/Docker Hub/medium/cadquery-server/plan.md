# cadquery-server — implementation plan
> Source: ./draft.md · Target: apps/cadquery-server/ · Difficulty: medium (arm64 risky) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.4.1` (PyPI, 2022-09-23; also git tag `0.4.1`). Draft tracked Docker Hub `:latest`; plan pins `0.4.1` |
| Renovate | `datasource=pypi`, `depName=cadquery-server` |
| License | MIT (PyPI metadata and GitHub) |
| Source | https://github.com/roipoussiere/cadquery-server (archived 2023-07-21; README says it moved to Codeberg and is no longer supported) |
| Install | `pip install "cadquery-server[cadquery]==0.4.1"`; extra `cadquery` pulls `cadquery==2.2.0b0` and `casadi` |
| Python | `requires_python >=3.8,<3.11`. The ContainerForge python base is 3.15.2, so it CANNOT run this stack. Python 3.10 is required |
| Checksum | PyPI hashes; use `pip install --require-hashes` only if a lock file is generated (not provided upstream) |
| Upstream Dockerfile | Reviewed: `python:3.10`, apt `libgl1 libgl1-mesa-glx`, pip install with `cadquery` extra, `VOLUME data`, `WORKDIR data` (= `/data`), `ENTRYPOINT ["cq-server"]` (subcommand `run`, default target `.`) |
| Port | 5000 (`DEFAULT_PORT` in `cq_server/cli.py`, flag `-p/--port`). The server runs `app.run(host='0.0.0.0', port=port)` so it binds all interfaces |
| Env vars | None read by the app itself |
| Wheels | `cadquery-ocp` cp310 manylinux wheels exist for x86_64 for 7.5 to 7.8; aarch64 cp310 wheels only exist from 7.9.3.0. `cadquery 2.2.0b0` (Python >=3.8,<3.11) declares `cadquery-ocp` without a version cap |

## 2. Target layout

```
apps/cadquery-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/example.py      # tiny CadQuery script seeded into an empty /config/scripts
```
`defaults/` is needed because the server needs at least one script in its target folder (empty-start behaviour UNVERIFIED) and is in the `.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (python base, matching the draft and the python rules), used as both build stage and final stage. The base's `/app/venv` (Python 3.15) is NOT used: a separate Python 3.10 is installed with `uv` into `/usr/local` and a dedicated venv at `/app/cq-venv`. Closest sibling: `apps/bazarr` (python base, uv install, apt libs).

## 4. Dockerfile

1. `FROM <python base>`, `ARG VERSION`, `USER root`.
2. `ENV HOME=/config UV_CACHE_DIR=/tmp/uv PIP_CACHE_DIR=/tmp/pip MPLCONFIGDIR=/tmp/matplotlib UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python`.
3. apt (not in base): `libgl1` (the upstream `libgl1-mesa-glx` is obsolete on 26.04; UNVERIFIED which extra X/GL libs the OCP wheel needs, candidates `libglu1-mesa libxrender1 libxext6 libsm6`). Not the app package, so no version pin (add `# hadolint ignore=DL3008`). `rm -rf /var/lib/apt/lists/*`.
4. `pip install uv` (as `apps/bazarr` does), `uv python install 3.10`, `uv venv --python 3.10 /app/cq-venv`.
5. `uv pip install --python /app/cq-venv/bin/python "cadquery-server[cadquery]==${VERSION}"`. If the resolver cannot satisfy it on arm64, add an explicit `cadquery-ocp` pin that has cp310 aarch64 wheels (7.9.3.x); API compatibility with cadquery 2.2.0b0 is UNVERIFIED.
6. Remove `uv` afterwards (`pip uninstall --yes uv`), `rm -rf /tmp/* /root/.cache`, `chown -R root:root /app/cq-venv && chmod -R 755 /app/cq-venv`.
7. License: copy `LICENSE` of the package (from `/app/cq-venv/lib/python3.10/site-packages/cadquery_server-*.dist-info/` if shipped, else download from the git tag) to `/usr/share/licenses/cadquery-server/`; third-party notices of cadquery/OCP also live in their `dist-info` (UNVERIFIED).
8. `ENV PATH=/app/cq-venv/bin:$PATH`, `EXPOSE 5000`, `VOLUME /config`.
9. `COPY --chmod=0755 . /`.
10. Final line `USER apps`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "cadquery-server"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=cadquery-server
  default = "0.4.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/roipoussiere/cadquery-server"
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
Validate with `docker buildx bake --print` from `apps/cadquery-server/`. Dockerfile `ARG VERSION` must receive exactly this value (no extra defaults).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/roipoussiere/cadquery-server"
ports:
  - port: 5000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
No app-specific env vars exist upstream, so none are invented. No `dependencies:`.

## 7. start.sh

1. `mkdir -p /config/scripts`; if the directory has no `*.py` file, `cp -n /defaults/example.py /config/scripts/` (never overwrite user scripts).
2. `export MPLCONFIGDIR=/tmp/matplotlib PYTHONDONTWRITEBYTECODE=1` (`__pycache__` must not be written next to scripts or `/app`).
3. `cd /config/scripts`.
4. `exec /app/cq-venv/bin/cq-server run -p 5000 /config/scripts` (binds 0.0.0.0 already). Do not pass `-r`; live reload stays on (`--dead` optional, off by default).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5000'
http:
- port: '5000'
  path: /
filePaths:
- /app/cq-venv/bin/cq-server
- /usr/share/licenses/cadquery-server
```
Probe for the only port, 5000. UNVERIFIED that `/` returns 200 with the seeded example script; if the index needs a script query string, use the `tcp` check plus a healthCommand `/app/cq-venv/bin/cq-server info /config/scripts`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| Scripts in `/data` (upstream `VOLUME data`) | `/config/scripts` (persistent) |
| `__pycache__` beside scripts / site-packages | `PYTHONDONTWRITEBYTECODE=1` |
| matplotlib font/config cache (`~/.config`, `~/.cache`) | `MPLCONFIGDIR=/tmp/matplotlib`, `HOME=/config` only for stray dotfiles |
| pip/uv caches | `/tmp` |
| venv | `/app/cq-venv` is read-only at runtime (python-runtime rule: never mutate venvs at runtime) |

Draft expectations (root, writable rootfs, no extra persistence) are replaced with UID 568, read-only rootfs, `/config` for scripts. Not privileged.

## 10. Risks, caveats and open questions

- BLOCKER-ish: `cadquery-server` requires Python <3.11 (3.10 reaches end of life in October 2026), so the image ships a standalone Python 3.10 beside the base's 3.15. Alternative is to skip this container.
- Upstream is archived and unmaintained (moved to Codeberg); renovate will never bump it. The unpinned transitive dependencies (Flask <3, jupyter-cadquery 3.x, numpy) may drift and break builds.
- arm64: `cadquery-ocp` cp310 wheels are x86_64 only up to 7.8; aarch64 starts at 7.9.3.0. Whether cadquery 2.2.0b0 works with OCP 7.9 is UNVERIFIED. Ship amd64 first; if arm64 fails, report instead of weakening tests.
- Large image and slow first build (OCP wheel is hundreds of MB).
- `cq-server` has no authentication and executes Python scripts in its target folder: anyone who can reach port 5000 or write to `/config/scripts` runs code.

## 11. Build and test steps

Run per `build-test-protocol.instructions.md`, one app only, max 10 rounds:

```sh
cd apps/cadquery-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create cadquery-server-probe-config
docker run --rm -d --name cadquery-server-probe --read-only --tmpfs /tmp \
  -v cadquery-server-probe-config:/config cadquery-server:<VERSION>
docker logs -f cadquery-server-probe        # expect: Flask `Running on http://0.0.0.0:5000` (or the port open via `ss -ltn`)
docker rm -f cadquery-server-probe; docker volume rm cadquery-server-probe-config
forgetool containers test --image cadquery-server:<VERSION> --config ./apps/cadquery-server/container-test.yaml
```

Always start from an empty `/config` volume and check that the container is still running, with no fatal errors or repeated stack traces. Attempt arm64 only if the amd64 loop is green or the failure is arm64-specific.

## 12. PR checklist

- [ ] Branch `feat/add-cadquery-server` from fresh `main`; one app per PR.
- [ ] Commit and PR title: `feat(cadquery-server): add new container` (Conventional Commits, target `main`).
- [ ] PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections, and only checks boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.` (no "Generated with ..." line).
- [ ] `docker buildx bake --print` exits 0; `VERSION` in `docker-bake.hcl` matches the Dockerfile `ARG VERSION`.
- [ ] Runtime is rootless (`USER apps`) and works with `--read-only --tmpfs /tmp` and an empty `/config`.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it; never sign for them.
- [ ] Untested items stated honestly in the PR: arm64 build, OCP/cadquery compatibility with the chosen OCP version, the exact apt GL libraries, and rendering of a real model in a browser.
