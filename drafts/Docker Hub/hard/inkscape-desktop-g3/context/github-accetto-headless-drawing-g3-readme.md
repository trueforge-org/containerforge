# accetto/headless-drawing-g3 README (G3v8)

Source URL: https://raw.githubusercontent.com/accetto/headless-drawing-g3/master/README.md
Date fetched: 2026-11-26

## Base and stack
- Ubuntu 24.04 LTS, Xfce, TigerVNC, noVNC, Chromium, Firefox, Mesa3D, VirtualGL. Test tools: glxgears, es2tri, glmark2.

## Image names (Docker Hub, accetto)
- `accetto/ubuntu-vnc-xfce-inkscape-g3` (Inkscape, this app's upstream image)
- Also: opengl, blender, drawio, freecad, gimp variants.

## Tags (examples on page)
- `latest`, `latest-vnc` (FEATURES_NOVNC=0), `latest-firefox-default`, `latest-firefox-default-vnc`.

## Build args and variables
| Name | Default | Purpose |
| --- | --- | --- |
| ARG_SUDO_INITIAL_PW | not stated | initial sudo pw, build time |
| FEATURES_NOVNC | enabled | "0" drops noVNC |
| FEATURES_FIREFOX_PLUS | enabled | "0" drops Firefox Plus |
| FEATURES_FIREFOX | not stated | Firefox toggle |
| ARG_FEATURES_USER_GROUP_OVERRIDE | removed since G3v3 | old UID/GID override |

Build-time overrides (G3v3 notes): user name, group name, UID, GID, sudo initial pw.

## User
| Item | Value |
| --- | --- |
| Default | headless:headless |
| UID:GID | 1001:1001 (since G3v6; earlier 1000:1000 and 1001:0) |
| Override | build time and run time |
| Sudo | yes |

## Not on page
- docker run example, flags, ports, volumes, runtime env vars, VNC/noVNC password handling. Point to user guide accetto.github.io/user-guide-g3 and per-image READMEs under docker/.

## Build tooling
- `builder.sh` (single image), `ci-builder.sh` (groups), `util-readme.sh` (Docker Hub READMEs), `secrets.rc` (sourced before build, see example-secrets.rc).
