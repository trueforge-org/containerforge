# appdaemon — implementation plan
> Source: ./draft.md · Target: apps/appdaemon/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Latest stable | 4.5.16 (PyPI upload 2026-11-13, wheel only, not yanked). Draft tag `4.5.16` is the same. |
| Renovate | `datasource=pypi depName=appdaemon` (default semver versioning) |
| License | Apache-2.0 (upstream `LICENSE.md` is the Apache License 2.0; PyPI `license` field is empty, so use the file, not the field) |
| Source | https://github.com/AppDaemon/appdaemon (docs: https://appdaemon.readthedocs.io/) |
| Install | `pip install appdaemon==4.5.16` (pure wheel `py3-none-any`, so one artifact for amd64 and arm64) |
| Python requirement | `>=3.10,<3.15` (pyproject and PyPI). **The current ContainerForge python base is 3.15.2 and cannot be used.** Use the existing `python:3.14.8` base (same one sabnzbd, home-assistant etc. use). |
| Entry point | `appdaemon = "appdaemon.__main__:main"` (console script, ends up in `/app/venv/bin/appdaemon`) |
| Checksum source | PyPI does not publish a separate checksum for a plain `pip install`. Pin the version with `==` (pip fetches over TLS from PyPI). Optional hardening: `--require-hashes` with the sha256 of the wheel, from the PyPI JSON API. |
| Upstream Dockerfile reviewed | https://github.com/AppDaemon/appdaemon/blob/239dd4b130f98a8053058fbe82d6cce9d62e919d/Dockerfile (alpine/musl, uv, `/conf` + `/certs` volumes, EXPOSE 5050, entrypoint `/start.sh`) and `scripts/start.sh` at tag 4.5.16 |
| Port | 5050/tcp (dashboard, admin, API), from `http: url: http://0.0.0.0:5050` in `conf/appdaemon.yaml.example` |
| Upstream env vars (read by upstream `start.sh`, not by the app) | `HA_URL`, `TOKEN`, `DASH_URL`, `HA_CERT_VERIFY`, `TIMEZONE`, `LATITUDE`, `LONGITUDE`, `ELEVATION`, plus MQTT ones (`MQTT_NAMESPACE`, `MQTT_CLIENT_HOST`, `MQTT_CLIENT_USER`, `MQTT_CLIENT_PASSWORD`). These are implemented by sed in the upstream script, so our `start.sh` must reimplement them. |
| Config dir | upstream `/conf`; ours `/config` (`appdaemon -c /config`) |
| Upstream runtime installs | upstream `start.sh` runs `apk add` for `system_packages.txt` and `uv pip install` for `requirements.txt` found under `/conf`. Not portable (musl/apk) and not possible on a read-only rootfs. Dropped, see section 10. |

## 2. Target layout

```
apps/appdaemon/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/appdaemon.yaml     # seeded into /config only when missing (copy of upstream conf/appdaemon.yaml.example)
```

- `defaults/` is on the `include/.dockerignore` allow-list, so `COPY --chmod=0755 . /` ships it as `/defaults/`.
- No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing in this repo uses it as a `FROM` base).
- Nearest siblings: `apps/sabnzbd` (python 3.14 base, defaults seeding), `apps/changedetection` (pip into `/app/venv`, `exec` from start.sh).

## 3. Base image

```
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232
```

- Why not 3.15.2 (the brief's current python base): appdaemon `requires-python <3.15`. Copy the digest exactly from the existing apps (8 apps use it). Add a comment like sabnzbd: `# stay on python 3.14 until appdaemon supports 3.15`.
- Python base already provides `/app/venv`, `pip`, `curl`, `yq` (mikefarah, `/usr/local/bin/yq`), `HOME=/config`, tini entrypoint and `/healthcheck.sh`.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION`; `USER root`.
2. `ENV HOME=/config` (already the base default, repeat as bazarr/pyload do) and `ENV PYTHONUNBUFFERED=1` (base already sets it; keep out unless missing).
3. No apt packages: appdaemon's dependencies (aiohttp, pydantic, bcrypt, uvloop, pyyaml...) are expected to have cp314 wheels. If the build shows a source build, add `build-essential libffi-dev` for that RUN and purge afterwards (UNVERIFIED: cp314 wheel availability for every dependency, check in the first build log).
4. Install into the base venv, no cache:
   ```dockerfile
   RUN /app/venv/bin/pip install --no-cache-dir "appdaemon==${VERSION}" \
       && mkdir -p /usr/share/licenses/appdaemon \
       && cp "$(/app/venv/bin/python -c 'import importlib.metadata as m; print([f for f in m.distribution("appdaemon").files if "LICENSE" in f.name.upper()][0].locate())')" /usr/share/licenses/appdaemon/LICENSE.md \
       && chown -R apps:apps /app && chmod -R 755 /app \
       && rm -rf /root/.cache /tmp/*
   ```
   The license path inside the wheel is UNVERIFIED (`licenses/LICENSE.md` in dist-info is likely). If the wheel carries no license file, fetch `https://raw.githubusercontent.com/AppDaemon/appdaemon/${VERSION}/LICENSE.md` instead (tag `4.5.16` confirmed to exist).
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5050`, `VOLUME /config`, `WORKDIR /config`.
6. Do not set `ENTRYPOINT`; the base entrypoint (`tini -- /entrypoint.sh`) execs `/start.sh`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "appdaemon" }
variable "VERSION" {
  // renovate: datasource=pypi depName=appdaemon
  default = "4.5.16"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/AppDaemon/appdaemon" }
```

Layout as `apps/bazarr/docker-bake.hcl` (copy it): `docker-metadata-action`, `default` group -> `image-local`, `image` (args VERSION, OCI labels source/licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/AppDaemon/appdaemon"
ports:
  - port: 5050
    protocol: tcp
    required: false
env:
  - {name: TZ, default: "Etc/UTC", required: false}
  - {name: HA_URL, default: "", required: false}          # written to appdaemon.yaml plugins.HASS.ha_url
  - {name: TOKEN, default: "", required: false}           # long-lived HA token -> plugins.HASS.token
  - {name: HA_CERT_VERIFY, default: "", required: false}  # -> plugins.HASS.cert_verify
  - {name: DASH_URL, default: "", required: false}        # -> http.url
  - {name: TIMEZONE, default: "", required: false}        # -> appdaemon.time_zone
  - {name: LATITUDE, default: "", required: false}
  - {name: LONGITUDE, default: "", required: false}
  - {name: ELEVATION, default: "", required: false}
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: home-assistant   # ✅ apps/home-assistant exists; AppDaemon needs a reachable HA and token for the HASS plugin
```

Write the `env` list in the block style the siblings use (one `- name:` / `default:` / `required:` per key, as in `apps/bazarr/settings.yaml`), the flow style above is only for brevity. MQTT variables are intentionally not listed (not supported in our start.sh, section 7).

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`. Rules: idempotent, no writes to `/app`, bind all interfaces.

1. `mkdir -p /config/apps /config/dashboards`.
2. Seed only when missing: `[ -f /config/appdaemon.yaml ] || [ -f /config/appdaemon.toml ] || cp /defaults/appdaemon.yaml /config/appdaemon.yaml`. Same guard for `/config/apps/apps.yaml` (upstream copies an example; seed a file containing only comments, see risk in section 10).
3. `defaults/appdaemon.yaml` is the upstream example verbatim (verified): `appdaemon:` latitude 0, longitude 0, elevation 30, time_zone, `plugins: HASS: {type: hass, ha_url:, token:, cert_verify: True}`, `http: url: http://0.0.0.0:5050`, `admin:`, `api:`, `hadashboard:`. `0.0.0.0` satisfies the bind-all rule.
4. Apply env to the file on every start (only when set), using `yq` (present in the ubuntu base) with `strenv()` so values with `/ & \ "` do not break and the token never lands on a command line:
   ```bash
   [ -n "${HA_URL:-}" ] && HA_URL="$HA_URL" yq -i '.appdaemon.plugins.HASS.ha_url = strenv(HA_URL)' /config/appdaemon.yaml
   # same pattern: TOKEN -> .appdaemon.plugins.HASS.token, HA_CERT_VERIFY (bool via env tag),
   # DASH_URL -> .http.url, TIMEZONE -> .appdaemon.time_zone, LATITUDE/LONGITUDE/ELEVATION -> numbers
   ```
   Applies only when the file is YAML (skip with a log line if the user supplied `appdaemon.toml`). `yq -i` rewrites the file and drops comments in it; acceptable, document it.
5. `export HOME=/config`; nothing needs `/tmp` caches (bytecode is disabled in the base), but export `XDG_CACHE_HOME=/tmp/.cache` for safety.
6. Final: `exec /app/venv/bin/appdaemon -c /config "$@"` (matches upstream `appdaemon -c $CONF "$@"`; extra args such as `-D DEBUG` pass through).
7. No runtime `apk`/`pip install` of user `requirements.txt` (read-only `/app/venv`). Optional follow-up, not in v1: a persistent `/config/venv` seeded from `/app/venv` per `python-runtime.instructions.md` if users need extra libs.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5050'
filePaths:
- /app/venv/bin/appdaemon
- /defaults/appdaemon.yaml
- /usr/share/licenses/appdaemon/LICENSE.md
```

- The test runs with no env vars, so the HA plugin has empty `ha_url`/`token`. Whether AppDaemon keeps serving port 5050 in that state is UNVERIFIED (it normally retries the HA connection). If the process exits, fix the defaults (for example generate a default config without the HASS plugin when `HA_URL` is unset), do not weaken the probe.
- Use `http` with path `/` only after a manual run confirms the response code (UNVERIFIED which paths answer 200 without HA).
- Sibling timeouts for python apps: 180.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/conf` (config, apps, dashboards, logs, namespaces) | `/config` (chart's `/conf` PVC must be remounted to `/config`) |
| `/certs` (custom HA CA) | not a volume; users can put certs under `/config/certs` and set `HA_CERT_VERIFY` to the path (UNVERIFIED that the plugin accepts a path, check docs) |
| Python bytecode, pip/uv cache | disabled in base env / `/tmp` |
| `apk add` and `pip install` at start | removed (read-only rootfs) |

- Draft/chart expectation was root (UID 0), `readOnlyRootFilesystem: false`. Reconciled: image runs as `apps` (UID 568) with read-only rootfs and `/tmp` tmpfs. Existing `/conf` data written as root needs `chown -R 568:568` or `fsGroup: 568` when migrating.
- Not privileged. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- Python 3.15 incompatibility (verified) forces the 3.14.8 base. Watch for renovate bumping the base to 3.15; keep the comment next to `FROM`.
- Draft caveat confirmed: needs Home Assistant plus a long-lived token. Without them the HASS plugin cannot connect, only the dashboard/admin is useful.
- Draft caveat: config and `apps` must exist before first start. Handled by seeding in `start.sh`; whether AppDaemon accepts an empty/comment-only `apps.yaml` is UNVERIFIED (upstream ships an example with content). If it errors, seed the minimal example from the upstream repo `conf/apps/apps.yaml.example` (not fetched here).
- Dropped features: runtime `system_packages.txt` and `requirements.txt` installs, MQTT env vars. Users needing extra Python packages need a derived image or the optional persistent venv.
- `yq -i` strips comments from the user's `appdaemon.yaml` when env vars are set.
- The token ends up in `/config/appdaemon.yaml` (same as upstream); recommend `chmod 600`: `start.sh` should `umask 077` before writing.
- No blockers: pure Python wheel, glibc, amd64 and arm64.

## 11. Build and test steps

```sh
cd apps/appdaemon
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name appdaemon-probe --read-only --tmpfs /tmp \
  -v appdaemon-probe-config:/config appdaemon:4.5.16
docker logs -f appdaemon-probe
# readiness: container still running, port 5050 open (e.g. docker exec appdaemon-probe bash -c '</dev/tcp/127.0.0.1/5050'),
# AppDaemon startup banner / "Starting Apps" style lines, no traceback. HA connection errors/retries are acceptable only if the process stays up.
docker rm -f appdaemon-probe; docker volume rm appdaemon-probe-config
forgetool containers test --image appdaemon:4.5.16 --config ./apps/appdaemon/container-test.yaml
```

Also run once with `-e HA_URL=http://x:8123 -e TOKEN='a/b&c' -e TIMEZONE=Europe/Berlin` and check `/config/appdaemon.yaml` (values intact, token not in `ps`). Then test an upgrade restart on the same volume (idempotent, no overwrite). Max 10 rounds; clean up scratch containers and volumes.

## 12. PR checklist

- Branch `feat/add-appdaemon`, commit and PR title `feat(appdaemon): add new container`, target `main`.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md` (tick "New container/image"; tick test boxes only for what actually ran). Put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (check `license/cla`; only the user can sign).
- Notes to include: python 3.14 pin reason, `/conf` -> `/config` and UID 568 migration, dropped runtime installs.
- Untested until run: arm64 build, cp314 wheel availability, behaviour without HA, empty `apps.yaml`, license file path in the wheel.
- Checklist: minimal app-scoped change, instruction files read, bake and Dockerfile versions aligned (4.5.16), rootless and read-only OK, empty `/config` OK, `bake --print` ran, no DOWNSTREAM file needed.
