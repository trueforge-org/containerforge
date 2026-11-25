# metatube — implementation plan
> Source: ./draft.md · Target: apps/metatube/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases and no tags (the API returns empty lists). Docker Hub `jvt038/metatube` has only the `latest` tag (last updated 2024-10-05, amd64 plus one `unknown` arch), so the upstream image is stale and amd64-only. This plan builds from source, pinned to master commit `879a385` (HEAD master committed 2026-08-25T18:03:18Z at the time of the check). The full 40-character SHA is UNVERIFIED: resolve it with `git ls-remote` before writing `VERSION`. |
| Difference from draft | The draft's `8080` port is wrong: upstream default is `PORT=5000`. The draft's "`/config` copy" matches the upstream Dockerfile. |
| Renovate | `datasource=git-refs depName=https://github.com/JVT038/MetaTube currentValue=master` (same pattern as `apps/fenrus`). The draft's `docker` datasource (`jvt038/metatube`) would track only `latest`, so it is not used. |
| License | GPL-3.0 (GitHub repo license, read via `gh api`). |
| Source URL | https://github.com/JVT038/MetaTube |
| Download (amd64 and arm64) | Source tarball `https://github.com/JVT038/MetaTube/archive/${VERSION}.tar.gz`. Pure Python source, so the same tarball serves both arches. No prebuilt binary. |
| Checksum source | None published. The tarball is pinned by commit SHA, which is content-addressed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/JVT038/MetaTube/879a385/Dockerfile. `FROM python:3.12-alpine`, `COPY . /config/`, `apk add --no-cache --upgrade alpine-sdk libffi-dev ffmpeg libmagic`, then `mkdir -p {/config,$DOWNLOADS,/database}`, `pip3 install -r /config/requirements.txt`, `apk del --purge alpine-sdk`. `ENTRYPOINT ["/usr/local/bin/python3", "config/metatube.py"]`. No USER, no VOLUME, no CMD. No arch-specific logic. |
| Upstream Dockerfile bug | `mkdir -p {/config,$DOWNLOADS,/database}` uses brace expansion, which Alpine `sh` does not do, so it likely creates one literal directory. Do not copy this line. Create each directory explicitly. |
| Port | `PORT`, default 5000 (README table and Dockerfile `ENV PORT=5000`). `EXPOSE $PORT`. |
| Env vars (real) | README table: `PORT` (5000), `HOST` (127.0.0.1), `DEBUG` (False), `DATABASE_URL` (`sqlite:///app.db`), `FFMPEG` (empty), `DOWNLOADS` (`/absolute/path/to/MetaTube/downloads`), `LOG` (False), `SOCKET_LOG` (False), `LOG_LEVEL` (10), `URL_SUBPATH` (/), `INIT_DB` (True). Dockerfile ENV: `PORT=5000`, `FFMPEG=/usr/bin`, `DOWNLOADS=/downloads`, `DATABASE_URL=sqlite:////database/app.db`. |
| Docker notes (README) | Set `HOST=0.0.0.0`, because the default `127.0.0.1` is not reachable from outside the container. Volumes `/downloads`, `/database` (put `DATABASE_URL` in `/database`, or the DB resets on update), and `/config/migrations`. Port 5000. |
| System deps | `libmagic1` on Debian and Ubuntu (README). FFmpeg is listed as 4.4.1 in the technology list, which is not an install step. |
| Python | README says Python 3.8+. The upstream image uses 3.12. |
| Database | SQLite only. |
| Dependency | None. |

## 2. Target layout

- `apps/metatube/Dockerfile`
- `apps/metatube/docker-bake.hcl`
- `apps/metatube/settings.yaml`
- `apps/metatube/container-test.yaml`
- `apps/metatube/start.sh`

No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md`, because this image is not a `FROM` base for other apps (no `apps/*/Dockerfile` uses `metatube`).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because the app is a pure Python package with pip dependencies, and the python sibling provides `/app/venv` (python-runtime rules). Upstream is `python:3.12-alpine`: ContainerForge uses the Ubuntu-based python sibling instead, so Python moves from 3.12 to 3.15.2. Python 3.15 compatibility of `requirements.txt` is UNVERIFIED: install and run it in the build and test. Closest sibling: `apps/bazarr` (python base, apt `ffmpeg` and `libmagic`-style runtime packages, `/config` state).

## 4. Dockerfile

1. `FROM` the python base above.
2. `ARG VERSION`, `ARG TARGETARCH` (only if an arch-specific wheel fails).
3. `USER root` for the install steps only.
4. Runtime apt packages (not in the python base; check first): `ffmpeg`, `libmagic1`. Build packages only if a pip wheel has to compile: `build-essential`, `libffi-dev` (Alpine `alpine-sdk` and `libffi-dev` in upstream). Remove the build packages in the same `RUN`. These packages come from the Ubuntu archive and are not pinned: pin them only if the Ubuntu release is known, and check them against `VERSION` (the app has no version string of its own, so the pin is the commit).
5. Download and extract the source to `/app/metatube` (not `/config`):

```dockerfile
RUN echo "*** Installing MetaTube ***" && \
  mkdir -p /app/metatube /downloads /tmp/metatube && \
  curl -fL -o /tmp/metatube.tar.gz \
    "https://github.com/JVT038/MetaTube/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/metatube.tar.gz -C /app/metatube --strip-components=1 && \
  rm /tmp/metatube.tar.gz
```

6. Install Python dependencies into the read-only venv at build time, following the python-runtime rule (`/app/venv` is not written at runtime):

```dockerfile
RUN /app/venv/bin/pip install --no-cache-dir -r /app/metatube/requirements.txt
```

   Keep pip cache in `/tmp` (`PIP_CACHE_DIR=/tmp/pip`). Do not use `/config`.
7. Create the database and migrations folders in the build, one at a time (not brace expansion):

```dockerfile
RUN mkdir -p /config/migrations && \
  ln -sfn /config/migrations /app/metatube/migrations
```

   `migrations/` is a volume in the upstream README (`/config/migrations`). Whether the app writes into its own source folder is UNVERIFIED. The symlink keeps writes out of `/app`.
8. License: `/usr/share/licenses/metatube/LICENSE` from the tarball (`/app/metatube/LICENSE`, file name UNVERIFIED beyond the GPL-3.0 detection).
9. Ownership: `chown -R apps:apps /app/metatube && chmod -R 755 /app/metatube`. `/downloads` must be writable by `apps`: `chown apps:apps /downloads`.
10. Environment:

```dockerfile
ENV PORT=5000 \
    HOST=0.0.0.0 \
    FFMPEG=/usr/bin \
    DOWNLOADS=/downloads \
    DATABASE_URL=sqlite:////config/app.db \
    PIP_CACHE_DIR=/tmp/pip \
    HOME=/config
```

   `DATABASE_URL` moves from upstream `/database/app.db` to `/config/app.db`, because `/config` is the persistent path in ContainerForge. Keep `DOWNLOADS=/downloads` (see section 9 for the volume).
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME ["/config", "/downloads"]
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "metatube"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/JVT038/MetaTube currentValue=master
  default = "879a385"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/JVT038/MetaTube"
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

- `VERSION` is the full commit SHA once resolved (`879a385` above is short and UNVERIFIED as the full value). Use the full SHA in both the bake file and the Dockerfile `ARG`.
- Validate with `docker buildx bake --print`. Renovate for `git-refs` updates the default on master pushes (noisy, see section 10).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/JVT038/MetaTube"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "5000"
    required: false
  - name: HOST
    default: "0.0.0.0"
    required: false
  - name: DATABASE_URL
    default: "sqlite:////config/app.db"
    required: false
  - name: DOWNLOADS
    default: "/downloads"
    required: false
  - name: FFMPEG
    default: "/usr/bin"
    required: false
  - name: DEBUG
    default: "False"
    required: false
  - name: LOG
    default: "False"
    required: false
  - name: LOG_LEVEL
    default: "10"
    required: false
  - name: URL_SUBPATH
    default: "/"
    required: false
  - name: INIT_DB
    default: "True"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /downloads
    required: false
```

- Only env vars the app reads are listed (README table). `TZ` is a sibling convention; keep it only if `start.sh` maps it, otherwise remove it (no invented env vars).
- `DATABASE_URL` default is the `/config` path. This differs from upstream's `/database` (chart compatibility, section 10).
- `/downloads` is a separate mountable path (media output). Listed as optional.
- No `dependencies` or `opt_dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config /config/migrations /downloads

export PORT="${PORT:-5000}"
export HOST="${HOST:-0.0.0.0}"
export DATABASE_URL="${DATABASE_URL:-sqlite:////config/app.db}"
export DOWNLOADS="${DOWNLOADS:-/downloads}"
export FFMPEG="${FFMPEG:-/usr/bin}"

cd /app/metatube
exec /app/venv/bin/python metatube.py
```

- `metatube.py` path: upstream runs `config/metatube.py` from `/`, so the entrypoint is `/config/metatube.py`. In ContainerForge the source is `/app/metatube/metatube.py` (or whichever module the README `uv run metatube` script names; UNVERIFIED which file is the entrypoint). Check the `[project.scripts]` entry in `pyproject.toml` at the pinned commit before writing `exec`.
- `HOST=0.0.0.0` is the default here, so the container is reachable from another container (see the Docker notes in section 1).
- `DATABASE_URL` is applied from `/config` each start. Only create the directory; never seed or overwrite an existing database.
- Idempotent: `mkdir -p`. No writes to `/app`.
- `exec` the Python process so signals reach PID 1.
- Use `/app/venv` (python-runtime rule). If `uv run` is needed, it must not write to `/app` (UNVERIFIED).

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
- /app/metatube/requirements.txt
- /app/venv/bin/python
- /usr/share/licenses/metatube/LICENSE
```

- `tcp` and `http` probes against port 5000 (the only port in `settings.yaml`).
- `http path: /` returns UNVERIFIED status until the first run. If a non-200 status is returned, check the app's actual route; do not loosen the probe.
- Test runs with no env vars, so the default `sqlite:////config/app.db` path is tested. No required-env code path exists in the upstream README.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/database/app.db` (SQLite, upstream `DATABASE_URL`) | `/config/app.db` (`DATABASE_URL` default). The chart mounts `/database` today. Chart users must move their DB to `/config/app.db` or set `DATABASE_URL` to their existing file. |
| `/downloads` (chart PVC `/downloads`) | Kept at `/downloads` as an optional volume (`settings.yaml`). Owned by `apps`. |
| `/config/migrations` (upstream volume) | Build-time directory `/config/migrations`, symlinked from `/app/metatube/migrations`. |
| pip cache | `/tmp/pip` (`PIP_CACHE_DIR`). |
| `HOME` | `/config`. |
| Logs and other writes | UNVERIFIED: check the logs on `--read-only --tmpfs /tmp` and remap any further write with a symlink into `/config`. |

Draft expectations, reconciled:
- Non-root: the chart forces UID 0. The image runs as `apps` (UID 568), so the chart value must be changed when the image is used (a chart change, not this PR).
- Read-only rootfs: the chart sets `readOnlyRootFilesystem: false`. The image is designed to work with `--read-only --tmpfs /tmp`, verified by the test in section 11.
- Privileged: no.
- Extra persistence: `/database` and `/downloads` (draft). The image uses `/config` for the database and `/downloads` for media.

## 10. Risks, caveats and open questions

- No versioned releases: the version is a commit SHA, so Renovate bumps on every master push (noisy). Consider pinning and adding a Renovate schedule or `packageRules` limit (repo config, not this app).
- Upstream image stale: `jvt038/metatube:latest` last updated 2024-10-05. The source build replaces it, so the image here is a new build, not a copy.
- `requirements.txt` on Python 3.15: UNVERIFIED. The upstream image uses 3.12, and the README says 3.8+.
- `mkdir -p {...}` brace-expansion bug in upstream (section 1). Not copied.
- Alpine to Ubuntu: the upstream `apk` line becomes `apt-get` with Ubuntu package names. `libmagic` is `libmagic1`. FFmpeg comes from apt.
- Metadata sources are external sites, so lookups need internet access and may break when those sites change (draft, inferred).
- `DATABASE_URL` path change from `/database` to `/config` affects chart users (section 9).
- Blockers: no versioned releases; upstream Alpine base; no arm64 upstream image. Source is pure Python plus apt packages, so arm64 is plausible but UNVERIFIED until built. Not musl-only once Ubuntu is used, no GPU, no privileged needs.

## 11. Build and test steps

```sh
cd apps/metatube
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name metatube-probe --read-only --tmpfs /tmp \
  -v metatube-probe-config:/config metatube:<full-sha>
docker logs -f metatube-probe
forgetool containers test --image metatube:<full-sha> --config ./apps/metatube/container-test.yaml
docker rm -f metatube-probe; docker volume rm metatube-probe-config
```

- Replace `<full-sha>` with the pinned commit in `VERSION`.
- Readiness signal: the startup line from `metatube.py` (UNVERIFIED text; take it from the first real log) and the listen on `0.0.0.0:5000`. The process must stay running.
- Check from outside the container (`-p 5000:5000`) that the port is reachable.
- Also run once with `--read-only` and a non-empty `/config` after restart, to confirm the database survives a restart.
- No DB dependency, so the protocol's DB exception does not apply.

## 12. PR checklist

- Branch `feat/add-metatube`, commit and PR title `feat(metatube): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Tell the user. Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: the full commit SHA resolution, Python 3.15 compatibility, the `metatube.py` entrypoint, the `http` probe status, the readiness log text, arm64 (unless built), and the `/database` to `/config` migration for chart users.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
