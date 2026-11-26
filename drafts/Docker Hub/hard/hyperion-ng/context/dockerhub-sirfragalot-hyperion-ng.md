# Docker Hub sirfragalot/hyperion.ng

Source URL: https://hub.docker.com/r/sirfragalot/hyperion.ng
Date fetched: 2026-11-26

## Image
- `sirfragalot/hyperion.ng`, third-party publisher (not the Hyperion project).
- Tags: `latest` only shown (digest sha256:1848762c..., 84.4 MB, updated about 8 months before fetch). Examples on the page reference `2.0.0-alpha.7` and `2.0.0-alpha.10-aarch64`.
- Pulls 100K+. Arch: no list; the `aarch64` example tag suggests ARM64.

## Run example (from page)
`docker run -d -v /path/on/host:/root/.hyperion --name="Hyperion" --network host sirfragalot/hyperion.ng:2.0.0-alpha.7`

## Ports (listed on page)
| Port | Proto |
| --- | --- |
| 19445 | tcp |
| 19444 | tcp |
| 8090 | tcp |

## Volumes
- `/root/.hyperion` (config/data). Compose example maps `/etc/hyperion` to it.

## Env vars
- None shown.

## Gotchas
- Page examples use host networking.
- Tags on the page are 2.0.0-alpha series, well behind the GitHub release 2.2.1.
- Image runs as root per the mount path `/root/.hyperion`.
