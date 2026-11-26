# alekslitvinenk/openvpn (Docker Hub, DockOvpn image)

Source URL(s) + fetch date:
- https://hub.docker.com/r/alekslitvinenk/openvpn
- Fetched 2026-11-26

## What it is
- Ready-to-use stateless OpenVPN server image, starts within seconds. 1M+ pulls, 49 stars. Last updated over 2 years before fetch (per page).

## Architectures
- Not listed. Single image, 7.2 MB, digest begins `sha256:8f3424e3d...`.

## Tags
- `latest` (each newly built release), `v#.#.#` (fixed release), `v#.#.#-regen-dh` (fresh DH file, rebuilt hourly), `dev` (master).

## Documented run command
```
docker run -it --rm --cap-add=NET_ADMIN -p 1194:1194/udp -p 80:8080/tcp --name dockovpn alekslitvinenk/openvpn
```
- Strongly recommends adding `-r` (regenerate PKI and DH).

## Env vars (page table)
- NET_ADAPTER (eth0), HOST_ADDR (localhost; host address override), HOST_TUN_PORT (1194), HOST_CONF_PORT (80), CRL_DAYS (3650). Advises against changing NET_ADAPTER and HOST_ADDR unless necessary.

## Ports and volumes
- 1194/udp tunnel. 8080/tcp config download (mapped to host 80 in the example; server shuts down after download).
- Optional volume: `-v openvpn_conf:/opt/Dockovpn_data`.

## Container options
- `-r/--regenerate`, `-n/--noop`, `-q/--quit`, `-s/--skip`.

## Helper commands (docker exec)
- `./version.sh`, `./genclient.sh` (z, o, `n name`), `./rmclient.sh <id>`, `./listconfigs.sh`, `./getconfig.sh <id>`.

## Gotchas
- Requires a Linux host, Docker, and a public IP. Compose is supported.
- A revoked custom-named client cannot be recreated with the same name.
