# Docker Hub mikeah/prusaslicer-novnc

Source: https://hub.docker.com/r/mikeah/prusaslicer-novnc (API https://hub.docker.com/v2/repositories/mikeah/prusaslicer-novnc), fetched 2026-11-26

| Field | Value |
| --- | --- |
| description | Prusaslicer in your web browser using noVNC and Supervisor |
| star_count / pull_count | 2 / 140711 |
| last_updated | 2024-09-13T00:59:33Z |

## Hub full description (summary)
- Basic noVNC build with supervisord serving PrusaSlicer in a browser; built for Unraid.
- Run: `docker run --detach --volume=...:/configs/ --volume=...:/prints/ -p 8080:8080 -e SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt ...`
- Optional `-p 5900:5900` for VNC viewer (TigerVNC default port 5900).
- GPU: `NVIDIA_VISIBLE_DEVICES` and `NVIDIA_DRIVER_CAPABILITIES` (`all` or narrower); tested only on Nvidia.
- Compose: `docker-compose.yml` (pre-built) and `docker-compose.build.yml` (`--build`).
- Unraid template repo: github.com/helfrichmichael/unraid-templates (default web port 6080 in template).
- Credits: derived from dmagyar's prusaslicer-vnc-docker.

## Gotchas
- Hub text says Unraid template default web port 6080, but the Dockerfile default NOVNC_PORT is 8080 and truecharts maps 8080.
