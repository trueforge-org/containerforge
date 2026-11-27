# jlesage/docker-qdirstat README (tag v26.09.1)

**Source URL(s):** https://raw.githubusercontent.com/jlesage/docker-qdirstat/v26.09.1/README.md (first ~9000 chars; env table complete) · fetched 2026-11-27

## What it is
Docker container for QDirStat, GUI over web (HTTP) or VNC. Unofficial.

## Quick start
```
docker run -d --name=qdirstat -p 5800:5800 \
  -v /docker/appdata/qdirstat:/config:rw \
  -v /home/user:/storage:ro \
  jlesage/qdirstat
```
GUI at http://host:5800. Host files appear under `/storage`.

## Env vars (same set as the jlesage GUI images)
Documented shared vars, with defaults:
| var | default | purpose |
| --- | --- | --- |
| USER_ID / GROUP_ID | 1000 / 1000 | runtime uid/gid |
| SUP_GROUP_IDS | (none) | supplementary gids |
| UMASK | 0022 | file mask |
| LANG | en_US.UTF-8 | locale |
| TZ | Etc/UTC | timezone |
| KEEP_APP_RUNNING | 0 | restart on crash |
| APP_NICENESS | 0 | nice level |
| INSTALL_PACKAGES / PACKAGES_MIRROR | (none) | apk install at start |
| CONTAINER_DEBUG | 0 | debug logs |
| DISPLAY_WIDTH / DISPLAY_HEIGHT | 1920 / 1080 | window size |
| DARK_MODE | 0 | dark mode |
| WEB_AUDIO, WEB_HOST_CLIPBOARD_SYNC, WEB_FILE_MANAGER, WEB_NOTIFICATION, WEB_TERMINAL | 0 | web features |
| WEB_AUTHENTICATION (+ _USERNAME, _PASSWORD, _TOKEN_VALIDITY_TIME) | 0 | login page |
| SECURE_CONNECTION (+ _VNC_METHOD SSL/TLS) | 0 / SSL | encrypted web/VNC |
| WEB_LOCALHOST_ONLY, VNC_LOCALHOST_ONLY | 0 | localhost-only |
| VNC_PASSWORD | (none) | GUI/VNC password |
| ENABLE_CJK_FONT | 0 | CJK font |

## Ports
| port | proto | use |
| --- | --- | --- |
| 5800 | TCP | web GUI |
| 5900 | TCP | VNC |

## Volumes
| path | purpose |
| --- | --- |
| /config | config, state, logs |
| /storage | files to inspect (mount host dirs here, `:ro` recommended) |

## Gotchas
- Web auth requires SECURE_CONNECTION unless WEB_AUTHENTICATION_ALLOW_INSECURE=1.
