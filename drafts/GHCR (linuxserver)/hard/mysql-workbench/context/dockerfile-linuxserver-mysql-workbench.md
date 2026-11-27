# Upstream Dockerfile: linuxserver/docker-mysql-workbench

Source URL(s):
- https://raw.githubusercontent.com/linuxserver/docker-mysql-workbench/4113f475a942/Dockerfile
- Blob variant: https://github.com/linuxserver/docker-mysql-workbench/blob/4113f475a942/Dockerfile
- Fetched 2026-11-27

## What it is
Single-stage Dockerfile on the Selkies desktop-streaming base, Arch Linux userland. Installs Workbench from the Arch repo via pacman.

## Base
- `FROM ghcr.io/linuxserver/baseimage-selkies:arch` (Arch, glibc)

## Args / labels / env
- ARGs: `BUILD_DATE`, `VERSION`, `WORKBENCH_VERSION` (optional pacman version pin, used as `mysql-workbench=<ver>` when set).
- LABEL build_version, maintainer thelamer.
- `ENV TITLE="MySQL Workbench" NO_GAMEPAD="true" PIXELFLUX_WAYLAND=true`

## Install steps (RUN, one layer)
1. `curl -o /usr/share/selkies/www/icon.png` from linuxserver docker-templates (remote icon fetch at build).
2. `pacman -Sy --noconfirm gnome-keyring libsecret "mysql-workbench[=$WORKBENCH_VERSION]" seahorse`
3. `mv /usr/sbin/mysql-workbench /usr/sbin/mysql-workbench-real` (wrapper script is supplied by root/ overlay, not fetched).
4. Writes `/build_version`.
5. Cleanup: `pacman -Scc --noconfirm`, rm `/tmp/*`, `/var/cache/pacman/pkg/*`, `/var/lib/pacman/sync/*`.

## Runtime
- `COPY root/ /` (s6 overlay files, not fetched).
- `VOLUME /config`
- `EXPOSE 3001`
- No USER, ENTRYPOINT or CMD in this file.

## Gotchas
- Keyring stack (gnome-keyring, libsecret, seahorse) is installed upstream; not part of an Ubuntu deb install.
- Upstream uses a wrapper at `/usr/sbin/mysql-workbench` that execs `-real`.
