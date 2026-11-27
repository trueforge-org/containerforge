# Context: pihole

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pihole/values.yaml + Chart.yaml | truecharts-pihole.md |
| https://raw.githubusercontent.com/pi-hole/docker-pi-hole/7a8d396/src/Dockerfile | pi-hole-docker-dockerfile.md |
| https://raw.githubusercontent.com/pi-hole/docker-pi-hole/master/README.md | docker-pi-hole-readme.md |
| https://github.com/pi-hole/FTL/releases/tag/v6.9 (HTML, after API 403) | ftl-release-v6.9.md (partial) |
| https://docs.pi-hole.net/docker/configuration/ (+ https://docs.pi-hole.net index) | pihole-docs-docker-configuration.md |
| https://raw.githubusercontent.com/pi-hole/pi-hole/master/LICENSE | pi-hole-core-license.md |

Skipped: raw/blob duplicate of the Dockerfile (github.com/.../blob/7a8d396/src/Dockerfile); github.com/pi-hole org page; github.com/pi-hole/FTL and github.com/pi-hole/pi-hole repo pages (covered by release/LICENSE); pi-hole.net marketing page; docs.pi-hole.net (index only, used for nav); no Docker Hub URL in list (image is GHCR).

Failures:
- https://api.github.com/repos/pi-hole/FTL/releases/tags/v6.9: 403 rate limit. Alternative HTML page used, partial result only (no asset list).
- https://api.github.com/repos/pi-hole/docker-pi-hole/releases/latest: 403 rate limit. HTML alternative https://github.com/pi-hole/docker-pi-hole/releases/latest also failed (no tag extracted).

## plan.md corrections
None. Checked plan facts against the fetched Dockerfile, README and docs (ports, env vars, UID/GID defaults, capabilities, healthcheck, ENTRYPOINT). No clear factual error proven.
Unverified in plan, not settled by these fetches: EUPL-1.2 version (LICENSE header read only partially), FTL license GPL-2.0, FTL release date 2026-11-11, docker-pi-hole license, core tag for 2026.11.0.
