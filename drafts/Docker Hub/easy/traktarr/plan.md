# traktarr — implementation plan
> Source: ./draft.md · Target: apps/traktarr/ · Difficulty: easy (dependency pins may raise it to medium) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 1.2.5 (release and tag `1.2.5`, commit `3c89b265aafcfa62a2235894d9b49eaecb31c171`; `--version` string in `traktarr.py` is also 1.2.5). The draft pins `master` HEAD `52d71964a2cd...` (2023-03-14), which is newer than the tag. Plan uses the tag. |
| Renovate | `datasource=github-tags depName=l3uddz/traktarr versioning=loose` (tags have no `v` prefix) |
| License | GPL-3.0 (GitHub API; `LICENSE.md` is GPLv3). SPDX `GPL-3.0-only` |
| Source | https://github.com/l3uddz/traktarr (not archived, last push 2023-03-14, so effectively unmaintained) |
| Download | `https://github.com/l3uddz/traktarr/archive/refs/tags/${VERSION}.tar.gz` (architecture independent, pure Python) |
| Checksum | UNVERIFIED: GitHub archives have no published checksum. Pin by tag only |
| Upstream Dockerfile | `docker/Dockerfile`: `python:3.7-alpine3.10`, pip install `requirements.txt`, `ENTRYPOINT ["python","traktarr.py"]`, `VOLUME /config`, ENV `TRAKTARR_CONFIG=/config/config.json`, `TRAKTARR_CACHEFILE=/config/cache.db`, `TRAKTARR_LOGFILE=/config/traktarr.log` (reviewed) |
| Requirements | `backoff==1.5.0 schedule==0.5.0 attrdict==2.0.0 click==6.7 requests~=2.20.0 pyfiglet cashier~=1.3 apprise~=0.8.2` |

Behaviour checked in source: the three `TRAKTARR_*` env vars are real click `envvar`s. The app has NO web server and opens NO port (no `5555` anywhere in `traktarr.py`, `misc/config.py` or the README). The draft's "5555/http (inferred)" is wrong. `traktarr run` is the long-running mode (a `schedule` loop). On a missing config it writes a default `config.json` and exits 0 ("Please edit the default configuration before running again!"). It also exits after adding new config options on upgrade.

## 2. Target layout

```
apps/traktarr/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (the app generates its own default config). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Pure Python app, base provides `/app/venv` (read-only at runtime, per the python-runtime rules). Closest sibling: `apps/bazarr` (zip/tarball into `/app`, pip install in the base venv). Fallback if 3.15 cannot run the old pins: an older python tag copied from another app's FROM line (for example the `python-node:3.14.8` pin used by `apps/changedetection`; a plain `python:3.14.x` tag must be checked to exist).

## 4. Dockerfile
1. `ARG VERSION`, `USER root`, `ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 HOME=/tmp TRAKTARR_CONFIG=/config/config.json TRAKTARR_CACHEFILE=/config/cache.db TRAKTARR_LOGFILE=/config/traktarr.log`. (The cache file is app state such as the blacklist/cache, so it stays in `/config`; pip caches go to `/tmp`.)
2. One `RUN`: `mkdir -p /app/traktarr /usr/share/licenses/traktarr`; `curl -fsSL "https://github.com/l3uddz/traktarr/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /app/traktarr --strip-components=1`; copy `LICENSE.md` to `/usr/share/licenses/traktarr/`.
3. Dependencies: `sed -i 's/^attrdict==.*/attrdict3/' /app/traktarr/requirements.txt` then `/app/venv/bin/pip install --no-cache-dir -r /app/traktarr/requirements.txt`. Reason: `attrdict` 2.0.x imports `collections.Mapping`, removed in Python 3.10, so it cannot import on 3.15 (UNVERIFIED by running; attrdict3 2.0.2, MIT, is the maintained drop-in providing the same `attrdict` module, checked on PyPI). Other old pins (`click==6.7`, `requests~=2.20`, `apprise~=0.8.2`, `cashier`, `backoff==1.5.0`) are UNVERIFIED on 3.15: if the build or `--help` fails, relax them one by one and record each change in a comment. No build tools are expected; if a wheel must compile, add `build-essential` in the same layer and purge it after.
4. `chown -R root:root /app/traktarr && chmod -R a+rX /app/traktarr`, remove `/root/.cache` and `/tmp/*`.
5. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `WORKDIR /config`. No `EXPOSE` (no port).

## 5. docker-bake.hcl
- `APP = "traktarr"`
- `VERSION` with `// renovate: datasource=github-tags depName=l3uddz/traktarr versioning=loose`, default `"1.2.5"`
- `LICENSE = "GPL-3.0-only"`, `SOURCE = "https://github.com/l3uddz/traktarr"`
- Standard four targets and default group as in `apps/bazarr/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml
Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/l3uddz/traktarr"`.
- ports: `ports: []` (the app opens no port).
- env: `TRAKTARR_CONFIG` (`/config/config.json`), `TRAKTARR_CACHEFILE` (`/config/cache.db`), `TRAKTARR_LOGFILE` (`/config/traktarr.log`), `TZ` (`Etc/UTC`); all `required: false`. All are set in `start.sh` or read by the app.
- volumes: `/config` (required true: `config.json`, cache, log).
- dependencies: `sonarr` ✅ and `radarr` ✅ exist in `apps/` (optional at runtime, they are the targets traktarr adds media to; list them as dependencies). Trakt credentials are configured in `config.json`, not env.

## 7. start.sh
```bash
#!/usr/bin/env bash
export TRAKTARR_CONFIG="${TRAKTARR_CONFIG:-/config/config.json}"
export TRAKTARR_CACHEFILE="${TRAKTARR_CACHEFILE:-/config/cache.db}"
export TRAKTARR_LOGFILE="${TRAKTARR_LOGFILE:-/config/traktarr.log}"
cd /app/traktarr
if [[ ! -f "${TRAKTARR_CONFIG}" ]]; then
  # Let the app write its own default config, it exits 0 afterwards.
  /app/venv/bin/python traktarr.py --help >/dev/null  # sanity import
  /app/venv/bin/python traktarr.py run || true
  echo "Default config written to ${TRAKTARR_CONFIG}. Add the Trakt, Sonarr and Radarr settings, then restart."
  exec sleep infinity   # keeps the container up so the user can edit the config (only on first start)
fi
exec /app/venv/bin/python traktarr.py run
```
Notes: idempotent, the config is only seeded when missing, no write to `/app` (`__pycache__` is disabled by `PYTHONDONTWRITEBYTECODE`). The `sleep infinity` keeps the container running for the protocol's "still running" criterion and the container test, at the cost of an idle first start; the alternative is to exit 0 and let the orchestrator restart (UNVERIFIED which is preferred, flag in PR). Run `traktarr run` with `--run-now` only if the user adds it; no env wrapper is invented.

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
filePaths:
- /app/traktarr/traktarr.py
- /config/config.json
- /usr/share/licenses/traktarr/LICENSE.md
healthCommands:
- command: /app/venv/bin/python /app/traktarr/traktarr.py --help
  expectedContent: Traktarr
  matchContent: true
```
No port exists, so no tcp/http probe (settings.yaml has `ports: []`). The test runs with no env and an empty `/config`, so it runs the "seed default config" path; `/config/config.json` then proves the seeding worked. If forgetool needs a probe for readiness and `ports: []` is rejected (UNVERIFIED), keep the filePaths-only check and say so in the PR.

## 9. Rootless and read-only-rootfs adaptations
- Writes: `config.json`, `cache.db` (cashier/sqlite), `traktarr.log` (rotating log): all remapped to `/config` through the three env vars. `__pycache__` suppressed; pip cache in `/tmp`.
- Draft expects UID 0 / readOnlyRootFilesystem false in TrueCharts. Here: `USER apps`, read-only rootfs compatible, since nothing outside `/config` and `/tmp` is written. Draft's "extra persistence: none" holds (`/config` only).
- `/app/venv` is not mutated at runtime.

## 10. Risks, caveats and open questions
- The draft's 5555 port is wrong: the container opens no port, so health checks are file/command based.
- Python 3.15 vs 2018-era pins is the main risk (see section 4). Possible need for an older python base.
- Unmaintained upstream (no release since 1.2.5; last commit 2023-03-14), so Renovate rarely fires. The draft's "pinned commit, manual bump" caveat becomes "tag 1.2.5".
- Needs a Trakt client id/secret, plus Sonarr and Radarr URLs/API keys in `config.json`; first run generates the default and stops, and the Trakt OAuth step is interactive: document `docker exec -it ... python traktarr.py trakt-authentication` (the function is `trakt_authentication` in source; the click command name `trakt-authentication` is UNVERIFIED).
- No blockers (no musl, GPU, privileged or arm64 issue; pure Python).

## 11. Build and test steps
```sh
cd apps/traktarr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name traktarr-probe --read-only --tmpfs /tmp -v traktarr-probe-config:/config traktarr:1.2.5
docker logs -f traktarr-probe   # expect "Dumping default config to: /config/config.json" and the "Please edit" line
# second run: edit /config/config.json with dummy values, restart, expect the validation errors for Trakt/Sonarr to be clean, non-crashing log lines
docker rm -f traktarr-probe; docker volume rm traktarr-probe-config
forgetool containers test --image traktarr:1.2.5 --config ./apps/traktarr/container-test.yaml
```
Readiness signal: the default-config message on first start; on a configured start, the `schedule` loop logs after the Trakt/Sonarr validation.

## 12. PR checklist
- Branch `feat/add-traktarr`, commit `feat(traktarr): add new container`, target `main`.
- Fill in the PR template, check only the true boxes.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: the Python 3.15 compatibility of the pinned requirements, the configured run against real Trakt, Sonarr and Radarr, arm64, and the Trakt OAuth step.
