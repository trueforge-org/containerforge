# jlesage/docker-makemkv Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-makemkv/v26.09.2/Dockerfile · fetched 2026-11-27 (first ~3500 chars; tail truncated)

## Build
- ARG MAKEMKV_VERSION=2.0.0; downloads makemkv-oss-${V}.tar.gz and makemkv-bin-${V}.tar.gz from www.makemkv.com/download/
- Stage makemkv-bin: `debian:12`, build.sh from src/makemkv-bin; xx-verify of makemkvcon, libmakemkv.so.1, libdriveio.so.0, libmmbd.so.0
- Stage makemkv-oss: `alpine:3.19`, build.sh from src/makemkv-oss; verify makemkv, mmccextr, mmgplsrv
- Cross-compile helper: tonistiigi/xx
- Final base: `jlesage/baseimage-gui:alpine-3.19-v4.14.0`
- Packages (add-pkg): openjdk8-jre-base, wget, sed, findutils, xdpyinfo, lsscsi, util-linux-misc, sg3_utils, qt5-qtbase-x11, adwaita-qt, font-croscore
- Icon: jlesage/docker-templates makemkv-icon.png
- `makemkv-update-beta-key /defaults/settings.conf` at build time

## Env vars (ENV)
| Var | Default |
| --- | --- |
| MAKEMKV_KEY | BETA |
| MAKEMKV_GUI | 1 |
| AUTO_DISC_RIPPER | 0 |
| AUTO_DISC_RIPPER_MAKEMKV_PROFILE | empty |
| AUTO_DISC_RIPPER_EJECT | 0 |
| AUTO_DISC_RIPPER_PARALLEL_RIP | 0 |
| AUTO_DISC_RIPPER_INTERVAL | 5 |
| AUTO_DISC_RIPPER_MIN_TITLE_LENGTH | empty |
| AUTO_DISC_RIPPER_BD_MODE | mkv |
| AUTO_DISC_RIPPER_DVD_MODE | mkv |
| AUTO_DISC_RIPPER_FORCE_UNIQUE_OUTPUT_DIR | 0 |
| AUTO_DISC_RIPPER_NO_GUI_PROGRESS | 0 |

## Volumes / ports
- VOLUME /storage, VOLUME /output
- No EXPOSE in fetched portion

## Gotchas
- Base is Alpine 3.19 here; jdownloader2 upstream uses 3.24.
- Tail of file (EXPOSE/ENTRYPOINT/labels) partly truncated; check raw file before relying on it.
