# hub.docker.com/r/mikeah/cura-novnc (draft "Container image")

Source URL(s) + fetch date:
- https://hub.docker.com/r/mikeah/cura-novnc · fetched 2026-11-26

## What it is
"Access Cura Slicer from your browser!" Basic noVNC build with supervisor presenting Cura in a browser; made for unRAID users; adapted from the author's prusaslicer-novnc. Work in progress; large image because the extracted AppImage duplicates dependencies. 50K+ pulls; updated about 2 years before fetch.

## Tags / size
- `latest` only on the page (digest `sha256:4a8f18baf…`, 1023.1 MB). Chart pins `5.8.1`. Architectures not stated.

## Run
- `docker run --detach --volume=cura-novnc-data:/configs/ -p 8080:8080 --name=cura-novnc cura-novnc` (note the page mounts `/configs/`, while the Dockerfile declares VOLUME `/home/cura/` and `/prints/`).
- Env named: `NVIDIA_VISIBLE_DEVICES`, `NVIDIA_DRIVER_CAPABILITIES` (GPU passthrough, Nvidia only, untested elsewhere).
- Unraid template default web port 6080.

## Gotchas
- Page says no USB or printer notes. Use case is slicing and sending prints.
