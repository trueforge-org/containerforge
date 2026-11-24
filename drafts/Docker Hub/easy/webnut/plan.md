# webnut — implementation plan
> Source: ./draft.md · Target: apps/webnut/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/rshipp/webNUT (Pyramid + Chameleon + waitress web UI for a NUT server). Default branch is `main` (HEAD `31f6d4a4d6f3e2db4f076924c882eaa913223a0c` on 2026-11-23, from `git ls-remote`) |
| Releases / tags | None. The repo has no tags and no GitHub releases. PyPI `webnut` has a single release `0.0.1` (2020-05-18, sdist only, no license metadata) |
| Version to ship | `0.0.1` (the `version=` in `setup.py`), built from a pinned commit. The draft's "pip install webnut" is not suitable: the PyPI sdist is 2020 code and its `nut2` dependency imports `telnetlib`, removed in Python 3.13 |
| Draft tag | The chart image is `edgd1er/webnut:latest` (unpinned) |
| Renovate | No release datasource exists. Use `datasource=git-refs depName=https://github.com/rshipp/webNUT currentValue=main` on a `COMMIT` variable. `VERSION` stays `0.0.1` |
| License | BSD-3-Clause (GitHub sidebar and `LICENSE`; PyPI metadata is empty) |
| Source archive | `https://github.com/rshipp/webNUT/archive/<COMMIT>.tar.gz` (arch independent, pure Python) |
| Checksum source | None published. Integrity comes from pinning the full commit SHA in the URL. UNVERIFIED: the tarball sha256 (compute once when implementing, optional) |
| Upstream Dockerfile reviewed | `edgd1er/docker-webnut` @ `e637b2e` (python:3.13-alpine3.23, musl, `pip install -e webNUT`, `sed` swaps `nut2` for `nut2-notl` in `setup.py`, symlinks `/app/webNUT/webnut/config.py` to `/config/config.py`, `EXPOSE 6543`, `VOLUME /config`) |
| Runtime deps | `pyramid`, `pyramid_chameleon`, `pyramid_debugtoolbar`, `waitress`, `nut2` (from `setup.py`). `nut2-notl` 2.1.3 exists on PyPI and is the telnetlib-free fork |
| Port | `6543/tcp` (`production.ini`: waitress `host = 0.0.0.0`, `port = 6543`) |
| Start command | `pserve /app/webNUT/production.ini` (README: serve like any Pyramid app) |
| Config | `webnut/config.py` is imported by `views.py` (`from . import config`) and must define `server`, `port`, `username`, `password`. `config.example.py` defaults: `127.0.0.1`, `3493`, `None`, `None`. A NUT connection is made per request (the `WebNUT(...)` object is built in `NUTViews.__init__`), so the UI starts without a reachable UPS |
| Env vars | Upstream reads none. The edgd1er wrapper uses `UPS_HOST` (127.0.0.1), `UPS_PORT` (3493), `UPS_USER` (monuser), `UPS_PASSWORD` (secret) |
| Health | `GET /` (UPS list page; errors if NUT is unreachable, so use tcp for the test) |

## 2. Target layout

```
apps/webnut/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.py      # reads UPS_* from the environment (see section 4)
```

`defaults/` is needed because `COPY . /` only carries allow-listed paths; the file is copied into the app tree at build time. No `root/`. No `DOWNSTREAM_CHANGES.md` (no app builds `FROM` it).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: pure Python web app, matches the draft. The base provides `/app/venv`, `pip`, `curl`, `ca-certificates`. Closest siblings: `apps/bazarr` (python base, app in `/app/bin`) and `apps/changedetection`. UNVERIFIED: Chameleon, zope.interface and MarkupSafe wheels for cp315 on both arches (a `pip download` on arm64 resolved cp315 wheels for MarkupSafe and zope.interface, Chameleon is pure Python). If any fail, drop to the `python:3.14.x` digest used by `apps/piper` with a "stay on 3.14 until ..." comment.

## 4. Dockerfile

1. `ARG VERSION`, `ARG COMMIT`, `USER root`. `ENV HOME=/config PYTHONDONTWRITEBYTECODE=1`.
2. No apt packages.
3. One `RUN`:
   - `mkdir -p /app/webNUT /usr/share/licenses/webnut`
   - `curl -fsSL "https://github.com/rshipp/webNUT/archive/${COMMIT}.tar.gz" | tar xz -C /app/webNUT --strip-components=1`
   - Swap the telnetlib dependency as upstream edgd1er does: `sed -i "s/    'nut2',/    'nut2-notl',/" /app/webNUT/setup.py`
   - `/app/venv/bin/pip install --no-cache-dir -e /app/webNUT` (editable, same as upstream wrapper, so `production.ini` and templates stay in `/app/webNUT`). Alternative if editable installs misbehave on a read-only tree: non-editable install plus copy of `production.ini`.
   - `cp /app/webNUT/LICENSE /usr/share/licenses/webnut/LICENSE`
   - `chown -R apps:apps /app && chmod -R 755 /app && rm -rf /tmp/* /root/.cache`
4. `COPY defaults/config.py /app/webNUT/webnut/config.py` before the chown step (it replaces the need for an `/app` write at runtime).
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6543`, `VOLUME /config`, `WORKDIR /config`.

`defaults/config.py` (no secret ever lands on disk; the app reads the environment at import time):

```python
import os
server = os.environ.get("UPS_HOST", "127.0.0.1")
port = int(os.environ.get("UPS_PORT", "3493"))
username = os.environ.get("UPS_USER") or None
password = os.environ.get("UPS_PASSWORD") or None
```

UNVERIFIED: whether `nut2-notl` expects `port` as int or str (upstream example uses int, the wrapper writes a string). Test both during the run step.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "webnut" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/rshipp/webNUT currentValue=main
  default = "0.0.1"
}
variable "COMMIT" { default = "31f6d4a4d6f3e2db4f076924c882eaa913223a0c" }
variable "LICENSE" { default = "BSD-3-Clause" }
variable "SOURCE"  { default = "https://github.com/rshipp/webNUT" }
```

Because Renovate's git-refs datasource tracks the digest, attach the comment to `COMMIT` rather than `VERSION` when implementing (VERSION is a static label). `target "image"` passes `VERSION` and `COMMIT` as args. Standard targets as in `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/rshipp/webNUT"`.
- `ports`: `6543` / `tcp` / `required: false`.
- `env` (all `required: false`, defaults equal `defaults/config.py`): `UPS_HOST` `127.0.0.1`, `UPS_PORT` `3493`, `UPS_USER` `""`, `UPS_PASSWORD` `""`, `TZ` `Etc/UTC`.
- `volumes`: `/config` / `required: false` (the app keeps no state; the volume exists for consistency with the draft and HOME).
- `dependencies`: none. The external NUT server (`upsd`) is not a ContainerForge app.

## 7. start.sh

```bash
#!/usr/bin/env bash
cd /app/webNUT
exec /app/venv/bin/pserve /app/webNUT/production.ini
```

- Idempotent, writes nothing to `/app` or `/config`.
- Binds `0.0.0.0:6543` through `production.ini`.
- Deliberately no "wait for upsd" loop (the edgd1er wrapper has one): with no env the test run would never open the port.
- Env to config: handled by `config.py` at import time. The password is not written to a file or passed on a command line.
- UNVERIFIED: `pserve` may try to write a `.pyc`/log; `PYTHONDONTWRITEBYTECODE` is set and logging goes to stderr.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '6543'
filePaths:
- /app/webNUT/production.ini
- /app/webNUT/webnut/config.py
- /usr/share/licenses/webnut/LICENSE
```

No `http` probe: `GET /` talks to NUT and fails without an `upsd`. The DB narrowing exception does not apply (no database). Copy the `timeoutSeconds` value from `apps/bazarr` or another python sibling if one exists.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Wrapper writes `/config/config.py` on every start and symlinks it into the package | Static `config.py` baked into `/app` that reads env; nothing is written at runtime |
| Wrapper runs as `user` with a private home | `USER apps` (UID 568), `HOME=/config` |
| Chart `runAsUser 0`, `readOnlyRootFilesystem false` | Not needed: the app writes nothing. Run as `apps`, read-only rootfs, `/tmp` tmpfs |
| Extra persistence | None beyond `/config` (matches draft) |
| pip cache | Disabled (`--no-cache-dir`); build cache removed |

## 10. Risks, caveats and open questions

- Pinning to a commit of an inactive upstream (no releases since 2020). Renovate git-refs will propose every commit on `main`.
- `nut2` vs `nut2-notl`: required on Python 3.13+. The `sed` on `setup.py` is fragile if upstream reformats the dependency list; the build should fail loudly (add `grep -q nut2-notl setup.py`).
- The draft says "pip install webnut"; that gives the 2020 sdist, which the plan does not use.
- Python 3.15 wheel availability is UNVERIFIED (section 3).
- The UI needs a reachable NUT server; with defaults it renders an error page for `GET /`.
- The `UPS_PASSWORD` default of `secret` in the edgd1er wrapper is dropped here (empty means no auth).

## 11. Build and test steps

```sh
cd apps/webnut
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name webnut-probe --read-only --tmpfs /tmp -v webnut-probe-config:/config webnut:0.0.1
docker logs -f webnut-probe          # expect: "Serving on http://0.0.0.0:6543" (waitress)
docker rm -f webnut-probe; docker volume rm webnut-probe-config
forgetool containers test --image webnut:0.0.1 --config ./apps/webnut/container-test.yaml
```

Manual extra: run with `-e UPS_HOST=<nut host>` against a real or stub `upsd` and open `/`.

## 12. PR checklist

- Branch `feat/add-webnut`, commit and title `feat(webnut): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Untested until implemented: build on both arches, Python 3.15 wheel availability, `nut2-notl` port type, real NUT server connection.
- Check boxes only for what was done (do not tick "Built container locally" unless it was).
