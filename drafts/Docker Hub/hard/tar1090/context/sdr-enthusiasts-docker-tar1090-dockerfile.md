# sdr-enthusiasts/docker-tar1090 Dockerfile

Source URL: https://raw.githubusercontent.com/sdr-enthusiasts/docker-tar1090/d89fb2efbe182198a0b9cde4d537b3ccd3250253/Dockerfile (pinned commit, fetched 2026-11-26)
Source blob URL (same file): https://github.com/sdr-enthusiasts/docker-tar1090/blob/d89fb2efbe182198a0b9cde4d537b3ccd3250253/Dockerfile

## Stages
- Optional telegraf stage: `FROM telegraf:1.26 AS telegraf` (tagged lines `##telegraf##`; creates `/tmp/emptyfile`)
- Final: `FROM ghcr.io/sdr-enthusiasts/docker-baseimage:wreadsb`
- SHELL: `["/bin/bash", "-o", "pipefail", "-c"]`
- No ARG declared. `##BRANCH##` placeholder inside RUN (defaults to main if unreplaced).

## ENV
| Var | Value |
| --- | --- |
| BEASTPORT | 30005 |
| MLATPORT | 30105 |
| GITPATH_TIMELAPSE1090 | /opt/timelapse1090 |
| HTTP_ACCESS_LOG | "false" |
| HTTP_ERROR_LOG | "true" |
| TAR1090_INSTALL_DIR | /usr/local/share/tar1090 |
| TAR1090_UPDATE_DIR | /var/globe_history/tar1090-update |
| INTERVAL | 8 |
| HISTORY_SIZE | 450 |
| ENABLE_978 | no |
| GZIP_LVL | 3 |
| CHUNK_SIZE | 60 |
| INT_978 | 1 |
| COMPRESS_978 | "" |
| TIMELAPSE1090_SOURCE | /run/readsb |
| TIMELAPSE1090_INTERVAL | 10 |
| TIMELAPSE1090_HISTORY | 24 |
| TIMELAPSE1090_CHUNK_SIZE | 240 |
| GRAPHS1090_REDUCE_IO | "false" |
| UPDATE_TAR1090 | "true" |
| PTRACKS | 8 |

## Build (single RUN block, bind-mounts context at /app/)
- Temp pkgs: git (removed after). Kept: nginx-light, collectd-core, rrdtool, bash-builtins, libpython3.11, libncurses6, jq. apt with no-suggests/no-recommends.
- Bias-T: downloads `09-rtlsdr-biastee-init` and `09-rtlsdr-biastee-down` to `/etc/s6-overlay/scripts/` (chmod +x).
- nginx: removes `/etc/nginx/sites-enabled/default`; copies `/app/rootfs/etc/nginx.tar1090/*` to `/etc/nginx/`; copies `nginx-tar1090-webroot.conf` from install dir to `/etc/nginx/`.
- tar1090: runs `/app/rootfs/tar1090-install.sh` with `/run/readsb`, `webroot`, install dir. Records tar1090 and tar1090-db versions in `VERSIONS`; removes update dir; downloads `aircraft.csv.gz` (tar1090-db) into install dir.
- graphs1090: shallow clone of wiedehopf/graphs1090 master into `/usr/share/graphs1090/git`; copies db, python, shell, config, `html`, `nginx-graphs1090.conf`, `default` -> `/etc/default/graphs1090`; runs `adjust-scripts-s6-sh`; creates `/usr/share/graphs1090/data-symlink`; symlinks `data` -> `/run/readsb`.
- telegraf (tagged): creates `/etc/telegraf/telegraf.d`; appends version to `/VERSIONS`.
- Container version: clones docker-tar1090 (branch) to `/tmp/clone`; writes `/.CONTAINER_VERSION` (timestamp_commit_branch).
- Cleanup: autoremove temp pkgs, apt clean, removes `/src/*`, `/tmp/*`, `/var/lib/apt/lists/*`, `/var/cache/*`; prints `/VERSIONS`.

## Ports / healthcheck
- EXPOSE 80/tcp
- HEALTHCHECK `--start-period=600s --interval=600s` running `/healthcheck.sh`

## Not present
- VOLUME, USER, ENTRYPOINT, CMD, WORKDIR.
