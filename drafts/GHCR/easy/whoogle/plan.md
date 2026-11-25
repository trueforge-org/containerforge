# whoogle — implementation plan
> Source: ./draft.md · Target: apps/whoogle/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v1.2.4 (draft matches). Published 2026-04-15T00:54:37Z. This is the final official release: the release notes and the PyPI description say Google blocks JavaScript-free queries and no further fixes are planned. Source: `gh api repos/benbusby/whoogle-search/releases/latest`, https://pypi.org/pypi/whoogle-search/json |
| Repo status | ARCHIVED (`gh api repos/benbusby/whoogle-search`: `archived: true`, pushed 2026-08-14). See section 10. |
| Renovate | `datasource=github-releases depName=benbusby/whoogle-search versioning=semver` (suggested; tags are `v1.2.4`). |
| License | MIT (repo `license.spdx_id` = MIT; PyPI classifier MIT). |
| Source URL | https://github.com/benbusby/whoogle-search |
| Download | Tag source archive `https://github.com/benbusby/whoogle-search/archive/refs/tags/v1.2.4.tar.gz` (not downloaded in this plan). PyPI wheel and sdist also exist for v1.2.4. |
| Checksums | PyPI publishes sha256: wheel `whoogle_search-1.2.4-py3-none-any.whl` = `43b748cd7af3406e0df2e7562fd347fa3cae90d65f360ce45a918d907408d264`; sdist `whoogle_search-1.2.4.tar.gz` = `56af022c494fd4ffcb72af7c2191e0ba0edae3eb124b210bda287863931c01f8`. No checksum for the GitHub tag archive: UNVERIFIED, the implementer computes and pins it. |
| Per-arch | Pure Python: the same source works on amd64 and arm64. arm64 for the native wheels pulled by pip (cryptography, brotli, cffi, pyOpenSSL): UNVERIFIED for the 3.15 glibc base. |
| Requirements | Pinned in `requirements.txt` at the tag: Flask==3.1.3, cryptography==46.0.7, pyOpenSSL==26.0.0, httpx[http2,socks]==0.28.1, stem==1.8.2, waitress==3.0.2, validators==0.35.0, python-dotenv==1.1.1, beautifulsoup4, brotli, cssutils, defusedxml, cachetools, plus pytest and pycodestyle (test/dev only). Source: https://github.com/benbusby/whoogle-search/blob/v1.2.4/requirements.txt |
| requires_python | Not declared on PyPI (None). Upstream image: `python:3.12-alpine3.22`. |
| Upstream Dockerfile reviewed | https://github.com/benbusby/whoogle-search/blob/v1.2.4/Dockerfile. Builder installs `requirements.txt` into `/install`; final stage on `python:3.12-alpine3.22` also installs `tor curl openrc libstdc++`, copies `misc/tor/torrc`, `misc/tor/start-tor.sh`, `app/`, `run`, `whoogle.env*`; user `whoogle` uid 927; `ARG config_dir=/config`, `VOLUME /config`; `EXPOSE $EXPOSE_PORT`; HEALTHCHECK `curl -f http://localhost:${EXPOSE_PORT}/healthz`; `CMD ["/bin/sh","-c","misc/tor/start-tor.sh & ./run"]`. |
| Run script | https://github.com/benbusby/whoogle-search/blob/v1.2.4/run: `APP_ROOT=$SCRIPT_DIR/app`, `STATIC_FOLDER=$APP_ROOT/static`, deletes `app/static/build/*.js|css`, then `python3 -um app --host ${ADDRESS:-0.0.0.0} --port ${PORT:-${EXPOSE_PORT:-5000}}`. |
| Env vars (real, read in code at v1.2.4) | `CONFIG_VOLUME` (config dir; upstream `/config`, default `app/static/config`), `APP_ROOT`, `STATIC_FOLDER`, `WHOOGLE_DOTENV_PATH`, `WHOOGLE_SECRET_KEY` (32+ chars, else `whoogle.key` in CONFIG_VOLUME), `WHOOGLE_USER`, `WHOOGLE_PASS`, `WHOOGLE_URL_PREFIX`, `HTTPS_ONLY`, `WHOOGLE_CSP`, `WHOOGLE_AUTOCOMPLETE`, `WHOOGLE_CONFIG_DISABLE`, `WHOOGLE_PROXY_{USER,PASS,TYPE,LOC}`, `WHOOGLE_ALT_{TW,YT,RD,MD,TL,IMG,WIKI,IMDB,QUORA,SO}`, `WHOOGLE_HTTP2`, `WHOOGLE_TOR_SERVICE` (0 skips Tor in start-tor.sh), `WHOOGLE_TOR_CONF`, `WHOOGLE_USER_AGENT`, `WHOOGLE_USER_AGENT_MOBILE`, `WHOOGLE_BUNDLE_STATIC`. Sources: `app/__init__.py`, `app/routes.py`, `app/request.py`, `app/services/http_client.py`, `app/utils/misc.py` at tag v1.2.4. Config keys: `whoogle.template.env` (`WHOOGLE_CONFIG_NEAR`, `WHOOGLE_CONFIG_COUNTRY`, `WHOOGLE_CONFIG_LANGUAGE`). |
| Ports | 5000/tcp HTTP (`EXPOSE_PORT` default 5000). `/healthz` route exists (`app/routes.py`). |
| Data/config write paths | `CONFIG_VOLUME` (upstream `/config`): `config.json`, `session/` (`SESSION_FILE_DIR`), `whoogle.key`, `bangs/bangs.json`. At import, `app/__init__.py` creates `BUILD_FOLDER` (`STATIC_FOLDER/build`) and writes CSS/JS bundles and symlinks into it (lines ~111-112, ~221-276). |
| Dependencies | None required. Tor is optional: upstream starts it, and `routes.py` reads `TOR_AVAILABLE`. |

## 2. Target layout

- `apps/whoogle/Dockerfile`
- `apps/whoogle/docker-bake.hcl`
- `apps/whoogle/settings.yaml`
- `apps/whoogle/container-test.yaml`
- `apps/whoogle/start.sh`

No `defaults/` (the app writes its own config on first start), no `etc/`, no `root/`. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base. The app tree goes to `/app/whoogle/`, matching the draft's "/app/containername" rule.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because Whoogle is a pure Python Flask/waitress app. Closest sibling: `apps/bazarr` (python base, pip-installs the app's requirements at build time into the base interpreter, `WORKDIR` and `USER apps`, `exec` start). The python base already sets `PIP_BREAK_SYSTEM_PACKAGES=1`, `PIP_NO_CACHE_DIR=1` and `PIP_ROOT_USER_ACTION=ignore`. Upstream used 3.12; 3.15 is the repo's current base, so this is a deliberate change.

## 4. Dockerfile

1. `ARG VERSION`, `ARG WHOOGLE_SHA256` (set to the computed sha256 of the tag archive, see section 1), `USER root`, `WORKDIR /app`.
2. `ENV CONFIG_VOLUME=/config EXPOSE_PORT=5000 APP_ROOT=/app/whoogle/app WHOOGLE_TOR_SERVICE=0`. Tor is not installed (see open question 10).
3. Download the tag archive to `/tmp` and verify it: `echo "${WHOOGLE_SHA256} /tmp/whoogle.tar.gz" | sha256sum -c -`.
4. `mkdir -p /app/whoogle && tar -xzf /tmp/whoogle.tar.gz -C /app/whoogle --strip-components=1`, then keep only what runs: `app/`, `misc/` (only if `app` needs it; check at build), `run`, `requirements.txt`, `whoogle.template.env`. Remove `test/`, `docs/`, `charts/`, `letsencrypt/`, `heroku.yml`, `app.json`, `docker-compose*.yaml`.
5. Install the pinned requirements into the base interpreter, as `apps/bazarr` does: `python3 -m pip install --no-cache-dir -r /app/whoogle/requirements.txt`. Pins are not changed. If a pin has no wheel for 3.15, the build fails and is recorded; do not silently change the pin.
6. Licence: `install -Dm0644 /app/whoogle/LICENSE /usr/share/licenses/whoogle/LICENSE`, then remove `/app/whoogle/LICENSE` if it is not needed at runtime.
7. `chown -R root:root /app && chmod -R 755 /app`, then `rm -rf /tmp/* /root/.cache`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
WORKDIR /app/whoogle

EXPOSE 5000
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "whoogle"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=benbusby/whoogle-search versioning=semver
  default = "1.2.4"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/benbusby/whoogle-search"
}
```

Then the default group and the four standard targets (`image`, `image-local`, `image-all`) copied from `apps/adguardhome-sync/docker-bake.hcl`. The `image` target passes `args = { VERSION = "${VERSION}" }` and the Dockerfile's `ARG VERSION` consumes it. Run `cd apps/whoogle && docker buildx bake --print`. The archived repo means Renovate is unlikely to propose a newer release, which is expected.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/benbusby/whoogle-search"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:
  - name: EXPOSE_PORT
    default: "5000"
    required: false
  - name: WHOOGLE_USER
    default: ""
    required: false
  - name: WHOOGLE_PASS
    default: ""
    required: false
  - name: WHOOGLE_URL_PREFIX
    default: ""
    required: false
  - name: WHOOGLE_SECRET_KEY
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Every name here is read by the app (section 1). `WHOOGLE_SECRET_KEY` is optional: when unset, the app generates `whoogle.key` in `/config`. No `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash

# The app writes CSS/JS bundles and symlinks into STATIC_FOLDER/build at import time.
# /app is read-only, so the static tree is copied to /tmp (ephemeral) on each start.
STATIC_DIR=/tmp/whoogle/static
mkdir -p /config "${STATIC_DIR}"
if [ ! -f "${STATIC_DIR}/settings/languages.json" ]; then
  cp -r /app/whoogle/app/static/. "${STATIC_DIR}/"
fi

export APP_ROOT=/app/whoogle/app
export STATIC_FOLDER="${STATIC_DIR}"
export CONFIG_VOLUME=/config

cd /app/whoogle
exec python3 -um app \
  --host "${ADDRESS:-0.0.0.0}" \
  --port "${PORT:-${EXPOSE_PORT:-5000}}"
```

- Idempotent. Empty `/config` works: the app creates `config.json`, `session/` and `whoogle.key` on demand.
- Nothing is written under `/app`. The `run` script is not used, because it deletes and writes files under `app/static/build`.
- `exec` for signal handling. Binds `0.0.0.0`.
- `WHOOGLE_USER`, `WHOOGLE_PASS` and `WHOOGLE_SECRET_KEY` are read from the environment by the app, not from argv, so secrets stay out of the process list.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '5000'
http:
- port: '5000'
  path: /healthz
filePaths:
- /app/whoogle/run
- /app/whoogle/requirements.txt
- /app/whoogle/app/__init__.py
- /usr/share/licenses/whoogle/LICENSE
```

- Only one port, so one tcp and one http probe.
- `/healthz` is the upstream healthcheck route. Its status is UNVERIFIED until the run.
- No `timeoutSeconds`, as in `apps/bazarr`, unless the run shows slow startup.
- The test runs with no env vars, which works: the app starts with defaults.
- The test does not call the search page, which reaches the Tor check (`TOR_AVAILABLE`). Covered in section 11 by hand.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path or behavior | Plan |
| --- | --- |
| `/whoogle` owned by user `whoogle` (uid 927) | `/app/whoogle` owned by root, read-only. Runs as `apps`. Upstream uid 927 is not kept. |
| `app/static/build` written at import (and chowned upstream) | Static tree copied to `/tmp/whoogle/static` in start.sh (section 7). |
| `/config` (config.json, session/, whoogle.key, bangs/) | `CONFIG_VOLUME=/config`. The only persistent write. |
| `/var/lib/tor` (chowned upstream), `/etc/tor/torrc` | Not present: Tor is not installed. |
| Chart security (draft): non-root no, read-only false | Target: non-root, read-only rootfs compatible. The draft's expectations are not reproduced. |

## 10. Risks, caveats and open questions

- Archived upstream, final release: Whoogle scrapes Google, and the project says Google blocks JS-free queries and no fix is planned. The container may start and serve pages but fail to return results. Decide before building whether to ship it at all. This is a product question for the user, not a build issue.
- Open question 10: Tor. Upstream runs Tor in the same container. This plan sets `WHOOGLE_TOR_SERVICE=0` and installs no Tor, which changes the upstream behavior. Confirm the user accepts that.
- `routes.py:233` does `int(os.environ.get('TOR_AVAILABLE'))`. If `TOR_AVAILABLE` is never set on the search path, this raises. Verify on the search page in section 11 and fix the real cause if it does (for example set `TOR_AVAILABLE=0` in the image), not by weakening the test.
- Python 3.15 wheels: `cryptography==46.0.7`, `pyOpenSSL==26.0.0`, `brotli==1.2.0`, `cffi==2.0.0` must have 3.15 glibc wheels. UNVERIFIED. The upstream image built them on Alpine with compilers (builder stage). If a wheel is missing, the build needs `build-essential` and `libffi-dev` (as in `apps/bazarr`) or a pin bump, which must be justified in the PR.
- Test-only pins (`pytest`, `pycodestyle`, `python-dateutil`) are installed too. Open question: filter them out of the runtime install.
- arm64 is UNVERIFIED for the same native-wheel reason. The draft's "arm64: yes" is only true for the pure source.
- Checksum for the tag archive is computed by the implementer, not published upstream. Alternative: use the sdist from PyPI, whose sha256 is published, if it contains `app/` and `run` (UNVERIFIED).
- `WHOOGLE_SECRET_KEY` is persisted in `/config/whoogle.key` when unset. Document it.
- Blockers: none in licence (MIT). The archived status is a functional blocker to decide, not a build error.

## 11. Build and test steps

```sh
cd apps/whoogle
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name whoogle-probe --read-only --tmpfs /tmp \
  -v whoogle-probe-config:/config whoogle:1.2.4
docker logs -f whoogle-probe      # expected readiness: waitress/Flask bound to 0.0.0.0:5000 (exact line UNVERIFIED)
docker exec whoogle-probe sh -c 'curl -fsS http://localhost:5000/healthz'
curl -fsS -o /dev/null -w '%{http_code}\n' "http://localhost:5000/"     # from the host, after publishing 5000
# Manual: open / and run one search to confirm the TOR_AVAILABLE path (section 10)

forgetool containers test --image whoogle:1.2.4 --config ./container-test.yaml

docker rm -f whoogle-probe; docker volume rm whoogle-probe-config
```

- Empty `/config` on the first start, then a restart on the same volume, to check idempotency.
- arm64: only if the amd64 build fails in an arm64-specific way. Otherwise say it is untested.
- Scratch containers and volumes are removed between rounds.

## 12. PR checklist

- Branch `feat/add-whoogle` from `main`. Commit and PR title `feat(whoogle): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, every section and checkbox kept, only applicable boxes checked. Notes contains `🤖 This PR is AI generated.`
- State the archived upstream status, the Tor decision, and what was not tested (arm64, Python 3.15 wheels if not built, search results). Do not tick "Built container locally" unless the build ran.
- Pre-completion: app-scoped change; bake and Dockerfile version-aligned; no `DOWNSTREAM_CHANGES.md` (not a base).
