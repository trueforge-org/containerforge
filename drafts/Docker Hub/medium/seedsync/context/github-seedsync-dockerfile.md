# GitHub: ipsingh06/seedsync (Dockerfile at ff2a103, default config script, release v0.8.6)

Source URL(s): raw src/docker/build/docker-image/Dockerfile at ff2a103; raw setup_default_config.sh (master); api releases/tags/v0.8.6; api releases/latest (fetched 2026-11-27)

## Release
- Tag `v0.8.6`, published 2020-12-31T04:49:58Z. Asset: `seedsync_0.8.6_amd64.deb` (only asset listed).
- `GET /releases/latest` returns tag `v0.8.6` (same as the tagged release; no newer release at fetch time).

## Upstream Dockerfile (ff2a103, docker-image dir)
- ARG STAGING_REGISTRY=localhost:5000, ARG STAGING_VERSION=latest.
- Stage `seedsync_run_python_env`: `FROM python:3.8-slim`. apt (after sed to add contrib non-free): gcc, libssl-dev, lftp, openssh-client, p7zip, p7zip-full, p7zip-rar, bzip2, curl, libnss-wrapper, libxml2-dev, libxslt-dev, libffi-dev. RAR codec symlink. get-pip.py; `pip3 install poetry`; `poetry install --no-dev` in /app/python (poetry.lock).
- ENV LC_ALL=C.UTF-8, LANG=C.UTF-8.
- Stage `seedsync_run_python_devenv`: poetry install with dev deps.
- Stage `seedsync_run_python`: COPY src/python to /app/python.
- Stages `seedsync_build_angular_export` and `seedsync_build_scanfs_export`: from STAGING_REGISTRY images (`seedsync/build/angular/export`, `seedsync/build/scanfs/export`). NOT public: must be rebuilt or extracted from the .deb.
- Final `seedsync_run`: COPY /html to /app/html, /scanfs to /app/scanfs; setup_default_config.sh to /scripts/; ssh/scp wrappers in /usr/local/sbin; run_as_user to /usr/local/bin; root ssh config StrictHostKeyChecking no.
- `groupadd -g 1000 seedsync`, `useradd -r -u 1000 -g seedsync seedsync`; mkdir /config and /downloads owned seedsync.
- `USER seedsync`; `RUN /scripts/setup_default_config.sh` at build.
- `CMD ["python", "/app/python/seedsync.py", "-c", "/config", "--html", "/app/html", "--scanfs", "/app/scanfs"]`.
- `EXPOSE 8800`.

## setup_default_config.sh (raw master)
- Sets CONFIG_DIR=/config, SETTINGS_FILE=/config/settings.cfg.
- Runs `python /app/python/seedsync.py -c /config --html / --scanfs / --exit` (errors ignored) to create settings.cfg.
- Replaces `local_path = <replace me>` with `\/downloads\/` (sed); prints settings file before and after.

## Env vars
- Upstream Dockerfile sets only LC_ALL, LANG. No app env vars.

## Ports
- 8800/tcp.

## Volumes/paths
- `/config` (settings.cfg), `/downloads` (local_path default).

## User/UID
- seedsync uid/gid 1000 (created with useradd -r -u 1000).

## Runtime deps
- python 3.8 (upstream), lftp, openssh-client, p7zip (+rar codec), libxml2/libxslt, libffi, libssl.

## Gotchas
- Upstream Python 3.8; poetry lock pins untested on newer Python.
- Angular frontend and scanfs come from non-public staging registry images.
- Build-time config generation runs the app once with `--exit`.
