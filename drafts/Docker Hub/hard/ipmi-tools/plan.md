# ipmi-tools — implementation plan
> Source: ./draft.md · Target: apps/ipmi-tools/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No releases or tags. Single pinned commit `d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246` (2023-01-04, "Merge pull request #8 ..."), 14 commits total. Draft container tag `latest`. |
| Renovate | `// renovate: datasource=git-refs depName=EdwardChamberlain/IPMI-Fan-Controller packageName=https://github.com/EdwardChamberlain/IPMI-Fan-Controller currentDigest=d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246` (same style as `apps/kasmvnc` KASM_NOVNC_VERSION). Branch name for git-refs: UNVERIFIED (`main` assumed, README/raw URLs on `main` resolve). |
| License | NONE found: the repo page shows no license and no LICENSE file in the root (files: `app/`, `.gitignore`, `README.md`, `dockerfile`, `quickstart.py`). Without a licence the code is all-rights-reserved. BLOCKER: ask the upstream author (open an issue) or get maintainer sign-off before shipping. Bake `LICENSE` cannot be set honestly; placeholder `LicenseRef-None-Specified`. |
| Source URL | https://github.com/EdwardChamberlain/IPMI-Fan-Controller |
| Download | `https://github.com/EdwardChamberlain/IPMI-Fan-Controller/archive/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246.zip` (arch independent, pure Python). No checksum published; the commit sha is the pin. |
| Upstream Dockerfile reviewed | `dockerfile` at that commit: `FROM tiangolo/meinheld-gunicorn-flask:python3.8`, `apt-get install ipmitool`, `pip install flask-wtf wtforms flask-bootstrap4`, `COPY ./app /app`. The base image serves `app/main.py` via gunicorn on port 80. `quickstart.py` maps `6060:80`. |
| App layout | `app/main.py` (`from flaskr import app`; `app.run(host='0.0.0.0', debug=True)` only under `__main__`), `app/config.py`, `app/ipmitools.py`, `app/flaskr/`. |
| Env vars (config.py) | `SECRET_KEY` (random `secrets.token_hex()` if unset), `APP_IPMI_HOST`, `APP_IPMI_USER`, `APP_IPMI_PASS` (each None if unset), `APP_LOG_LEVEL` (default `INFO`). |
| How IPMI is reached | `ipmitools.py` builds an `ipmitool` command with host, user, password from config, so IPMI is used over the network (iDRAC/BMC, Dell raw commands `0x30 0x30 0x01 0x00/0x01`, `0x30 0x30 0x02 0xff <hex>`). README: "IPMI must be enabled in iDRAC", credentials via env or typed into the web GUI. The draft's claim that `/dev/ipmi*` is required is NOT supported by the code: UNVERIFIED which interface flag is used (`lanplus` vs `lan`), so check `ipmitools.py` when implementing. |
| Ports | 5000/tcp when run via `python main.py`; the Docker base used 80. Port is not defined by the app when run under gunicorn; we choose 5000 (draft inferred 5000). |

## 2. Target layout

```
apps/ipmi-tools/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No defaults/ (no config file; config is env based). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Python Flask app plus apt `ipmitool` (draft). Closest sibling: `apps/bazarr` (python base, app in `/app`, `uv pip install`). Compatibility of a 2023 Flask-Bootstrap4/Flask-WTF stack with Python 3.15: UNVERIFIED and the main technical risk.

## 4. Dockerfile

1. `ARG VERSION` (commit sha), `USER root`, `WORKDIR /app`.
2. `apt-get update && apt-get install -y --no-install-recommends ipmitool unzip && rm -rf /var/lib/apt/lists/*`; pin `ipmitool=<resolute version>` and check against upstream ipmitool (UNVERIFIED version; ipmitool is not the app version, so the app `VERSION` guard does not apply, but the Dockerfile rules prefer pinned apt packages; record the version found at build time). Check unzip/curl are not already in the base before installing.
3. Download the commit zip with `curl -fsSL`, `unzip -q` to `/tmp`, move `IPMI-Fan-Controller-<sha>/app/*` to `/app/bin/`. Verify the extracted tree contains `main.py`.
4. Install Python deps into `/app/venv` (as bazarr does via `uv`): `flask flask-wtf wtforms flask-bootstrap4 gunicorn`. Pin versions after a first successful resolve (UNVERIFIED which versions work; `flask-bootstrap4` is unmaintained and may need `Flask<3` and `WTForms<3`). Remove `uv` afterwards; `chown -R root:root /app && chmod -R 755 /app`.
5. Licence: upstream has none, so ship nothing under `/usr/share/licenses/ipmi-tools/` except a `NOTICE` stating "no licence found upstream"; revisit after upstream answers.
6. `ENV HOME=/config PIP_CACHE_DIR=/tmp/pip PYTHONDONTWRITEBYTECODE=1 PORT=5000 APP_LOG_LEVEL=INFO`.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5000`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

`APP = "ipmi-tools"`, `VERSION = "d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246"` under the git-refs renovate comment from section 1 (a sha as VERSION means the image tag `ipmi-tools:<sha>`; alternative is a `0.0.0-d1ea5f1` style tag, decide when implementing), `LICENSE = "LicenseRef-None-Specified"` (blocker, see section 10), `SOURCE = "https://github.com/EdwardChamberlain/IPMI-Fan-Controller"`. Standard targets: `docker-metadata-action`, `image` (args `VERSION`, OCI labels), `image-local`, `image-all` (amd64, arm64), `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/EdwardChamberlain/IPMI-Fan-Controller"
ports:
  - {port: 5000, protocol: tcp, required: true}
env:
  - {name: APP_IPMI_HOST, default: "", required: false}
  - {name: APP_IPMI_USER, default: "", required: false}
  - {name: APP_IPMI_PASS, default: "", required: false}
  - {name: SECRET_KEY, default: "", required: false}
  - {name: APP_LOG_LEVEL, default: "INFO", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: false}
dependencies: []
```
The first five names are read by `config.py`. `SECRET_KEY` empty means the app generates one (changes each restart, invalidating sessions): `start.sh` persists one in `/config`. `PORT` is read only by our `start.sh`, so it is not listed as an app variable. The draft/chart persistence `/data` is not needed (the app stores no data as far as seen); `/config` kept for the secret key.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config
if [ -z "${SECRET_KEY:-}" ]; then
  [ -s /config/secret_key ] || (umask 077; python -c 'import secrets;print(secrets.token_hex(32))' > /config/secret_key)
  SECRET_KEY="$(cat /config/secret_key)"; export SECRET_KEY
fi
cd /app/bin
exec /app/venv/bin/gunicorn --bind "0.0.0.0:${PORT:-5000}" --workers 1 --threads 4 main:app
```
Idempotent, seeds only when missing, no writes to `/app`, binds all interfaces, final `exec`. Never uses `main.py` directly (it forces `debug=True`). `main:app` works because `main.py` does `from flaskr import app` (UNVERIFIED that `app` is importable at module level; confirm in build). Note upstream passes credentials in a shell command line (`shell=True`), visible in the process list inside the container; we cannot change upstream code without a patch (see section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '5000'
  path: /
filePaths:
- /usr/bin/ipmitool
- /app/bin/main.py
```
Port 5000 probed. `/` may redirect or need form data; adjust the path to a route that returns 200 (UNVERIFIED). Test has no env vars, so the secret-key generation and the IPMI-credentials path are covered only by hand (the app starts without credentials, per config defaults None).

## 9. Rootless and read-only-rootfs adaptations

- Chart: `runAsUser 568`, read-only rootfs, PVC `/data`. Our image: `USER apps`, read-only rootfs ok; writes only `/config/secret_key` and `/tmp`.
- Draft expects `/dev/ipmi*` and host kernel modules; code review shows the app talks to the BMC over the network, so no device passthrough and no privileged mode is needed unless the user points `ipmitool` at a local interface. Reconcile in the PR: network IPMI only, `/dev/ipmi*` unsupported unless upstream code is changed (UNVERIFIED; if the code uses `-I open` this changes).
- Python: `/app/venv` read-only; `PIP_CACHE_DIR` and bytecode off.

## 10. Risks, caveats and open questions

- BLOCKER: no licence in the upstream repository. Do not merge until a licence is granted or the maintainers decide otherwise.
- Pinned to a 2023 commit with 4 open issues; not maintained, 20 stars. Updates by hand.
- Fan control writes to the BMC (raw `0x30` Dell commands): a bad setting can overheat a server. The app has no authentication of its own (UNVERIFIED), so expose only on a trusted network.
- Credentials are put into a `shell=True` command (injection and process-list exposure, per code review); mitigated only by network isolation, or by carrying a patch (not planned).
- Python 3.15 vs old Flask-Bootstrap4/WTForms: UNVERIFIED; may force pinning older libraries or choosing a different base.
- `ipmitool` package pin and arm64 build of ipmitool: UNVERIFIED.
- Difficulty is mostly licensing and age, not packaging.

## 11. Build and test steps

```sh
cd apps/ipmi-tools
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ipmi-tools-probe --read-only --tmpfs /tmp \
  -v ipmi-tools-probe-config:/config ipmi-tools:d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246
docker logs -f ipmi-tools-probe
forgetool containers test --image ipmi-tools:d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246 --config ./apps/ipmi-tools/container-test.yaml
docker rm -f ipmi-tools-probe; docker volume rm ipmi-tools-probe-config
```
Expected readiness: gunicorn `Listening at: http://0.0.0.0:5000` and `Booting worker`, port 5000 open, container still running. Manual: reach `http://localhost:5000` from the host. A real BMC test (iDRAC) is not possible in CI.

## 12. PR checklist

- Branch `feat/add-ipmi-tools`; commit/PR title `feat(ipmi-tools): add new container`; target `main`.
- PR template filled, only applicable boxes checked; Notes contain `🤖 This PR is AI generated.`
- CLA reminder: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State the missing upstream licence prominently in the PR.
- Untested unless run: build, Python 3.15 dependency compatibility, gunicorn entrypoint, read-only run, any real IPMI/BMC command. Say so in the PR.
