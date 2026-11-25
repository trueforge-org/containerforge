# maloja — implementation plan
> Source: ./draft.md · Target: apps/maloja/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 3.2.10 (git tag `v3.2.10`). Docker Hub `krateng/maloja` `latest` and `3.2.10` both last updated 2026-11-06. The draft's `master` tarball is not used: pin the tag. |
| Git tag date | UNVERIFIED: no GitHub release object (`releases` empty, `releases/latest` 404). The tag exists (`/repos/krateng/maloja/tags`). |
| Renovate | `datasource=github-tags depName=krateng/maloja versioning=semver` (tag prefix `v`). UNVERIFIED: no renovate config in the repo was checked. If `v` is not stripped, add `extractVersion`. |
| License | GPL-3.0 (GitHub license API). UNVERIFIED: the `LICENSE` header must show whether it is `-only` or `-or-later` before the bake `LICENSE` is set. |
| Source URL | https://github.com/krateng/maloja |
| Source tarball | `https://github.com/krateng/maloja/archive/refs/tags/v${VERSION}.tar.gz` (tag exists). |
| Per-arch download | Same tarball for all arches. Pure Python, no compiled artifact of our own. |
| Checksum source | None published by upstream. UNVERIFIED: the tarball can only be pinned by tag. Optionally record a locally computed `sha256` in the Dockerfile and say so in the PR. |
| Upstream Dockerfile reviewed | `Containerfile` at tag v3.2.10: base `lsiobase/alpine:3.21` (musl), `WORKDIR /usr/src/app`, build deps via apk (gcc, g++, python3-dev, libxml2-dev, libxslt-dev, libffi-dev, libc-dev, py3-pip, linux-headers), runtime apk (python3, py3-lxml, libmagic, tzdata), venv at `/venv`, `pip install -r requirements.txt`, then `pip3 install /usr/src/app`, `container/root/` copied to `/` (s6 init; contents UNVERIFIED), `ENV MALOJA_SKIP_SETUP=yes MALOJA_CONTAINER=yes PYTHONUNBUFFERED=1 PUID=0 PGID=0`, `EXPOSE 42010`. Upstream runs as root. |
| Port | 42010 (README and `EXPOSE`). |
| Env vars (real) | `MALOJA_DATA_DIRECTORY` (README: config and data directory, example `/mljdata`), `PUID`/`PGID` (upstream host-ownership handling; not used here, we run as `apps`), `MALOJA_SKIP_SETUP`, `MALOJA_CONTAINER` (both set by the upstream Containerfile; whether the app reads `MALOJA_CONTAINER` is UNVERIFIED). |
| Default data path | UNVERIFIED: the default when `MALOJA_DATA_DIRECTORY` is unset was not confirmed. The plan sets it explicitly. |
| Python dependencies | `bottle 0.13.*`, `waitress 3.0.*`, `doreah 2.0.*`, `nimrodel 0.8.*`, `setproctitle 1.3.*`, `jinja2 3.1.*`, `lru-dict 1.3.*`, `psutil 5.9.*`, `sqlalchemy 2.0`, `python-datauri 3.0.*`, `python-magic 0.4.*`, `requests 2.32.*`, `toml 0.10.*`, `PyYAML 6.0.*`, plus `lxml` (from the apk `py3-lxml` line). Source: `requirements.txt` at v3.2.10. |
| Dependency containers | None. UNVERIFIED: the storage engine (the draft says SQLite-style, sqlalchemy is present). |

## 2. Target layout

- `apps/maloja/Dockerfile`
- `apps/maloja/docker-bake.hcl`
- `apps/maloja/settings.yaml`
- `apps/maloja/container-test.yaml`
- `apps/maloja/start.sh`

No `defaults/` (Maloja has no shipped config to seed; confirm in the first run). No `etc/`, `scripts/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

Runtime stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`.

Fits because the app is a pure Python package installed with pip, and the python sibling already provides `/usr/local/bin/python`, pip and the `apps` user. The base is built on the ubuntu family, so the glibc wheels and apt packages work. Closest siblings: `apps/bazarr` (python app with requirements installed in the image, apt libs such as `libxml2` and `libxslt`) and `apps/webhook` (python base, `apps` user, `/config` as `WORKDIR`).

Do not use `lsiobase/alpine` (upstream musl base). The draft's ubuntu plan replaces it.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. Runtime apt packages for the app (not in base, pinned names not needed: they are libraries, not the app):
   `apt-get install -y --no-install-recommends libmagic1 libxml2-16 libxslt1.1` (names follow `apps/bazarr`; `libmagic1` is inferred from upstream's `libmagic` apk). Then `rm -rf /var/lib/apt/lists/*`.
3. Fetch and unpack the source, then build a venv under the app folder. Do not touch the base's `/app/venv` (python-runtime rule):

```dockerfile
RUN set -eux; \
    mkdir -p /tmp/maloja /app/maloja /usr/share/licenses/maloja; \
    curl -fsSL -o /tmp/maloja.tar.gz \
        "https://github.com/krateng/maloja/archive/refs/tags/v${VERSION}.tar.gz"; \
    tar xzf /tmp/maloja.tar.gz -C /tmp/maloja --strip-components=1; \
    /usr/local/bin/python -m venv /app/maloja/venv; \
    /app/maloja/venv/bin/pip install --requirement /tmp/maloja/requirements.txt; \
    /app/maloja/venv/bin/pip install /tmp/maloja; \
    cp /tmp/maloja/LICENSE /usr/share/licenses/maloja/LICENSE; \
    chown -R root:root /app && chmod -R 755 /app; \
    rm -rf /tmp/*
```

   The base sets `PIP_NO_CACHE_DIR=1`, so pip writes no cache. Build scratch stays in `/tmp`.
4. Wheels must exist for amd64 and arm64 for `lxml`, `psutil`, `lru-dict`, `setproctitle`, `python-magic` (UNVERIFIED for every dependency). If one needs a compile, add its `-dev` package in a `build-essential` step, then remove it in the same `RUN`.
5. Tail (same as siblings):

```dockerfile
ENV MALOJA_DATA_DIRECTORY=/config \
    MALOJA_SKIP_SETUP=yes

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 42010
VOLUME /config
```

   `MALOJA_CONTAINER` is not set here until a read in the code is confirmed (see section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "maloja"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=krateng/maloja versioning=semver
  default = "3.2.10"
}

variable "LICENSE" {
  default = "GPL-3.0-only"   // UNVERIFIED: GitHub reports GPL-3.0; confirm -only vs -or-later from the LICENSE file
}

variable "SOURCE" {
  default = "https://github.com/krateng/maloja"
}
```

Then the standard `group "default"` and `image`, `image-local`, `image-all` targets copied from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` must equal the Dockerfile `ARG VERSION` default (the bake passes it as a build arg). Validate with `docker buildx bake --print` in `apps/maloja/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/krateng/maloja"
ports:
  - port: 42010
    protocol: tcp
    required: false
env:
  - name: MALOJA_DATA_DIRECTORY
    default: "/config"
    required: false
  - name: MALOJA_SKIP_SETUP
    default: "yes"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`MALOJA_DATA_DIRECTORY` must match `start.sh`. Do not list `PUID`/`PGID`: they belong to the upstream root-based entrypoint and are not read here. Add other README variables only after they are read from the README or code (UNVERIFIED for the rest).

## 7. start.sh

```bash
#!/usr/bin/env bash

export MALOJA_DATA_DIRECTORY="${MALOJA_DATA_DIRECTORY:-/config}"
export MALOJA_SKIP_SETUP="${MALOJA_SKIP_SETUP:-yes}"

mkdir -p "${MALOJA_DATA_DIRECTORY}"
cd "${MALOJA_DATA_DIRECTORY}" || exit 1

exec /app/maloja/venv/bin/maloja start
```

- The `start` subcommand and the console-script name are UNVERIFIED. Read the upstream `container/root/` run script at tag v3.2.10 (the Containerfile copies it to `/`) and copy the exact command. Do not guess it.
- Idempotent: it only creates `/config`. Maloja creates its own files on first start (UNVERIFIED). If it needs a seed file, use `cp -n` from `/app/...` into `/config` only when missing.
- Writes: only `/config` and `/tmp`. Nothing under `/app`.
- Network: confirm that the waitress server binds `0.0.0.0`, not `127.0.0.1`, from the config or source (UNVERIFIED). Test it from outside the container (section 11).
- `exec` hands PID 1 to Maloja for signals.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '42010'
http:
- port: '42010'
  path: /
filePaths:
- /app/maloja/venv/bin/python
- /usr/share/licenses/maloja/LICENSE
```

- Every settings port has a probe: `tcp` and `http` on 42010.
- The `http` path `/` is UNVERIFIED for a 200 response. If the first-run page returns non-200, use the path that does (`apps/webhook` uses `/`, `apps/bazarr` uses `/api/system/ping`; the app's own health route is UNVERIFIED).
- No env is needed to start, so no required-env code path is untested.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `MALOJA_DATA_DIRECTORY` (config, data, cache) | `/config` (set in `start.sh` and `settings.yaml`) |
| Upstream runs as root with `PUID`/`PGID` | Not used. The image runs as `apps` (UID 568). Existing users with files owned by root in their volume must `chown` them (UNVERIFIED impact). |
| Python bytecode, pip cache, build scratch | `PYTHONDONTWRITEBYTECODE` is set by the base; `PIP_NO_CACHE_DIR=1` from base; build scratch in `/tmp`. Confirm no `__pycache__` writes under `/app` at runtime (UNVERIFIED). |
| Upstream `container/root/` s6 scripts | Not copied. Replaced by `start.sh`. |

Draft expectations reconciled: the chart forces UID 0 (the image runs as 568, so this is a change for users), `readOnlyRootFilesystem` is false in the chart (the image should work with `--read-only --tmpfs /tmp`, to verify), not privileged. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- Start command and console-script name not verified (see section 7). Blocker for `start.sh` until read from upstream.
- `MALOJA_CONTAINER` is set upstream but whether the app reads it is UNVERIFIED. Left out of `settings.yaml` until confirmed.
- Default `MALOJA_DATA_DIRECTORY` value is UNVERIFIED. The plan sets it, so the default does not matter for this image.
- Storage engine and any on-disk migration from an upstream `lsiobase` volume are UNVERIFIED. Users moving from the Docker Hub image must check where their data is.
- Every pip dependency needs a wheel for both amd64 and arm64, or a build path (UNVERIFIED for each).
- Scrobbling clients need the server URL and an API key before anything is recorded (draft caveat, inferred).
- A settings file may be needed in the data path before first start (draft caveat, inferred; not confirmed).
- Blockers: none confirmed. Not musl-only (the upstream musl base is replaced), no GPU, no privileged need, arm64 expected (pure Python).

## 11. Build and test steps

```sh
cd apps/maloja
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name maloja-probe --read-only --tmpfs /tmp \
  -p 42010:42010 -v maloja-probe-config:/config maloja:3.2.10
docker logs -f maloja-probe
curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:42010/
forgetool containers test --image maloja:3.2.10 --config ./apps/maloja/container-test.yaml
docker rm -f maloja-probe; docker volume rm maloja-probe-config
```

- Expected readiness signal: the waitress server line that names port 42010 (exact text UNVERIFIED; read it from the first run). The container must still be running after the startup window.
- Also run it with `-p 42010:42010` and curl from the host, to prove it is not bound to localhost only.
- Restart the container with the same `/config` volume and confirm the data survives.
- Round limit and cleanup: 10 rounds per the build-test protocol.

## 12. PR checklist

- Branch `feat/add-maloja`, commit and PR title `feat(maloja): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Untested, to state honestly in the PR: the start command (until read from upstream), the arm64 build and wheels, the HTTP probe status code, restart persistence, `--read-only` behaviour, and the user-visible change from root (UID 0) to `apps` (UID 568).
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened; `LICENSE` confirmed before merge.
