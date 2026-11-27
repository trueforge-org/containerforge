# linuxserver/docker-digikam README (usage)
Source URL: https://raw.githubusercontent.com/linuxserver/docker-digikam/fd0663bebb867b7dba24c63d14e0493e7d94c0b9/README.md (fetched 2026-11-27)

## Ports
| Port | Function |
| --- | --- |
| 3000 | digiKam GUI HTTP, must be reverse-proxied |
| 3001 | digiKam GUI HTTPS (served directly) |

## Volumes
- `/config` (home dir, stores database)

## Env
| Var | Notes |
| --- | --- |
| PUID | default 1000 in examples |
| PGID | default 1000 in examples |
| TZ | e.g. Etc/UTC |
| UMASK | optional, e.g. 022 |
| CUSTOM_USER / PASSWORD | enable HTTP basic auth (none by default) |
| AUTO_GPU | `false` disables GPU detection |
| LC_ALL | session language |
| PIXELFLUX_WAYLAND | changelog: `false` disables Wayland (default off per changelog) |
| FILE__<VAR> | read variable from file |

## Other
- `--shm-size="1gb"` recommended for desktop images
- Access: `https://yourhost:3001/`
- Internal MySQL mode: setup asks to locate mysql_install_db, mysqladmin, mysqld binaries

## Gotchas
- README says port 3001 is HTTPS, but the TrueCharts chart targets 3000.
