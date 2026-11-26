# kapowarr — implementation plan
> Source: ./draft.md · Target: apps/kapowarr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `V1.3.2`, latest stable, published 2026-09-14 (https://github.com/Casvt/Kapowarr/releases/tag/V1.3.2). Draft and chart pin `v1.0.0-beta-4` (digest `sha256:951c583a...`, last pushed to Docker Hub 2024-01-03). Plan moves to `V1.3.2`. |
| Renovate | `datasource=github-releases depName=Casvt/Kapowarr versioning=loose` (proposed; tag has an uppercase `V` prefix. No renovate annotation found in the chart, UNVERIFIED). |
| License | GPL-3.0 (root `LICENSE`, GNU GENERAL PUBLIC LICENSE v3: https://raw.githubusercontent.com/Casvt/Kapowarr/V1.3.2/LICENSE). No "or later" clause checked. |
| Source URL | https://github.com/Casvt/Kapowarr |
| Download | `https://github.com/Casvt/Kapowarr/releases/download/V1.3.2/Kapowarr-release.zip`, confirmed on https://github.com/Casvt/Kapowarr/releases/expanded_assets/V1.3.2. Arch-neutral Python source zip, so one download serves amd64 and arm64. |
| Checksum source | No `.sha256` asset. The GitHub release API digest for `Kapowarr-release.zip` is `sha256:b90ce35f767627ce609025f7eeb1fc31b3cab4e9e975ca9c7d79c84bbd32f05b`; verify the download against it in the Dockerfile (`sha256sum -c`) and refresh it on each `VERSION` bump. |
| Upstream Dockerfile reviewed | Tag `V1.0.0-beta-4`: https://raw.githubusercontent.com/Casvt/Kapowarr/V1.0.0-beta-4/Dockerfile. Base `python:3.8-slim-buster` (EOL), `WORKDIR /app`, `pip3 install -r requirements.txt`, `COPY . .`, `EXPOSE 5656`, `STOPSIGNAL SIGINT`, `CMD ["python3", "/app/Kapowarr.py"]`, no `USER` line (runs as root). The V1.3.2 Dockerfile was not fetched. |
| Requirements | https://raw.githubusercontent.com/Casvt/Kapowarr/V1.3.2/requirements.txt: `flask ~=3.0`, `waitress ~=3.0`, `aiohttp ~=3.9`, `cryptography >=46.0.5`, `flask-socketio ~=5.3`, `cron-converter`, `bencoding`, `beautifulsoup4`, `requests[socks]`. No apt packages named. Draft's `build-essential` is inferred, not confirmed. |
| Port | 5656 (upstream `EXPOSE` in beta-4, chart service `main`: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kapowarr/values.yaml). |
| Env vars | None verified. The source was only partly read. No env var names are listed in `settings.yaml` until confirmed. UNVERIFIED. |
| Data / config paths | Chart mounts `/app/temp_downloads`, `/comics-1` (media), and `/app/db`. Chart does not use `/config`. Upstream writes under `/app` (beta-4 `WORKDIR /app`). Exact data path in V1.3.2 source: UNVERIFIED. |
| Runs as | Chart forces `runAsUser: 0`, `runAsGroup: 0`. Upstream runs as root. |
| arm64 | Yes: `mrcas/kapowarr:v1.3.2` manifest has amd64 and arm64 (https://hub.docker.com/v2/repositories/mrcas/kapowarr/tags/v1.3.2). Source zip is arch-neutral, so the wheel question is only for `cryptography` (see section 10). |
| copy-from | `mrcas/kapowarr:v1.3.2` (amd64 and arm64) exists but is not used, because the plan builds from the release zip on the ContainerForge base. |
| Dependency containers | None. |

## 2. Target layout

- `apps/kapowarr/Dockerfile`
- `apps/kapowarr/docker-bake.hcl`
- `apps/kapowarr/settings.yaml`
- `apps/kapowarr/start.sh`
- `apps/kapowarr/container-test.yaml`

No `defaults/`, `etc/` or `health/` needed unless the data-path fix in section 9 needs a file. No `root/`. `DOWNSTREAM_CHANGES.md` not needed: the app is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because Kapowarr is a pip-installed Python app. The base provides `/app/venv` (created by `python3 -m venv /app/venv`) and the pip settings. Closest sibling: `apps/bazarr` (Python app from a release zip, installed with pip). The python base's `/app/venv` is the only venv used, per the python runtime rules.

The upstream `python:3.8` is EOL. The ContainerForge python sibling replaces it. Compatibility of Kapowarr V1.3.2 and its requirements with Python 3.15 is UNVERIFIED. Fallback if the install fails: `ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca`, used by `apps/changedetection` for the same reason (3.14 pin). Record the choice in the PR.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. Fetch the release zip, unpack it to `/app/kapowarr`, install requirements into the bundled venv:

```dockerfile
ARG VERSION
USER root

RUN set -eux; \
  echo "*** Installing Kapowarr ***"; \
  mkdir -p /app/kapowarr; \
  curl -fsSL -o /tmp/kapowarr.zip \
    "https://github.com/Casvt/Kapowarr/releases/download/V${VERSION}/Kapowarr-release.zip"; \
  /app/venv/bin/python -m zipfile -e /tmp/kapowarr.zip /app/kapowarr; \
  /app/venv/bin/pip install --no-cache-dir -r /app/kapowarr/requirements.txt; \
  chown -R apps:apps /app; chmod -R 755 /app; \
  rm -rf /tmp/*
```

- `python -m zipfile -e` avoids an `unzip` apt package. `bazarr` installs `unzip` explicitly, but this base has not been checked for it.
- The zip layout (where `requirements.txt` and `Kapowarr.py` sit) is UNVERIFIED. Run `python -m zipfile -l` on the downloaded file in the build and adjust the paths.
- The base already installs `build-essential` in its own build stage (`apps/python/Dockerfile`). Do not add it again. Check whether the package is still present in the base image before relying on it for a wheel build.
- Checksum: add `echo "b90ce35f767627ce609025f7eeb1fc31b3cab4e9e975ca9c7d79c84bbd32f05b  /tmp/kapowarr.zip" | sha256sum -c -` after the download (value from section 1).
- `chown -R apps:apps /app` at build time only. At runtime `/app` is read-only.

3. Single stage image; the tail below ends the file.
4. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5656
VOLUME /config
```

License file: copy the zip's `LICENSE` (if present in the zip) to `/usr/share/licenses/kapowarr/LICENSE`. If the zip has no license file, copy the root `LICENSE` from the V1.3.2 tag (https://raw.githubusercontent.com/Casvt/Kapowarr/V1.3.2/LICENSE) in the build step.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kapowarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Casvt/Kapowarr versioning=loose
  default = "1.3.2"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Casvt/Kapowarr"
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

`VERSION` is `1.3.2` in bake and `V${VERSION}` in the download URL, so the Dockerfile `ARG` matches. Validate with `docker buildx bake --print` from `apps/kapowarr/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Casvt/Kapowarr"
ports:
  - port: 5656
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Only `TZ` is listed, because no other env var was verified in the source (section 1). Do not add names from the draft or the chart without checking them in the source.
- The ComicVine API key is set in the UI (inferred in the draft), not as an env var. Do not list it.
- Media (`/comics-1`) and downloads (`/app/temp_downloads`) are chart-side mounts. They are not `/config` and are not listed here. Revisit after the data-path check in section 9.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

cd /app/kapowarr
exec /app/venv/bin/python /app/kapowarr/Kapowarr.py
```

- The `Kapowarr.py` path and the `cd` target depend on the zip layout (section 4). Adjust both after `zipfile -l`.
- Directories under `/config` are created only with `mkdir -p`. Data-path directories (section 9) are added after the source check. Nothing is seeded.
- No writes to `/app`. Caches and scratch go to `/tmp`: set `TMPDIR=/tmp` if the app downloads to a temp directory.
- `exec` gives the Python process PID 1 signal handling. Upstream uses `STOPSIGNAL SIGINT`; keep it in the Dockerfile if the app handles SIGINT cleanly (UNVERIFIED).
- Bind address: the app must listen on `0.0.0.0`. UNVERIFIED: the default host in `Kapowarr.py` or the waitress call. Check it in the source and test from outside the container.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5656'
http:
- port: '5656'
  path: /
filePaths:
- /app/kapowarr/requirements.txt
```

- `tcp` and `http` probes for 5656, as required for every port in `settings.yaml`. The `http` path `/` may redirect to a setup page on first run. Confirm the status with a run. If it is not 200, use the path that returns 200 and record the reason. Do not loosen the check to accept any status.
- `timeoutSeconds: 120` is a first guess. Python apps in the sibling family use 120 to 180. Raise it only after a measured startup.
- `filePaths` checks that the app and its requirements exist. Replace `requirements.txt` with `Kapowarr.py` once the path is confirmed.
- No env var is required for startup, so no required-env path is hidden from the test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Database and state (chart `/app/db`; beta-4 writes under `/app`) | Target `/config/db`. Exact path in V1.3.2 source UNVERIFIED. Method to choose after the source check: a relative path resolved from the working directory (`cd /config` in `start.sh`), or build-time symlinks in `/app/kapowarr` pointing at `/config/...`, created in the Dockerfile and resolved by `start.sh` (the symlink targets must exist at runtime). |
| Temporary downloads (chart `/app/temp_downloads`) | `/config/temp_downloads` if the download path is persistent, or `/tmp` for scratch. Decide after the source check. Large downloads may not fit in `/tmp`. |
| Media (chart `/comics-1`) | User mount, not a `/config` path. Not part of the image. |
| Python bytecode and pip cache | `PYTHONDONTWRITEBYTECODE=1` and `PIP_NO_CACHE_DIR=1` are already set by the python base. Keep them. |

Draft expectations reconciled:
- The chart runs as UID 0. This image runs as `apps` (`USER apps`), so the chart override is not needed.
- The chart's `readOnlyRootFilesystem` default is true. The plan must start with `--read-only --tmpfs /tmp`. If the app writes next to its code, the run fails and the path is fixed as in the table above.
- Not privileged. No extra persistence beyond `/config` in the image itself.

## 10. Risks, caveats and open questions

- Data path (blocker until checked): the upstream V1.3.2 path for `db` and `temp_downloads` is not verified. Read `Kapowarr.py` and the database module in the V1.3.2 zip before writing `start.sh` (section 9).
- Python 3.15 with Kapowarr V1.3.2 and its requirements: UNVERIFIED. The `cryptography >=46.0.5` pin needs a wheel for each arch on Python 3.15. If none exists, the 3.14 fallback in section 3 applies.
- Zip layout: UNVERIFIED (section 4).
- Checksum: only the GitHub API asset digest exists (section 1); it must be refreshed by hand on each bump. Renovate `loose` with the uppercase `V` tag prefix handling is UNVERIFIED (may need `extractVersion=^V(?<version>.+)$`).
- Version jump: the chart uses `v1.0.0-beta-4`, the plan uses `V1.3.2`. The database may need a migration from beta-4. UNVERIFIED. The PR should state whether an existing beta-4 database starts on V1.3.2.
- ComicVine needs an API key, set in the UI (inferred). Not testable in a single container.
- `build-essential` is inferred, not confirmed (section 1). Add build packages only if a wheel build fails.
- No blockers confirmed. Not musl-only, no GPU, no privileged, arm64 manifest present.

## 11. Build and test steps

```sh
cd apps/kapowarr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name kapowarr-probe --read-only --tmpfs /tmp \
  -p 5656:5656 -v kapowarr-probe-config:/config kapowarr:1.3.2
docker logs -f kapowarr-probe
curl -sS -o /dev/null -w '%{http_code}\n' http://localhost:5656/
docker exec kapowarr-probe ss -ltn
docker rm -f kapowarr-probe; docker volume rm kapowarr-probe-config

forgetool containers test --image kapowarr:1.3.2 --config ./apps/kapowarr/container-test.yaml
```

Readiness signals (expected, UNVERIFIED until a run): the process stays up, the log shows the web server listening on port 5656 (waitress prints a listening line, UNVERIFIED), and no traceback is printed. Check that a restart with the same `/config` volume keeps the database. Confirm bind from another container, not only from `localhost`.

## 12. PR checklist

- Branch `feat/add-kapowarr` from `main`. Commit and PR title `feat(kapowarr): add new container`. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Confirm `docker buildx bake --print` passes and bake `VERSION` (`1.3.2`) equals the Dockerfile `ARG VERSION`.
- Untested to state honestly in the PR: the `V1.3.2` zip layout, the data path, Python 3.15 compatibility, arm64 wheel for `cryptography`, runtime on `--read-only`, the `http` status code, the beta-4 database upgrade.
