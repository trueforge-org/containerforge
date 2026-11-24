# pastey — implementation plan
> Source: ./draft.md · Target: apps/pastey/ · Difficulty: easy (medium risk: old pinned Python deps) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.5.1` (latest GitHub release, 2022-09-06, tag `0.5.1` = commit `533dda7ad7d8b20407d0bc750f1dbdbb69308d1c`). The draft's `0.5.1-slim` tag is the same release built from `Dockerfile-slim`. `main` has later unreleased commits (HEAD 2024-06-08). |
| Renovate | `datasource=github-releases` · `depName=Cesura/pastey` · `versioning=semver` (tags have no `v` prefix) |
| License | `BSD-3-Clause` (GitHub API `spdx_id`; `LICENSE` in repo root) |
| Source | https://github.com/Cesura/pastey |
| Download (arch independent, pure Python) | `https://github.com/Cesura/pastey/archive/refs/tags/${VERSION}.tar.gz` (verified to extract; top dir `pastey-0.5.1/`) |
| Checksum | None published upstream. HTTPS download only. |
| Upstream Dockerfile reviewed | `Dockerfile-slim` @ 0.5.1: `python:3.8.13-slim-bullseye`, `COPY . /app/`, `./patch_no_tensorflow.sh`, `pip install -r requirements.txt`, `EXPOSE 5000`, `ENV PASTEY_DATA_DIRECTORY=/app/data`, `CMD python3 app.py`. `Dockerfile` (full) is `tensorflow/tensorflow:2.9.1` and is not wanted. |
| requirements.txt | `Flask~=2.2.2`, `Flask-Limiter~=2.6.2`, `guesslang-experimental~=2.2.3` (removed by the patch script), `cryptography~=3.4.7` |
| Port | `5000` (`config.listen_port`, env `PASTEY_LISTEN_PORT`). Server is the Flask dev server (`app.run`). |
| Listen address | `0.0.0.0` default (`PASTEY_LISTEN_ADDRESS`) |
| Data path | `PASTEY_DATA_DIRECTORY` (upstream image sets `/app/data`, code default `./data`). One file per paste. |
| Env vars read by `app.py` | `PASTEY_DATA_DIRECTORY`, `PASTEY_LISTEN_ADDRESS`, `PASTEY_LISTEN_PORT`, `PASTEY_USE_WHITELIST` (True), `PASTEY_RESTRICT_PASTING` (False), `PASTEY_GUESS_THRESHOLD`, `PASTEY_RECENT_PASTES` (10), `PASTEY_WHITELIST_CIDR` (`127.0.0.1/32,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16`, comma separated), `PASTEY_BLACKLIST_CIDR` (empty), `PASTEY_BEHIND_PROXY` (False), `PASTEY_DEFAULT_THEME` (Light), `PASTEY_PURGE_INTERVAL` (3600), `PASTEY_FORCE_SHOW_RECENT` (False), `PASTEY_IGNORE_GUESS`, `PASTEY_SHOW_CLI_BUTTON` (True), `PASTEY_FORCE_HTTPS_LINKS` (False), `PASTEY_OVERRIDE_DOMAIN` (empty), `PASTEY_MINIMUM_URL_LENGTH` (5). Rate limit (`5/hour`) has no env var, only `config.py`. |
| Other facts | `app.py` uses `from distutils.util import strtobool` (module removed in Python 3.12) and `Limiter(app, key_func=..., storage_uri="memory://")` (positional `app`, Flask-Limiter 2.x style). `from __main__ import app, limiter` means it must be started as `python app.py`. |

## 2. Target layout

```
apps/pastey/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base for anything).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: Flask app installed with pip, no apt packages and no Node. Closest sibling: `apps/bazarr` (python base, source in `/app/...`, `exec /usr/local/bin/python`). Python deps go into the system interpreter under `/usr/local` (as bazarr does), so `/app/venv` stays untouched (python-runtime rules).

## 4. Dockerfile

1. `FROM` line above, `ARG VERSION`, `USER root`.
2. `ENV HOME=/config PASTEY_DATA_DIRECTORY=/config/data` (base already sets `PIP_NO_CACHE_DIR`, `PYTHONDONTWRITEBYTECODE`, `PIP_BREAK_SYSTEM_PACKAGES`).
3. One `RUN` that:
   - `curl -fsSL -o /tmp/pastey.tar.gz "https://github.com/Cesura/pastey/archive/refs/tags/${VERSION}.tar.gz"`; `mkdir -p /app/pastey && tar xzf ... -C /app/pastey --strip-components=1`.
   - `cd /app/pastey && ./patch_no_tensorflow.sh` (slim variant: removes guesslang, TensorFlow and the AUTO option; needs no AVX). The script is `sed`-based and silent on a miss, so add `! grep -q guesslang app.py requirements.txt` after it (build fails if the patch did not apply).
   - Python 3.15 compat patches (all `sed`, each followed by a `grep` assert):
     - `sed -i -E 's/^(Flask|Flask-Limiter|cryptography)~=.*/\1/' requirements.txt` (the 2022 pins `Flask 2.2`, `cryptography 3.4.7` are not expected to build or run on Python 3.15 / OpenSSL 3; UNVERIFIED, see section 10).
     - `sed -i 's/^    app,$/    app=app,/' app.py` (makes `Limiter(...)` keyword-only, valid for Flask-Limiter 2.x to 4.x).
     - replace `from distutils.util import strtobool` with an inline `def strtobool(v): ...` (accepts y/yes/t/true/on/1 and n/no/f/false/off/0, same contract as distutils).
   - `pip install -r requirements.txt` (system interpreter, no cache).
   - `mkdir -p /usr/share/licenses/pastey && cp LICENSE /usr/share/licenses/pastey/`.
   - `rm -rf /tmp/* && chown -R root:root /app/pastey && chmod -R a+rX,go-w /app/pastey`. (Runs as `apps`; read-only is enough.)
4. `USER apps`, `COPY --chmod=0755 . /`.
5. `WORKDIR /app/pastey`, `EXPOSE 5000`, `VOLUME /config`.

No apt packages needed (pure-Python wheels expected; if `cryptography` has no 3.15 wheel yet, add `build-essential libffi-dev libssl-dev cargo` in a temporary `apt-get` step and purge it, as `apps/bazarr` does).

## 5. docker-bake.hcl

Copy `apps/adguardhome-sync/docker-bake.hcl` and set:
- `APP = "pastey"`
- `VERSION`: `// renovate: datasource=github-releases depName=Cesura/pastey versioning=semver` then `default = "0.5.1"`
- `LICENSE = "BSD-3-Clause"`
- `SOURCE = "https://github.com/Cesura/pastey"`
- targets `docker-metadata-action`, `image` (args VERSION, OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Cesura/pastey"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:        # every var below is read by app.py; defaults match start.sh / upstream config.py
  - {name: PASTEY_DATA_DIRECTORY, default: "/config/data", required: false}
  - {name: PASTEY_LISTEN_ADDRESS, default: "0.0.0.0", required: false}
  - {name: PASTEY_LISTEN_PORT, default: "5000", required: false}
  - {name: PASTEY_USE_WHITELIST, default: "True", required: false}
  - {name: PASTEY_WHITELIST_CIDR, default: "127.0.0.1/32,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16", required: false}
  - {name: PASTEY_BLACKLIST_CIDR, default: "", required: false}
  - {name: PASTEY_RESTRICT_PASTING, default: "False", required: false}
  - {name: PASTEY_RECENT_PASTES, default: "10", required: false}
  - {name: PASTEY_BEHIND_PROXY, default: "False", required: false}
  - {name: PASTEY_DEFAULT_THEME, default: "Light", required: false}
  - {name: PASTEY_PURGE_INTERVAL, default: "3600", required: false}
  - {name: PASTEY_FORCE_SHOW_RECENT, default: "False", required: false}
  - {name: PASTEY_SHOW_CLI_BUTTON, default: "True", required: false}
  - {name: PASTEY_FORCE_HTTPS_LINKS, default: "False", required: false}
  - {name: PASTEY_OVERRIDE_DOMAIN, default: "", required: false}
  - {name: PASTEY_MINIMUM_URL_LENGTH, default: "5", required: false}
volumes:
  - path: /config
    required: true
```
Use the block style of the siblings (one `- name:` / `default:` / `required:` mapping per var) in the real file. `PASTEY_GUESS_THRESHOLD` and `PASTEY_IGNORE_GUESS` are deliberately omitted: language detection is patched out, so they have no effect. `dependencies`: none (key omitted).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${PASTEY_DATA_DIRECTORY:-/config/data}"
mkdir -p "${DATA_DIR}"          # seed only when missing; never touches /app
export PASTEY_DATA_DIRECTORY="${DATA_DIR}"
export PASTEY_LISTEN_ADDRESS="${PASTEY_LISTEN_ADDRESS:-0.0.0.0}"

cd /app/pastey                  # app imports the `pastey` package relative to cwd
exec /usr/local/bin/python app.py
```
Idempotent, writes only under `/config`, binds all interfaces (verified `config.listen_address = "0.0.0.0"`), no caches to redirect (`PYTHONDONTWRITEBYTECODE` is set in the base). The app prints its full configuration on start (`USING THE FOLLOWING CONFIGURATION`).

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
- /app/pastey/app.py
- /usr/share/licenses/pastey/LICENSE
```
Port 5000 is the only port in `settings.yaml` and has both probes. `GET /` returns the paste form without any env var (UNVERIFIED status code; confirm 200 in the build/run step). No env vars are needed for startup, so nothing is hidden from the test. `timeoutSeconds` 180 is the forgetool runtime minimum.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/app/data` (pastes; chart mounts a PVC here) | `PASTEY_DATA_DIRECTORY=/config/data`, created by `start.sh` |
| `/app` source tree | read-only at runtime; patches applied at build time |
| bytecode / pip cache | disabled by base ENV; nothing written to `/app` |
| Flask-Limiter state | `memory://`, no disk |

Draft security expectations reconciled: chart runs UID 0 / `readOnlyRootFilesystem: false`; the image runs as `apps` with a read-only rootfs and a persistent `/config` only. The chart's `/app/data` mount must move to `/config` (existing pastes need copying to `/config/data`; mention in the PR). Not privileged.

## 10. Risks, caveats and open questions

- Draft caveat resolved: the data path is `/app/data` upstream; this image uses `/config/data`. The draft's "python 3.8 base is EOL" is moot because we use the ContainerForge Python 3.15.2 base, but that raises the real risk below.
- HIGH: upstream pins (`Flask~=2.2.2`, `Flask-Limiter~=2.6.2`, `cryptography~=3.4.7`) target Python 3.8. The plan relaxes them and patches `Limiter(...)` and `distutils`. UNVERIFIED: whether Flask 3.x / Flask-Limiter 4.x accept the rest of `routes.py` (`@limiter.limit(..., exempt_when=...)`, the `from __main__ import` pattern). If the build run fails, fallback order: (a) keep `Flask-Limiter<3` and `Flask<3` and only drop the `cryptography` pin; (b) use `ghcr.io/trueforge-org/python:3.14.x` as changedetection does for incompatible deps.
- Upstream is unmaintained since 2024-06 and the release is from 2022; `main` may contain fixes, but we follow the release tag.
- Flask development server (`app.run`) is used upstream; no WSGI server is added to keep the patch surface small.
- Default whitelist makes private CIDRs "admin" (view recent, delete). Behind a reverse proxy set `PASTEY_BEHIND_PROXY=True`, otherwise every client appears as the proxy IP.
- No upstream checksum for the source tarball.
- amd64 and arm64 are both fine (pure Python); no musl, GPU or privileged needs.

## 11. Build and test steps

```sh
cd apps/pastey
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create pastey-probe-config
docker run --rm -d --name pastey-probe --read-only --tmpfs /tmp \
  -v pastey-probe-config:/config pastey:0.5.1
docker logs -f pastey-probe     # expect: "USING THE FOLLOWING CONFIGURATION" then "Running on http://0.0.0.0:5000"
curl -fsS http://<container-ip>:5000/ -o /dev/null -w '%{http_code}\n'   # from another container/host port
docker rm -f pastey-probe; docker volume rm pastey-probe-config
forgetool containers test --image pastey:0.5.1 --config ./apps/pastey/container-test.yaml
```
Also paste once (`POST /raw`) and restart the container with the same volume to confirm the paste survives. Round limit 10; remove scratch containers and volumes each round.

## 12. PR checklist

- Branch `feat/add-pastey`; commit and PR title `feat(pastey): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, tick only what applies.
- Put `🤖 This PR is AI generated.` in the Notes section; no "Generated with" line.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- Be honest about what is untested: Python 3.15 compatibility of the relaxed dependencies, arm64 build and run, behavior behind a reverse proxy, migration from an existing `/app/data` volume. Do not tick "Built container locally" unless it was built.
- Pre-completion: bake `--print` OK, `VERSION` aligned between `docker-bake.hcl` and Dockerfile `ARG`, rootless and read-only, empty `/config` start, no weakened assertions.
