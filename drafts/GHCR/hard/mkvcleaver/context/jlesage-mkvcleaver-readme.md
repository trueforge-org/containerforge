# Source: jlesage/docker-mkvcleaver README (v26.09.1)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-mkvcleaver/v26.09.1/README.md (fetched 2026-11-27, 43 KB; key sections extracted)

## Env vars
| Var | Default | Notes |
| --- | --- | --- |
| USER_ID | 1000 | app user |
| GROUP_ID | 1000 | |
| KEEP_APP_RUNNING | 0 | restart on crash when 1 |
| DISPLAY_WIDTH | 1920 | README default (chart uses 1280) |
| DISPLAY_HEIGHT | 1080 | README default (chart uses 768) |
| WEB_AUTHENTICATION | 0 | enable web auth |
| WEB_AUTHENTICATION_ALLOW_INSECURE | 0 | not recommended |
| WEB_AUTHENTICATION_USERNAME | (none) | single-user credentials |
| SECURE_CONNECTION | 0 | encrypted GUI access |
| SECURE_CONNECTION_VNC_METHOD | SSL | SSL or TLS |
| SECURE_CONNECTION_CERTS_CHECK_INTERVAL | 60 | seconds, 0 disables |
| WEB_LISTENING_PORT | 5800 | -1 disables HTTP |
| VNC_LISTENING_PORT | 5900 | -1 disables VNC |
| ENABLE_CJK_FONT | 0 | installs WenQuanYi Zen Hei |
| VNC_PASSWORD | (none) | also via /config/.vncpass_clear |
| WEB_HOST_CLIPBOARD_SYNC | enabled by default | |
| WEB_FILE_MANAGER_ALLOWED_PATHS / DENIED_PATHS | | comma-separated |

## Ports
| Port | Proto | Purpose |
| --- | --- | --- |
| 5800 | TCP | web GUI |
| 5900 | TCP | VNC |

## Volumes/paths
| Path | Mode | Purpose |
| --- | --- | --- |
| /config | rw | config, state, logs, certs (/config/certs/*.pem), /config/webauth-htpasswd |
| /storage | rw | host files |

## User/UID
- USER_ID / GROUP_ID env vars control the runtime user (default 1000 per README).

## Config files
- /config/certs/vnc-server.pem, /config/certs/web-privkey.pem, /config/certs/web-fullchain.pem
- /config/.vncpass_clear (plain VNC password, read then encrypted to /config/.vncpass)
- /config/webauth-htpasswd (Apache htpasswd format)

## Gotchas
- Web auth requires SECURE_CONNECTION=1 unless WEB_AUTHENTICATION_ALLOW_INSECURE=1.
- Reverse proxy examples use 127.0.0.1:5800.
- Container docs: GUI at http://<host>:5800.
