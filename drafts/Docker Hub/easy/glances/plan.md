# glances — implementation plan
> Source: ./draft.md · Target: apps/glances/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `4.5.9` on PyPI (released 2026-11-07). The draft tag is `ubuntu-4.3.0.8-full`, which is older. |
| Renovate | `datasource=pypi depName=glances` (same style as `apps/esphome`, `apps/home-assistant`). |
| License | `LGPL-3.0-only` (PyPI `license_expression`; README says LGPL v3). Files `COPYING`, `AUTHORS`. |
| Source URL | https://github.com/nicolargo/glances |
| Download | `pip install "glances[web]==4.5.9"`; same for amd64 and arm64. Requires Python >= 3.10; PyPI classifiers list 3.10 to 3.14, not 3.15. |
| Extras (verified list) | `action, all, browser, cloud, containers, export, gpu, graph, mcp, raid, sensors, smart, snmp, sparklines, web, wifi`. Web UI and API need `web` (FastAPI, Uvicorn). |
| Native dependency | `psutil` needs Python headers and gcc if no wheel exists for the interpreter (PyPI page). The python base keeps `build-essential` and dev libs, so a source build is possible; a wheel for Python 3.15 is UNVERIFIED. |
| Checksum source | None for pip. |
| Port | 61208/tcp web UI and REST API (`EXPOSE 61209 61208` in upstream Dockerfile; 61209 is XMLRPC). Docs run it with `GLANCES_OPT="-w"`. |
| Env | `GLANCES_OPT` (upstream image CMD: `/venv/bin/python${PYTHON_VERSION} -m glances ${GLANCES_OPT}`), default usage `-w`. Password and username env vars are not documented; passwords come from `--password` (file under `~/.config/glances/glances.pwd`) or a `[passwords]` config block. |
| Config | custom file via `-C <file>`; upstream image copies a default to `/etc/glances/glances.conf`. |
| Upstream Dockerfile reviewed | `docker-files/ubuntu.Dockerfile` (stages base, build, buildminimal, buildfull, release; `full` adds `libzmq5 libvirt-clients`; base apt packages `python3 curl lm-sensors smartmontools net-tools tzdata`; runs as root, `# USER glances` commented out with the note that the Docker plugin would not work non-root). |
| Health endpoint | UNVERIFIED. Use `/` for the probe; Glances v4 also exposes a status API under `/api/4/` (path not confirmed). |

## 2. Target layout

```
apps/glances/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`: Glances runs without a config file. Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```
Why: draft says python sibling with a pip install into the venv under `/app`. Because Python 3.15 is not a declared target of Glances, the documented fallback is `ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232` (already used by 8 apps); switch if `psutil` or the app fails to build or run. Closest sibling: `apps/esphome` (single pip install of the app; `HOME=/config`). Python rules apply (`/app/venv` read-only, caches to `/tmp`).

## 4. Dockerfile

```dockerfile
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache \
    PIP_NO_CACHE_DIR=1

USER root
WORKDIR /app

RUN set -eux; \
    /app/venv/bin/pip install --no-cache-dir "glances[web]==${VERSION}"; \
    mkdir -p /usr/share/licenses/glances; \
    curl -fsSL -o /usr/share/licenses/glances/COPYING \
      "https://raw.githubusercontent.com/nicolargo/glances/v${VERSION}/COPYING"; \
    chown -R root:root /app; chmod -R 755 /app; \
    rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 61208
VOLUME /config
```
Notes:
- `COPYING` at tag `v4.5.9` returns the LGPL v3 text (read OK).
- No apt packages: the upstream base adds `lm-sensors smartmontools net-tools`, but they serve optional plugins. Add them (with pinned versions, checked against the Ubuntu 26.04 archive) only if the first version should include sensors and SMART. `tzdata` and `curl` already exist in the ubuntu base.
- Extras kept minimal (`web`). Candidate follow-ups from the verified extras list: `containers` (needs a Docker socket and group access, UID 568 will not have it), `sensors`, `smart`, `raid`, `gpu`. The draft warns that the plain pip install lacks the plugins of the upstream "full" image.
- Final `USER apps`; `COPY --chmod=0755 . /`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "glances"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=glances
  default = "4.5.9"
}

variable "LICENSE" {
  default = "LGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/nicolargo/glances"
}
```
Standard `group "default"`, `image`, `image-local` (`glances:${VERSION}`), `image-all` (amd64, arm64) as in `apps/esphome`. Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/nicolargo/glances"
ports:
  - port: 61208
    protocol: tcp
    required: true
env:
  - name: GLANCES_OPT
    default: "-w"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```
`GLANCES_OPT` is the variable the upstream image uses; here `start.sh` reads it (default must equal `-w`). `/config` is optional (only for `glances.conf` and the password file). 61209 (XMLRPC, only with `-s`) is not opened by default and is not listed. `dependencies:` none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/.cache}"
mkdir -p "${XDG_CACHE_HOME}" /config

GLANCES_OPT="${GLANCES_OPT:--w}"

ARGS=()
# optional user config, never overwritten, nothing seeded
if [ -f /config/glances.conf ]; then
  ARGS+=(-C /config/glances.conf)
fi

# GLANCES_OPT is intentionally word-split like the upstream image does
# shellcheck disable=SC2086
exec /app/venv/bin/glances "${ARGS[@]}" ${GLANCES_OPT} "$@"
```
- Idempotent, runs with empty `/config`, nothing written under `/app`, caches in `/tmp`.
- All interfaces: Glances web mode binds `0.0.0.0` by default per its `--bind` default (UNVERIFIED; the docs page read does not mention `--bind`). Verify with a connection from a second container; if it binds to localhost add `-B 0.0.0.0` to the default `GLANCES_OPT` and to settings.
- Glances log file location (`glances.log` under a temp or cache dir) is UNVERIFIED; the `XDG_CACHE_HOME=/tmp/.cache` default is meant to cover it; check with `--read-only`.
- No secrets handled; a password, if wanted, goes through the config file or `--password` flag in `GLANCES_OPT` (documented upstream, UNVERIFIED for non-root).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '61208'
  path: /
filePaths:
- /app/venv/bin/glances
```
- Probe for the single declared port (HTTP, which implies the TCP wait).
- The test runs with no env, so `GLANCES_OPT` defaults to `-w` and starts the web server.
- `timeoutSeconds` omitted (180 s minimum applies; Glances starts in seconds).
- If `/` is not 200 (e.g. it redirects), use the API route confirmed during the first run; do not weaken to a file check.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| root `~/.config/glances/glances.pwd` | `HOME=/config`, so `/config/.config/glances/` (persistent, only if a password is created) |
| `~/.cache/glances` or temp log | `XDG_CACHE_HOME=/tmp/.cache` |
| `/etc/glances/glances.conf` (baked by upstream) | optional `/config/glances.conf` via `-C` |
| `/venv` install location | `/app/venv` (read-only) |
| upstream root user | `apps` (568) |
| `/proc`, `/sys` host metrics | read only, no remap |

Draft expectations: non-root yes (the chart uses 1000; this port uses 568, which the chart must match), `readOnlyRootFilesystem: true` yes (Glances should write only to `/tmp`; UNVERIFIED), privileged no. `hostPID`/`hostNetwork` are off in the chart, so by default Glances reports container-only metrics; document in the PR. Extra persistence none (`/config` optional).

## 10. Risks, caveats and open questions

- Draft caveat: plugins (GPU, sensors, Docker, SMART, RAID) need extra Python extras and host access; first version ships `web` only.
- Draft caveat: without host namespaces only container metrics are visible. Mounting `/etc/os-release` read-only shows the host OS (upstream docs).
- Docker plugin needs the Docker socket and group membership; a non-root `apps` user will not have it. The upstream Dockerfile comments say the same ("If used, the Glances Docker plugin do not work").
- Python 3.15 is not a classifier of Glances 4.5.9 and `psutil` may have to compile; fallback base 3.14.8 (section 3).
- The draft tag (4.3.0.8) is old; this plan uses 4.5.9 (latest PyPI). The `all` extra pulls many heavy packages; not used.
- Web UI and API are unauthenticated by default; expose only internally or add a password.
- No blocker: both arches, glibc, no privileged mode needed.

## 11. Build and test steps

```sh
cd apps/glances
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create glances-probe-config
docker run --rm -d --name glances-probe --read-only --tmpfs /tmp \
  -v glances-probe-config:/config glances:4.5.9
docker logs -f glances-probe     # expect the web server start line and "Uvicorn running on http://0.0.0.0:61208" (wording UNVERIFIED)
# from a second container: curl -fsS http://glances-probe:61208/   (checks non-localhost binding)
docker rm -f glances-probe; docker volume rm glances-probe-config
forgetool containers test --image glances:4.5.9 --config ./apps/glances/container-test.yaml
```
Max 10 rounds. If the build fails on `psutil`, switch the base to Python 3.14.8 and retry from `bake --print`.

## 12. PR checklist

- [ ] Branch `feat/add-glances`; commit and PR title `feat(glances): add new container`; target `main`.
- [ ] PR template filled; only applicable boxes ticked.
- [ ] Notes: `🤖 This PR is AI generated.` plus the host-metrics and plugin limitations.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- [ ] `docker buildx bake --print` passed; `ARG VERSION` equals bake `VERSION` (`4.5.9`).
- [ ] Untested until run: build on Python 3.15, arm64, read-only start (log/cache writes), non-localhost binding, forgetool. Do not tick "Built container locally" unless done.
