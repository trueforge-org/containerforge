# tvhproxy — implementation plan
> Source: ./draft.md · Target: apps/tvhproxy/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No releases or tags. Pin the last commit `08096e664aca5b59059de7f609bd9e0aaba95191` (2018-01-08). The repo is ARCHIVED (read-only), so it will never change. Use the date `20180108` as `VERSION` and keep the commit in `TVHPROXY_COMMIT`, as `apps/nextcloud-imaginary` does |
| Renovate | `datasource=git-refs depName=https://github.com/jkaberg/tvhProxy versioning=loose` on `TVHPROXY_COMMIT` (nothing will be proposed, the repo is archived) |
| License | GitHub reports NOASSERTION. `LICENSE` text: "Copyright (c) 2016 by Joel Kaaberg and contributors... Some rights reserved. Redistribution and use in source and binary forms ... permitted provided that the following conditions are met" followed by three conditions (source notice, binary notice, no endorsement). SPDX `BSD-3-Clause` (full file read 2026-11-25) |
| Source | https://github.com/jkaberg/tvhProxy |
| Download | `https://raw.githubusercontent.com/jkaberg/tvhProxy/<commit>/tvhProxy.py`, `.../templates/device.xml`, `.../LICENSE`, `.../requirements.txt` (arch independent) |
| Checksum | UNVERIFIED: none published. A commit-pinned URL is immutable, so that is the integrity anchor |
| Upstream Dockerfile | The traced image is `chvb/docker-tvhproxy` (alpine 3.6, py-flask, py-requests, py-gevent, `wget` of master's `tvhProxy.py`, `su duser`). Reviewed, only used for the run command (`python /opt/tvhproxy/tvhProxy.py`) |

From `tvhProxy.py` (verified): env vars `TVH_BINDADDR` (default empty string = all interfaces), `TVH_URL` (default `http://test:test@localhost:9981`), `TVH_PROXY_URL` (default `http://localhost`), `TVH_TUNER_COUNT` (6), `TVH_WEIGHT` (300), `TVH_CHUNK_SIZE` (1048576), `TVH_PROFILE` (`pass`). Server: gevent `WSGIServer((bindAddr, 5004))`, so the port is fixed at 5004. Requirements: `flask`, `requests`, `gevent`. It renders `templates/device.xml`, so that directory is needed next to the script. Latest PyPI versions seen: flask 3.1.3, requests 2.34.2, gevent 26.9.0 (gevent is not pinned upstream).

## 2. Target layout

```
apps/tvhproxy/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Single Flask/gevent script. Closest sibling: `apps/bazarr` (venv install, `/app/bin` layout). The draft's `unzip` apt package is not needed, because individual files are fetched by commit URL.

## 4. Dockerfile
1. `ARG VERSION`, `ARG TVHPROXY_COMMIT` (default equal to the bake default), `USER root`, `ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 HOME=/tmp`.
2. `RUN mkdir -p /app/tvhproxy/templates /usr/share/licenses/tvhproxy`, then `curl -fsSL` each of `tvhProxy.py` (to `/app/tvhproxy/`), `templates/device.xml` (to `/app/tvhproxy/templates/`) and `LICENSE` (to `/usr/share/licenses/tvhproxy/LICENSE`) from `https://raw.githubusercontent.com/jkaberg/tvhProxy/${TVHPROXY_COMMIT}/...`.
3. `/app/venv/bin/pip install --no-cache-dir flask requests gevent` (PyPI has cp315 manylinux wheels for x86_64 and aarch64 for gevent 26.9.0 and greenlet 3.5.6, checked 2026-11-25; if a later release has none, add `build-essential` and purge it in the same layer).
4. `chown -R root:root /app/tvhproxy && chmod -R a+rX /app/tvhproxy`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5004`, `VOLUME /config`, `WORKDIR /app/tvhproxy` (read-only, the app only reads it).
The app keeps no state, but the settings schema requires a `/config` volume entry (see section 6).

## 5. docker-bake.hcl
- `APP = "tvhproxy"`
- `VERSION` default `"20180108"` and `TVHPROXY_COMMIT` default the full commit sha above, each preceded by `// renovate: datasource=git-refs depName=https://github.com/jkaberg/tvhProxy versioning=loose` (as in `apps/nextcloud-imaginary/docker-bake.hcl`). UNVERIFIED: how Renovate would treat the date-style `VERSION`; the repo is archived. Pass both through `args` in `image`.
- `LICENSE = "BSD-3-Clause"`, `SOURCE = "https://github.com/jkaberg/tvhProxy"`
- Standard four targets and default group. Validate with `docker buildx bake --print`.

## 6. settings.yaml
Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/jkaberg/tvhProxy"`.
- ports: `5004` tcp (required true).
- env, all `required: false` and defaults identical to the script: `TVH_URL` (`http://test:test@localhost:9981`), `TVH_PROXY_URL` (`http://localhost`), `TVH_BINDADDR` (`""`), `TVH_TUNER_COUNT` (`"6"`), `TVH_WEIGHT` (`"300"`), `TVH_CHUNK_SIZE` (`"1048576"`), `TVH_PROFILE` (`pass`), `TZ` (`Etc/UTC`).
- volumes: `- path: /config` with `required: false`. The app is stateless, but the schema requires at least one volume and requires `/config` to be listed, so `[]` is invalid.
- dependencies: `- name: tvheadend` ✅ (`apps/tvheadend` exists; a Tvheadend server is needed at runtime for the channel list).

## 7. start.sh
```bash
#!/usr/bin/env bash
cd /app/tvhproxy
exec /app/venv/bin/python /app/tvhproxy/tvhProxy.py
```
The script reads its env directly. `TVH_BINDADDR` is empty by default, which binds all interfaces (verify from outside, per the start-script rules). Credentials are inside `TVH_URL`, which is how upstream is configured; document that they are visible in the container environment.

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
http:
- port: '5004'
  path: /discover.json
filePaths:
- /app/tvhproxy/tvhProxy.py
- /app/tvhproxy/templates/device.xml
- /usr/share/licenses/tvhproxy/LICENSE
```
`/discover.json` is rendered from config only (no Tvheadend call), so it answers with no env vars. (`/lineup.json` calls Tvheadend, do not probe it.)

## 9. Rootless and read-only-rootfs adaptations
- Upstream writes nothing (no files, no DB). The only runtime artifacts are Python bytecode (disabled) and the gevent monkey-patching in memory. Nothing needs a `/config` or `/tmp` remap except `HOME=/tmp`.
- The draft's TrueCharts values use UID 0 and a writable rootfs; here `USER apps` and a read-only rootfs are fine. No extra persistence.

## 10. Risks, caveats and open questions
- Needs a reachable Tvheadend (the sibling `apps/tvheadend`), set through `TVH_URL`; `TVH_PROXY_URL` must be the URL clients use to reach this container, or the HDHomeRun discovery advertises `http://localhost`.
- Archived and unmaintained upstream, last change 2018, with a gevent/Flask codebase of that age (`from gevent import monkey` ordering, `Flask` templates). UNVERIFIED on Flask 3.x / Python 3.15; test `/discover.json` and `/device.xml`.
- GitHub does not machine-detect the licence (see section 1); the text is the three-clause BSD licence.
- The draft says "tracks upstream master": this plan pins the final commit instead.
- No blockers (pure Python, no arm64 issue).

## 11. Build and test steps
```sh
cd apps/tvhproxy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tvhproxy-probe --read-only --tmpfs /tmp -v tvhproxy-probe-config:/config tvhproxy:20180108
docker logs -f tvhproxy-probe
curl -fsS http://<container-ip>:5004/discover.json
docker rm -f tvhproxy-probe; docker volume rm tvhproxy-probe-config
forgetool containers test --image tvhproxy:20180108 --config ./apps/tvhproxy/container-test.yaml
```
Readiness signal: the process stays up and port 5004 answers `/discover.json` (the script prints no startup line).

## 12. PR checklist
- Branch `feat/add-tvhproxy`, commit `feat(tvhproxy): add new container`, target `main`.
- Fill in the PR template, check only the true boxes.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: the lineup path against a real Tvheadend, arm64, and behaviour on Python 3.15 with current Flask/gevent.
