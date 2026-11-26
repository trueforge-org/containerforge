# dchesterton/amcrest2mqtt (GitHub)

Source URL(s) + fetch date:
- https://github.com/dchesterton/amcrest2mqtt (repo, via tags page)
- https://raw.githubusercontent.com/dchesterton/amcrest2mqtt/master/README.md
- https://raw.githubusercontent.com/dchesterton/amcrest2mqtt/9917b41381c62ef32281c0f508caf3254cf76968/Dockerfile
- https://raw.githubusercontent.com/dchesterton/amcrest2mqtt/1.0.16/src/amcrest2mqtt.py
- https://raw.githubusercontent.com/dchesterton/amcrest2mqtt/1.0.16/requirements.txt
- https://github.com/dchesterton/amcrest2mqtt/tags
- Fetched 2026-11-26

## What it is
Small Python app that publishes every event from one Amcrest camera/doorbell (via the `python-amcrest` library) to an MQTT broker. One instance handles one device; run one container per device. Docker is the only supported deployment method (running under Python directly is unsupported by upstream).

## Install/build steps and build deps
Upstream Dockerfile (at commit 9917b41, the commit cited in plan.md):
- `FROM python:3.9-alpine` (base stage), builder stage `FROM base`.
- Builder: `pip install --no-warn-script-location --prefix=/install -r /requirements.txt`.
- Final: `STOPSIGNAL SIGINT`, `COPY --from=builder /install /usr/local`, `COPY src /app`, `COPY VERSION /app`, `WORKDIR /app`, `CMD [ "python", "-u", "/app/amcrest2mqtt.py" ]`.
- No ENV, USER, ENTRYPOINT or EXPOSE in upstream.
- No apt/native build deps declared; all deps are pure Python.

## Runtime deps
Python packages pinned in `requirements.txt` at tag 1.0.16 (verbatim):
```
amcrest==1.9.7
paho-mqtt==1.6.1
python-slugify==6.1.1
```
An MQTT broker (upstream example uses `MQTT_HOST`) and a reachable Amcrest device.

## Binaries/entrypoint/CLI flags
- Entrypoint: `python -u /app/amcrest2mqtt.py` (upstream CMD). No CLI flags; all config via env vars.
- Layout: `src/amcrest2mqtt.py` is copied to `/app`, `VERSION` next to it.

## Env vars
| Variable | Required | Default | Notes |
| --- | --- | --- | --- |
| AMCREST_HOST | yes | none | device host |
| AMCREST_PORT | no | 80 | |
| AMCREST_USERNAME | no | admin | |
| AMCREST_PASSWORD | yes | none | |
| MQTT_USERNAME | yes | none | required even though password optional |
| MQTT_PASSWORD | no | empty | |
| MQTT_HOST | no | localhost | |
| MQTT_PORT | no | 1883 | |
| MQTT_QOS | no | 0 | |
| MQTT_TLS_ENABLED | no | off | enabled only when value is exactly `true` |
| MQTT_TLS_CA_CERT | when TLS | none | path; passed to `tls_set` |
| MQTT_TLS_CERT | when TLS | none | path; passed to `tls_set` |
| MQTT_TLS_KEY | when TLS | none | path; passed to `tls_set` |
| HOME_ASSISTANT | no | false | enabled only when `true` |
| HOME_ASSISTANT_PREFIX | no | homeassistant | discovery prefix |
| STORAGE_POLL_INTERVAL | no | 3600 | seconds; 0 disables storage polling |
| DEVICE_NAME | no | camera machine name | override |

## Ports
None. Upstream exposes and maps no ports (Amcrest and MQTT ports are outbound client connections: 80 and 1883 by default).

## Volumes/paths and persistent data
- Reads `./VERSION` if present, otherwise `../VERSION` (relative to working directory); newlines stripped.
- Writes no files. TLS cert/key files must be reachable inside the container at the given paths (upstream does not specify mounts).

## User/UID and permissions
Upstream sets no USER (runs as root in the upstream image). Nothing requires root at runtime.

## Config files and formats
None. Configuration is env-only.

## Healthcheck/readiness endpoints
None. Readiness signal is log output (startup logs, then "online" publish on MQTT).

## MQTT behaviour
- Base topic `amcrest2mqtt/{serial}/` with subtopics: `config`, `status`, `event`, `motion`, `doorbell`, `human`, `storage/used`, `storage/used_percent`, `storage/total`. Publishes are retained.
- Client ID `amcrest2mqtt_{serial}`, persistent session; last-will publishes `offline` to status; `online` published after setup, followed by a JSON config payload.
- Home Assistant discovery (when `HOME_ASSISTANT=true`): configs under `{prefix}/binary_sensor|sensor/amcrest2mqtt-{serial}/.../config`; entities for motion, doorbell (AD110/AD410), human (AD410 only), version/serial/host (diagnostic, disabled by default), storage used/used%/total (only with polling enabled).
- Event sources: motion from `ProfileAlarmTransmit` (AD110) or `VideoMotion` (other models); human from `CrossRegionDetection` with Human type; doorbell from `_DoTalkAction_` Invite action.

## Version/release info and asset naming
- Distribution is by git tags only. Tags are plain semver without `v` prefix (e.g. `1.0.16`). The tags page shows 1.0.16 (Mar 23, 2022), 1.0.15, 1.0.14 (Dec 31, 2021), 1.0.13/1.0.12 (Dec 30, 2021), 1.0.11/1.0.10 (Oct 26, 2021), 1.0.9, 1.0.8, 1.0.7 (Jul 2021). Commits are auto-titled "Version 1.0.x [skip ci]".
- No GitHub Releases were confirmed on the tags page (the page did not show release notes). Plan.md says the repo has no Releases, so `github-tags` renovate is the right datasource.
- Source tarball for a tag: `https://github.com/dchesterton/amcrest2mqtt/archive/refs/tags/<tag>.tar.gz` (per plan.md; no checksum published).
- Docker Hub: `dchesterton/amcrest2mqtt`, tags `latest` only in the listing (see dockerhub file).

## Arch support
Not stated upstream. Pure Python, so arch-neutral in principle (plan.md states the same).

## Gotchas
- Upstream: `MQTT_USERNAME` is required even though `MQTT_PASSWORD` is optional.
- Upstream bug: the TLS key check in the script tests `mqtt_tls_cert` a second time, so a missing `MQTT_TLS_KEY` is not caught by the check.
- With TLS enabled, the script exits 1 when CA cert or cert is missing.
- Exit behaviour: missing AMCREST_HOST, AMCREST_PASSWORD or MQTT_USERNAME logs an ERROR and calls `sys.exit(1)`.
- Signal handling: SIGINT handler does a graceful exit (publishes offline, disconnects, `os._exit(0)`); a second SIGINT calls `os._exit(1)`. An unexpected MQTT disconnect (nonzero rc) exits with that code. Upstream Dockerfile uses `STOPSIGNAL SIGINT`, which matches this handler. Plan.md notes that SIGTERM (default action) skips the offline publish.
- Upstream pins Python 3.9 (EOL) in the Dockerfile; the pinned libs are from 2021-2022.
- Multiple devices are not supported; one container per device.
- Home Assistant add-ons by third parties exist; upstream supports only the Docker version.
- Contradicts plan.md? No contradictions found. Plan.md's statement "the app only handles SIGINT (SIGTERM uses the default action)" is consistent with the source summary.
