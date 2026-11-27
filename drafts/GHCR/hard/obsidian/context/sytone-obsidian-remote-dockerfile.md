# Source: sytone/obsidian-remote Dockerfile (commit ac1c8e6c)

Source URL(s) + date: https://raw.githubusercontent.com/sytone/obsidian-remote/ac1c8e6c956b252782a0a6acf2aa3172cd4105a3/Dockerfile (fetched 2026-11-27; blob variant = same)

## Build
- `FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal` (Ubuntu 20.04, linuxserver s6 base).
- LABEL authors github@sytone.com; source https://github.com/sytone/obsidian-remote; title "Container hosted Obsidian MD"; description "Hosted Obsidian instance allowing access via web browser".
- apt (no-recommends): curl, libnss3, dbus-x11, uuid-runtime; autoclean; removes apt lists, /var/tmp/*, /tmp/*.
- ARG OBSIDIAN_VERSION=0.15.9.
- Download: https://github.com/obsidianmd/obsidian-releases/releases/download/v$OBSIDIAN_VERSION/Obsidian-$OBSIDIAN_VERSION.AppImage -> /obsidian.AppImage (curl -L).
- Extract: `/obsidian.AppImage --appimage-extract` (chmod +x first).
- ENV: CUSTOM_PORT=8080, GUIAUTOSTART=true, HOME=/vaults, TITLE="Obsidian v$OBSIDIAN_VERSION".
- COPY root/ /.
- EXPOSE 8080, 27123, 27124. VOLUME ["/config","/vaults"].
- No USER, no ENTRYPOINT (inherited from linuxserver base).

## Runtime deps
- linuxserver rdesktop-web (KasmVNC/web desktop, s6), libnss3, dbus-x11, uuid-runtime.

## Env vars (Dockerfile)
| Var | Default |
| --- | --- |
| CUSTOM_PORT | 8080 |
| GUIAUTOSTART | true |
| HOME | /vaults |
| TITLE | Obsidian v0.15.9 |

## Ports
- 8080 (web UI), 27123 (http API), 27124 (https API).

## Volumes
- /config, /vaults.

## Gotchas
- Upstream AppImage pinned to Obsidian 0.15.9 (amd64 only in this Dockerfile's download; AppImage is x86_64).
- HOME=/vaults in upstream (persistent path).
