# Kapowarr docs: Docker install (casvt.github.io/Kapowarr/installation/docker/)

## Source URL(s) + date
- https://casvt.github.io/Kapowarr/installation/docker/ (2026-11-26)
- Also fetched (truncated, HTML shell only, no content extracted): https://casvt.github.io/Kapowarr/installation/installation/ and https://casvt.github.io/Kapowarr/ (root). Counted as failed in README.

## Volumes/paths (documented)
| Host | Container | Notes |
| --- | --- | --- |
| docker volume `kapowarr-db` or host folder (e.g. `/opt/Kapowarr/db`) | `/app/db` | database file |
| download folder (e.g. `/home/<user>/comic-downloads`) | `/app/temp_downloads` | must not overlap DB/root/download folders |
| root folder (e.g. `/home/<user>/comics`) | `/comics` | additional roots: `-v <path>:/comics-2` etc. (path must be unique in container) |

- DB, root and download folders may not intersect.

## Run command (documented)
- `docker run ... -v kapowarr-db:/app/db -v <download>:/app/temp_downloads -v <root>:/comics -p 5656:5656 -e PUID=0 -e PGID=0 -e TZ=Etc/UTC mrcas/kapowarr:latest`
- Compose: `image: mrcas/kapowarr:latest`, `environment` PUID=0, PGID=0, TZ=Etc/UTC, ports `5656:5656`, volumes as above, named volume `kapowarr-db`.

## Env vars
| Name | Documented value | Meaning |
| --- | --- | --- |
| PUID | 0 | user the app runs as |
| PGID | 0 | group the app runs as |
| TZ | Etc/UTC | timezone name |

## Ports
- 5656 (host side may be changed, container side stays 5656).

## User/UID
- Default documented as PUID=0 PGID=0. Folders must be writable by the PUID/PGID user.

## Gotchas
- Docs say host folders need read/write/exec for the container user.
- Containers are ephemeral; only mapped paths persist.
