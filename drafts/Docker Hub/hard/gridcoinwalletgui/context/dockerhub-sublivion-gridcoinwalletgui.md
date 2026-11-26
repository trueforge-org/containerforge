# Docker Hub sublivion/gridcoinwalletgui

Source URL: https://hub.docker.com/r/sublivion/gridcoinwalletgui
Date fetched: 2026-11-26

## Image
- `sublivion/gridcoinwalletgui` (third-party publisher, not Grafana/Gridcoin project).
- Desktop GUI wallet in container, Ubuntu 26.04 + xfce, served over VNC/noVNC.
- Tags: `latest` only (digest sha256:ce79edd2c..., 442.3 MB).
- Arch list not shown.

## Run example (from page)
`docker run -d --name gridcoinwalletgui -p 5901:5901 -p 6901:6901 -v <data>:/headless/.GridcoinResearch/ sublivion/gridcoinwalletgui`

## Ports
| Port | Use |
| --- | --- |
| 5901 | VNC |
| 6901 | noVNC (browser at http://localhost:6901/) |

## Volumes/paths
- `/headless/.GridcoinResearch/` (wallet data; page says back up wallet.dat and gridcoinresearch.conf)
- `/var/lib/boinc-client/` (optional, BOINC data for CPID; works with separate BOINC container)

## Env vars
| Name | Purpose |
| --- | --- |
| VNC_PW | VNC password |
| VNC_RESOLUTION | Screen resolution, e.g. 1920x1080 |

## Gotchas
- "cannot obtain a lock on data directory": check permissions of the persistent data folder.
- Author advises local-only use, no external port exposure.
- Base lineage: ConSol docker-headless-vnc-container.
- Latest noted update: Gridcoin 5.5.2.0-leisure and move to Ubuntu 26.04 (GitHub latest release is 5.5.3.0).
