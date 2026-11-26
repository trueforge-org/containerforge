# Giftie/docker-mediaelch Dockerfile

**Source:** https://raw.githubusercontent.com/Giftie/docker-mediaelch/master/Dockerfile (fetched 2026-11-26)

## Base / stages
- FROM `jlesage/baseimage-gui:ubuntu-18.04-v3`
- Single stage.

## ENV / ARG
| Type | Name | Value |
|---|---|---|
| ENV | LANG | en_US.UTF-8 |
| ENV | LANGUAGE | en_US:en |
| ENV | LC_ALL | en_US.UTF-8 |
| ENV | APP_NAME | "MediaElch" |
| ARG | - | none |

## Packages (active)
- software-properties-common (for add-apt-repository), locales, ffmpeg (runtime, random screenshots)
- mediaelch from PPA `ppa:mediaelch/mediaelch-stable`

## Build commands (active)
- apt-get update -y; apt-get upgrade -y
- add-apt-repository ppa:mediaelch/mediaelch-stable; apt-get update -y
- adduser --disabled-password --gecos "" mediaelch
- chmod +x /usr/local/bin/docker-entrypoint.sh
- locale-gen en_US.UTF-8; update-locale LANG=en_US.UTF-8
- Appends LC_ALL/LANG/LANGUAGE exports to /home/mediaelch/.profile and .bashrc

## Files copied
| Source | Destination |
|---|---|
| entrypoint.sh | /usr/local/bin/docker-entrypoint.sh |
| startapp.sh | /startapp.sh |

## User
- User `mediaelch` (passwordless, no explicit UID). No USER instruction (base image default).

## Volumes
- /movies
- /home/mediaelch/.config/kvibes

## Ports / entrypoint / healthcheck
- EXPOSE, ENTRYPOINT, CMD, HEALTHCHECK: none active (sshd EXPOSE 22, entrypoint and sshd CMD lines are commented out).
- WORKDIR: none.

## Display
- No explicit X11/VNC config; GUI from base image jlesage/baseimage-gui; /startapp.sh is the app start script.

## Gotchas
- Commented-out in source: build-from-source (qmake/make), GCC 8 toolchain, sshd setup, alternate VOLUME line.
