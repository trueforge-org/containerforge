# linuxserver webtop docs (docs.linuxserver.io/images/docker-webtop)

## Source URL(s) + date
- https://docs.linuxserver.io/images/docker-webtop (fetched 2026-11-27, MkDocs page, text extracted)

## What it is
- Webtop: Alpine, Ubuntu, Fedora, Arch based containers with full desktop environments, accessed via a browser.
- Built on Docker Baseimage Selkies (streams desktop to browser). Full Selkies docs: docs.linuxserver.io/selkies.

## Architectures
- x86-64 (`amd64-<version tag>`), arm64 (`arm64v8-<version tag>`).

## Version tags (upstream docs)
- latest (transitioning to alpine-xfce per docs notice)
- alpine-i3, alpine-kde, alpine-mate, alpine-xfce
- arch-i3, arch-kde, arch-mate, arch-xfce
- debian-i3, debian-kde, debian-mate, debian-xfce
- fedora-i3, fedora-kde, fedora-mate, fedora-xfce
- ubuntu-i3, ubuntu-kde, ubuntu-lxqt, ubuntu-mate, ubuntu-xfce
- dev (Selkies ubuntu development head)
- Openbox and IceWM are not listed (dropped 17.06.25).

## Ports
| Port | Function |
| --- | --- |
| 3000 | Web desktop GUI HTTP (must be proxied) |
| 3001 | Web desktop GUI HTTPS (self-signed cert by default) |

## Env vars
| Env | Function |
| --- | --- |
| PUID | UserID, default 1000 in examples |
| PGID | GroupID, default 1000 in examples |
| TZ | Timezone, e.g. Etc/UTC |
| LC_ALL | Session language, e.g. ja_JP.UTF-8 |
| UMASK | Umask for launched apps, e.g. 022 |
| CUSTOM_USER / PASSWORD | Enables HTTP basic auth (trusted LAN only) |
| AUTO_GPU | Set false to disable automatic GPU config |
| FILE__<VAR> | Load env var from file (Docker secrets) |

## Volumes
- `/config` = abc user home directory.

## Misc
- `--shm-size=1gb` recommended for all desktop images.
- GPU: `--device /dev/dri` for Intel/AMD; Nvidia needs proprietary driver 580+ (not on Alpine images).

## User / UID
- Default user `abc`, mapped via PUID/PGID.

## Security
- Container gives privileged-like access; web terminal has passwordless sudo. No auth by default.
- HTTPS required for WebCodecs.

## Version/changelog facts
- 16.11.26: latest tag transition to alpine-xfce announced.
- 10.06.26: Alpine rebased to 3.24. 07.04.26: Ubuntu rebased to Resolute. 26.03.26: Fedora 44.
- 17.06.25: all images rebased to Selkies; openbox and icewm dropped; Alpine 3.22; Fedora 42.
- 26.09.24: Alpine images swap firefox to chromium.
