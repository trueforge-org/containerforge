# kitana — implementation plan
> Source: ./draft.md · Target: apps/kitana/ · Difficulty: easy by the draft, but medium in practice (old Python code, see section 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.4.3-2` (tag `0.4.3-2`, no `v` prefix, 2023-04-07). It is the latest release; the repo was last pushed 2023-07-25. The draft links the same release. |
| Renovate | `datasource=github-releases depName=pannal/Kitana versioning=loose` (tags such as `0.4.3-2` are not strict semver). |
| License | `MIT` (`LICENSE` starts with an icon credit and then "MIT License"; GitHub reports `NOASSERTION` for that reason). |
| Source (`SOURCE`) | https://github.com/pannal/Kitana |
| What it is | A CherryPy web UI that talks to a Plex server and its Sub-Zero plugin. The README says that without a valid Plex.TV authentication Kitana can do nothing, and all auth data is kept server-side in session files. |
| Download (both arches) | `https://github.com/pannal/Kitana/releases/download/0.4.3-2/Kitana.zip` (source zip with a top-level `Kitana/` folder; pure Python, so one artifact for amd64 and arm64). The asset name was `Kitana.zip` for this release but older releases used `Kitana-0.4.3-1.zip`, so the name may change in future releases (UNVERIFIED). |
| Checksum source | Upstream publishes none. sha256 of `Kitana.zip` computed locally on 2026-11-23: `9cfb39683df31dca1d3d1718f898177f6000c342986ac2d9c73adfd56d086325`. Pin it as a Dockerfile ARG and bump it together with `VERSION`. |
| Port | `31337/tcp`. This differs from the draft's inferred `8000`. Verified in `kitana.py` (`--bind`, default `0.0.0.0:31337`) and the upstream `EXPOSE 31337`. |
| Env vars | None read directly. `-A/--global-token` accepts the name of an env var holding the Plex token. All configuration is by CLI flags: `-B host:port`, `-p prefix`, `-P` (behind proxy), `-PH`, `-PB`, `-i`, `-l`, `--shadow-assets`, `-t`, `-pt`, `--allow-not-owned`. |
| Data path | Upstream `VOLUME /app/data`. `kitana.py` creates `<baseDir>/data/sessions` (cherrypy FileSession, timeout 525600 minutes) and nothing else. |
| Runtime writes | `plugins/SassCompilerPlugin.py` runs at every start. It walks `os.getcwd()`, deletes and recreates every `css` dir next to a `sass` dir (`static/css`) and compiles SASS with `libsass`. |
| Python requirements | `requirements.txt` pins `cryptography<3.5`, `cherrypy==18.8.0`, `requests==2.26.0`, `xmltodict==0.12.0`, `libsass==0.21.0`, `jinja2==3.0.3`, `PyGithub==1.55`, `furl==2.1.3`, `ndg-httpsclient==0.5.1`, `certifi==2022.12.7`, `cffi==1.15.0`. Only `cherrypy`, `requests`, `xmltodict`, `sass`, `jinja2`, `furl`, `github` are imported by the code (grep). |
| Python 3.15 findings | `pip download libsass==0.21.0` fails to build on Python 3.15.2 here, so the pins cannot be installed as they are. `kitana.py` and `util/update.py` import `distutils`, which was removed from Python 3.12. Unpinned `cherrypy 18.10.0`, `requests`, `xmltodict`, `libsass 0.23.0`, `jinja2 3.1.6`, `PyGithub 2.10.0`, `furl 2.1.4` install on Python 3.15.2 (pip resolution only). Whether the app then runs correctly was NOT tested: UNVERIFIED. |
| Upstream Dockerfile reviewed | https://github.com/pannal/Kitana/blob/master/Dockerfile (`python:3.8-alpine`, `ENTRYPOINT ["python","kitana.py"]`, `EXPOSE 31337`, `VOLUME /app/data`; no `USER`). |

## 2. Target layout

```
apps/kitana/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- `start.sh` is needed to run from a writable copy in `/tmp` and link the sessions dir (section 7).
- No `defaults/`, `etc/`, `scripts/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.
- Closest siblings: `apps/bazarr` (python base, zip release, `start.sh` running `python`) and `apps/changedetection` (installs into `/app/venv`).

## 3. Base image

```
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```

Pure Python tool, as the draft says. The base ships `/app/venv` (pip, setuptools and wheel pinned), `curl`, `unzip` and build tools. The 3.15 base is what is available; if the compatibility patches in section 4 do not hold, ask maintainers whether an older python base tag may be used (like `apps/changedetection`, which pins 3.14.8).

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION`; `ARG KITANA_SHA256=9cfb39683df31dca1d3d1718f898177f6000c342986ac2d9c73adfd56d086325`.
2. `USER root` for the install only.
3. `ENV PYTHONUNBUFFERED=1` is already set by the base; pip cache is disabled there (`PIP_NO_CACHE_DIR=1`). Use `/tmp` for any scratch.
4. `RUN set -eux` step:
   - `curl -fsSLo /tmp/Kitana.zip "https://github.com/pannal/Kitana/releases/download/${VERSION}/Kitana.zip"`
   - `echo "${KITANA_SHA256}  /tmp/Kitana.zip" | sha256sum -c -`
   - `unzip -q /tmp/Kitana.zip -d /tmp/kitana-src && mv /tmp/kitana-src/Kitana /app/kitana`
   - Relax the old pins and drop packages the code does not import:
     `sed -E 's/[<>=!~].*$//' /app/kitana/requirements.txt | grep -viE '^(ndg-httpsclient|cffi|cryptography)$' > /tmp/requirements.txt && echo packaging >> /tmp/requirements.txt`
   - `/app/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt`
   - Replace the removed `distutils` imports: `sed -i 's/^from distutils.util import strtobool$/strtobool = lambda v: str(v).strip().lower() in ("y","yes","t","true","on","1")/' /app/kitana/kitana.py` and `sed -i 's/^from distutils.version import LooseVersion$/from packaging.version import Version as LooseVersion/' /app/kitana/util/update.py`. `LooseVersion` is only constructed and compared in the code (grep), so `packaging.version.Version` is a drop-in for `0.4.3-2` style tags.
   - Build-time import gate: `cd /app/kitana && /app/venv/bin/python -c "import cherrypy, sass, jinja2, furl, github, requests, xmltodict, packaging; import util.update"` so a bad dependency set fails the build and not the first run.
   - Licence: `mkdir -p /usr/share/licenses/kitana && cp /app/kitana/LICENSE /usr/share/licenses/kitana/LICENSE`
   - `chown -R apps:apps /app/kitana && chmod -R 755 /app/kitana && rm -rf /tmp/*`
5. `COPY --chmod=0755 . /`
6. `EXPOSE 31337`, `VOLUME /config`, `WORKDIR /config`.
7. Final `USER apps`.

No apt packages are installed (wheels are used for 3.15; libsass 0.23 ships abi3 wheels, UNVERIFIED for aarch64). `PIP_PREFER_BINARY=1` is already set by the base.

## 5. docker-bake.hcl

- `APP` = `kitana`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=pannal/Kitana versioning=loose
  default = "0.4.3-2"
  ```
- `LICENSE` = `MIT`, `SOURCE` = `https://github.com/pannal/Kitana`
- The four standard targets plus `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl` (`image-all` = amd64 + arm64).
- Validate with `cd apps/kitana && docker buildx bake --print`.
- The `KITANA_SHA256` ARG default in the Dockerfile has to change with every `VERSION` bump (renovate will not do that; note it in the PR).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pannal/Kitana"
ports:
  - port: 31337
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No `dependencies:` (draft: none). The Plex server is external to ContainerForge (`apps/plex` exists but Kitana only needs a reachable Plex.TV login and PMS, not a hard dependency). Extra flags are passed as container args, not env, so no further env entries are invented.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

RUN_DIR=/tmp/kitana

# Sessions (Plex auth) are the only state worth keeping.
mkdir -p /config/sessions

# Kitana recompiles its SASS into static/css at every start (it deletes and
# rewrites that dir under the current working directory) and uses <script dir>/data,
# so run a fresh copy from /tmp. /app stays read-only.
rm -rf "${RUN_DIR}"
cp -a /app/kitana "${RUN_DIR}"
rm -rf "${RUN_DIR}/data"
mkdir -p "${RUN_DIR}/data"
ln -s /config/sessions "${RUN_DIR}/data/sessions"

cd "${RUN_DIR}"
exec /app/venv/bin/python kitana.py -B 0.0.0.0:31337 "$@"
```

- Idempotent; empty `/config` works; nothing is written to `/app`; the app copy is about 1.8 MB.
- Binds on all interfaces. Extra upstream flags such as `-P`, `-p /kitana` or `-A <ENV_NAME>` are appended from the container args (the base entrypoint passes `"$@"` to `/start.sh`).
- `exec` hands PID 1 (via tini) to the Python process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '31337'
filePaths:
- /start.sh
- /app/kitana/kitana.py
- /usr/share/licenses/kitana/LICENSE
```

`180` follows the python siblings (`babybuddy`, `beets`). A `tcp` probe is used because the root page's behaviour without Plex auth is UNVERIFIED; switch to `http` with `path: /` if a local run returns 200. No env vars are required.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `<baseDir>/data/sessions` | Symlinked in the `/tmp` copy to `/config/sessions` (persistent, empty at first start). |
| `static/css` rewritten by the SASS plugin at every start (cwd walk) | Runs inside the `/tmp/kitana` copy. |
| Python bytecode / pip caches | `PYTHONDONTWRITEBYTECODE` and `PIP_NO_CACHE_DIR` are set by the base; nothing else. |

Draft expectations: the chart runs UID 0, writable rootfs, `/app/data` PVC. Ours runs as UID 568, read-only rootfs, not privileged, and persistence moves to `/config/sessions`. Existing session data from `/app/data/sessions` is not migrated; users log in to Plex.TV again.

## 10. Risks, caveats and open questions

- **Main risk: code and pins are from 2021-2023 (Python 3.8 era).** `distutils` is gone and pins cannot build on 3.15. The plan patches the two import lines and unpins dependencies, but the running app on Python 3.15.2 plus CherryPy 18.10 / Jinja2 3.1 / PyGithub 2.x is UNVERIFIED. Expect up to a few fix rounds in the build protocol. If it cannot be made to work, fall back to an older python base or mark the app `unfixable`.
- The base's `setuptools` is pinned by the python image; no `distutils` shim is relied on.
- The draft's port `8000` is wrong; the real port is `31337`.
- Draft caveat "needs a Plex server URL and token by hand" is partly right: users log in with Plex.TV in the UI, and the Plex server needs the Sub-Zero plugin; `-A` can supply a global token.
- Upstream has `update_check` using PyGithub against GitHub; it only logs a notice when a newer release exists and needs outbound network (UNVERIFIED failure mode if offline).
- `Kitana.zip` asset naming may change; the checksum ARG must be refreshed with each version.
- No musl, GPU, privileged or arm64 blockers (pure Python; wheel availability on aarch64 is UNVERIFIED).

## 11. Build and test steps

```sh
cd apps/kitana
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create kitana-probe-config
docker run --rm -d --name kitana-probe --read-only --tmpfs /tmp \
  -v kitana-probe-config:/config kitana:0.4.3-2
docker logs -f kitana-probe      # expect "Starting SassCompilerPlugin", "Compiling ... static/sass", CherryPy "Serving on http://0.0.0.0:31337" and no traceback
docker rm -f kitana-probe; docker volume rm kitana-probe-config
forgetool containers test --image kitana:0.4.3-2 --config ./apps/kitana/container-test.yaml
```

Also open `http://<ip>:31337/` from another container or the host to prove it is not localhost-only, and restart the container with the same volume to check `/config/sessions` is reused.

## 12. PR checklist

- Branch `feat/add-kitana` from `main`; commit and PR title `feat(kitana): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, check only boxes that apply, and put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` shows status).
- Document in the PR: the two source patches, the unpinned dependencies, the `/tmp` run copy, and the checksum ARG bump rule.
- Untested so far: everything. The image has not been built or run; the Python 3.15 compatibility is unproven; arm64 is not built; no Plex server was available to test a real login.
