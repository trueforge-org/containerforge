# dashmachine — implementation plan
> Source: ./draft.md · Target: apps/dashmachine/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | DECISION NEEDED. Latest GitHub release is `v0.5-4.2` (name "Version 0.5-4", published 2020-05-30, no assets). The project is stale. Upstream Docker image `rmountjoy/dashmachine:latest` was last updated 2020-09-22 and is built from commit `be50c2e763ae4e18f95855c18ba31c42199a4b3e`. Recommended: pin the commit the upstream image was built from (as `apps/fenrus` pins a commit) unless the tag is verified to point at the same commit. UNVERIFIED: which commit the tag `v0.5-4.2` points to. |
| Draft tag | `v0.5-4.2` (tarball https://github.com/rmountjoy92/DashMachine/archive/refs/tags/v0.5-4.2.tar.gz, matches the tag, not fetched). |
| Renovate | Option A (tag): `datasource=github-releases depName=rmountjoy92/DashMachine versioning=loose`. Option B (commit): `datasource=git-refs depName=https://github.com/rmountjoy92/DashMachine currentValue=master` (precedent `apps/fenrus`). UNVERIFIED: neither checked against Renovate's datasource docs. |
| License | GPLv3 per the README badge (https://raw.githubusercontent.com/rmountjoy92/DashMachine/be50c2e763ae4e18f95855c18ba31c42199a4b3e/README.md). UNVERIFIED: the `LICENSE` file fetch returned 404, so the SPDX id (`GPL-3.0-only` or `GPL-3.0-or-later`) is not confirmed. Do not set `LICENSE` until it is. |
| Source URL | https://github.com/rmountjoy92/DashMachine |
| Download | Tag tarball `https://github.com/rmountjoy92/DashMachine/archive/refs/tags/${VERSION}.tar.gz` (Option A) or `https://github.com/rmountjoy92/DashMachine/archive/${VERSION}.tar.gz` for a commit (Option B). No release asset. |
| Per-arch download URLs | Same source for amd64 and arm64. The app is pure Python (interpreted). |
| Checksum source | None published. UNVERIFIED: no checksum source found. Option B pins the commit SHA, which is content-addressed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/rmountjoy92/DashMachine/be50c2e763ae4e18f95855c18ba31c42199a4b3e/Dockerfile |
| Upstream build | `FROM python:3.8-slim`. Installs `inetutils-ping` (apt, lists removed). `WORKDIR /dashmachine`. `COPY requirements.txt`, `pip install --no-cache-dir --progress-bar off -r requirements.txt`. `COPY . /dashmachine/`. |
| Upstream runtime | `EXPOSE 5000`. `ENV PRODUCTION=true`. `VOLUME /dashmachine/dashmachine/user_data`. No `USER` (root). No `ENTRYPOINT`. `CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]`. |
| Base Python | Upstream is `python:3.8-slim` (3.8 is end-of-life). The draft did not state it. |
| Env vars (real, README) | `CONTEXT_PATH` (subfolder hosting, e.g. `/dash`). This is the only documented env var. `PRODUCTION=true` is set by the upstream image; UNVERIFIED whether the code reads it. |
| Default login | `admin` / `admin` (README). Not changed by the docs. |
| Port | 5000 (upstream `EXPOSE`, and gunicorn bind `0.0.0.0:5000`, so the server already listens on all interfaces). |
| Data and config | Upstream volume `/dashmachine/dashmachine/user_data`: holds `config.ini`, custom backgrounds and icons, and the SQLite database (README and Dockerfile). UNVERIFIED: whether the app code writes anywhere else. The code paths were not fetched. |
| Image | `docker.io/rmountjoy/dashmachine:latest`. amd64 only, digest `sha256:497692b7…`, 57938846 bytes, last updated 2020-09-22. Source: https://hub.docker.com/v2/repositories/rmountjoy/dashmachine/tags/latest. No arm64, so `copy-from arm64` is not an option. |
| TrueCharts values | Not fetched. The draft says the chart persists `/dashmachine/dashmachine/user_data` as root. UNVERIFIED. |
| Dependencies | None external. Flask and gunicorn from `requirements.txt` (versions UNVERIFIED). |

## 2. Target layout

- `apps/dashmachine/Dockerfile`
- `apps/dashmachine/docker-bake.hcl`
- `apps/dashmachine/settings.yaml`
- `apps/dashmachine/container-test.yaml`
- `apps/dashmachine/start.sh` (needed: it seeds `/config` and creates the `user_data` link target, and it starts gunicorn)

No `defaults/`, `etc/`, `health/`, `root/` needed. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The app is copied to `/app/dashmachine`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because the app is a Python web app (Flask under gunicorn) with no Node or other runtime. Closest siblings: `apps/bazarr` (python base, `USER root` for installs, `USER apps`, `COPY --chmod=0755 . /`) and `apps/changedetection` (python base, deps installed into `/app/venv` at build time). The python base creates `/app/venv` (checked in `apps/python/Dockerfile`), so the python-runtime rule applies: install into `/app/venv`, use it read-only at runtime.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. Install `inetutils-ping` (upstream uses it for status checks; UNVERIFIED that the app needs it at runtime). `apt-get update && apt-get install -y --no-install-recommends inetutils-ping && rm -rf /var/lib/apt/lists/*`. Check first whether the base already has `ping`.
3. Download and extract. No git history, so use the tarball (Option A) or the commit tarball (Option B):

```dockerfile
RUN curl -fL -o /tmp/dashmachine.tar.gz \
      "https://github.com/rmountjoy92/DashMachine/archive/refs/tags/${VERSION}.tar.gz" && \
    mkdir -p /app/dashmachine && \
    tar xzf /tmp/dashmachine.tar.gz -C /app/dashmachine --strip-components=1 && \
    rm /tmp/dashmachine.tar.gz
```

4. Install Python dependencies into the bundled venv at build time:

```dockerfile
RUN /app/venv/bin/pip install -U --no-cache-dir -r /app/dashmachine/requirements.txt && \
    /app/venv/bin/pip install -U --no-cache-dir gunicorn
```

   `gunicorn` is listed explicitly in case `requirements.txt` does not pin it (UNVERIFIED: read the file first; if it pins gunicorn, drop the second line). `PIP_NO_CACHE_DIR=1` is set by the base.
5. Map the upstream data path to `/config`. The app's `user_data` folder lives inside the source tree, so replace it with a symlink:

```dockerfile
RUN rm -rf /app/dashmachine/dashmachine/user_data && \
    ln -s /config/user_data /app/dashmachine/dashmachine/user_data
```

   Dangling until `start.sh` creates `/config/user_data`. Remove `/tmp/*` at the end.
6. Ownership and license:

```dockerfile
RUN chown -R apps:apps /app/dashmachine && chmod -R 755 /app/dashmachine && \
    mkdir -p /usr/share/licenses/dashmachine && \
    cp /app/dashmachine/LICENSE /usr/share/licenses/dashmachine/LICENSE
```

   UNVERIFIED: a `LICENSE` file exists in the tree (the fetch returned 404 at `be50c2e7`). If absent, ship the README statement and do not invent a license file; then set `LICENSE` in bake to the confirmed id.
7. Tail:

```dockerfile
ENV PRODUCTION=true
USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME /config
WORKDIR /app/dashmachine
```

   Keep `ENV PRODUCTION=true` only if the code reads it (section 1). `CONTEXT_PATH` is not set in the image; it is a user setting (section 6).

## 5. docker-bake.hcl

Copy the layout of `apps/adguardhome-sync/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "dashmachine"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rmountjoy92/DashMachine versioning=loose
  default = "v0.5-4.2"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rmountjoy92/DashMachine"
}
```

- Option A (tag) as shown. Option B (commit): use the `git-refs` annotation from section 1 and `default = "be50c2e763ae4e18f95855c18ba31c42199a4b3e"`.
- `LICENSE` is a placeholder: `GPL-3.0-only` is not confirmed (section 1). Confirm before merge.
- Then the standard `group "default"`, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`) and `image-all` (`linux/amd64`, `linux/arm64`). Validate with `docker buildx bake --print` from `apps/dashmachine/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rmountjoy92/DashMachine"
ports:
  - port: 5000
    protocol: tcp
    required: true
env:
  - name: CONTEXT_PATH
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `CONTEXT_PATH` is the only documented app variable. Empty default means "no subfolder".
- `PRODUCTION` is not listed unless verified as read by the code (section 1). It is set in the Dockerfile.
- No `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/user_data

cd /app/dashmachine || exit 1

exec /app/venv/bin/gunicorn --bind 0.0.0.0:5000 wsgi:app
```

- Idempotent. Creates `/config/user_data` only if missing. Nothing is seeded from the repo: the app creates `config.ini` and the database itself on first start (UNVERIFIED: the app creates them when missing rather than failing).
- Writes nothing into `/app`.
- `CONTEXT_PATH` is read by the app, not by this script (UNVERIFIED: whether the app reads it at import time, which decides where a change takes effect).
- The gunicorn command is the upstream `CMD`, with the absolute path to the venv binary (`/app/venv/bin` is not on `PATH` for `CMD` in the base; UNVERIFIED that the base `PATH` already includes it). `exec` keeps gunicorn as PID 1 under `tini`.
- `wsgi.py` must exist at `/app/dashmachine/wsgi.py` (UNVERIFIED: the file name at the pinned commit; the upstream CMD uses `wsgi:app`).

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
- /app/dashmachine/wsgi.py
- /app/dashmachine/requirements.txt
- /app/venv/bin/gunicorn
```

- `timeoutSeconds: 180` is the most common value across `apps/*/container-test.yaml`.
- `http` path `/` is UNVERIFIED: the app may redirect to a login page (302). Use the path that returns 200 on a fresh `/config`. Do not weaken the probe to pass.
- No env-gated code paths. `CONTEXT_PATH` is optional and the default is tested. A `CONTEXT_PATH` run is an extra manual check (section 11).
- Add the LICENSE file to `filePaths` only if it is present (section 4 step 6).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/dashmachine/dashmachine/user_data` (`config.ini`, backgrounds, icons, SQLite DB) | `/app/dashmachine/dashmachine/user_data` -> `/config/user_data` (build-time symlink; `start.sh` creates the target) |
| Upstream runs as root | `USER apps` (568). `/config` is owned by `apps` in the base |
| Other writes (logs, caches, temp files) | UNVERIFIED for every code path. Any writes outside `user_data` go to `/tmp` or `/config`. Test with `--read-only --tmpfs /tmp` |
| `ping` binary | Installed in the image. UNVERIFIED that `ping` works as non-root without `NET_RAW`. If it fails, the status checks fail, not the container |

Security expectations from the draft, reconciled:

- Chart: `runAsUser 0`, `runAsGroup 0`. This image: `apps`. Existing data in the chart's root-owned PVC must be `chown`ed to 568, or copied to `/config/user_data` by the user. Document in the PR.
- `readOnlyRootFilesystem`: chart `false`. The plan is compatible with `--read-only --tmpfs /tmp` (to be proven in section 11).
- `privileged`: no.
- Persistence: the chart persists `/dashmachine/dashmachine/user_data`. This image uses `/config/user_data`.

## 10. Risks, caveats and open questions

- DECISION: version pin. Stale upstream (2020). The tag and the commit may differ. Confirm with the user (Option A or B, section 5).
- Python base: upstream is 3.8 (EOL). The base is 3.15.2. Pinned `requirements.txt` versions may not install on 3.15 (no wheels, removed APIs). This is the main build risk. UNVERIFIED until the build runs.
- Security: default login `admin` / `admin`. This is the upstream default and the README does not change it. Document in the PR that the user must change it on first login. Do not change the default in the image without a decision from the user.
- License: `LICENSE` file missing at `be50c2e7` (404). SPDX id not confirmed (section 1).
- Data: the database and `config.ini` are in `user_data` (README). Their file paths in the code are UNVERIFIED beyond that.
- Dashboard content is created through the web UI (manual setup). Nothing is seeded.
- arm64: no upstream arm64 image. Building from source is pure Python, so both arches should work. UNVERIFIED: pinned wheels on arm64.
- Blockers: none found (no GPU, no privileged, no musl-only). Stale project and Python 3.8 are the main cost.

## 11. Build and test steps

```sh
cd apps/dashmachine
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dashmachine-probe --read-only --tmpfs /tmp \
  -v dashmachine-probe-config:/config dashmachine:v0.5-4.2
docker logs -f dashmachine-probe
forgetool containers test --image dashmachine:v0.5-4.2 --config ./apps/dashmachine/container-test.yaml
docker rm -f dashmachine-probe; docker volume rm dashmachine-probe-config
```

- Expected readiness signal: gunicorn logs `Listening at: http://0.0.0.0:5000` (gunicorn default wording, UNVERIFIED for this app), then the process stays up.
- After the first start, `/config/user_data` must exist and hold the database and `config.ini` after first use. Restart with the same volume and check the user data is not reset.
- Run once with `CONTEXT_PATH=/dash` as an extra manual check (not in `container-test.yaml`).
- Not tested by this plan: arm64, `CONTEXT_PATH`, data migration from the chart's root-owned PVC, `ping` status checks.

## 12. PR checklist

- Branch `feat/add-dashmachine`, commit `feat(dashmachine): add new container`, PR title the same, target `main`.
- Tell the user the CLA is needed: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Say in the PR that the upstream project is stale (last release 2020) and that the default `admin` / `admin` login is upstream's.
- State what was not tested: arm64, `CONTEXT_PATH`, data migration, `ping`, and the `--read-only` run if not performed.
- `docker buildx bake --print` passes; `VERSION` in `docker-bake.hcl` equals the build's version; `LICENSE` confirmed; no assertion weakened.
