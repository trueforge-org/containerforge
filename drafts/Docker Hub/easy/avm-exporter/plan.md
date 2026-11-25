# avm-exporter — implementation plan
> Source: ./draft.md · Target: apps/avm-exporter/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Latest stable | 4.0.3 (PyPI upload 2026-11-06, wheel + sdist, not yanked). Draft says release tag `fritzexporter-v4.0.3`; the plain version is `4.0.3`. |
| PyPI package | `fritz-exporter` (the draft calls it `fritz_exporter`; same normalized name) |
| Renovate | `datasource=pypi depName=fritz-exporter` |
| License | Apache-2.0 (PyPI SPDX expression; license file `LICENSE.md`) |
| Source | https://github.com/pdreker/fritz_exporter (docs https://pdreker.github.io/fritz_exporter/) |
| Python requirement | `>=3.14`, so the current python 3.15.2 base is allowed |
| Dependencies | attrs, defusedxml, fritzconnection, prometheus-client, pyyaml, requests |
| Per-arch artifact | pure Python wheel, same for amd64 and arm64 (upstream publishes amd64, arm/v6, v7, arm64 images) |
| Checksum | none published separately; pin `==4.0.3` |
| Upstream Dockerfile reviewed | https://github.com/pdreker/fritz_exporter/blob/09a957c03cd7c253ea8147d0aecd1a06a08b6bbe/Dockerfile (alpine python 3.14.8; wheel built with uv; `ENV FRITZ_LISTEN_ADDRESS=0.0.0.0`; `EXPOSE 9787`; `ENTRYPOINT python -m fritzexporter`; user 65534; creates `/etc/fritz`) |
| Entry | `python -m fritzexporter [--config PATH] [--log-level LVL] [--version]` (from `__main__.py`) |
| Port | 9787/tcp (`exporter_port`/`FRITZ_PORT`, default 9787, allowed range 1024-65535) |
| Env vars (config.py and docs) | `FRITZ_LISTEN_ADDRESS` (default `127.0.0.1`), `FRITZ_PORT`, `FRITZ_LOG_LEVEL`, `FRITZ_HOSTNAME` (default `fritz.box`), `FRITZ_NAME`, `FRITZ_USERNAME`, `FRITZ_PASSWORD`, `FRITZ_PASSWORD_FILE`, `FRITZ_HOST_INFO`, `FRITZ_WIFI_CLIENT_INFO`, `FRITZ_CONNECTION_TIMEOUT`, `FRITZ_USE_TLS`, `FRITZ_DEVICE_PORT`, `FRITZ_REMOTE_ACCESS`, `FRITZ_ALLOW_UNSAFE_MD5_PASSWORD`. Env mode supports exactly one device; several devices need a config file. |
| Startup behaviour | With no `FRITZ_USERNAME` and no password (and no `--config`) the exporter logs "Invalid configuration" and **exits with status 1**. An empty config file also exits 1. |
| Config file | YAML via `--config`; keys `exporter_port`, `listen_address`, `log_level`, `devices[]` (`name`, `hostname`, `username`, `password` or `password_file`, ...). Unknown keys are rejected. Passwords longer than 32 chars give 401. |
| Metrics path | `/metrics` (`__main__.py` uses `prometheus_client.start_http_server`) |

## 2. Target layout

```
apps/avm-exporter/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.example.yaml   # example only, seeded into /config when missing
```

No `root/`, no `DOWNSTREAM_CHANGES.md`. Nearest siblings: `apps/redis-exporter` (exporter, port probe), `apps/pyload-ng` and `apps/bazarr` (pip into python base).

## 3. Base image

```
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```

Pure Python, requires >=3.14, so the standard python base fits. Fallback if a dependency lacks cp315 wheels: use `python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232` (used by 8 other apps) with a comment.

## 4. Dockerfile

1. `FROM` above, `ARG VERSION`, `USER root`.
2. No apt packages (pure wheels; pyyaml has wheels, if not add `build-essential libyaml-dev` for that RUN and purge).
3. ```dockerfile
   RUN /app/venv/bin/pip install --no-cache-dir "fritz-exporter==${VERSION}" \
       && mkdir -p /usr/share/licenses/avm-exporter \
       && curl -fsSL -o /usr/share/licenses/avm-exporter/LICENSE.md \
            "https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v${VERSION}/LICENSE.md" \
       && chown -R apps:apps /app && chmod -R 755 /app && rm -rf /root/.cache /tmp/*
   ```
   `LICENSE.md` exists at tag `fritzexporter-v4.0.3` (checked 2026-11-25). Do not use a shell heredoc inside the continued `RUN` line; it breaks the Dockerfile parser.
4. `ENV FRITZ_LISTEN_ADDRESS=0.0.0.0` (as upstream; required because the app defaults to 127.0.0.1) and `ENV HOME=/config`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9787`, `VOLUME /config`, `WORKDIR /config`. No ENTRYPOINT (base tini entrypoint runs `/start.sh`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "avm-exporter" }
variable "VERSION" {
  // renovate: datasource=pypi depName=fritz-exporter
  default = "4.0.3"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/pdreker/fritz_exporter" }
```

Copy the target layout of `apps/bazarr/docker-bake.hcl` (4 standard targets plus default group, `image-all` for amd64 and arm64). Run `docker buildx bake --print`.

## 6. settings.yaml

Schema header and `schema_version: 1`, `upstream_env_url: "https://github.com/pdreker/fritz_exporter"`.

- ports: `9787` tcp, `required: false`.
- env (names exactly as the app reads them; defaults match start.sh):
  - `TZ` `Etc/UTC`
  - `FRITZ_LISTEN_ADDRESS` `0.0.0.0`
  - `FRITZ_PORT` `9787`
  - `FRITZ_LOG_LEVEL` `INFO`
  - `FRITZ_HOSTNAME` `fritz.box`
  - `FRITZ_NAME` `""`
  - `FRITZ_USERNAME` `""` (required for env mode, not for config-file mode, so `required: false`)
  - `FRITZ_PASSWORD` `""`
  - `FRITZ_PASSWORD_FILE` `""`
  - `FRITZ_HOST_INFO` `false`, `FRITZ_WIFI_CLIENT_INFO` `false`
  - `FRITZ_DEVICE_PORT` `""`, `FRITZ_REMOTE_ACCESS` `""` (read by `config.py`; unset means the app default)
  - `FRITZ_CONNECTION_TIMEOUT` `10`, `FRITZ_USE_TLS` `false`, `FRITZ_ALLOW_UNSAFE_MD5_PASSWORD` `false` (defaults from config.py: timeout 10, TLS off; others UNVERIFIED but they are only passed through when set)
  - Optional: `FRITZ_CONFIG_FILE` (our own name, read by start.sh, default `/config/config.yaml`).
- volumes: `/config` (`required: false`; only needed for the config-file mode, nothing is persisted).
- dependencies: none (needs an external FRITZ!Box with TR-064, not a container).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
CONFIG_FILE="${FRITZ_CONFIG_FILE:-/config/config.yaml}"
[ -f /config/config.example.yaml ] || cp /defaults/config.example.yaml /config/config.example.yaml
if [ -s "${CONFIG_FILE}" ]; then
  echo "Using config file ${CONFIG_FILE}"
  exec /app/venv/bin/python -m fritzexporter --config "${CONFIG_FILE}" "$@"
fi
if [ -z "${FRITZ_USERNAME:-}" ] || { [ -z "${FRITZ_PASSWORD:-}" ] && [ -z "${FRITZ_PASSWORD_FILE:-}" ]; }; then
  echo "No ${CONFIG_FILE} and no FRITZ_USERNAME/FRITZ_PASSWORD(_FILE): the exporter will refuse to start." >&2
fi
exec /app/venv/bin/python -m fritzexporter "$@"
```

- Env mode needs no mapping: the app reads `FRITZ_*` itself. Password is never put on the command line.
- `FRITZ_LISTEN_ADDRESS` default comes from the Dockerfile ENV; config-file mode ignores it, so the example config must contain `listen_address: 0.0.0.0` (documented in the example and upstream docs).
- `defaults/config.example.yaml`: `exporter_port: 9787`, `listen_address: 0.0.0.0`, `log_level: INFO`, `devices:` with one commented example (`name`, `hostname: fritz.box`, `username`, `password_file: /config/password`). It is named `.example` so it is never picked up as the real config (an empty or placeholder real config would exit 1).
- No writes to `/app`; no caches needed.

## 8. container-test.yaml

The test runs without env vars and the exporter exits with code 1 in that case (verified in `__main__.py`/`config.py`), so a `tcp`/`http` probe on 9787 cannot pass. Do not seed fake credentials to force it. Plan:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
mainRunner:
  enabled: false

runners:
- entrypoint: test -f /app/venv/bin/python
- entrypoint: test -f /defaults/config.example.yaml
- entrypoint: test -f /usr/share/licenses/avm-exporter/LICENSE.md
- entrypoint: /app/venv/bin/python -m fritzexporter --version
  expectedOutput: "4.0.3"
```

No top-level `filePaths`: the forgetool schema says `mainRunner.enabled: false` skips all main-runner checks, including `filePaths`, so the file checks are runners. The `--version` output is the plain version (`print(__version__)`); confirm the string on the first build.

(Same `mainRunner` + `runners` shape as `apps/bookstack/container-test.yaml`; `runners` syntax checked against the forgetool schema.) This is a deviation from "probe every port"; justify it in the PR. The port path is exercised by hand in section 11 with env vars set. `--version` exiting 0 is verified in `__main__.py`.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes nothing at runtime except reading config; `/etc/fritz` (upstream config dir) is not needed. Config comes from env or `/config`.
- Upstream already runs as non-root 65534; ours runs as `apps` 568. Mounted config and password files must be readable by UID 568 (chart: `fsGroup`/file mode).
- Draft expectation: non-root yes, read-only yes, not privileged, config via configmap at `/exporter/config.yaml`. Reconcile: mount the configmap at `/config/config.yaml` (or set `FRITZ_CONFIG_FILE=/exporter/config.yaml`). No `/data`.
- Python bytecode and pip caches are off in the base; nothing uses `/tmp`.

## 10. Risks, caveats and open questions

- **Decision needed (blocker):** the exporter exits 1 without credentials (verified). `container-test.instructions.md` says an image MUST still start without env vars, and the build protocol requires the container to stay running on an empty `/config`. A maintainer must either accept this exception, or have `start.sh` log the missing settings and idle (`exec sleep infinity`, as `apps/duckdns` does) when unconfigured. Until decided, sections 7 and 8 describe the exit-1 variant, which does not pass protocol step 3.
- Needs a FRITZ!Box with TR-064 enabled and a dedicated user; password length max 32.
- Config file must set `listen_address: 0.0.0.0` or the port is unreachable from other pods (verified in docs).
- cp315 wheels for pyyaml/other deps: UNVERIFIED, fall back to python 3.14.8 base if needed.
- Draft links the GitHub release `fritzexporter-v4.0.3` as the binary; we deliberately use PyPI instead (same artifact, simpler renovate).
- App name `avm-exporter` follows the draft/chart; upstream project name is `fritz_exporter`.
- No blockers: glibc, amd64+arm64, no GPU, no privileges.

## 11. Build and test steps

```sh
cd apps/avm-exporter
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
# 1) no env: expect the "Invalid configuration" message and exit code 1 (documented behaviour)
docker run --rm --read-only --tmpfs /tmp -v avm-exporter-probe-config:/config avm-exporter:4.0.3
# 2) env mode with dummy credentials (the exporter starts and serves even if the box is unreachable: UNVERIFIED, check log)
docker run --rm -d --name avm-exporter-probe --read-only --tmpfs /tmp -v avm-exporter-probe-config:/config \
  -e FRITZ_USERNAME=test -e FRITZ_PASSWORD=test avm-exporter:4.0.3
docker logs -f avm-exporter-probe   # expect "Exporter is ready" (log line in __main__.py) and the listen address 0.0.0.0:9787
curl -s http://<container-ip>:9787/metrics | head   # from another container, not localhost
docker rm -f avm-exporter-probe; docker volume rm avm-exporter-probe-config
forgetool containers test --image avm-exporter:4.0.3 --config ./apps/avm-exporter/container-test.yaml
```

Also test config-file mode with a file in the volume. Max 10 rounds, clean up scratch resources.

## 12. PR checklist

- Branch `feat/add-avm-exporter`, commit and PR title `feat(avm-exporter): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, tick "New container/image" and only the boxes that apply; `🤖 This PR is AI generated.` in Notes.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Notes: exits without credentials by design; test is runner-based for that reason; env-only supports one device.
- Untested until run: arm64, cp315 wheels, exporter behaviour with an unreachable FRITZ!Box, license path in wheel, `/metrics` path.
- Checklist: app-scoped change, instructions read, VERSION aligned (4.0.3), rootless and read-only, empty `/config` works, `bake --print` run, no DOWNSTREAM file.
