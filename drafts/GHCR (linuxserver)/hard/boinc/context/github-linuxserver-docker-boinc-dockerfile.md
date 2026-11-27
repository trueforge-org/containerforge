# linuxserver/docker-boinc Dockerfile (master; identical at pinned f7a1ea8759da)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-boinc/master/Dockerfile (fetched 2026-11-27); https://raw.githubusercontent.com/linuxserver/docker-boinc/f7a1ea8759dae4d9fed9069d86d25aceca07acc2/Dockerfile (blob URL; byte-identical to master).

## What it is
Desktop BOINC manager + client on the linuxserver Selkies base (GUI over browser). Not a headless image.

## Base
- `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute` (single stage).
- ARG: BUILD_DATE, VERSION, BOINC_VERSION (optional apt pin).
- Labels: build_version; maintainer aptalca.

## Env (set in Dockerfile)
| Var | Value |
| --- | --- |
| NVIDIA_DRIVER_CAPABILITIES | compute,video,utility |
| DEBIAN_FRONTEND | noninteractive |
| CUSTOM_PORT | 8080 |
| CUSTOM_HTTPS_PORT | 8181 |
| TITLE | BOINC |
| NO_GAMEPAD | true |
| PIXELFLUX_WAYLAND | true |

## Install steps
1. Icon: curl `boinc-icon.png` (linuxserver docker-templates) -> `/usr/share/selkies/www/icon.png`.
2. `add-apt-repository ppa:costamagnagianfranco/boinc`.
3. Package: `boinc-client` or `boinc-client=${BOINC_VERSION}` if set.
4. apt install (no-install-recommends): boinc-client, at-spi2-core, boinc-client-opencl, boinc-manager, bzip2, xz-utils.
5. `ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so`; `/etc/OpenCL/vendors/nvidia.icd` = `libnvidia-opencl.so.1`.
6. Writes `/build_version`.
7. Cleanup: apt clean, rm `/config/.cache`, `/config/.launchpadlib`, `/tmp/*`, apt lists.
8. `COPY root/ /`.

## Entrypoint/flags
- No ENTRYPOINT/CMD; s6 base.

## Ports
- None (no EXPOSE). Web GUI ports come from CUSTOM_PORT 8080 and CUSTOM_HTTPS_PORT 8181 in base.

## Volumes/paths
- No VOLUME. Config/data dir `/config` (per README and base).

## User/UID
- Not set in Dockerfile (base handles PUID/PGID).

## Arch
- Built for amd64 and arm64 per Hub; x86_64 lib path hardcoded in the symlink step.

## Gotchas
- Depends on a PPA (`ppa:costamagnagianfranco/boinc`), not the main Ubuntu archive.
- `/config/.cache` cleanup targets a path under /config in the build.
