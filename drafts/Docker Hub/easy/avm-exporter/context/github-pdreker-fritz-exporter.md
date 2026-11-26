# pdreker/fritz_exporter (source, Dockerfile, entry point, license)

**Source URL(s) + fetch date**
- https://github.com/pdreker/fritz_exporter (repo)
- https://github.com/pdreker/fritz_exporter/blob/09a957c03cd7c253ea8147d0aecd1a06a08b6bbe/Dockerfile (fetched as raw at that commit)
- https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/README.md
- https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/LICENSE.md
- https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/fritzexporter/__main__.py
- https://github.com/pdreker/fritz_exporter/releases/tag/fritzexporter-v4.0.3
- Not fetched successfully: `.../fritzexporter-v4.0.3/src/fritzexporter/__main__.py` and `.../src/fritzexporter/config.py` (404; the package is at the repo root); `fritzexporter/config.py` (404).
- Fetched 2026-11-26

**What it is**
- Prometheus exporter for AVM FRITZ! devices (Fritz!Box, Fritz!Repeater). Talks to the device's TR-064 API via the `fritzconnection` Python module. Multi-device support via config file.
- License: Apache License 2.0 (LICENSE.md; copyright 2019-2026 Patrick Dreker).
- Latest release `fritzexporter-v4.0.3` (titled "fritzexporter: v4.0.3", marked Latest, published 06 Nov, changelog date 2026-11-05). The only release note: a Helm chart fix so the image tracks the chart's appVersion (issue #803). Two assets listed, names not rendered; checksums not confirmed.

**Install/build steps and build deps (Dockerfile at 09a957c)**
- Stage `uv`: `docker.io/astral/uv:0.13.7` pinned by digest, `--platform=$BUILDPLATFORM`.
- Stage `build`: `python:3.14.8-alpine` pinned by digest, `--platform=$BUILDPLATFORM`. Copies `/uv` to `/usr/local/bin/uv`. WORKDIR `/app`. Copies `README.md`, `pyproject.toml`, `uv.lock`, then the `fritzexporter` directory. Runs `uv export --frozen --no-dev --no-emit-project --format requirements.txt` then `uv build --wheel`.
- Runner stage: `python:3.14.8-alpine` (same digest, target platform). ENV `PIP_NO_CACHE_DIR=true`, `PIP_DISABLE_PIP_VERSION_CHECK=true`, `FRITZ_LISTEN_ADDRESS=0.0.0.0` (a comment says a config file sets its own `listen_address`). `LABEL Name=fritzbox_exporter`. `EXPOSE 9787`. WORKDIR `/app`.
- Installs: `pip install --require-hashes --requirement requirements.txt`, then `pip install --no-deps` on the wheel. `mkdir /etc/fritz`.
- `USER 65534:65534` (nobody, matching the Helm chart). `ENTRYPOINT ["python", "-m", "fritzexporter"]`. No VOLUME, no CMD.

**Runtime deps**
- From PyPI requires_dist: `attrs<27.0,>=22.2`, `defusedxml<0.8,>=0.7.1`, `fritzconnection>=1.0.0`, `prometheus-client>=0.6.0`, `pyyaml`, `requests`. Python `>=3.14`.

**Binaries/entrypoint/CLI flags (fritzexporter/__main__.py at 4.0.3)**
- `--config` (path to config file). `--log-level` choices `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL` (default from config, else INFO per help). `--version` prints `__version__` alone and exits 0.
- Invalid configuration (`ExporterError`): logs `Invalid configuration: <msg>` at critical level, then `sys.exit(1)` (no traceback).
- Metrics: `prometheus_client.start_http_server(int(config.exporter_port), str(config.listen_address))`. Logs `Starting listener at <addr>:<port>`, then `Exporter is ready` at INFO.
- After start it waits for SIGTERM/SIGINT (skipped when `FRITZ_EXPORTER_UNDER_TEST` is set) and logs `Received <signal>, shutting down`.

**Env vars** (from README, docs and plan.md; config.py could not be fetched)
- `FRITZ_LISTEN_ADDRESS`: default `127.0.0.1` since v3.0.0 (was `0.0.0.0` before). The Docker image sets `0.0.0.0` (v4.0.0). A config file used with plain Docker must set `listen_address: 0.0.0.0`.
- `FRITZ_ALLOW_UNSAFE_MD5_PASSWORD=true`: per device; legacy MD5 login for FRITZ!OS older than 7.24.
- `FRITZ_NAME`: now defaults to the hostname (formerly `Fritz!Box`).
- Env mode supports one device only; several devices need a config file.
- Other `FRITZ_*` names from plan.md (`FRITZ_PORT`, `FRITZ_LOG_LEVEL`, `FRITZ_HOSTNAME`, `FRITZ_USERNAME`, `FRITZ_PASSWORD`, `FRITZ_PASSWORD_FILE`, `FRITZ_HOST_INFO`, `FRITZ_WIFI_CLIENT_INFO`, `FRITZ_CONNECTION_TIMEOUT`, `FRITZ_USE_TLS`, `FRITZ_DEVICE_PORT`, `FRITZ_REMOTE_ACCESS`) were NOT confirmed (config.py not fetched).
- `FRITZ_EXPORTER_CONFIG` was removed in v2.0.0 (docs).

**Ports**
- 9787 (`EXPOSE 9787`; chart uses 9787 and `exporter_port: 9787`). Metrics path `/metrics` (plan.md; not confirmed in fetched sources).

**Config files and formats**
- YAML via `--config`. Top-level `exporter` keys in the chart: `exporter_port`, `listen_address`, `devices`. Per device: `name`, `hostname`, `username`, `password` (chart); plan.md also lists `password_file`, `log_level`.
- Unknown keys, a missing password, or duplicate device names stop startup (README).
- `allow_unsafe_md5_password` per device; `host_info: true` and `wifi_client_info: true` enable per-host and per-WiFi-client metrics (docs; host info is disabled by default, slow).

**Volumes/paths and persistent data**
- None baked in. No VOLUME. The chart mounts a configmap at `/exporter/config.yaml`.
- Dockerfile creates `/etc/fritz` (unused by the entry point).

**User/UID & permissions**
- `USER 65534:65534`. Mounted config and password files must be readable by UID 65534 (README).

**Healthcheck/readiness endpoints**
- None in the image. Chart probes: tcp on the service port (liveness, readiness, startup).

**Version/release info and asset naming**
- PyPI `fritz-exporter` 4.0.3 wheel `fritz_exporter-4.0.3-py3-none-any.whl`, sdist `fritz_exporter-4.0.3.tar.gz` (see pypi-fritz-exporter.md).
- GitHub tag `fritzexporter-v4.0.3`; asset names not rendered.

**Arch support**
- Pure Python wheel (plan.md). Docker Hub page does not list arches; plan.md's "amd64, arm/v6, v7, arm64" image claim not confirmed here.

**Gotchas**
- Invalid config exits 1 (documented above). An env-only run without credentials is therefore not a running server (plan.md section 10 blocker).
- Passwords over 32 characters give 401 (Fritz!OS caps; docs). Use 32 or fewer.
- Prometheus is a separate stack; Grafana cannot read the exporter directly (docs).
- Old libseccomp on the Docker host can cause a Python time-init error on Raspberry Pi (docs).
