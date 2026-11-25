# timetagger — implementation plan
> Source: ./draft.md · Target: apps/timetagger/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `26.1.3`. Latest GitHub release `v26.1.3` (published 2026-02-02T12:22:59Z, `gh api repos/almarklein/timetagger/releases/latest`). PyPI `info.version` is `26.1.3` (https://pypi.org/pypi/timetagger/json). Draft container tag `v26.1.3-nonroot` matches. |
| Renovate | `// renovate: datasource=pypi depName=timetagger versioning=pep440` (PyPI is the install source; the `VERSION` default is `26.1.3`). |
| License | GPL-3.0 (GitHub API `repos/almarklein/timetagger/license`, `spdx_id` GPL-3.0; PyPI `license` field `GPL-3.0`). |
| Source URL | https://github.com/almarklein/timetagger |
| Download | `pip install timetagger==${VERSION}` from PyPI (pure Python, no native build). |
| Checksum source | PyPI file hashes for the `timetagger-26.1.3` wheel/sdist (hash values UNVERIFIED: not fetched). pip verifies hashes when `--require-hashes` is used; plan uses that. |
| Upstream Dockerfile reviewed | `deploy/repo.nonroot.Dockerfile` @ `681720d84c94be660f30947db4b23e52d36cbe32` (2026-02-02): https://raw.githubusercontent.com/almarklein/timetagger/681720d84c94be660f30947db4b23e52d36cbe32/deploy/repo.nonroot.Dockerfile. Base `python:3.13-slim-bookworm`; `groupadd -g 1000 timetagger` and `useradd -r -u 1000 -m -g timetagger timetagger`; `mkdir /opt/timetagger`; `USER 1000`; `WORKDIR /opt/timetagger`; `COPY . /opt/timetagger`; `pip install --no-cache-dir install pip --upgrade`; `pip install uvicorn uvloop httptools`; `pip install --no-cache-dir --no-warn-script-location -e .`; `CMD ["python", "-m", "timetagger"]`. No `ENV`, `ARG`, `VOLUME`, `EXPOSE`, `ENTRYPOINT`. |
| Port | UNVERIFIED: the upstream image has no `EXPOSE`. The draft's `8080` is inferred; the chart's port must be confirmed (README or the server's default bind, not fetched). |
| Env vars (real) | UNVERIFIED: the upstream nonroot Dockerfile sets none. The timetagger server's own configuration variables are not confirmed (README not fetched in this run). |
| Data path | Upstream nonroot image: app at `/opt/timetagger`. Chart stores data at `/opt/_timetagger` (chart key `config`, draft). Plan keeps data in `/config` (draft). The server's data-dir variable is UNVERIFIED. |
| arm64 | Yes: pure Python package; the base `python` image provides the interpreter for both arches. |
| Dependencies | None. Extras installed upstream: `uvicorn`, `uvloop`, `httptools` (ASGI server, unpinned upstream). |
| Python version | Upstream `python:3.13-slim-bookworm`. `requires_python >=3.6.0` (PyPI). The ContainerForge `python` base is 3.15.2; compatibility with 3.15 is UNVERIFIED and must be tested in the build. |

## 2. Target layout

- `apps/timetagger/Dockerfile`
- `apps/timetagger/docker-bake.hcl`
- `apps/timetagger/settings.yaml`
- `apps/timetagger/container-test.yaml`
- `apps/timetagger/start.sh`

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (current python base, brief; same FROM as `apps/babybuddy/Dockerfile` and `apps/apprise-api/Dockerfile`).

Why: the python base already ships `/app/venv` (read-only at runtime per the python-runtime rule) and the `apps` user. Closest siblings: `apps/bazarr` (python with `start.sh`), `apps/babybuddy` and `apps/apprise-api` (python FROM).

## 4. Dockerfile

1. `ARG VERSION` (default `26.1.3`, same as bake). No other ARG needed.
2. `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d...`.
3. `USER root` (for the venv install step only).
4. Install the app into `/app/venv`, which is read-only at runtime. Use a venv install via the base's `VENV_FOLDER=/app/venv` (set by the base) or an explicit `/app/venv/bin/pip`:
   ```dockerfile
   RUN set -eux; \
       /app/venv/bin/python -m pip install --no-cache-dir --no-compile \
         "timetagger==${VERSION}" \
         "uvicorn" "uvloop" "httptools"
   ```
   Pin the extras too: `uvicorn`, `uvloop`, `httptools` are unpinned upstream; the plan pins them only after checking the versions in the first build (UNVERIFIED versions; do not invent numbers). Pip cache goes to `/tmp` (`PIP_NO_CACHE_DIR=1` is already set by the base).
5. License: `timetagger` installs its own `LICENSE` in site-packages `dist-info`; copy it to `/usr/share/licenses/timetagger/LICENSE` in the same step (`find /app/venv -name 'LICENSE*' -path '*timetagger*'`). UNVERIFIED file path until built.
6. `chown -R apps:apps /app && chmod -R 755 /app`.
7. `USER apps`, then `COPY --chmod=0755 . /`.
8. `EXPOSE 8080` only after the port is verified (section 1).
9. `VOLUME /config`.

Do not copy the upstream `COPY . /opt/timetagger` source tree: the PyPI package is used instead (the draft says "installed with pip from the repo copy into /app"; the PyPI route avoids the `-e .` editable install and keeps `/app` read-only). If the repo copy is kept for any reason, put it under `/app` read-only and reference it there, never under `/config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "timetagger"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=timetagger versioning=pep440
  default = "26.1.3"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/almarklein/timetagger"
}
```

Then `image`, `image-local` (`${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`) and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/almarklein/timetagger"
ports:
  - port: 8080          # UNVERIFIED: confirm the server's listen port before keeping this
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only `TZ` is listed; the timetagger configuration variables are UNVERIFIED and must not be invented. Credentials for the web UI are configured by the server (draft: manual setup; how is UNVERIFIED), so no credential env var is listed until confirmed. The port must match `container-test.yaml` (section 8).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Data goes to /config (persistent); the app package stays read-only in /app
export HOME=/config
mkdir -p /config/timetagger

# Server data directory variable: UNVERIFIED name, set only after confirmed from the README
# export TIMETAGGER_DATA_DIR=/config/timetagger

exec /app/venv/bin/python -m timetagger
```

Notes:
- Idempotent: only `mkdir -p`; nothing to seed (the server creates its own data).
- No writes to `/app`. Caches are not written (`PIP_NO_CACHE_DIR` is set by the base).
- Bind address: the server must listen on `0.0.0.0` for other containers. The default bind is UNVERIFIED (not fetched); check it in the run log and set the upstream's bind option only if it defaults to localhost.
- `exec` for signal handling.
- Data migration: the chart stores data under `/opt/_timetagger`. Existing data must be copied to `/config/timetagger` by the user; this is a note for the PR, not part of the start script.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /start.sh
- /app/venv/bin/python
- /usr/share/licenses/timetagger/LICENSE
```

- The `tcp` and `http` probes use the port from `settings.yaml`; both are UNVERIFIED until the port is confirmed. If the server returns a non-200 on `/`, keep the probe only with the code it actually returns (UNVERIFIED).
- `timeoutSeconds: 120` matches the python sibling precedent (check `apps/bazarr/container-test.yaml`-style values before merging).
- No DB, no narrowed assertions.
- The test runs without env vars, so credentials-required code paths are not tested: if the server refuses to start without them, add that path to `filePaths` and test it by hand (protocol step 3).

## 9. Rootless and read-only-rootfs adaptations

| Upstream/chart write path | Remap |
| --- | --- |
| `/opt/timetagger` (app source and `-e .` install, upstream) | `/app/venv` (installed package, read-only at runtime) |
| `/opt/_timetagger` (chart data PVC, `config` key) | `/config/timetagger` via `HOME=/config` and `start.sh`; user copies existing data once |
| pip cache, build scratch | `/tmp` (base sets `PIP_NO_CACHE_DIR=1`; no cache is written at run time) |
| uvicorn/uvloop/httptools | Installed in `/app/venv` at build time |

Security expectations (draft, chart values): non-root (chart `runAsUser 1000`, `runAsGroup 1000`); this plan runs `apps` (the base UID, not 1000: check the base's `apps` UID and note the difference in the PR), read-only rootfs compatible, not privileged, one `/config` volume instead of the chart's `/opt/_timetagger` PVC.

## 10. Risks, caveats and open questions

- Port 8080 is inferred by the draft (not in the upstream image). Confirm before settings or tests use it.
- The server's env var names and bind default are UNVERIFIED (README not fetched). Do not list env vars until confirmed.
- Web UI credentials: how they are set is UNVERIFIED. Until confirmed, the container starts with the server's default (state this in the PR).
- The draft's "pip package is unpinned" caveat: the plan pins `timetagger==26.1.3` and pins the extras after the first build.
- Python 3.15 compatibility with `timetagger` 26.1.3 is UNVERIFIED: the upstream image uses 3.13. If the first build fails on 3.15, record the failure and the version tested, do not silently switch base.
- Data migration from `/opt/_timetagger` to `/config/timetagger` is a user action (draft caveat).
- The PyPI release upload time for 26.1.3 is not confirmed (listing truncated in the fetch); the GitHub release date is confirmed.
- arm64: pure Python, expected to work; not built here.
- Blockers: none known beyond the UNVERIFIED items.

## 11. Build and test steps

```sh
cd apps/timetagger
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name timetagger-probe --read-only --tmpfs /tmp \
  -v timetagger-probe-config:/config timetagger:26.1.3
docker logs -f timetagger-probe
forgetool containers test --image timetagger:26.1.3 --config ./apps/timetagger/container-test.yaml
docker rm -f timetagger-probe; docker volume rm timetagger-probe-config
```

- Expected readiness signal: the server's startup line on `:8080` (UNVERIFIED text; take the real line from the first log). The process must stay running.
- Empty `/config` start: use a fresh volume per round.
- Run `docker run ... python -m timetagger --help` or the equivalent check if the server has no ready line, and record it.

## 12. PR checklist

- Branch `feat/add-timetagger`, commit `feat(timetagger): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; only check what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Say what was not tested: the port and env var names (UNVERIFIED), web UI credentials, the Python 3.15 build (if not run), arm64, and the data migration from the chart's `/opt/_timetagger`.
- Confirm `docker buildx bake --print` ran and whether the image built.
