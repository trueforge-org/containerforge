# Selkies (selkies-project/selkies) and Selkies config reference

## Source URL(s) + date
- https://raw.githubusercontent.com/selkies-project/selkies/main/README.md (fetched 2026-11-27)
- https://docs.linuxserver.io/selkies/user-guide/configuration/ (fetched 2026-11-27, text extracted)
- https://docs.selkies.io redirects to /latest/ (not followed; linuxserver page used instead)

## What it is
- Selkies: streams a desktop or single app to a browser. Python package on PyPI (`selkies`), MPL-2.0 license.
- Part of LinuxServer.io ecosystem; used as base by linuxserver webtop images.

## Env vars (linuxserver Selkies config page)
| Env | Default / function |
| --- | --- |
| PORT | Internal HTTP port, default 3000 |
| CUSTOM_PORT | Internal HTTP port, default 3000 (webtop) |
| CUSTOM_HTTPS_PORT | Internal HTTPS port, default 3001 |
| CUSTOM_WS_PORT | Internal port Selkies websocket server uses |
| CUSTOM_USER / PASSWORD | HTTP basic auth (nginx handles login) |
| SUBFOLDER | Subfolder prefix behind reverse proxy |
| TITLE | Sidebar header and browser tab title |
| SELKIES_MODE | websockets (default) or webrtc |
| SELKIES_ENABLE_BASIC_AUTH | false default |
| SELKIES_WAYLAND_SOCKET_INDEX | Wayland socket index (webtop Dockerfile sets 2) |
| AUTO_GPU | Automatic GPU config when detected |
| DRI_NODE | Encoding GPU device path |
| LC_ALL | Session language |

## Ports (webtop)
- HTTP 3000, HTTPS 3001 (self-signed). Port map in docs lists 3000 and 3001 only.

## Gotchas
- Port 3001 serves HTTPS; port 3000 exists for reverse proxies.
- WebCodecs (video/audio) requires a secure context (HTTPS).
