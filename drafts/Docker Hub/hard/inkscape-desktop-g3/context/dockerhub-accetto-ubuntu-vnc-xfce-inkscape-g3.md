# Docker Hub accetto/ubuntu-vnc-xfce-inkscape-g3

Source URL: https://hub.docker.com/r/accetto/ubuntu-vnc-xfce-inkscape-g3
Date fetched: 2026-11-26

## Image
- `accetto/ubuntu-vnc-xfce-inkscape-g3` (publisher accetto). Headless Ubuntu 24.04 + Xfce + VNC/noVNC + Inkscape (G3v8).
- Tags described: `latest` (VNC/noVNC), `chromium` (adds Chromium), `firefox` (adds Firefox).
- `latest` digest sha256:55697f8bb..., 288 MB, updated about 9 months before fetch. Pulls 10K+. Arch not shown.
- Only command shown: `docker pull accetto/ubuntu-vnc-xfce-inkscape-g3`. No run example, volumes or env var list. Points to external user guide.

## Ports
| Port | Use |
| --- | --- |
| 5901 | VNC |
| 6901 | noVNC (browser) |

## Notes from page
- Chromium runs in no-sandbox mode. Chromium from Ubuntu 18.04 packages; Firefox from Mozilla Team PPA (snap not supported in containers).
- Env vars, VNC params, user and group can be overridden (per external user guide).
