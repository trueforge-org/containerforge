# jlesage/docker-czkawka: repo root and README

Source URL(s) + date: https://github.com/jlesage/docker-czkawka (repo root HTML, fetched 2026-11-27) and https://raw.githubusercontent.com/jlesage/docker-czkawka/v26.09.2/README.md (fetched 2026-11-27, used for facts below).

## Env vars (from README)
| Var | Purpose | Default |
| --- | --- | --- |
| USER_ID | run-as UID | 1000 |
| GROUP_ID | run-as GID | 1000 |
| SUP_GROUP_IDS | supplementary GIDs | (none) |
| TZ | timezone | Etc/UTC |
| KEEP_APP_RUNNING | restart app on crash when 1 | 0 |
| APP_NICENESS | nice value (-20..19; negative needs --cap-add=SYS_NICE) | 0 |
| INSTALL_PACKAGES | apk packages at startup | (none) |
| PACKAGES_MIRROR | apk mirror | (none) |
| CONTAINER_DEBUG | debug logging when 1 | 0 |
| DARK_MODE | dark mode when 1 | 0 |
| DISPLAY_WIDTH | window width | 1920 |
| DISPLAY_HEIGHT | window height | 1080 |
| WEB_AUDIO | audio in browser when 1 | 0 |
| WEB_HOST_CLIPBOARD_SYNC | clipboard sync | 1 |
| WEB_FILE_MANAGER | web file manager when 1 | 0 |
| WEB_FILE_MANAGER_ALLOWED_PATHS | allowed paths (AUTO, ALL, or list) | (see README) |
| WEB_FILE_MANAGER_DENIED_PATHS | denied paths (win over allowed) | (none) |
| WEB_NOTIFICATION | notifications (needs HTTPS) when 1 | 0 |
| WEB_TERMINAL | web terminal when 1 (HTTPS recommended) | 0 |
| WEB_TERMINAL_SHELL_PATH | terminal shell | /bin/sh |
| WEB_AUTHENTICATION | login page when 1 (needs HTTPS) | 0 |
| WEB_AUTHENTICATION_ALLOW_INSECURE | allow auth without SECURE_CONNECTION | 0 |
| SECURE_CONNECTION | HTTPS/VNC TLS when 1 | 0 |
| SECURE_CONNECTION_VNC_METHOD | SSL or TLS | SSL |
| SECURE_CONNECTION_CERTS_CHECK_INTERVAL | cert change check seconds (0 disables) | 60 |
| WEB_LISTENING_PORT | web GUI port (-1 disables) | 5800 |
| VNC_LISTENING_PORT | VNC port (-1 disables) | 5900 |
| VNC_PASSWORD | VNC password | (none) |
| ENABLE_CJK_FONT | install WenQuanYi Zen Hei when 1 | 0 |
| CZKAWKA_GUI_KROKIET | deprecated, ignored | n/a |

## Ports
| Port | Proto | Use |
| --- | --- | --- |
| 5800 | TCP | web GUI |
| 5900 | TCP | VNC |

## Volumes/paths
| Path | Mode | Purpose |
| --- | --- | --- |
| /config | rw | config, state, logs |
| /storage | rw | host files |
- Trash (when enabled in Czkawka): `/config/xdg/data/Trash`.
- Certs: `/config/certs/vnc-server.pem`, `/config/certs/web-privkey.pem`, `/config/certs/web-fullchain.pem`.
- Web auth file: `/config/webauth-htpasswd`. VNC password file: `/config/.vncpass` (and `.vncpass_clear` input).

## User/UID
- Runs as USER_ID/GROUP_ID (default 1000). Mapping of host volume ownership via these vars.

## Gotchas
- Krokiet is no longer in this image (separate jlesage/docker-krokiet image). Container parameters are compatible.
- Upstream says trash is under /config; the TrueCharts chart mounts a separate /trash volume.
