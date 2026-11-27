# pinry — implementation plan
> Source: ./draft.md · Target: apps/pinry/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest GitHub release `v2.1.15`, published 2026-11-26. Source: https://api.github.com/repos/pinry/pinry/releases/latest. Draft ships `getpinry/pinry:2.1.13` (Docker Hub last updated 2024-10-03). Build `2.1.14`, not 2.1.13. |
| Draft binary (`pip:pinry`) | **Not usable.** PyPI `pinry` latest is `1.3.2`, uploaded 2013-09-26, Simplified BSD, sdist only, no wheel. Source: https://pypi.org/pypi/pinry/json. Do not install from PyPI. |
| Renovate | `datasource=github-releases depName=pinry/pinry versioning=semver` (standard form; not fetched from a renovate config) |
| License | BSD-2-Clause (GitHub SPDX). Source: https://api.github.com/repos/pinry/pinry |
| Source URL | https://github.com/pinry/pinry |
| Download (amd64 and arm64) | GitHub tag archive `https://github.com/pinry/pinry/archive/refs/tags/v${VERSION}.tar.gz`. The release has no assets. Pure Python and a JS frontend; no arch-specific binary. |
| Checksum source | None published (no release assets). Record the sha256 of the tag archive at first build; the tag itself is the pin. UNVERIFIED: no published checksum. |
| Upstream Dockerfile reviewed | Pinned commit: https://raw.githubusercontent.com/pinry/pinry/a21b1e73c2f889499286339b8cc59c411e40b9b1/Dockerfile.autobuild (summary only; verbatim fetch was refused). Latest tag directive read from `Dockerfile.autobuild?ref=v2.1.14` via `gh api`. Stages: `node:18-bookworm` builds `pinry-spa` with pnpm; `python:3.9.12-slim-buster` builds `mysqlclient` and `cx-Oracle`; final `python:3.9.12-slim-buster` with nginx, pwgen, Pillow deps, remaps `www-data` to UID/GID 1000, `pip install` of `requirements.txt`, copies `pinry-spa` build, `EXPOSE 80`, `VOLUME ["/data"]`, `CMD /pinry/docker/scripts/start.sh`, `DJANGO_SETTINGS_MODULE` set to a docker settings module, no `USER` (runs as root). |
| Docker Hub | `getpinry/pinry:2.1.13`, last updated 2024-10-03, amd64 only. Source: https://hub.docker.com/v2/repositories/getpinry/pinry/tags/2.1.13 |
| copy-from amd64 | Candidate `getpinry/pinry:2.1.13` (Debian slim, glibc). Not recommended: it is one version behind and amd64 only. Build from source instead. |
| copy-from arm64 | `no` (not published for arm64). |
| Port | Upstream nginx on 80. Non-root cannot bind 80, so the plan uses 8000 for gunicorn or 8080 for nginx (see section 10). Draft's 8000 is inferred. |
| Data | Upstream `VOLUME ["/data"]` (static files and database). Chart's extra paths: none beyond `/data`. |
| Env vars | `DJANGO_SETTINGS_MODULE` (set in the upstream image; module path UNVERIFIED). Secret key env name UNVERIFIED (draft says Django needs a secret key from the environment). Read them from the source in the build step; do not invent names. |
| Docs | https://pinry.readthedocs.io/ (not fetched; UNVERIFIED for env var and admin steps) |
| Dependencies | None (sqlite or upstream default DB; UNVERIFIED which). |

## 2. Target layout

- `apps/pinry/Dockerfile`
- `apps/pinry/docker-bake.hcl`
- `apps/pinry/settings.yaml`
- `apps/pinry/container-test.yaml`
- `apps/pinry/start.sh` (runs migrations, collects static files into `/tmp` or `/config`, then `exec`s the server; see section 7)

No `defaults/` unless a settings module needs seeding; no `root/`; no `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` for the final stage. Reason: Django app installed with pip, matching the draft. Closest sibling: `apps/python` (venv under `/app/venv`) and `apps/bazarr` (Python app layout). The frontend build needs node, so use the python-node base for a build stage only: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend`. Upstream pins Python 3.9 and node 18; UNVERIFIED that pinry 2.1.14 runs on Python 3.15 (see section 10).

## 4. Dockerfile

1. Frontend stage `FROM <python-node digest> AS frontend`, `ARG VERSION`, `USER root`.
2. `ENV PNPM_HOME=/tmp/pnpm PATH=/tmp/pnpm:$PATH`; `corepack enable` or `npm install -g pnpm@<pinned>` (pin the pnpm version from the repo's `pinry-spa/package.json` `packageManager` field; UNVERIFIED value).
3. `curl -fL "https://github.com/pinry/pinry/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1`.
4. `cd /tmp/src/pinry-spa && pnpm install --frozen-lockfile && pnpm build` (output directory is the upstream `dist`; UNVERIFIED name, check in the build).
5. Final stage `FROM <python digest>`, `ARG VERSION`, `USER root`. Install only what the Python wheels need. Upstream installs `nginx` and `pwgen`; keep `nginx` only if the runtime uses it (see section 10). `apt-get install -y --no-install-recommends` for needed packages, pin versions, `rm -rf /var/lib/apt/lists/*`.
6. Install the app into the read-only venv path: `python3 -m venv /app/venv` is already present in the base (see `VENV_FOLDER`), so `/app/venv/bin/pip install -r /tmp/src/requirements.txt` (UNVERIFIED: the repo's requirements file name and contents). Use `PIP_CACHE_DIR=/tmp/pip`. Do not write under `/app` after this step except the venv.
7. `COPY --from=frontend /tmp/src/pinry-spa/<dist> /app/pinry/static/` and `COPY --from=frontend /tmp/src /app/pinry` for the Python source. Make `/app/pinry` owned by `apps:apps` and read-only at run time.
8. License: `COPY --from=frontend /tmp/src/LICENSE /usr/share/licenses/pinry/LICENSE`.
9. `ENV DJANGO_SETTINGS_MODULE=<docker settings module, UNVERIFIED> PYTHONPATH=/app/pinry PATH=/app/venv/bin:$PATH`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

WORKDIR /app/pinry
EXPOSE 8000
VOLUME /config
```

    The VOLUME is `/config` (not `/data`) to follow ContainerForge. The upstream `/data` path is remapped in section 9.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pinry"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=pinry/pinry versioning=semver
  default = "2.1.14"
}

variable "LICENSE" {
  default = "BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/pinry/pinry"
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

Validate with `docker buildx bake --print` from `apps/pinry`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pinry/pinry"
ports:
  - port: 8000
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

The secret key variable must be added with a `default` or handled by `start.sh` on first run (`required: true` rule). Its name and whether a generated key is acceptable are UNVERIFIED. Admin account creation is a manual `createsuperuser` step (draft caveat, inferred), not an env var.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/media /config/db
cd /app/pinry
/app/venv/bin/python manage.py migrate --noinput
exec /app/venv/bin/gunicorn --bind 0.0.0.0:8000 pinry.wsgi:application
```

Idempotent: `migrate` is safe on restart, and `/config` is only created if missing. The media and database paths must point to `/config` through settings (UNVERIFIED: the settings variable names). `exec` keeps signals. Static files: the frontend build goes to `/app/pinry/static` (read-only), so `collectstatic` must not write there at run time; collect into `/tmp/static` if needed (UNVERIFIED whether pinry uses `collectstatic`). The gunicorn entry path `pinry.wsgi:application` is UNVERIFIED.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/pinry/manage.py
- /app/venv/bin/gunicorn
- /usr/share/licenses/pinry/LICENSE
```

Port 8000 has both `tcp` and `http` probes. The test runs with no env vars, so a missing `DJANGO_SECRET` path (if it refuses to start) must be checked by hand per the protocol. `timeoutSeconds: 120` is UNVERIFIED as a fit: `apps/bazarr` sets no `timeoutSeconds`; sibling `apps/changedetection` uses 180, so use 180 if startup is slow.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (database, media uploads, static files) | `/config/db` and `/config/media` (persistent, seeded by `start.sh`) |
| Static files written by `collectstatic` | `/tmp/static` (ephemeral) or built at image build time into `/app/pinry/static` |
| `www-data` user, UID/GID 1000 | Not used. Run as `apps` (ContainerForge user). Note: upstream data owned by UID 1000 on existing installs; plan a `chown` note in docs only if needed. |
| pip and cache | `/tmp/pip`, `PIP_NO_CACHE_DIR` or `PIP_CACHE_DIR=/tmp/pip` |
| nginx temp and logs (if nginx is kept) | `/tmp` |

Draft security expectations, reconciled: the chart runs as UID 0 with `runAsNonRoot: false` and `readOnlyRootFilesystem: false`. This image runs as `apps` and works with `--read-only --tmpfs /tmp`. Not privileged. The draft's "extra-persistence: none beyond /data" is consistent with `/config` as the single volume.

## 10. Risks, caveats and open questions

- **Python version.** Upstream image pins Python 3.9 and the plan uses 3.15.2. Pinry 2.1.14 compatibility with Python 3.15 is UNVERIFIED and is the first thing to test. If it fails, record the failure and stop per the protocol rather than pinning an old base.
- **Static serving.** Upstream serves static files via nginx on 80. Running gunicorn alone needs a static-file solution (for example whitenoise, if the requirements include it, or serving through the nginx sibling). UNVERIFIED which upstream uses; decide after reading `requirements.txt` and the docker start script.
- **Port.** Upstream exposes 80. The plan uses 8000 (draft inferred); confirm once the server is chosen.
- **Secret key.** Django needs a key from the environment; the upstream default is not for production (draft caveat). The plan must not hard-code a key in the image.
- **Admin account.** `createsuperuser` is a manual step after first start (draft caveat, inferred). Document it in the PR, not in `start.sh`.
- **PyPI `pinry` is stale** (1.3.2, 2013). The draft's `pip:pinry` source is rejected; the tag archive is used instead.
- **Frontend build** needs node 18 upstream; the python-node base's node version is UNVERIFIED.
- Not blocking: BSD-2-Clause license, no database dependency is confirmed, not privileged, no GPU. arm64 is not published upstream (`copy-from arm64: no`), but building from source covers arm64, untested.

## 11. Build and test steps

```sh
cd apps/pinry
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pinry-probe --read-only --tmpfs /tmp \
  -v pinry-probe-config:/config pinry:2.1.14
docker logs -f pinry-probe
forgetool containers test --image pinry:2.1.14 --config ./apps/pinry/container-test.yaml
docker rm -f pinry-probe; docker volume rm pinry-probe-config
```

Expected readiness: migrations applied, then a gunicorn "Listening at: http://0.0.0.0:8000" line, the process stays up, and `/` returns a response on 8000. Restart with the same `/config` volume and confirm the database survives. Also curl from outside the container (`-p 8000:8000`) to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-pinry`, commit and PR title `feat(pinry): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the build on Python 3.15, the frontend build, the static-file path, the secret key handling, arm64, and the admin step.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
