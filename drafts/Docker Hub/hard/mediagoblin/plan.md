# mediagoblin — implementation plan
> Source: ./draft.md · Target: apps/mediagoblin/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.15.0` (latest non-rc tag `v0.15.0`; `v0.15.0rc1` and `rc2` also exist) |
| Renovate | sr.ht is not a Renovate datasource: `// renovate: datasource=git-tags depName=mediagoblin packageName=https://git.sr.ht/~mediagoblin/mediagoblin extractVersion=^v(?<version>\d+\.\d+\.\d+)$ versioning=semver`. Release candidates are excluded by the regex. UNVERIFIED: that Renovate can list tags from sr.ht. |
| License | AGPL-3.0-or-later (setup.cfg says `AGPLv3`; source headers say "or any later version"). Also ships `licenses/AGPLv3.txt` and `CC0_1.0.txt`. |
| Source | https://git.sr.ht/~mediagoblin/mediagoblin (draft links https://mediagoblin.org/) |
| Download | `https://git.sr.ht/~mediagoblin/mediagoblin/archive/v0.15.0.tar.gz`. Same for amd64 and arm64 (pure Python plus pip wheels). |
| Checksum | None published. sha256 of the tarball fetched today is `8290079a9f0010bebb45c5e303e99dd153ba416c4178e18a9eb2abcd106f3549`. UNVERIFIED: that sr.ht archives are byte-stable over time. Pin it as an `ARG` and, if a later build mismatches, re-check against `git archive` of the tag before updating. |
| Upstream Dockerfile reviewed | In-repo `Dockerfile` (v0.15.0): Debian bookworm-slim, `python3-venv`, `python3-gst-1.0`, gstreamer plugins, `poppler-utils`, `libexiv2-27`, entrypoint script, `EXPOSE 6543`, `HEALTHCHECK curl http://localhost:6543/`. The draft's `mtlynch/mediagoblin` Dockerfile is a dev image on Debian buster and is obsolete. |
| Install | `setup.cfg` is a standard PEP 517 package (`python_requires >=3.7`), so `pip install .` works. Extras: `audio` (numpy), `video` (`pygobject<3.51`), `raw_image` (`py3exiv2`). Core deps include PasteScript, waitress, celery, SQLAlchemy>=1.4, Pillow, soundfile, bcrypt, bleach, PyLD. |
| Ports | 6543/tcp (Paste server `broadcast` in `paste.ini` is `0.0.0.0:6543`; the default section is `127.0.0.1`) |
| Config | `paste.ini` and `mediagoblin.ini` (from `mediagoblin.example.ini`). `paste.ini` reads `mediagoblin_local.ini` and `mediagoblin.ini` from its own directory. `data_basedir` defaults to `%(here)s/user_dev` (media goes to `user_dev/media/{queue,public}`). SQLite `mediagoblin.db` is the default `sql_engine`. |
| Env vars | Only `CELERY_ALWAYS_EAGER` is read by the app itself (`mediagoblin/app.py` line 148). `ADMIN_USER`, `ADMIN_PASSWORD`, `ADMIN_EMAIL`, `BROKER_URL`, `PLUGINS`, `SKIP_MIGRATE`, `FORCE_RECONFIG` are read by the upstream `entrypoint.sh`, so they are ours to re-implement in `start.sh`. |
| CLI | `gmg dbupdate`, `gmg assetlink`, `gmg adduser --username --password --email`, `gmg makeadmin <user>` (from the upstream entrypoint). Serve: `paster serve /srv/paste.ini --server-name=broadcast`. |

## 2. Target layout

```
apps/mediagoblin/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/mediagoblin.ini   # derived from mediagoblin.example.ini, see section 7
  defaults/paste.ini         # server section bound to 0.0.0.0
```
No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a base).

## 3. Base image

Decision: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` with the system Python and a venv created with `--system-site-packages`. Reason: video and audio processing needs `python3-gst-1.0` and `python3-gi` from apt, and those bindings are bound to the distro Python. The draft proposes `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. That base works for image and PDF only, because gi cannot be shared with a custom Python, and Python 3.15 may break old packages (PasteScript, Paste, celery). Use the python base only as a fallback and document that gstreamer features are then off. Closest sibling: `apps/bazarr` for the venv and `/app` layout.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG SRC_SHA256`, `USER root`.
2. `apt-get install -y --no-install-recommends python3 python3-venv python3-dev python3-gi python3-gst-1.0 gir1.2-gstreamer-1.0 gir1.2-gst-plugins-base-1.0 gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav poppler-utils ffmpeg sqlite3 libjpeg-dev libpng-dev libffi-dev libsndfile1 build-essential curl ca-certificates` (the draft list plus what the upstream Dockerfile installs). Package names on 26.04 are UNVERIFIED. Remove `build-essential` and `-dev` packages after the venv build if the size matters. Clean apt lists.
3. Fetch and verify: `curl -fL -o /tmp/mg.tgz https://git.sr.ht/~mediagoblin/mediagoblin/archive/v${VERSION}.tar.gz && echo "${SRC_SHA256}  /tmp/mg.tgz" | sha256sum -c -`, extract to `/tmp/src --strip-components=1`.
4. `python3 -m venv --system-site-packages /app/venv && /app/venv/bin/pip install --no-cache-dir "/tmp/src[audio]"` (`paster` comes from PasteScript, which is already in `install_requires`). Add `[video]` only if `pygobject<3.51` builds against Ubuntu's `libgirepository` dev files. Otherwise rely on the apt `python3-gi` via system site packages. Use `PIP_CACHE_DIR=/tmp/pip`.
5. Copy `licenses/` and `COPYING` to `/usr/share/licenses/mediagoblin/`.
6. Keep a copy of `mediagoblin.example.ini` and `paste.ini` in `/app/mediagoblin-defaults/` (read-only source for seeding).
7. `ENV HOME=/config PATH=/app/venv/bin:$PATH PYTHONDONTWRITEBYTECODE=1 XDG_CACHE_HOME=/tmp/.cache`, `chown -R apps:apps /app`, `rm -rf /tmp/*`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6543`, `VOLUME /config`.

The python-runtime rule applies: `/app/venv` is read-only at runtime, caches go to `/tmp`, and no `/config/venv`.

## 5. docker-bake.hcl

- `APP=mediagoblin`, `LICENSE=AGPL-3.0-or-later`, `SOURCE=https://git.sr.ht/~mediagoblin/mediagoblin`.
- `VERSION` `0.15.0` with the renovate comment from section 1, and `SRC_SHA256` (manual bump, mention in the PR). Pass both as `args`.
- Standard four targets plus `group "default"`. Check with `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://git.sr.ht/~mediagoblin/mediagoblin"`.
- `ports`: 6543 tcp, required false.
- `env`: `TZ` (`Etc/UTC`), `CELERY_ALWAYS_EAGER` (`true`, read by the app), `ADMIN_USER` (`admin`), `ADMIN_PASSWORD` (empty: generated and logged on first run), `ADMIN_EMAIL` (`admin@example.com`), `SQL_ENGINE` (empty means the default SQLite in `/config`). The last four are handled by our `start.sh`, not by MediaGoblin.
- `volumes`: `/config` required (config, SQLite DB, `user_dev/media`).
- `dependencies`: none required (SQLite default). `opt_dependencies`: `postgresql` ✅ (via `SQL_ENGINE=postgresql://...`). The draft's claim of a mandatory database does not hold: SQLite is the default.

## 7. start.sh

1. `mkdir -p /config/user_dev/{media/queue,media/public,plugin_static,theme_static} /tmp/.cache`.
2. Seed only when missing: `cp -n /app/mediagoblin-defaults/paste.ini /config/paste.ini` and `mediagoblin.ini` from the example (`defaults/mediagoblin.ini`). In `paste.ini` set the `broadcast` server to `host = 0.0.0.0`, `port = 6543`.
3. If `SQL_ENGINE` is set, rewrite the `sql_engine` line in `/config/mediagoblin.ini` on every start (so a changed value applies), escaping `|` and `&` for `sed`. Do not put a DB password on the command line.
4. `export CELERY_ALWAYS_EAGER=${CELERY_ALWAYS_EAGER:-true}`. With eager mode no separate celery worker is needed. If a user sets it to `false`, they must also run a worker, which this image does not start (see section 10).
5. `cd /config && gmg -cf /config/mediagoblin.ini dbupdate && gmg -cf /config/mediagoblin.ini assetlink` on every start (both are idempotent per upstream).
6. First-run admin: if `/config/.admin-created` is missing, generate a password when `ADMIN_PASSWORD` is empty, run `gmg adduser` and `gmg makeadmin`, log the user name (and the generated password once, as upstream does), then touch the marker. The password reaches `gmg` as an argument, so it is briefly visible in the process list. UNVERIFIED: whether `gmg adduser` can read the password from stdin. Check `gmg adduser --help`.
7. Final: `exec paster serve /config/paste.ini --server-name=broadcast`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '6543'
http:
- port: '6543'
  path: /
filePaths:
- /app/venv/bin/gmg
- /app/venv/bin/paster
- /usr/share/licenses/mediagoblin/COPYING
```
No env is needed, because SQLite starts without a DB service, so there is no DB narrowing. The admin-creation path runs with defaults (a generated password) and is therefore partly covered. Check the `ADMIN_PASSWORD` path by hand.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/srv/mediagoblin` (paste.ini, mediagoblin.ini, DB, `user_dev`) | `/config` |
| `user_dev/media/{queue,public}` | `/config/user_dev/media/...` (persistent uploads) |
| `gmg assetlink` symlinks | `/config/user_dev/{plugin,theme}_static` |
| Python bytecode, pip and Babel caches | `PYTHONDONTWRITEBYTECODE=1`, `/tmp` |
| Entrypoint `usermod`, `chown /srv`, `su mediagoblin` | dropped; we run as `apps` (568) from the start |

Draft expectation of root (UID 0, writable rootfs) is rejected. The var path `/var/lib/mediagoblin` from the chart becomes `/config`. No privileged mode.

## 10. Risks, caveats and open questions

- Largest risk: Ubuntu 26.04 system Python is new, and old packages (PasteScript, Paste, celery) may fail on it. If so, pin versions in a constraints file inside the Dockerfile, and do not edit upstream sources.
- Celery: only eager mode is covered. Large video transcodes then run inside the web request path and can time out. A real worker needs a broker (`BROKER_URL`) and a second process, which would be a follow-up (`gmg celery`).
- `pygobject<3.51` build needs gir dev packages. If it cannot build, video and audio fall back to the apt `python3-gi` through system site packages.
- sr.ht availability and archive stability, as in section 1.
- The draft says "needs database": not true by default, SQLite is enough for small sites.
- No arm64 blocker is known: all dependencies are pure Python or apt packages.

## 11. Build and test steps

```sh
cd apps/mediagoblin
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create mediagoblin-probe-config
docker run --rm -d --name mediagoblin-probe --read-only --tmpfs /tmp -v mediagoblin-probe-config:/config mediagoblin:0.15.0
docker logs -f mediagoblin-probe   # expect the dbupdate run, "NEW ADMINISTRATOR ACCOUNT CREATED", then Paste serving on http://0.0.0.0:6543
docker rm -f mediagoblin-probe; docker volume rm mediagoblin-probe-config
forgetool containers test --image mediagoblin:0.15.0 --config ./apps/mediagoblin/container-test.yaml
```
Also test a restart on the same volume (no second admin, no DB reset), and upload one image and one video by hand to prove the gstreamer path.

## 12. PR checklist

- Branch `feat/add-mediagoblin`, commit and PR title `feat(mediagoblin): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- List untested items: arm64, video and audio processing, PostgreSQL mode, a separate celery worker, whether Renovate can read sr.ht tags.
- Confirm `bake --print`, `VERSION` and `SRC_SHA256` aligned between bake and Dockerfile, license files shipped, `USER apps`, an empty `/config` start.
