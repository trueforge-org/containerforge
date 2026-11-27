# community-valheim-tools/valheim-server-docker (Dockerfile, main)

Source URL(s) + date: https://raw.githubusercontent.com/community-valheim-tools/valheim-server-docker/main/Dockerfile (fetched 2026-11-27). Repo moved: lloesche/valheim-server-docker -> community-valheim-tools/valheim-server-docker (301).

## Build (multi-stage)
- Stage `build-env` (debian:trixie-slim): busybox 1.36.1 (sha256 pinned, built from busybox.config), supervisor 4.3.0 (pip), python-a2s 1.4.1 (pip), Go 1.24.1 (manual tarball), env2cfg and valheim-logfilter (Go, `go test` gated by TESTS).
- Stage `i386-libs` (`--platform=linux/386 debian:buster-slim`): 32-bit libs (libc6-dev, libstdc++6, libsdl2-2.0-0, libcurl4), apt sources repointed to archive.debian.org.
- Final: `debian:trixie-slim`; copies `/usr/local/` from build-env and i386 libs; `COPY fake-supervisord /usr/bin/supervisord`.
- Final apt installs: libc6-dev, libsdl2-2.0-0, curl, iproute2, libcurl4, ca-certificates, procps, locales, unzip, zip, rsync, openssh-client, jq, python3, libpulse-dev, libatomic1, libc6, tini; `dist-upgrade` run.
- steamcmd: downloads `https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz` to `/opt/steamcmd`, runs `su - valheim -c "/opt/steamcmd/steamcmd.sh +login anonymous +quit"` at build.
- `/bin/sh` -> bash; locale en_US.UTF-8; `python` alternative to python3.

## User/UID
- Build args consumed at runtime: `PGID` (default 0) and `PUID` (default 0). `groupadd -g ${PGID:-0} -o valheim`, `useradd -g ${PGID:-0} -u ${PUID:-0} -o --create-home valheim`.

## Paths
- `/config` created (symlinked as `/home/valheim/.config/unity3d/IronGate/Valheim`), `/var/run/valheim`, `/var/log/supervisor`, `/opt/valheim`, `/opt/steamcmd`.
- Scripts in `/usr/local/bin/` (`valheim-server`, `valheim-updater`, `valheim-backup`, `valheim-status`, `bootstrap` in `/usr/local/sbin/`); defaults in `/usr/local/etc/valheim/`.
- Supervisor config `/usr/local/etc/supervisord.conf`.

## Ports
- `EXPOSE 2456-2458/udp`.

## Arch
- Final image debian trixie; i386 libs copied for steamcmd (32-bit).

## Gotchas
- Final-stage `dist-upgrade` runs at build time.
- Build-time `TESTS` arg (default true) runs go/tox/shellcheck tests.
- Full Dockerfile tail beyond ~80 lines not inspected (ENTRYPOINT/USER/VOLUME not captured).
