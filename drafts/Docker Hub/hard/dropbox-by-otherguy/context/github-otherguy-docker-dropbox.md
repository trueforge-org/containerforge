# otherguy/docker-dropbox (wrapper repo: Dockerfile, docker-entrypoint.sh, README)

Source URL(s) + fetch date:
- https://github.com/otherguy/docker-dropbox (README, repo page)
- https://raw.githubusercontent.com/otherguy/docker-dropbox/master/Dockerfile
- https://raw.githubusercontent.com/otherguy/docker-dropbox/master/docker-entrypoint.sh
- Fetched 2026-11-26

## What it is
- Wrapper that runs the proprietary Dropbox Linux daemon (dropboxd) in a container. The daemon is downloaded at container start, not baked into the image.
- README: "Run Dropbox inside a Docker container." Local host folder mount or sharing via `--volumes-from`.
- License: MIT (LICENSE.md, per README). The Dropbox daemon itself is closed source under Dropbox terms.

## Install/build steps (Dockerfile)
- `FROM ubuntu:22.04`. LABEL maintainer (wrapper author). ARG DEBIAN_FRONTEND=noninteractive, DEBCONF_NONINTERACTIVE_SEEN=true.
- WORKDIR `/opt/dropbox`; EXPOSE `17500` (comment: not strictly needed with host networking).
- ENV LANG=C.UTF-8, LC_ALL=C.UTF-8.
- RUN 1: `apt-get update` then `apt-get install -y --no-install-recommends software-properties-common gnupg2 curl wget libglapi-mesa libxext-dev libxdamage-dev libxshmfence-dev libxxf86vm-dev libxcb-glx0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present-dev ca-certificates gosu tzdata libc6 libxdamage1 libxcb-present0 libxcb-sync1 libxshmfence1 libxxf86vm1 python3-gpg python3-pip`.
- RUN 2: `mkdir -p /opt/dropbox`; `useradd --home-dir /opt/dropbox --comment "Dropbox Daemon Account" --user-group --shell /usr/sbin/nologin dropbox` (no fixed UID; system assigned); `chown -R dropbox:dropbox /opt/dropbox`.
- VOLUME `["/opt/dropbox"]`.
- ARG VCS_REF=main, VERSION="", BUILD_DATE=""; label-schema labels (version "${VERSION}").
- ENV POLLING_INTERVAL=5, SKIP_SET_PERMISSIONS=false, ENABLE_MONITORING=false.
- COPY `docker-entrypoint.sh /` and `monitoring.py /`.
- No USER instruction (container starts as root; entrypoint uses gosu to drop to `dropbox`).
- ENTRYPOINT `["/docker-entrypoint.sh"]`, CMD `["/opt/dropbox/bin/dropboxd"]`.

## Runtime deps
- python3, python3-pip (for dropbox.py CLI and optional prometheus_client), gosu, tzdata, X11/GL libs listed above (libxcb, libxshmfence, libxxf86vm, libxdamage, libglapi-mesa).

## Entrypoint flow (docker-entrypoint.sh)
1. TZ: if empty, read from /etc/timezone; else check `/usr/share/zoneinfo/${TZ}` exists (exit 1 if not), write /etc/timezone and `ln -fs` /etc/localtime.
2. UID/GID: defaults from `id -u dropbox` / `id -g dropbox`; if GID clashes, usermod/groupdel/groupadd; then `usermod -u ${DROPBOX_UID} -g ${DROPBOX_GID} --non-unique dropbox`.
3. POLLING_INTERVAL: must match `^[0-9]+$`, else set to 5.
4. SKIP_SET_PERMISSIONS: if `true`, only non-recursive `chown` of /opt/dropbox; else `chown -R`. `/opt/dropbox/Dropbox` gets chmod 755 if it exists.
5. Removes stale `command_socket`, `iface_socket`, `unlink.db`, `dropbox.pid` from `/opt/dropbox/.dropbox/`.
6. Version/install (runs if DROPBOX_SKIP_UPDATE empty OR `/opt/dropbox/bin/VERSION` missing):
   - `curl -I -s https://www.dropbox.com/download/?plat=lnx.x86_64` (no redirect follow; reads `Location`), strips whitespace, parses version `X.Y.Z` before `.tar.gz` after `x86_64-`.
   - First time: `mkdir /opt/dropbox/bin`, `/tmp`; `install -dm0 /opt/dropbox/.dropbox-dist` and `chmod u-w /opt/dropbox/.dropbox-dist` (blocks self-update); removes group/other write on /tmp.
   - Update: `curl -# -L $DL | tar xzf - -C $tmpdir` (mktemp), `rm -rf /opt/dropbox/bin/*`, moves `.dropbox-dist/*` into `/opt/dropbox/bin/`; chown/chmod `*.so`.
7. CLI: if `/opt/dropbbox.py` missing (typo in upstream: "dropbbox" so effectively always downloads), `wget -O /opt/dropbox.py https://www.dropbox.com/download?dl=packages/dropbox.py`; writes `/usr/bin/dropbox` bash wrapper for `python3 /opt/dropbox.py "$@"`.
8. `umask 002`; prints timezone; `dpkg-reconfigure --frontend noninteractive tzdata`.
9. Starts daemon in background: `gosu dropbox "$@" &` (PID stored), `trap "/bin/kill -SIGQUIT ${DROPBOX_PID}" INT`.
10. If ENABLE_MONITORING=true: `python3 -m pip install prometheus_client`; `gosu dropbox python3 /monitoring.py -i ${POLLING_INTERVAL} &`.
11. Polling loop: `sleep 5`, then while daemon alive: `gosu dropbox dropbox status` (when /proc/PID and info.json exist), delete /tmp dirs older than 1 day (`-mtime +1`), sleep POLLING_INTERVAL. Script exits when daemon exits (container exits).

## Env vars
| Name | Default | Notes |
| --- | --- | --- |
| TZ | from /etc/timezone | Validated against zoneinfo; README recommends setting it. |
| DROPBOX_UID | 1000 (README) / `id -u dropbox` (script) | Must match owner of mounted files. |
| DROPBOX_GID | 1000 (README) / `id -g dropbox` (script) | Same. |
| POLLING_INTERVAL | 5 | Seconds between status polls. Must be integer. |
| SKIP_SET_PERMISSIONS | false | true = skip recursive chown. |
| DROPBOX_SKIP_UPDATE | unset | true = skip update at startup (daemon may still self-update). |
| ENABLE_MONITORING | false | true = experimental Prometheus endpoint on port 8000 (dropbox_status, dropbox_num_syncing, dropbox_num_downloading, dropbox_num_uploading). |

## Ports
- EXPOSE 17500 (upstream). README: no -p mappings; quickstart uses `--net="host"` for LAN Sync. Port 8000 only with ENABLE_MONITORING.

## Volumes/paths and persistent data
- `/opt/dropbox`: VOLUME. Daemon home with binaries (`/opt/dropbox/bin`) and account settings. Without persistent mount, account must be re-linked each restart.
- `/opt/dropbox/Dropbox`: synced files. Omit on first run so Dropbox creates it.
- `/opt/dropbox/.dropbox`: account settings (README persistence example).
- Optional: `/etc/timezone`, `/etc/localtime`.

## User/UID & permissions
- Image creates `dropbox` system user (no fixed UID), home /opt/dropbox, shell nologin. Runtime UID/GID from DROPBOX_UID/GID (README default 1000, TrueCharts sets 99/100).

## Account linking
1. Start container. 2. `docker logs --follow dropbox` shows the authentication URL. 3. Open in browser and sign in. 4. Success: "This computer is now linked to Dropbox."
- Management: `docker exec -it dropbox gosu dropbox dropbox [command]` (status, help). Version: `docker exec -it dropbox cat /opt/dropbox/bin/VERSION`.

## Gotchas
- macOS: mounting the data folder does not work (issue #6). Dropbox dropped support for several Linux filesystems; the dropbox-filesystem-fix patch no longer bypasses detection in newer clients.
- Linux: watching more than 10,000 folders needs a higher `fs.inotify.max_user_watches` (host setting).
- Upstream typo `/opt/dropbbox.py` means the CLI helper is re-downloaded on every start.
- Daemon may self-update; DROPBOX_SKIP_UPDATE is not fully reliable.

## Arch support
- README does not state supported architectures. Download endpoint is `lnx.x86_64` only (amd64 path).
