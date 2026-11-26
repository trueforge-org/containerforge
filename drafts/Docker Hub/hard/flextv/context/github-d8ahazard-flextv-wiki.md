# GitHub wiki: d8ahazard/FlexTV

Source URL(s) + fetch date (2026-11-26):
- https://github.com/d8ahazard/FlexTV/wiki (Home; 26 pages; last edited Oct 14 2018)
- https://github.com/d8ahazard/FlexTV/wiki/Using-Docker (followed sub-page; last edited Apr 26 2019)

## Home

- Welcome note only; says "a lot of things have changed", sidebar lists installation, post-install, integrations, settings pages. Many sub-pages returned "There was an error while loading" (content unavailable).
- Never explicitly says outdated. Plain sidebar titles include Installation, Using Docker, Using XAMPP, Using Raspberry Pi, Plex Settings, Logs.

## Using-Docker (followed sub-page)

Image named on this page: `digitalhigh/FlexTV` on Docker Hub (page links to a `digitalhigh/flextv` repo). This is NOT the `jcreynolds/flextv` image in the draft.

Arch tags: x86-64 `amd64-latest`, arm64 `arm64v8-latest`, armhf `arm32v7-latest`.

Run example (page):
```
docker create --name=FlexTV -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -p 80:80 -v <path to data>:/config --restart unless-stopped digitalhigh/FlexTV
```

| Item | Value (per page) |
| --- | --- |
| Web UI port | 80 (`-p 80:80`) |
| Data volume | `/config` (host path to be chosen) |
| Env | `PUID=1000`, `PGID=1000`, `TZ=Europe/London` (any valid zone) |
| Required Plex settings | none listed |

- Host volume must be owned by the PUID/PGID user (page). Style matches LinuxServer-type images, with PUID/PGID handling.
- Support commands on page: `docker exec -it FlexTV /bin/bash`, `docker logs -f FlexTV`, version via `build_version` label.
- Only changelog entry: "25.04.19: Initial release."

## Gotchas

- Conflict: this page's image (`digitalhigh/FlexTV`, port 80, /config, PUID/PGID) differs from the draft and plan (`jcreynolds/flextv`, runs as root in the chart). Not resolved from sources; see README plan.md corrections.
- Page itself is dated 2019 and says details may be outdated.
