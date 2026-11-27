# Source: jlesage/docker-mkvtoolnix README (v26.10.1)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-mkvtoolnix/v26.10.1/README.md (fetched 2026-11-27, 42 KB; key sections extracted)

## Env vars
| Var | Default | Notes |
| --- | --- | --- |
| USER_ID | 1000 | runtime user |
| GROUP_ID | 1000 | runtime group |
| SUP_GROUP_IDS | (none) | supplementary groups |
| UMASK | 0022 | octal |
| LANG | (locale) | e.g. en_US.UTF-8 |
| TZ | Etc/UTC | |
| KEEP_APP_RUNNING | 0 | restart on exit when 1 |
| APP_NICENESS | 0 | -20..19; negative needs extra perms |
| INSTALL_PACKAGES | (none) | Alpine packages at startup |
| PACKAGES_MIRROR | (none) | Alpine mirror |
| CONTAINER_DEBUG | 0 | |
| DISPLAY_WIDTH | 1920 | |
| DISPLAY_HEIGHT | 1080 | |
| DARK_MODE | 0 | |
| WEB_AUDIO | 0 | |
| WEB_HOST_CLIPBOARD_SYNC | (enabled by default per README text) | |
| WEB_FILE_MANAGER | 0 | |
| WEB_FILE_MANAGER_ALLOWED_PATHS | (none allowed by default) | comma list |
| WEB_FILE_MANAGER_DENIED_PATHS | (none) | denied wins |
| WEB_NOTIFICATION | 0 | needs HTTPS |
| WEB_TERMINAL | 0 | |
| WEB_TERMINAL_SHELL_PATH | /bin/sh | |
| WEB_AUTHENTICATION | 0 | needs secure connection |
| WEB_AUTHENTICATION_ALLOW_INSECURE | 0 | not recommended |
| WEB_AUTHENTICATION_TOKEN_VALIDITY_TIME | 24 | hours |
| WEB_AUTHENTICATION_USERNAME / PASSWORD | (none) | single user |
| SECURE_CONNECTION | 0 | |
| SECURE_CONNECTION_VNC_METHOD | SSL | SSL or TLS |
| SECURE_CONNECTION_CERTS_CHECK_INTERVAL | 60 | 0 disables |
| WEB_LOCALHOST_ONLY | 0 | |
| VNC_LOCALHOST_ONLY | 0 | |
| WEB_LISTENING_PORT | 5800 | -1 disables HTTP |
| VNC_LISTENING_PORT | 5900 | -1 disables VNC |
| VNC_PASSWORD | (none) | |
| ENABLE_CJK_FONT | 0 | WenQuanYi Zen Hei |

## Ports
| Port | Proto | Purpose |
| --- | --- | --- |
| 5800 | TCP | web GUI |
| 5900 | TCP | VNC |

## Volumes/paths
| Path | Mode | Purpose |
| --- | --- | --- |
| /config | rw | config, state, logs, certs, webauth-htpasswd |
| /storage | rw | host files |

## Config files
- /config/certs/vnc-server.pem, web-privkey.pem, web-fullchain.pem
- /config/.vncpass_clear, /config/.vncpass
- /config/webauth-htpasswd

## Gotchas
- Same env/feature set as the mkvcleaver image (shared jlesage baseimage-gui).
- Web file manager and terminal are off by default.
