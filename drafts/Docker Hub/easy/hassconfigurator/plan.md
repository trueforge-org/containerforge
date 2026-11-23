# hass-configurator — implementation plan
> Source: ./draft.md · Target: apps/hass-configurator/ (draft folder and chart are named `hassconfigurator`; repo apps use hyphens, see section 10) · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `0.7.0`, uploaded to PyPI on 2026-10-18 (previous: 0.6.0). The draft's image is the 2021-era `causticlab/hass-configurator-docker:x86_64` on Python 3.9 alpine, so this is a newer upstream than the draft knew. |
| Renovate | `datasource=pypi depName=hass-configurator versioning=pep440`. |
| License | MIT (`LICENSE.txt` in the sdist, "Copyright (c) 2016 Daniel"; `setup.py` `license='MIT'`; PyPI metadata MIT). |
| Source | https://github.com/danielperna84/hass-configurator |
| Artifact | PyPI sdist `https://files.pythonhosted.org/packages/source/h/hass-configurator/hass_configurator-0.7.0.tar.gz`, pure Python, so amd64 and arm64 are identical. Entry point `hass-configurator = hass_configurator.configurator:main`. |
| Checksum source | PyPI file digest sha256 `1a73aa09eb1ee1ed7acdc4c55dc9147fedadf7a7a3947fd63e6ed832b082e44c` (recomputed from the downloaded sdist, identical). |
| Dependencies | `setup.py`: `pyotp`, `gitpython`, `legacy-cgi` (needed for Python above 3.12, `cgi` was removed). `gitpython` needs a `git` binary, which the ubuntu base has (`git` is in the base's apt list in `apps/ubuntu/Dockerfile`). Python 3.15 compatibility of `legacy-cgi` is UNVERIFIED. |
| Upstream Dockerfile (the one the draft links) | Reviewed (`causticlab/hass-configurator-docker`, commit `7ed3f9f`): `python:3.9-alpine`, `pip install hass-configurator==$HC_BUILD_VERSION gitpython pyotp`, `run.sh` that starts `hass-configurator /config/settings.conf` if that file exists, otherwise bare `hass-configurator`, `EXPOSE 3218`, `VOLUME /config`. Alpine and Python 3.9 are irrelevant here: we pip install from PyPI on the python base. |
| Port | `3218` (code default `PORT = 3218`, `LISTENIP = "0.0.0.0"`). |
| Config model (read in `configurator.py` 0.7.0) | Optional positional argument: path to a JSON settings file. Every environment variable starting with `HC_` (prefix configurable with `ENV_PREFIX`) overrides it; `true/false` become booleans, digits become integers, `none/null` become `None`, and `ALLOWED_NETWORKS`, `BANNED_IPS`, `IGNORE_PATTERN` are comma separated lists. Keys seen in the source: `LISTENIP`, `PORT`, `BASEPATH` (default `None`), `ENFORCE_BASEPATH` (False), `SSL_CERTIFICATE`, `SSL_KEY`, `HASS_API` (default `http://127.0.0.1:8123/api/`), `HASS_WS_API`, `HASS_API_PASSWORD`, `USERNAME`, `PASSWORD`, `CREDENTIALS` (deprecated), `ALLOWED_NETWORKS`, `ALLOWED_DOMAINS`, `BANNED_IPS`, `BANLIMIT` (0), `GIT` (False), `IGNORE_PATTERN`, `DIRSFIRST`, `HIDEHIDDEN`, `SESAME`, `SESAME_TOTP_SECRET`, `VERIFY_HOSTNAME`, `IGNORE_SSL`, `NOTIFY_SERVICE`, `LOGLEVEL` (read as `HC_LOGLEVEL`, default `info`). CLI flags include `--standalone`, `--listen`, `--port`, `--basepath`, `--enforce`, `--git`. |
| Writes | UI preferences file `.hass_configurator_prefs.json` in `BASEPATH` if set, else the current directory; the editor writes whatever files the user edits under the base path; GitPython/git may write `~/.gitconfig`. Nothing is written to the package directory. |
| Auth | No authentication unless `USERNAME`/`PASSWORD` (or `CREDENTIALS`, `ALLOWED_NETWORKS`) are set. |
| Project status | Not archived or abandoned as the draft assumed: a release exists from 2026-10-18. |

## 2. Target layout

```
apps/hass-configurator/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: a settings file is optional and every option is reachable through `HC_*` env. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```

Python web app installed from PyPI, as the draft says. Closest sibling: `apps/apprise-api` (pip into `/app/venv`) and `apps/bazarr` (python base, run with `/usr/local/bin/python`). Fallback if `legacy-cgi` or `gitpython` fail on 3.15: `ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232` (already used by other apps in the repo). Python rules apply: `/app/venv` is read only at runtime, pip caches go to `/tmp`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `ARG SHA256=1a73aa09eb1ee1ed7acdc4c55dc9147fedadf7a7a3947fd63e6ed832b082e44c` (update together with `VERSION`; not renovated). `USER root`.
2. No apt packages: `git` and `curl` are in the ubuntu base, and every Python dependency is pure Python or has wheels (compilers are in the python base if a build is needed).
3. One `RUN`:
   - `mkdir -p /tmp/hc /usr/share/licenses/hass-configurator`
   - `curl -fsSL -o /tmp/hc/hc.tar.gz "https://files.pythonhosted.org/packages/source/h/hass-configurator/hass_configurator-${VERSION}.tar.gz"`
   - `echo "${SHA256}  /tmp/hc/hc.tar.gz" | sha256sum -c -`
   - `tar xzf /tmp/hc/hc.tar.gz -C /tmp/hc --strip-components=1 && cp /tmp/hc/LICENSE.txt /usr/share/licenses/hass-configurator/`
   - `/app/venv/bin/pip install --no-cache-dir /tmp/hc/hc.tar.gz` (the sdist builds with the venv's setuptools; its three dependencies come from PyPI)
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/hc /root/.cache`.
4. `ENV HOME=/config` (git config lives there) and `ENV PYTHONUNBUFFERED=1`.
5. `RUN install -d -o apps -g apps /hass-config` so the editor target exists and is owned by `apps` when nothing is mounted.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3218`, `VOLUME /config`, `VOLUME /hass-config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "hass-configurator" }
variable "VERSION" {
  // renovate: datasource=pypi depName=hass-configurator versioning=pep440
  default = "0.7.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/danielperna84/hass-configurator" }
```

Standard blocks from `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `group "default"` (`image-local`), `image` (args `VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/danielperna84/hass-configurator"
ports:
  - port: 3218
    protocol: tcp
    required: true
env:      # block style as apps/bazarr/settings.yaml: name / default / required
  - HC_BASEPATH: "/hass-config"       # start.sh default
  - HC_ENFORCE_BASEPATH: "true"       # start.sh default (upstream default false)
  - HC_LISTENIP: "0.0.0.0"
  - HC_PORT: "3218"
  - HC_HASS_API: "None"               # start.sh default (upstream default http://127.0.0.1:8123/api/ makes no sense in a container)
  - HC_LOGLEVEL: "info"
  - HC_USERNAME: ""                   # not exported by start.sh when empty
  - HC_PASSWORD: ""
  - HC_ALLOWED_NETWORKS: ""
  - HC_GIT: "false"
  - TZ: "Etc/UTC"
volumes:
  - path: /config          # required: true  (optional settings.conf, git config)
  - path: /hass-config     # required: false (the Home Assistant config directory to edit)
dependencies: []
```

All `env` entries are `required: false`. The names are real `HC_*` keys from `load_settings()` (section 1); do not add others unless verified. Defaults equal what `start.sh` exports. `HC_USERNAME`, `HC_PASSWORD` and `HC_ALLOWED_NETWORKS` default to empty and are only exported when set (an exported empty string would be parsed as a value). The Home Assistant container is not a dependency: the editor works on any directory.

## 7. start.sh

```bash
#!/usr/bin/env bash

# Editor target: the Home Assistant config directory (mount it at /hass-config)
export HC_BASEPATH="${HC_BASEPATH:-/hass-config}"
export HC_ENFORCE_BASEPATH="${HC_ENFORCE_BASEPATH:-true}"
export HC_LISTENIP="${HC_LISTENIP:-0.0.0.0}"
export HC_PORT="${HC_PORT:-3218}"
# Standalone mode unless a Home Assistant API URL is given (the default 127.0.0.1:8123 is the wrong container)
export HC_HASS_API="${HC_HASS_API:-None}"

args=()
if [ -f /config/settings.conf ]; then
  args+=(/config/settings.conf)
fi

if [ -z "${HC_USERNAME:-}" ] || [ -z "${HC_PASSWORD:-}" ]; then
  echo "WARNING: HC_USERNAME/HC_PASSWORD are not set. Anyone who can reach port ${HC_PORT} can edit ${HC_BASEPATH}." >&2
fi

cd /config
exec /app/venv/bin/hass-configurator "${args[@]}"
```

Notes: nothing is seeded (a settings file is optional), so an empty `/config` works and a restart changes nothing; no write to `/app`; all state is in `/config` and `/hass-config`; scratch is `/tmp`. The password only travels in the environment, never on the command line. The listener is `0.0.0.0` (code default, exported explicitly). `exec` hands the process to the base `tini`. The `HC_*` variables override the settings file, because that is how upstream merges them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3218'
filePaths:
- /app/venv/bin/hass-configurator
```

One TCP probe for the one declared port. No `http` probe yet: the status of `/` is UNVERIFIED (it should be 200 without credentials; add `http: - port: '3218' path: /` after section 11 confirms it). The test runs without env vars, i.e. the unauthenticated standalone start, which is the path `start.sh` takes by default. `timeoutSeconds` follows Python siblings (UNVERIFIED value, `apps/changedetection` uses 180 for a heavier app).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or privilege | Remap |
| --- | --- |
| Chart `runAsUser 0`, `runAsGroup 0` | Runs as `apps`. The editor only needs write access to the mounted `/hass-config`; mounted volumes must be writable by the `apps` UID/GID (set pod `fsGroup` or the volume owner). |
| `readOnlyRootFilesystem: false` | Not needed: only `/config`, `/hass-config` and `/tmp` are written. |
| `.hass_configurator_prefs.json` | Written to `BASEPATH`, i.e. `/hass-config` (UI theme only, failure is logged as a warning). |
| `~/.gitconfig` and git credentials | `HOME=/config`. |
| `/hass-config` PVC and `/config` (chart's own) | Both kept as separate volumes, as the draft lists. |
| Privileged | No. |

## 10. Risks, caveats and open questions

- Naming: the draft folder and chart are `hassconfigurator`, but apps in this repo use hyphens (`home-assistant`, `speedtest-tracker`). This plan uses `hass-configurator`; rename if the chart to app mapping needs the other name.
- Security: the editor gives write access to Home Assistant's config (draft caveat). With no `HC_USERNAME`/`HC_PASSWORD` it is open; the warning in `start.sh` and the PR note are required, and `HC_ENFORCE_BASEPATH=true` is the default so it cannot browse the rest of the container filesystem (this changes the upstream default, call it out).
- The draft says the project looks unmaintained; the PyPI release from 2026-10-18 shows otherwise (verified). The fixed `x86_64` tag in the draft is irrelevant now, since pip installs a pure Python package for both architectures.
- The UI loads JavaScript, CSS and fonts from CDNs for some assets (the README says the configurator does not work offline for the client), so air-gapped users need to know this.
- Python 3.15 with `legacy-cgi`, `gitpython` and `pyotp` is UNVERIFIED (fallback in section 3).
- If `/hass-config` is not mounted the editor opens an empty folder (draft caveat).
- The Home Assistant side (`HC_HASS_API`, `HC_HASS_API_PASSWORD`, websocket API) was not exercised.
- Checksum is a pinned ARG (not renovated), so bump `VERSION` and `SHA256` together.
- No musl, GPU, privileged or arm64 blocker.

## 11. Build and test steps

```sh
cd apps/hass-configurator
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
mkdir -p /tmp/hc-probe-hass && chmod 777 /tmp/hc-probe-hass     # scratch dir standing in for /hass-config
docker run --rm -d --name hass-configurator-probe --read-only --tmpfs /tmp \
  -v hass-configurator-probe-config:/config -v /tmp/hc-probe-hass:/hass-config -p 3218:3218 hass-configurator:0.7.0
docker logs -f hass-configurator-probe
curl -si http://127.0.0.1:3218/ | head -3      # expect 200 without credentials
docker rm -f hass-configurator-probe; docker volume rm hass-configurator-probe-config; rm -rf /tmp/hc-probe-hass
forgetool containers test --image hass-configurator:0.7.0 --config ./apps/hass-configurator/container-test.yaml
```

Also run once with `-e HC_USERNAME=a -e HC_PASSWORD=b` and check that `/` returns 401, and once with a `/config/settings.conf` mount. Expected readiness: the log shows the server listening (the app logs through `logging` at INFO, exact line UNVERIFIED), the container stays running, port 3218 answers, and there is no "Unable to import Git module" or `cgi` import error.

## 12. PR checklist

- [ ] Branch `feat/add-hass-configurator` from `main`; commit and PR title `feat(hass-configurator): add new container`.
- [ ] Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- [ ] `🤖 This PR is AI generated.` in the Notes section.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- [ ] `docker buildx bake --print` exits 0.
- [ ] Notes mention: unauthenticated by default and the safer defaults chosen (`HC_ENFORCE_BASEPATH=true`, standalone mode).
- [ ] Untested list: arm64, Home Assistant API integration, git features, Python 3.15 with the three dependencies until the build runs, and `forgetool` if unavailable. Do not tick "Built container locally" unless it was.
