# jlesage/docker-putty README (tag v26.09.1)

**Source URL(s):** https://raw.githubusercontent.com/jlesage/docker-putty/v26.09.1/README.md · fetched 2026-11-27

## What it is
Docker container for PuTTY, GUI served over web (HTTP) or VNC. Unofficial (not by PuTTY authors).

## Quick start
```
docker run -d --name=putty -p 5800:5800 -v /docker/appdata/putty:/config:rw jlesage/putty
```
Web GUI at http://host:5800.

## Env vars (selection, default)
| var | default | purpose |
| --- | --- | --- |
| USER_ID | 1000 | app runtime uid |
| GROUP_ID | 1000 | app runtime gid |
| SUP_GROUP_IDS | (none) | supplementary gids |
| UMASK | 0022 | file mask |
| LANG | en_US.UTF-8 | locale |
| TZ | Etc/UTC | timezone |
| KEEP_APP_RUNNING | 0 | restart on crash |
| APP_NICENESS | 0 | nice level (-20..19; negative needs extra perms) |
| INSTALL_PACKAGES | (none) | apk packages at startup |
| PACKAGES_MIRROR | (none) | apk mirror |
| CONTAINER_DEBUG | 0 | debug logs |
| DISPLAY_WIDTH | 1920 | window width |
| DISPLAY_HEIGHT | 1080 | window height |
| DARK_MODE | 0 | dark mode |
| WEB_AUDIO | 0 | audio to browser |
| WEB_HOST_CLIPBOARD_SYNC | 0 | clipboard sync |
| WEB_FILE_MANAGER | 0 | web file manager |
| WEB_FILE_MANAGER_ALLOWED_PATHS / DENIED_PATHS | - | path allow/deny lists |
| WEB_NOTIFICATION | 0 | desktop notifications |
| WEB_TERMINAL | 0 | web terminal |
| WEB_TERMINAL_SHELL_PATH | /bin/sh | terminal shell |
| WEB_AUTHENTICATION | 0 | login page (needs SECURE_CONNECTION) |
| WEB_AUTHENTICATION_ALLOW_INSECURE | 0 | not recommended |
| WEB_AUTHENTICATION_TOKEN_VALIDITY_TIME | - | token lifetime hours |
| WEB_AUTHENTICATION_USERNAME / PASSWORD | - | single user creds |
| SECURE_CONNECTION | 0 | HTTPS/VNC encryption |
| SECURE_CONNECTION_VNC_METHOD | SSL | SSL or TLS |
| SECURE_CONNECTION_CERTS_CHECK_INTERVAL | - | cert change check (seconds) |
| WEB_LOCALHOST_ONLY | 0 | web localhost only |
| VNC_LOCALHOST_ONLY | 0 | VNC localhost only |
| WEB_LISTENING_PORT | - | internal web port (rarely changed) |
| VNC_LISTENING_PORT | - | internal VNC port |
| VNC_PASSWORD | (none) | GUI/VNC password |
| ENABLE_CJK_FONT | 0 | WenQuanYi Zen Hei font |

## Ports
| port | proto | use |
| --- | --- | --- |
| 5800 | TCP | web GUI |
| 5900 | TCP | VNC |

## Volumes
| path | rw | purpose |
| --- | --- | --- |
| /config | rw | config, state, logs, persistent files |

Cert paths (when SECURE_CONNECTION): /config/certs/vnc-server.pem, web-privkey.pem, web-fullchain.pem.
VNC password file: /config/.vncpass (see VNC Password section); `/config/.vncpass_clear` supported.

## User/UID
- Runs as USER_ID/GROUP_ID (default 1000:1000).

## Gotchas
- Web auth requires SECURE_CONNECTION unless WEB_AUTHENTICATION_ALLOW_INSECURE=1.
- Web terminal and file manager strongly recommend HTTPS.
