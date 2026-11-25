# searxng — implementation plan
> Source: ./draft.md · Target: apps/searxng/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream publishes no GitHub release (`/releases/latest` 404). Docker Hub `searxng/searxng` tags are `YYYY.MM.DD-<shortsha>`; newest version tag `2026.11.23-a7163d091` (Hub, 2026-11-23), plus `latest`. Draft pin: commit `1ebea4a073ec6011bae25c042d97308278184c83` (Hub tag `2026.11.20-1ebea4a07`). Decide in the build round whether to pin the newest tag's commit (full SHA UNVERIFIED; GitHub tag API was rate-limited) or the draft commit. |
| Renovate | Candidate: `// renovate: datasource=docker depName=docker.io/searxng/searxng versioning=regex:^(?<major>\d{4})\.(?<minor>\d{2})\.(?<patch>\d{2})-[0-9a-f]+$` (UNVERIFIED that renovate regex versioning accepts this form in this repo; check a sibling with `versioning=regex`). Fallback: git-refs on `https://github.com/searxng/searxng`. |
| License | AGPL-3.0 (GitHub repo SPDX `AGPL-3.0`). Upstream image label: `AGPL-3.0-or-later`. Bake `LICENSE` should be `AGPL-3.0-or-later` to match the image label and the `apps/python` sibling convention. |
| Source URL | https://github.com/searxng/searxng (docs: https://docs.searxng.org/) |
| Download | Source archive `https://github.com/searxng/searxng/archive/${VERSION}.tar.gz` (VERSION = pinned commit SHA). No binary. Interpreted app installed with uv. |
| Per-arch | Source install, so both amd64 and arm64 are built from the same source. Hub manifests per arch not inspected (UNVERIFIED). |
| Checksum source | None published. The archive is content-addressed by the commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/searxng/searxng/1ebea4a073ec6011bae25c042d97308278184c83/container/Dockerfile: builder on `docker.io/searxng/base:searxng-builder`, runs `uv venv` and `uv pip install --requirements requirements.txt --requirements requirements-server.txt`; final on `docker.io/searxng/base:searxng`, uid/gid 977, `EXPOSE 8080`, `VOLUME` for config and data, `ENTRYPOINT /usr/local/searxng/entrypoint.sh`. |
| Base images | The upstream base is Void Linux (https://raw.githubusercontent.com/searxng/base/main/Dockerfile, also codeberg). We do not use it; we use the ContainerForge `python` sibling. |
| Entrypoint | https://raw.githubusercontent.com/searxng/searxng/master/container/entrypoint.sh: checks config and data dirs; copies `settings.template.yml` to `$__SEARXNG_CONFIG_PATH/settings.yml` when missing and replaces `ultrasecretkey` with a random value; chowns volumes to `searxng:searxng` when root; maps `SEARXNG_PORT` to `GRANIAN_PORT`; then `exec /usr/local/searxng/.venv/bin/granian searx.webapp:app`. |
| Template settings | https://raw.githubusercontent.com/searxng/searxng/master/container/settings.template.yml: `use_default_settings: true`, `server.secret_key: "ultrasecretkey"`, `server.image_proxy: true`. |
| Env vars (real) | Upstream settings comments (https://raw.githubusercontent.com/searxng/searxng/master/searx/settings.yml): `SEARXNG_PORT`, `SEARXNG_BIND_ADDRESS` (default `127.0.0.1:8888` in file), `SEARXNG_SECRET`, `SEARXNG_BASE_URL`. Image ENV: `GRANIAN_HOST="::"`, `GRANIAN_PORT="8080"`, `GRANIAN_INTERFACE=wsgi`, `GRANIAN_WORKERS_KILL_TIMEOUT=30s`, `GRANIAN_BLOCKING_THREADS=4`, `GRANIAN_BLOCKING_THREADS_IDLE_TIMEOUT=5m`, `GRANIAN_WEBSOCKETS=false`. Chart names `BIND_ADDRESS`, `INSTANCE_NAME`, `BASE_URL` are not upstream names (UNVERIFIED whether the app reads them). Use the `SEARXNG_*` names. |
| Ports | 8080/tcp (`EXPOSE 8080`, `GRANIAN_PORT`). |
| Config path | `__SEARXNG_CONFIG_PATH=/etc/searxng` upstream; settings file `$__SEARXNG_CONFIG_PATH/settings.yml`. |
| Data path | `__SEARXNG_DATA_PATH=/var/cache/searxng` upstream (cache). |
| Python deps | https://raw.githubusercontent.com/searxng/searxng/master/requirements.txt: flask 3.1.3, lxml 6.1.3, pyyaml 6.0.3, curl_cffi 0.17.0, valkey 6.1.1 (client only), msgspec, typer and others. `requirements-server.txt` (granian) was not fetched (UNVERIFIED content). |
| Chart | TrueCharts values (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/searxng/values.yaml): port 8080, persistence `config` at `/etc/searxng`, probes `/healthz`, `capabilities.add SETUID, SETGID`, `disableS6Caps`. |
| Dependencies | None required. Valkey is optional and only a client library is installed; no server is needed. |

## 2. Target layout

- `apps/searxng/Dockerfile`
- `apps/searxng/docker-bake.hcl`
- `apps/searxng/settings.yaml`
- `apps/searxng/container-test.yaml`
- `apps/searxng/start.sh` (replaces upstream `entrypoint.sh`; implements the seeding and secret rules below)
- `apps/searxng/defaults/settings.template.yml` (copied from upstream `container/settings.template.yml`, with `ultrasecretkey` kept as the placeholder for `sed`). Needed because the template is seeded into `/config` on first start (reason: `start.sh` seeds it only when missing).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. It provides `/app/venv` (read-only at runtime) and `apt-get` for system packages. Closest sibling: `apps/bazarr` (python app, `uv pip install` from source, `USER apps`). The searxng upstream base (Void) is not used.

Python 3.15 compatibility of searxng's pinned deps is UNVERIFIED; the build round will tell.

## 4. Dockerfile

1. Single stage on the python base, as in `apps/bazarr`: `uv` installs into `/app/venv`, which the base already creates. No separate build stage is needed.
2. `ARG VERSION`, `ARG SOURCE_REF` (full commit SHA, see section 5), `USER root`, `ENV UV_CACHE_DIR=/tmp/uv PIP_NO_CACHE_DIR=1`.
3. Build dependencies (apt, only if needed for wheels that have no binary for the arch; UNVERIFIED list): `build-essential libffi-dev libxml2-dev libxslt1-dev libssl-dev`. Remove after install if added. Do not reinstall what the base has.
4. Source: `curl -fL https://github.com/searxng/searxng/archive/${SOURCE_REF}.tar.gz | tar xz -C /tmp/searxng --strip-components=1`.
5. Install into the existing venv: `uv pip install --python /app/venv/bin/python --requirements /tmp/searxng/requirements.txt --requirements /tmp/searxng/requirements-server.txt` (requirements-server.txt contents UNVERIFIED; upstream installs it).
6. Copy app: `mkdir -p /app/searxng && cp -r /tmp/searxng/searx /app/searxng/searx`; `cp /tmp/searxng/container/settings.template.yml /app/searxng/settings.template.yml` (or use `defaults/`, see layout). `compileall` optional (upstream does it for speed; not required).
7. Version marker: write `/app/searxng/searx/version_frozen.py` only if upstream's `version_frozen.py` is missing from the tarball (UNVERIFIED; upstream copies `./searx/version_frozen.py` from the repo). Set `__SEARXNG_VERSION` from `ARG VERSION`.
8. Licence: `COPY --from`? Not needed; `cp /tmp/searxng/LICENSE /usr/share/licenses/searxng/LICENSE`.
9. Cleanup: `rm -rf /tmp/searxng /tmp/uv`, `apt-get clean`, `rm -rf /var/lib/apt/lists/*`.
10. Permissions: `chown -R root:root /app/searxng && chmod -R 755 /app/searxng`.
11. Final: `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`.
12. ENV (set in Dockerfile):
    - `__SEARXNG_VERSION=${VERSION}`, `__SEARXNG_CONFIG_PATH=/config`, `__SEARXNG_DATA_PATH=/tmp/searxng` (ephemeral cache, see section 9).
    - `GRANIAN_PROCESS_NAME=searxng GRANIAN_INTERFACE=wsgi GRANIAN_HOST=0.0.0.0 GRANIAN_PORT=8080 GRANIAN_WEBSOCKETS=false GRANIAN_BLOCKING_THREADS=4 GRANIAN_WORKERS_KILL_TIMEOUT=30s GRANIAN_BLOCKING_THREADS_IDLE_TIMEOUT=5m`. `GRANIAN_HOST` is `0.0.0.0` here, not upstream's `::`, so the app does not need IPv6 inside the container (decision recorded in section 10).
    - `SEARXNG_SETTINGS_PATH=/config/settings.yml` (UNVERIFIED name: upstream sets `__SEARXNG_SETTINGS_PATH`; the build round must confirm which one `searx/` reads. Set both if needed).
    - `SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt` (the python base already provides CA certs; keep if present).
13. `EXPOSE 8080`, `VOLUME /config`, `ENTRYPOINT ["/start.sh"]` (or `CMD` via start.sh; match `apps/bazarr`'s `start.sh` pattern).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "searxng"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/searxng/searxng versioning=regex:^(?<major>\d{4})\.(?<minor>\d{2})\.(?<patch>\d{2})-[0-9a-f]+$
  default = "2026.11.23-a7163d091"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/searxng/searxng"
}

group "default" {
  targets = ["image-local"]
}
```

Plus the four standard targets copied from `apps/bazarr/docker-bake.hcl`. Important: `VERSION` here is the Hub tag, but the Dockerfile fetches the source by commit. Map it: the Dockerfile takes `ARG SOURCE_REF` (the full commit SHA of the tag) and `ARG VERSION` (the tag). Set `SOURCE_REF` in bake with its own renovate-free default (commit SHA, UNVERIFIED full SHA of `a7163d091`). If the full SHA cannot be confirmed, use the draft commit and keep `VERSION` as the draft's tag `2026.11.20-1ebea4a07`, which matches the commit. Choose one of these and record it in the PR body.

Validate with `docker buildx bake --print` from `apps/searxng/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/searxng/searxng"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: SEARXNG_PORT
    default: "8080"
    required: false
  - name: SEARXNG_BIND_ADDRESS
    default: "0.0.0.0"
    required: false
  - name: SEARXNG_SECRET
    default: ""
    required: false
  - name: SEARXNG_BASE_URL
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Notes: `SEARXNG_SECRET` has an empty default, so `start.sh` must generate one on first start (see section 7). `SEARXNG_BIND_ADDRESS` is read by upstream (settings comment); the chart's `BIND_ADDRESS` is dropped. `INSTANCE_NAME` is not listed (UNVERIFIED that upstream reads it).

## 7. start.sh

Rules from `start-script.instructions.md`: idempotent, seed only when missing, write only to `/config` and `/tmp`, `exec` the final process, bind all interfaces.

```bash
#!/usr/bin/env bash
set -eu

CONFIG_DIR="${__SEARXNG_CONFIG_PATH:-/config}"
SETTINGS="${CONFIG_DIR}/settings.yml"
TEMPLATE="/app/searxng/settings.template.yml"

mkdir -p "${CONFIG_DIR}"

# Seed settings only when missing (never overwrite user state).
if [ ! -s "${SETTINGS}" ]; then
    cp "${TEMPLATE}" "${SETTINGS}"
    # Replace the public placeholder secret with a random one, once.
    sed -i "s/ultrasecretkey/$(head -c 24 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')/" "${SETTINGS}"
fi

# SEARXNG_PORT must be numeric; an invalid value is ignored (upstream behaviour).
case "${SEARXNG_PORT:-}" in
    '') ;;
    *[!0-9]*) unset SEARXNG_PORT ;;
    *) export GRANIAN_PORT="${SEARXNG_PORT}" ;;
esac

export SEARXNG_SETTINGS_PATH="${SETTINGS}"
export GRANIAN_HOST="${GRANIAN_HOST:-0.0.0.0}"
export GRANIAN_PORT="${GRANIAN_PORT:-8080}"

exec /app/venv/bin/granian searx.webapp:app
```

Rules this implements:
- Empty `/config` works: the template is copied; no other state is needed.
- Restarts do not overwrite the file or the secret.
- `SEARXNG_SECRET` (if set) overrides the file's key through upstream's env override (UNVERIFIED mechanism; the build round must confirm by checking that `searx` reads `SEARXNG_SECRET`). If the env is empty, the file's random key is used.
- `SEARXNG_BASE_URL` and `SEARXNG_BIND_ADDRESS` are applied by upstream from env (settings comments).
- No write to `/app`. Caches go to `/tmp` (`__SEARXNG_DATA_PATH`, `UV_CACHE_DIR`).
- The ubuntu/python base may not provide `base64` or `head` from coreutils: both are in coreutils (provided by the ubuntu base, UNVERIFIED that the minimal base includes them).
- Upstream's `update-ca-certificates` and `chown` steps are not reproduced: the ContainerForge base handles CA certs, and `/config` is owned by `apps` at runtime (check `COPY --chmod`/ownership in the round).

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
- /app/venv/bin/granian
- /app/searxng/searx/webapp.py
- /app/searxng/settings.template.yml
- /usr/share/licenses/searxng/LICENSE
```

- `timeoutSeconds: 120` because the first start compiles and loads Python modules. A probe on `/healthz` is UNVERIFIED (upstream does not document it in fetched files; the chart uses it). Use `/` for the HTTP probe until `/healthz` is confirmed.
- The test runs with no env vars, so `SEARXNG_SECRET` is empty and the seeded random key is used (the default code path). The `SEARXNG_SECRET` path is not run by the test: add `filePaths` only for files, and run the env path yourself per the protocol (step 3 with `-e SEARXNG_SECRET=...`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/etc/searxng` (config, `settings.yml`) | `/config` (`__SEARXNG_CONFIG_PATH=/config`). Persistent. |
| `/var/cache/searxng` (cache) | `/tmp/searxng` (`__SEARXNG_DATA_PATH`). Ephemeral cache: the rule says caches go to `/tmp`. |
| `/usr/local/searxng` (app, root-owned 0555 upstream) | `/app/searxng` (root-owned 755, not writable at runtime). |
| Python bytecode / uv cache | `UV_CACHE_DIR=/tmp/uv` at build; `PYTHONDONTWRITEBYTECODE=1` from the base. |
| Upstream runs as uid 977 and the chart runs as root with `SETUID`/`SETGID` | Runtime is `USER apps`; no capabilities needed. The chart's root and capability overrides are not carried over. |

Security expectations from the draft (read-only rootfs possible; non-root no; capabilities SETUID/SETGID) are replaced: runtime is non-root and read-only-rootfs capable with `/config` and `/tmp` writable only.

## 10. Risks, caveats and open questions

- Version: the Hub tag and the source commit must match. Record the mapping (`VERSION` tag and `SOURCE_REF` commit) in `docker-bake.hcl` and the PR.
- `requirements-server.txt` and `granian` content: not fetched. Confirm the pinned granian version in the build round.
- Python 3.15 compatibility of `curl_cffi`, `lxml` and other binary wheels: UNVERIFIED for arm64 and amd64. Build from source is a fallback.
- `GRANIAN_HOST`: upstream sets `::`. This plan uses `0.0.0.0` for IPv4-only hosts. Confirm that `::` is not required by the chart's probes.
- Secret: the template key is public (`ultrasecretkey`). The random replacement only happens when `settings.yml` is missing. If `SEARXNG_SECRET` is set, verify in the round that it overrides the file key.
- `/healthz`: UNVERIFIED in upstream source. Use `/` for the test.
- Public engines can be blocked, so results may be empty without tuning. This is a documentation note only, not a build blocker.
- Blockers: none known for the build. Runtime engines depend on the network.

## 11. Build and test steps

From `apps/searxng/`:

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty `/config`, read-only:
   ```sh
   docker volume create searxng-probe-config
   docker run --rm -d --name searxng-probe --read-only --tmpfs /tmp \
     -v searxng-probe-config:/config searxng:<version>
   docker logs -f searxng-probe   # expect granian to report the listening address on 8080
   ```
   Pass: the container stays up, logs a listening line, no traceback. Then `docker rm -f searxng-probe; docker volume rm searxng-probe-config`.
4. Restart on the same volume to confirm the secret is kept: `docker run ... -v searxng-probe-config:/config` again, then `grep server: -A2 /config/settings.yml` (through `docker run --rm` with the volume) and compare the key.
5. Secret override: run once with `-e SEARXNG_SECRET=test-secret` and confirm the app starts (UNVERIFIED that the key is applied; check the log).
6. `forgetool containers test --image searxng:<version> --config ./container-test.yaml`. If `forgetool` is unavailable, check port 8080 and `/` by hand.
7. arm64 is only built if step 2 failed on arm64 (protocol rule); otherwise note it as untested.

## 12. PR checklist

- Branch `feat/add-searxng` from `main`; commit `feat(searxng): add new container`; PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md` with every section and checkbox kept; tick only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; the `license/cla` check shows status.
- Say what was not tested: arm64 build, `SEARXNG_SECRET` override path (unless step 5 ran), restart path (unless step 4 ran), the upstream test suite, and Python 3.15 compatibility of all wheels.
- No `DOWNSTREAM_CHANGES.md` (searxng is not a `FROM` base).
