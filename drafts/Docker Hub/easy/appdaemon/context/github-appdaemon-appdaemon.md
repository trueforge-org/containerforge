# AppDaemon/appdaemon (source, Dockerfile, start.sh, example config, license)

**Source URL(s) + fetch date**
- https://github.com/AppDaemon/appdaemon (repo; README via raw tag 4.5.16/README.md)
- https://github.com/AppDaemon/appdaemon/blob/239dd4b130f98a8053058fbe82d6cce9d62e919d/Dockerfile (fetched as raw at that commit)
- https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/scripts/start.sh
- https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/conf/appdaemon.yaml.example
- https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/LICENSE.md
- https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/README.md
- Fetched 2026-11-26

**What it is**
- "Apps for the Home Assistant home automation package." Described as a loosely coupled, multi-threaded, sandboxed Python execution environment for home automation (Home Assistant, MQTT). Includes the HADashboard dashboard.
- License: Apache License 2.0 (LICENSE.md, version January 2004).
- Latest version 4.5.16 (see pypi-appdaemon.md).

**Install/build steps and build deps (upstream Dockerfile, commit 239dd4b)**
- Base: `python:3.12-alpine3.23` (pinned with digest, alias `base`). `ARG PYTHON_RELEASE=3.12` must match the tag.
- Builder: `apk add uv`. On `TARGETARCH=arm` only: `git build-base cython linux-headers rust cargo` (for building orjson and uvloop). Env `UV_LOCKED=true`, `UV_COMPILE_BYTECODE=true`, `UV_LINK_MODE=copy`, `UV_PROJECT_ENVIRONMENT=/usr/local`, `UV_SYSTEM_PYTHON=true`, `UV_NO_MANAGED_PYTHON=true`, `CARGO_NET_GIT_FETCH_WITH_CLI=true`.
- Install: `uv sync --inexact --no-install-project --no-dev --no-editable` (with `uv.lock` and `pyproject.toml` bind-mounted); `uv pip install /dist/*.whl`.
- Runtime stage: `apk --no-cache add curl` (for healthchecks); `uv` also installed in the runtime; `COPY ./conf /opt/conf`; `COPY ./scripts/start.sh /start.sh`; `COPY --from=builder /usr/local /usr/local`.
- `EXPOSE 5050`; `VOLUME /conf` and `VOLUME /certs`; `WORKDIR /conf`; `ENTRYPOINT ["/start.sh"]`; no `USER` (runs as root); no `CMD`; no `HEALTHCHECK`.
- Upstream is Alpine/musl. ContainerForge uses its python base (plan.md), so the apk/musl path does not carry over.

**Runtime deps**
- Python (`>=3.10,<3.15` per PyPI; upstream image uses 3.12), `curl`, `uv` (upstream).

**Binaries/entrypoint/CLI flags**
- Upstream `/start.sh` (verbatim logic, 4.5.16):
  - `CONF=/conf`, `CONF_SRC=/opt/conf`.
  - If neither `appdaemon.yaml` nor `appdaemon.toml` in `$CONF`: `cp $CONF_SRC/appdaemon.yaml.example $CONF/appdaemon.yaml`.
  - If `$CONF/apps` is missing: `cp -r $CONF_SRC/apps $CONF/apps`. If neither `apps.yaml` nor `apps.toml`: `cp $CONF_SRC/apps/apps.yaml.example $CONF/apps/apps.yaml`.
  - If `$CONF/dashboards` is missing: `cp -r $CONF_SRC/dashboards $CONF/dashboards`.
  - Env applied with `sed -i` on every start (only when set): `HA_URL` -> `      ha_url:`; `TOKEN` -> `      token:`; MQTT block (`MQTT_NAMESPACE`, `MQTT_CLIENT_HOST`, `MQTT_CLIENT_USER`, `MQTT_CLIENT_PASSWORD`, only when all four set; inserts an MQTT plugin before `http:`); `HA_CERT_VERIFY` -> `      cert_verify:`; `DASH_URL` -> `  url:` (or inserts a `HADashboard:` block); `TIMEZONE` -> `  time_zone:`; `LATITUDE` -> `  latitude:`; `LONGITUDE` -> `  longitude:`; `ELEVATION` -> `  elevation:`.
  - Installs `system_packages.txt` found under `$CONF` via `apk add`.
  - Extends `PYTHONPATH` with all `site-packages` under `/usr/lib`.
  - Installs `requirements.txt` found under `$CONF` via `uv pip install --upgrade -r`.
  - Final line: `exec uv run --frozen appdaemon -c $CONF "$@"`.
- Note: the final command is `uv run --frozen appdaemon`, not a bare `appdaemon`.
- Env vars read by upstream start.sh: `HA_URL`, `TOKEN`, `MQTT_NAMESPACE`, `MQTT_CLIENT_HOST`, `MQTT_CLIENT_USER`, `MQTT_CLIENT_PASSWORD`, `HA_CERT_VERIFY`, `DASH_URL`, `TIMEZONE`, `LATITUDE`, `LONGITUDE`, `ELEVATION`, `PYTHONPATH`.

**Env vars** (see the list above; upstream docs add only `HA_URL` and `TOKEN` as the required pair in Docker usage)

**Ports**
- 5050 (`EXPOSE 5050`; `http: url: http://0.0.0.0:5050` in the example config).

**Volumes/paths and persistent data**
- `/conf`: config, `apps/`, `dashboards/`, `requirements.txt`, `system_packages.txt` (upstream). `/certs`: custom HA certificates (upstream volume).
- `-v /etc/localtime:/etc/localtime:ro` is the upstream timezone fix (docs).

**User/UID & permissions**
- Upstream runs as root (no USER). The docs say nothing about UID or permissions.

**Config files and formats (conf/appdaemon.yaml.example, verbatim at 4.5.16)**
```yaml
appdaemon:
  latitude: 0
  longitude: 0
  elevation: 30
  time_zone: Europe/Berlin
  plugins:
    HASS:
      type: hass
      ha_url:
      token:
      cert_verify: True
http:
  url: http://0.0.0.0:5050
admin:
api:
hadashboard:
```

**Healthcheck/readiness endpoints**
- Upstream has none. Its Docker docs give no health path. The TrueCharts chart uses HTTP `/` probes (truecharts-appdaemon.md).

**Version/release info and asset naming**
- PyPI `appdaemon` 4.5.16 wheel only (`appdaemon-4.5.16-py3-none-any.whl`). See pypi-appdaemon.md.
- Upstream project docs: releases have slowed because the project is stable (not abandoned).

**Arch support**
- Pure Python wheel (`py3-none-any`). Upstream Docker image multi-arch per the docs (linux/arm/v6, linux/arm/v7, linux/arm64/v8, linux/amd64). Upstream Dockerfile compiles native deps only for arm32.

**Gotchas**
- Upstream copies `apps/apps.yaml.example` (with content) when `apps.yaml` is missing. plan.md's comment-only seed differs; plan.md already flags this as a risk.
- Upstream start.sh writes config with `sed`, not `yq`; plan.md's `yq -i strenv()` approach is a ContainerForge design, not an upstream behaviour.
- Upstream start.sh installs packages and requirements at runtime; incompatible with read-only rootfs (plan.md agrees).
- Plan.md step 6 says the start command "matches upstream `appdaemon -c $CONF "$@"`"; upstream actually uses `uv run --frozen appdaemon -c $CONF "$@"`.
