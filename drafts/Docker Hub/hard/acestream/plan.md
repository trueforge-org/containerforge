# acestream — implementation plan
> Source: ./draft.md · Target: apps/acestream/ · Difficulty: hard (likely blocked on licence and CPython 3.10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Chart/draft tag `2.1.1.1` of `vstavrinov/acestream-service` (Docker Hub tags: `latest` and `2.1.1.1` both pushed 2025-10-30, amd64 only). The service tag is the wrapper's own version. The engine inside is `3.2.11` (`ACE_VERSION="3.2.11_ubuntu_22.04_x86_64_py3.10"` in `vstavrinov/acestream-engine`). |
| Renovate | No GitHub releases or tags exist on `vstavrinov/acestream-service` (`/releases/latest` redirects to `/releases`). Use `datasource=docker depName=vstavrinov/acestream-service versioning=loose` as the tracker for the tag, and bump the engine tarball URL by hand. |
| License | Wrapper repo has no LICENSE file (404 on `raw/.../LICENSE`): UNVERIFIED. The Ace Stream engine is closed source; redistribution terms were not found: UNVERIFIED. Do not publish until clarified (see section 10). |
| Source URL | https://github.com/vstavrinov/acestream-service (wrapper), https://acestream.org/ (engine) |
| Downloads | amd64 only: `https://download.acestream.media/linux/acestream_3.2.11_ubuntu_22.04_x86_64_py3.10.tar.gz` (HTTP 200, 77,019,795 bytes, sha256 measured today `9b6bbd76a55e5a434641afae3b9cf8e6154ce1cf392152ec3aed5ac265432b2e`). The tarball is not versioned-by-URL beyond the filename. No arm64 build found. |
| Checksum | None published by the vendor. The sha256 above is our own measurement and can be pinned in the Dockerfile. |
| Wrapper files | `search.py`, `setup.cfg`, `default.conf`, `nginx.conf` in `vstavrinov/acestream-service` (master `0fa3ec9...`). Dockerfile installs `nginx`, `pip install gunicorn flask git+https://github.com/vstavrinov/acestream_search.git`. |
| Upstream Dockerfile reviewed | `acestream-service/Dockerfile` at the draft commit and `vstavrinov/acestream-engine/Dockerfile` (base `python:3.10`). Engine start: `./start-engine --client-console --live-cache-type memory`. |
| Engine internals | `start-engine` sets `LD_LIBRARY_PATH=${ROOT}/lib` and runs `acestreamengine`. `readelf -d` shows `NEEDED libpython3.10.so.1.0`; the `lib/` tree holds `cp310` wheels and `py3.10` eggs. It needs a CPython 3.10 shared library plus `pip install -r requirements.txt` (`pycryptodome lxml apsw psutil pynacl iso8601 aiohttp`). |
| Real env vars | Only those the wrapper's CMD reads: `PORT` (nginx listen port, default 80), `ENTRY` (external host port used to rewrite stream URLs, default empty), `SCHEME` (`https` default or `http`), plus `TMP`, `PYTHONDONTWRITEBYTECODE`, `COLUMNS` as ENV. |
| Ports | nginx front on `$PORT` (80 default; the chart sets 8008), engine HTTP API `6878` on localhost (nginx proxies it), gunicorn `search.py` on `127.0.0.1:3031`. Standard engine stream port `6868` is rewritten by nginx `sub_filter`. |
| Runtime paths | Everything lives in `/dev/shm` (`/dev/shm/.ACEStream`, `/dev/shm/tmp`, copied `/dev/shm/nginx`). The image runs as user `ace` (uid 1000 per chart). |

## 2. Target layout

```
apps/acestream/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/nginx/acestream.conf.template   # nginx server block copied from upstream default.conf (adapted)
  scripts/search.py                   # only if vendored from upstream; see section 4 for the alternative
```

- `etc/` and `scripts/` are on the `.dockerignore` allow-list; no `root/`.
- No `DOWNSTREAM_CHANGES.md` (no downstream consumers).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

The wrapper layer (Flask/gunicorn search) fits the python base, but the closed engine needs CPython 3.10 specifically, so the image would carry two Pythons: 3.15 for the search service and a 3.10 shared build for the engine. nginx is installed from apt (the `nginx` app is the alternative base but would then lack Python). Closest siblings: `apps/bazarr` (python + venv) and `apps/it-tools` (nginx config).

## 4. Dockerfile

1. `ARG VERSION`, `ARG ENGINE_VERSION=3.2.11`, `ARG TARGETARCH`; fail the build early on non-amd64: `RUN test "${TARGETARCH}" = "amd64"`. Therefore `image-all` must be amd64 only (see section 5).
2. `USER root`; apt packages not in base (check with `dpkg -l` first): `nginx`, `unzip`, plus whatever supplies CPython 3.10 with `libpython3.10.so.1.0`. On ubuntu 26.04 `python3.10` is not in the archive (UNVERIFIED, check `apt-cache policy python3.10`), so the likely route is `uv python install 3.10` (python-build-standalone) into `/usr/local`, and then verifying `ldd` of `acestreamengine` resolves `libpython3.10.so.1.0` (UNVERIFIED whether the standalone build ships a shared libpython; this is the main technical risk).
3. Download and verify, then extract to `/app/engine`:
   ```dockerfile
   RUN curl -fsSL -o /tmp/ace.tgz "https://download.acestream.media/linux/acestream_${ENGINE_VERSION}_ubuntu_22.04_x86_64_py3.10.tar.gz" && \
       echo "9b6bbd76a55e5a434641afae3b9cf8e6154ce1cf392152ec3aed5ac265432b2e  /tmp/ace.tgz" | sha256sum -c - && \
       mkdir -p /app/engine && tar xzf /tmp/ace.tgz -C /app/engine && \
       cd /app/engine/lib && for e in *.egg; do unzip -q -o "$e"; rm -f "$e"; done
   ```
   The upstream engine Dockerfile also unzips the `.egg` files into `lib/`, mirrored above.
4. Install the engine's pip requirements with the 3.10 interpreter into a venv under `/app/venv310` (`uv venv --python 3.10` then `uv pip install -r /app/engine/requirements.txt`), with `UV_CACHE_DIR=/tmp/uv-cache`. Install `gunicorn flask` plus the `acestream_search` package into the 3.15 venv following `.github/instructions/python-runtime.instructions.md` (read it again before writing: `/app/venv`, caches to `/tmp`). Pin `acestream_search` to a commit, not the moving `git+https` HEAD.
5. Licence files: there is no vendor licence file in the tarball (`tar tzf` shows only `requirements.txt`-class text files, UNVERIFIED for licence text). Write a short `/usr/share/licenses/acestream/NOTICE` pointing at https://acestream.org/ and the wrapper repo.
6. `chown -R apps:apps /app && chmod -R 755 /app`, remove `/tmp/*`, apt lists, then `USER apps`.
7. `ENV TMPDIR=/tmp HOME=/tmp PORT=8080 SCHEME=http ENTRY=` (see section 6 for why 8080), `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`.

## 5. docker-bake.hcl

- `APP = "acestream"`, `LICENSE`: UNVERIFIED. The engine is proprietary; use the SPDX expression `LicenseRef-Proprietary` only after legal review, and do not merge with a guessed id. `SOURCE = "https://github.com/vstavrinov/acestream-service/"`.
- `VERSION` default `"2.1.1.1"` with `// renovate: datasource=docker depName=vstavrinov/acestream-service versioning=loose`. `ARG VERSION` in the Dockerfile must equal it; `ENGINE_VERSION` stays a separate ARG with its own default (3.2.11) and is not renovated.
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, group `default`; set `image-all.platforms = ["linux/amd64"]` only, because there is no arm64 engine. Note this deviates from the standard two-platform list on purpose.
- `docker buildx bake --print` must pass.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/vstavrinov/acestream-service/"
ports:
  - port: 8080        # nginx front (draft's port 80 moved, rootless)
    protocol: tcp
    required: false
env:
  - {name: PORT, default: "8080", required: false}
  - {name: SCHEME, default: "http", required: false}
  - {name: ENTRY, default: "", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: true}
```

- 6878 is bound to localhost behind nginx and is not published, so it is not listed (no false port claims). No `dependencies:`.
- `PORT`, `SCHEME`, `ENTRY` are the real variable names read by upstream's CMD. The upstream default of `SCHEME` is `https`; this image defaults to `http` for direct use, which is a deliberate change and must match `start.sh`.

## 7. start.sh

1. `mkdir -p /tmp/ace/.ACEStream /tmp/ace/tmp /tmp/nginx/{conf.d,lib,logs}`; upstream symlinks `.ACEStream` next to the binary into `/dev/shm`, which is impossible on read-only `/app`, so instead export `HOME=/tmp/ace` and `TMPDIR=/tmp/ace/tmp` (UNVERIFIED that the engine honours `HOME` for `.ACEStream`; upstream used a symlink next to the binary, so test it and fall back to `bind`-free alternatives such as running from a copy of the engine in `/tmp`).
2. Render the nginx config from `/etc/nginx/acestream.conf.template` into `/tmp/nginx/conf.d/default.conf` with `sed`, replacing `PORT` with `${PORT:-8080}`, `SCHEME` with `${SCHEME:-http}` and `ENTRY` with `${ENTRY:+:$ENTRY}`, exactly as upstream's CMD does. Use a full `nginx.conf` with `pid /tmp/nginx/nginx.pid`, `error_log /dev/stderr`, `access_log /dev/stdout` and all `*_temp_path` under `/tmp/nginx` (the upstream `nginx.conf` already uses `/dev/shm/nginx` for pid and includes).
3. Start `gunicorn --bind 127.0.0.1:3031 search:app &` from the venv, then `nginx -c /tmp/nginx/nginx.conf -g 'daemon off;' &`. nginx listens on `0.0.0.0:${PORT}` (upstream `listen PORT;`).
4. Start the engine as the third background process (same flags as upstream; it stays on localhost behind nginx): `/app/engine/start-engine --client-console --live-cache-type memory &`. Because step 5 needs a supervising shell, the script cannot end in a plain `exec` of the engine; it ends in the `wait -n` loop and then exits non-zero (deliberate deviation from the `exec` rule, UNVERIFIED that signals reach children: add a `trap` that forwards SIGTERM).
5. Three processes without a supervisor: if any dies, the container keeps serving a broken front. Add a small `wait -n` loop that exits when any background child exits.
6. Idempotent: nothing is seeded in `/config`; all state is ephemeral by design (`--live-cache-type memory`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
filePaths:
- /app/engine/start-engine
- /app/engine/acestreamengine
```

- An `http` probe on `/search.m3u` is possible (served by gunicorn behind nginx), but that route may call out to the internet; keep `tcp` and only add the HTTP probe after checking it returns without network. UNVERIFIED.
- `timeoutSeconds`: copy a similar multi-process sibling (`apps/bookstack` uses 240); 120 is a placeholder.
- Not DB-dependent, so no narrowing comment.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/dev/shm/.ACEStream`, `/dev/shm/tmp`, `/dev/shm/engine_runtime.json` (symlinked into `/srv/ace`) | `/tmp/ace/...` via `HOME`/`TMPDIR`; test that the engine writes only there. |
| `/dev/shm/nginx` (config copy, pid, lib) | `/tmp/nginx`. |
| `/var/log/nginx/*.log` (symlinked to stdout/stderr) | write straight to `/dev/stdout`/`/dev/stderr`. |
| `/var/lib/nginx` (symlinked to `/dev/shm/nginx/lib`) | all `*_temp_path` directives under `/tmp/nginx`. |
| nginx port 80 | `PORT=8080` default (non-root cannot bind 80). |

The chart ran as uid 1000 with `readOnlyRootFilesystem: false`; the new image runs as `apps` with the rootfs read-only. The engine must not be privileged (nothing in the chart or upstream indicates it needs it, though "unknown" in the draft is still UNVERIFIED). Chart service port 8008 maps to the container `PORT`; document that deployments set `PORT` accordingly.

## 10. Risks, caveats and open questions

- BLOCKER candidate: redistribution of the closed-source Ace Stream engine is not cleared (draft caveat). Decide with the maintainers before any build or PR; the wrapper repo also has no licence file.
- BLOCKER candidate: the engine needs a CPython 3.10 shared library; ubuntu 26.04 and the python base ship 3.15. If `libpython3.10.so.1.0` cannot be provided, the port cannot be done on ubuntu (the upstream image is Debian `python:3.10`, which is glibc, so `COPY --from=vstavrinov/acestream-service` is not a clean route either: it would need the whole interpreter tree).
- amd64 only: no arm64, so `image-all` is amd64-only and downstream arm64 users are unsupported.
- Engine from 2022-era Ubuntu 22.04 build running on 26.04 glibc: UNVERIFIED runtime compatibility (bundled `libavcodec` 58 etc. use `LD_LIBRARY_PATH`).
- Engine version 3.2.11 is old and unmaintained by the wrapper; the wrapper's last push was 2025-10-30.
- Multi-process container without a supervisor; mitigated only by the `wait -n` loop.
- Streaming of copyrighted live TV via this tool may be unlawful in some places; confirm intended use.

## 11. Build and test steps

Run from the repo root, one app only, in this order (per `build-test-protocol.instructions.md`):

```sh
cd apps/acestream
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name acestream-probe --read-only --tmpfs /tmp \
  -v acestream-probe-config:/config acestream:2.1.1.1
docker logs -f acestream-probe     # expect: nginx started, gunicorn "Listening at: http://127.0.0.1:3031", engine startup lines; no "libpython3.10" load error
cd ../.. && forgetool containers test --image acestream:2.1.1.1 --config ./apps/acestream/container-test.yaml
docker rm -f acestream-probe; docker volume rm acestream-probe-config
```

- From outside the container, confirm `curl -sI http://<container-ip>:8080/` reaches the engine through the nginx proxy to 6878 (a plain tcp probe only proves nginx listens).
- Fresh volume per round; round limit 10.

## 12. PR checklist

- [ ] Do not open a PR until the licence question in section 10 is answered by the maintainers.
- [ ] Branch `feat/add-acestream`, commit and PR title `feat(acestream): add new container`, target `main`.
- [ ] PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; only tick boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] `docker buildx bake --print` passes; `ARG VERSION` equals the bake default; final `USER apps`; `COPY --chmod=0755 . /` kept.
- [ ] State the amd64-only platform list in the PR.
- [ ] Untested at plan time: everything runtime (CPython 3.10 shared lib, engine start on glibc 26.04, `HOME` handling, nginx temp paths, `/search.m3u`), and the licence status.
- [ ] No files outside `apps/acestream/`; no `root/`; no secrets.
