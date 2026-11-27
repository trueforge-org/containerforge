# Source: netdata/netdata packaging/docker/Dockerfile (tag v2.13.0)

Source URL(s) + date: https://raw.githubusercontent.com/netdata/netdata/v2.13.0/packaging/docker/Dockerfile (fetched 2026-11-27)

## Stages
1. `netdata/builder:v3` AS builder (pre-built deps): copies repo to /opt/netdata.git; ARGs RELEASE_CHANNEL (default nightly; nightly|stable), BUILD_VERSION, RELEASE_SOURCE, CFLAGS, EXTRA_INSTALL_OPTS, DEBUG_BUILD, BUILD_ARCH.
   - If RELEASE_SOURCE set: writes packaging/release-info (version, channel, source).
   - Installs via `./netdata-installer.sh --dont-wait --dont-start-it --use-system-protobuf --disable-ebpf --enable-plugin-otel --enable-plugin-netflow --internal-systemd-journal ${EXTRA_INSTALL_OPTS} --install-no-prefix /` (+ `--stable-channel` if stable).
   - Moves output into /app/{usr,var,etc} tree; installs run.sh and health.sh into /app/usr/sbin.
   - Sets plugin modes: 4755 setuid for cgroup-network, local-listeners, apps.plugin, debugfs.plugin, freeipmi.plugin, go.d.plugin, perf.plugin, ndsudo, slabinfo.plugin, network-viewer.plugin, systemd-journal.plugin; ipmi.plugin u+s.
   - var/lib/netdata and var/cache/netdata: dirs 0770, files 0660; cloud.d 0700.
2. `netdata/base:v3` AS base (final):
   - LABELs: authors, url https://netdata.cloud, documentation https://learn.netdata.cloud, source github, title "Netdata Agent", vendor "Netdata Inc.".
   - ARG NETDATA_UID=201, NETDATA_GID=201; ENV DOCKER_GRP=netdata, DOCKER_USR=netdata.
   - ENV NETDATA_LISTENER_PORT=19999; EXPOSE $NETDATA_LISTENER_PORT.
   - ENV NETDATA_EXTRA_DEB_PACKAGES="".
   - Logs symlinked to /dev/stdout or /dev/stderr under /var/log/netdata.
   - Creates system group and user `netdata` (uid/gid 201, shell nologin, home /etc/netdata).
   - Copies /etc/netdata to /etc/netdata.stock.
   - `ENTRYPOINT ["/usr/sbin/run.sh"]`
   - `HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD /usr/sbin/health.sh`

## Env vars (Dockerfile)
| Var | Default | Notes |
| --- | --- | --- |
| NETDATA_LISTENER_PORT | 19999 | EXPOSE |
| NETDATA_OFFICIAL_IMAGE | from ARG OFFICIAL_IMAGE (false) | |
| DISABLE_TELEMETRY | (commented out) | set to 1 to disable telemetry |
| NETDATA_EXTRA_DEB_PACKAGES | "" | |
| DOCKER_GRP / DOCKER_USR | netdata | |

## Ports
- 19999 (EXPOSE).

## User/UID
- netdata: UID 201, GID 201 (ARG NETDATA_UID / NETDATA_GID).

## Volumes/paths
- /etc/netdata (config, stock copy at /etc/netdata.stock), /var/lib/netdata, /var/cache/netdata, /var/log/netdata (symlinks to stdout/stderr), /usr/libexec/netdata, /usr/share/netdata.

## Healthcheck
- `/usr/sbin/health.sh` every 60s, timeout 10s, 3 retries.

## Gotchas
- Builder/base images are `netdata/builder:v3` and `netdata/base:v3`; both must be available for a rebuild.
- Plugin binaries need setuid 4755 (apps.plugin etc.): restricts non-root/read-only design.
- Build disables eBPF (--disable-ebpf).
- Netdata's own comment: group-write permissions for lib/cache dirs (PR 6543).
