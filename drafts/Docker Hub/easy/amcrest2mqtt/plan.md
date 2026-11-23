# amcrest2mqtt — implementation plan
> Source: ./draft.md · Target: apps/amcrest2mqtt/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 1.0.16 (git tag; the draft's container tag `dchesterton/amcrest2mqtt:1.0.16` matches). Quirk: the `VERSION` file inside tag 1.0.16 says `1.0.15`, so the app logs "App Version: 1.0.15". |
| Renovate | `datasource=github-tags depName=dchesterton/amcrest2mqtt versioning=loose`. The repo has tags but no GitHub Releases (`/releases/latest` redirects to `/releases`), so `github-releases` would not work. |
| License | MIT (LICENSE: "MIT License, Copyright (c) 2021 Daniel Chesterton") |
| Source URL | https://github.com/dchesterton/amcrest2mqtt |
| Download | Source tarball, arch-neutral: `https://github.com/dchesterton/amcrest2mqtt/archive/refs/tags/${VERSION}.tar.gz` (contains `src/amcrest2mqtt.py`, `requirements.txt`, `VERSION`, `LICENSE`) |
| Python deps | `requirements.txt` at 1.0.16: `amcrest==1.9.7`, `paho-mqtt==1.6.1`, `python-slugify==6.1.1`. amcrest 1.9.7 requires `argcomplete, httpx, requests, typing-extensions, urllib3` (all pure Python; PyPI `requires_python` is empty/`None` for all three pinned packages, so no declared cap below 3.15). |
| Checksum | UNVERIFIED: upstream publishes none for the tag tarball. Python deps are version-pinned in `requirements.txt` without hashes. |
| Upstream Dockerfile reviewed | https://github.com/dchesterton/amcrest2mqtt/blob/9917b41381c62ef32281c0f508caf3254cf76968/Dockerfile (`python:3.9-alpine` builder, `pip install --prefix=/install -r /requirements.txt`, `COPY src /app`, `COPY VERSION /app`, `STOPSIGNAL SIGINT`, `CMD python -u /app/amcrest2mqtt.py`) |
| Env vars (read in `src/amcrest2mqtt.py`) | `AMCREST_HOST` (required), `AMCREST_PORT` (80), `AMCREST_USERNAME` (admin), `AMCREST_PASSWORD` (required), `MQTT_USERNAME` (required), `MQTT_PASSWORD` (none), `MQTT_HOST` (localhost), `MQTT_PORT` (1883), `MQTT_QOS` (0), `MQTT_TLS_ENABLED` (only the exact string `true` enables), `MQTT_TLS_CA_CERT`, `MQTT_TLS_CERT`, `MQTT_TLS_KEY`, `HOME_ASSISTANT` (only `true` enables), `HOME_ASSISTANT_PREFIX` (homeassistant), `STORAGE_POLL_INTERVAL` (3600; 0 disables), `DEVICE_NAME` |
| Ports | None. It is an MQTT and camera client. |
| Behaviour | The script `sys.exit(1)`s immediately when `AMCREST_HOST`, `AMCREST_PASSWORD` or `MQTT_USERNAME` is unset. It reads `./VERSION` or `../VERSION` relative to the working directory. It writes no files. It only handles SIGINT (SIGTERM uses the default action). |

## 2. Target layout

```
apps/amcrest2mqtt/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: Python bridge installed with pip (draft says python runtime image). Load `python-runtime.instructions.md`: `/app/venv` is bundled by the base; treat it as read-only at runtime, install into it at build time as root. Closest siblings: `apps/bazarr` (python, release download, `/app/bin`), `apps/changedetection` (pip into `/app/venv/bin/pip`). Fallback if a pinned dep fails on 3.15: use the 3.14 pin as `apps/changedetection` does (`ghcr.io/trueforge-org/python-node:3.14.8@...` there; the plain `python:3.14.x` digest must be copied from a published tag, UNVERIFIED which exist).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `USER root`; `WORKDIR /app`.
2. No apt packages (draft: none; all deps are pure-Python wheels, `build-essential` and `libffi-dev` are already in the python base's build stage list but are not needed at runtime; verify no source builds occur, else add the needed `-dev` packages in the same RUN and purge them).
3. Install app and deps:
   ```sh
   mkdir -p /app/amcrest2mqtt /usr/share/licenses/amcrest2mqtt && \
   curl -fsSL -o /tmp/app.tar.gz "https://github.com/dchesterton/amcrest2mqtt/archive/refs/tags/${VERSION}.tar.gz" && \
   tar xzf /tmp/app.tar.gz -C /app/amcrest2mqtt --strip-components=1 && \
   /app/venv/bin/pip install --no-cache-dir -r /app/amcrest2mqtt/requirements.txt && \
   cp /app/amcrest2mqtt/LICENSE /usr/share/licenses/amcrest2mqtt/LICENSE && \
   chown -R root:root /app/amcrest2mqtt && chmod -R a+rX /app/amcrest2mqtt && \
   rm -rf /tmp/* /root/.cache
   ```
   Do not use a hard-coded `v`: the tag is `1.0.16`. Layout means `src/amcrest2mqtt.py` finds `../VERSION`.
4. `ENV PYTHONUNBUFFERED=1` is already in the base; add nothing else. No cache dirs go to `/config`.
5. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`, `VOLUME /config` (kept to match the repo pattern; the app stores nothing there, TLS cert files may be mounted under it). No `EXPOSE` (no ports). Final `USER apps`.

## 5. docker-bake.hcl

- `APP` = `amcrest2mqtt`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-tags depName=dchesterton/amcrest2mqtt versioning=loose
  default = "1.0.16"
  ```
- `LICENSE` = `MIT`; `SOURCE` = `https://github.com/dchesterton/amcrest2mqtt`
- Same 4 targets and `default` group as `apps/bazarr/docker-bake.hcl` (it also has `image`, `image-local`, `image-all`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/dchesterton/amcrest2mqtt"`.
- `ports: []` (same form as `apps/cloudflareddns/settings.yaml`).
- `env` (names exactly as the app reads them, defaults as in the app): `AMCREST_HOST` "" , `AMCREST_PORT` "80", `AMCREST_USERNAME` "admin", `AMCREST_PASSWORD` "", `MQTT_HOST` "localhost", `MQTT_PORT` "1883", `MQTT_USERNAME` "", `MQTT_PASSWORD` "", `MQTT_QOS` "0", `MQTT_TLS_ENABLED` "false", `MQTT_TLS_CA_CERT` "", `MQTT_TLS_CERT` "", `MQTT_TLS_KEY` "", `HOME_ASSISTANT` "false", `HOME_ASSISTANT_PREFIX` "homeassistant", `STORAGE_POLL_INTERVAL` "3600", `DEVICE_NAME` "", `TZ` "Etc/UTC".
- `required`: all `false` in the file, because the rule "required:true needs a non-empty default or start.sh handling" cannot hold for credentials. `AMCREST_HOST`, `AMCREST_PASSWORD`, `MQTT_USERNAME` are mandatory in practice; `start.sh` reports them clearly (section 7). Use `true` for them only if the schema or reviewers accept `required: true` with an empty default.
- `volumes: - path: /config  required: false`.
- `dependencies`: none declared hard (the draft lists none). Note in the PR: needs an MQTT broker; `apps/mosquitto` exists (opt_dependencies: `mosquitto`).

## 7. start.sh

```bash
#!/usr/bin/env bash
missing=""
for v in AMCREST_HOST AMCREST_PASSWORD MQTT_USERNAME; do
  [ -z "${!v}" ] && missing="$missing $v"
done
[ -n "$missing" ] && echo "[amcrest2mqtt] ERROR: required environment variable(s) not set:$missing" >&2

cd /app/amcrest2mqtt/src
exec /app/venv/bin/python -u /app/amcrest2mqtt/src/amcrest2mqtt.py
```
Behaviour: no env mapping is needed (the app reads the env directly); with missing variables the app exits 1 itself with its own message, so the failure is loud rather than an idle container. Idempotent, no `/config` seeding, no writes to `/app`, `exec` for signals. Do not `export` or log passwords. Because the app only handles SIGINT, `docker stop` ends it through SIGTERM's default action without the MQTT "offline" handling; a wrapper trap translating TERM to INT is optional and not planned.

## 8. container-test.yaml

The test runs without env vars and the app exits when they are missing, and there is no port, so only static assertions are possible (same pattern as `apps/cloudflareddns`):
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /app/amcrest2mqtt/src/amcrest2mqtt.py
- /app/amcrest2mqtt/VERSION
- /app/venv/bin/python
- /usr/share/licenses/amcrest2mqtt/LICENSE
runners:
- entrypoint: /app/venv/bin/python -c "import amcrest, paho.mqtt.client, slugify"
```
The `runners` entrypoint quoting is UNVERIFIED with forgetool (other apps use `entrypoint: test -x /path`); if it does not parse, replace by `entrypoint: test -d /app/venv/lib` style checks, never by a no-op. This is not a database-dependent app and no narrowing comment applies; full functional testing needs a camera and a broker, which the single-container suite cannot provide. Add `timeoutSeconds` only if CI needs it.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| None found in `src/amcrest2mqtt.py` (no file writes; it only reads `VERSION` and optional TLS files) | Nothing to remap. `.pyc` writing is disabled by the base (`PYTHONDONTWRITEBYTECODE=1`). |
| pip at build time | Build stage only; `--no-cache-dir`, cache removed. |

Draft expectations: non-root UID 568 is kept; the draft's "app may write under /app" is not confirmed (no writes found), so the read-only rootfs works. Not privileged. No extra persistence (no `/data`). The container must share a network with the camera and broker (the camera is on the LAN; no host network is required unless the camera is only reachable that way).

## 10. Risks, caveats and open questions

- Draft: needs an MQTT broker and Amcrest cameras plus credentials in env. One container per camera (upstream design).
- Draft: Python 3.9 EOL in the upstream image. Pins (`amcrest 1.9.7`, `paho-mqtt 1.6.1`, `python-slugify 6.1.1`) are old; Python 3.15 compatibility is UNVERIFIED (pure Python, no declared `requires_python` cap, but runtime behaviour untested, e.g. `paho-mqtt` 1.6.1 callback API). Fallback is a 3.14 base as in `apps/changedetection`.
- Version files out of sync upstream (VERSION file 1.0.15 in tag 1.0.16): cosmetic.
- Renovate: tags only, `github-tags`; confirm the repo's renovate config handles it.
- Not blockers: not musl-only, no GPU, no privileged, arm64 is fine (pure Python). Upstream may be unmaintained; note in the PR.

## 11. Build and test steps

```sh
cd apps/amcrest2mqtt
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
# smoke: missing env must give the clear error and exit 1
docker run --rm --read-only --tmpfs /tmp -v amcrest2mqtt-probe-config:/config amcrest2mqtt:1.0.16
# imports work on the read-only rootfs
docker run --rm --read-only --tmpfs /tmp --entrypoint /app/venv/bin/python amcrest2mqtt:1.0.16 -c "import amcrest, paho.mqtt.client, slugify; print('ok')"
# optional with a local mosquitto container: set the three required vars and expect "App Version: 1.0.15" then a connection attempt
docker volume rm amcrest2mqtt-probe-config
forgetool containers test --image amcrest2mqtt:1.0.16 --config ./apps/amcrest2mqtt/container-test.yaml
```
Readiness signal: log line `[INFO] App Version: ...` followed by the camera and MQTT connection logs. Without a camera, only the missing-env error and the imports can be checked. Max 10 rounds, fresh `/config` volume each round.

## 12. PR checklist

- Branch `feat/add-amcrest2mqtt`; commit and title `feat(amcrest2mqtt): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested unless run: image build amd64 and arm64, Python 3.15 runtime behaviour, connection to a real camera and a broker, TLS to MQTT, Home Assistant discovery, `forgetool` run. Only tick "Built container locally" if it was.
- Standard checklist: minimal scope, instruction files followed, bake and Dockerfile aligned, rootless and read-only, `bake --print` ran.
