# shortipy — implementation plan
> Source: ./draft.md · Target: apps/shortipy/ · Difficulty: easy · Role: main · Verified on 2026-11-23 (re-checked 2026-11-24)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Upstream has **no releases and no tags** (Releases section empty, 49 commits). Latest commit on `master`: `52afd093cbca282d834bf389023a0bdc69055aae` (2025-05-25), the same commit the draft's Dockerfile link points to (`52afd09`). Pin that commit. Draft chart tag is `knex666/shortipy:latest`, which is built from this repo. |
| Renovate | `datasource=git-refs depName=https://github.com/maschhoff/shortipy currentValue=master` with `VERSION` = full commit SHA, the form in `apps/tvheadend/docker-bake.hcl`. UNVERIFIED: whether Renovate actually bumps a SHA held in a bake default with this annotation (the shared custom manager was not inspected). |
| License | GPL-3.0 (LICENSE.md, "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007"). SPDX `GPL-3.0-only` (UNVERIFIED if "or later"; README does not say). |
| Source URL | https://github.com/maschhoff/shortipy (the draft says "fork of maschhoff/shortipy by knex666": the knex666 image is built from the maschhoff repo, so use maschhoff directly) |
| Download | Source tarball: `https://github.com/maschhoff/shortipy/archive/${VERSION}.tar.gz` (git archive of a commit; pip packages `flask` 3.1.3 and `uWSGI` 2.0.31 are current on PyPI) |
| Checksum | None published. A commit SHA is content-addressed, so the pinned SHA is the integrity check; say so in a comment. |
| Upstream Dockerfile | https://github.com/maschhoff/shortipy/blob/52afd09/Dockerfile reviewed: `python:3.11.0-slim-buster`, `WORKDIR /source`, `ENV FLASK_APP=shorti.py FLASK_RUN_HOST=0.0.0.0 FLASK_RUN_PORT=4321`, `COPY ./ /source`, apt `build-essential python3-dev`, `pip3 install -r requirements.txt`, `CMD ["uwsgi", "app.ini"]`. |
| requirements.txt | `flask`, `uWSGI` (unpinned) |
| app.ini | `wsgi-file = shorti.py`, `callable = app`, `http = 0.0.0.0:4321`, `processes = 4`, `threads = 2`, `master = true`, `chmod-socket = 660`, `vacuum = true`, `die-on-term = true` |
| Port | **4321/http** (README, app.ini, Dockerfile). The draft's `5000` is wrong (inferred). |
| Data | `jdb.py` reads and writes `./data/db.json` relative to the working directory (README: mount `/shortipy/data`). Seeds `{"shortlinks":{"1234":"https://github.com/maschhoff/shortipy"}}` on first use. Writes `server.log` only in `__main__` mode, which uwsgi does not use. |
| Env vars | The app reads none. `FLASK_*` vars in upstream Dockerfile are unused under uwsgi. |

## 2. Target layout

```
apps/shortipy/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No other files. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: Flask + uWSGI need Python and a compiler (uWSGI builds from sdist; PyPI has no wheel for 2.0.31). `apps/python/Dockerfile` installs `build-essential` and never purges it (it only removes the apt lists) and builds Python into `/usr/local` with headers, so no extra apt step is expected (UNVERIFIED against the published image digest; confirm with `docker run --rm --entrypoint sh <python-image> -c 'which gcc'`). Closest sibling: `apps/bazarr` (python base, source into `/app/bin`, pip install, `exec python`).

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION` (the commit SHA). No `TARGETARCH` needed (pure source + pip).
2. `# renovate: datasource=pypi depName=flask` `ARG FLASK_VERSION=3.1.3` and `# renovate: datasource=pypi depName=uWSGI` `ARG UWSGI_VERSION=2.0.31` (pin so the image is reproducible; upstream requirements are unpinned).
3. `USER root`, then one RUN:
   ```sh
   mkdir -p /app/shortipy /usr/share/licenses/shortipy
   curl -fsSL "https://github.com/maschhoff/shortipy/archive/${VERSION}.tar.gz" | tar xz -C /app/shortipy --strip-components=1
   cp /app/shortipy/LICENSE.md /usr/share/licenses/shortipy/
   pip install --no-cache-dir "flask==${FLASK_VERSION}" "uWSGI==${UWSGI_VERSION}"
   rm -rf /app/shortipy/data /app/shortipy/.github /root/.cache /tmp/*
   chown -R root:root /app && chmod -R 755 /app
   ```
   Python base sets `PIP_BREAK_SYSTEM_PACKAGES=1`, `PIP_NO_CACHE_DIR=1`, so system `pip` works at build time (bazarr installs into system site-packages with `uv`). `apps/python/Dockerfile` creates `/app/venv` but does not put it on `PATH`, so this install leaves it untouched.
4. `ENV PYTHONDONTWRITEBYTECODE=1` (already in base), `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 4321`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP = "shortipy"`
- `VERSION` preceded by `// renovate: datasource=git-refs depName=https://github.com/maschhoff/shortipy currentValue=master` (the form used by `apps/tvheadend/docker-bake.hcl`), default `"52afd093cbca282d834bf389023a0bdc69055aae"`. The Dockerfile `ARG VERSION` consumes it, so aligned. If a human-readable tag is wanted, the image tag becomes the SHA; acceptable for an untagged project.
- `LICENSE = "GPL-3.0-only"`, `SOURCE = "https://github.com/maschhoff/shortipy/"`
- Standard targets: `docker-metadata-action`, `image` (args.VERSION + OCI source/licenses labels), `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default" = ["image-local"]`.
- Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/maschhoff/shortipy/"
ports:
  - port: 4321
    protocol: tcp
    required: true
env:
  - name: SHORTIPY_PORT
    default: "4321"
    required: false
  - name: SHORTIPY_PROCESSES
    default: "1"
    required: false
  - name: SHORTIPY_THREADS
    default: "1"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
`SHORTIPY_*` are image-level variables read by `start.sh` (the app itself reads none). If the reviewer prefers no invented names, drop the three `SHORTIPY_*` entries and hardcode the values in `start.sh`; settings.yaml must match whichever is chosen. Dependencies: none (draft: none).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
# jdb.py uses ./data/db.json, so run from /config and keep /config/data persistent.
mkdir -p /config/data
cd /config
exec uwsgi \
  --http "0.0.0.0:${SHORTIPY_PORT:-4321}" \
  --pythonpath /app/shortipy \
  --wsgi-file /app/shortipy/shorti.py \
  --callable app \
  --master \
  --processes "${SHORTIPY_PROCESSES:-1}" \
  --threads "${SHORTIPY_THREADS:-1}" \
  --vacuum \
  --die-on-term \
  --need-app
```
- Idempotent. The app seeds `db.json` itself on the first request; do not overwrite an existing one.
- Nothing written under `/app`. Put uwsgi temp/pid under `/tmp` if it complains (UNVERIFIED; no pidfile or socket is configured here).
- Binds `0.0.0.0` (explicit). Check from outside the container.
- Upstream uses 4 processes x 2 threads; with a flat JSON file and no locking, concurrent writers can lose links, so defaults are 1x1 (diverges from upstream on purpose; mention in PR).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '4321'
  path: /
tcp:
- port: '4321'
filePaths:
- /app/shortipy/shorti.py
```
`GET /` renders `layout.html` without touching the DB, so it returns 200 with an empty `/config` and no env. `timeoutSeconds`: default as in `apps/bazarr` (none set there) is fine; add `timeoutSeconds: 120` only if CI needs it. No DB dependency, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

- Only write path upstream: relative `./data/db.json` (and `server.log` in dev mode only). Remapped by running with cwd `/config` and creating `/config/data`.
- uWSGI source/templates in `/app/shortipy` are read-only and owned by root; the runtime user is `apps` (568). The chart's `runAsUser 0` is not needed: port 4321 is unprivileged.
- Draft expectation "writes data to /config": satisfied through `/config/data/db.json`. Upstream's mount point `/shortipy/data` changes to `/config/data`; mention in the PR for migration.
- No pip, bytecode or log caches at runtime (`PYTHONDONTWRITEBYTECODE=1`). Jinja templates are not compiled to disk.

## 10. Risks, caveats and open questions

- Draft caveats: depends on the fork staying available (resolved: pinned commit, tarball by SHA, unpinned deps replaced by pinned Flask and uWSGI); storage backend (resolved: JSON file `data/db.json`); uwsgi port (resolved: 4321, not 5000).
- No releases or tags: renovate cannot follow versions, only the `master` head. Upstream is low activity (last commit 2025-05-25).
- JSON file DB without locking and short codes are random 4-digit numbers (`randint(1111,9999)`), so collisions and races are possible. No authentication, anyone reaching the port can add links.
- `redirect()` accepts any stored URL (open redirect by design).
- uWSGI builds from source: needs gcc and Python headers at build time (arm64 as well, no wheel). If the base lacks them add and purge `build-essential`. UNVERIFIED: that uWSGI 2.0.31 compiles against Python 3.15 (not built); this is the main build risk.
- `chmod-socket` from upstream `app.ini` is irrelevant (no unix socket), dropped.
- No arm64 blocker expected.

## 11. Build and test steps

```sh
cd apps/shortipy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create shortipy-probe-config
docker run --rm -d --name shortipy-probe --read-only --tmpfs /tmp \
  -v shortipy-probe-config:/config shortipy:52afd093cbca282d834bf389023a0bdc69055aae
docker logs -f shortipy-probe
forgetool containers test --image shortipy:<VERSION> --config ./apps/shortipy/container-test.yaml
docker rm -f shortipy-probe; docker volume rm shortipy-probe-config
```
Readiness signal: uWSGI log lines `WSGI app 0 ... ready` and `spawned uWSGI worker 1`, port 4321 open, `GET /` returns 200. Manual path check: POST a link (`short=example.com`), confirm `/config/data/db.json` appears, restart the container and confirm the code `1234` still redirects.

## 12. PR checklist

- Branch `feat/add-shortipy`, commit and PR title `feat(shortipy): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Do not tick "Built container locally" or others unless done. Untested unless run: arm64 build, write-then-restart persistence, renovate git-refs behaviour, gcc availability in the base, uWSGI on Python 3.15.
- Pre-completion: `bake --print` passes, VERSION aligned between bake and Dockerfile, read-only rootfs run with empty `/config` is clean.
