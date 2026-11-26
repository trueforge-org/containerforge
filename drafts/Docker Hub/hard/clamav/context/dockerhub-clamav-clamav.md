# hub.docker.com/r/clamav/clamav (official ClamAV image, draft "Container image")

Source URL(s) + fetch date:
- https://hub.docker.com/r/clamav/clamav · fetched 2026-11-26

## What it is
"The official Alpine-based Docker images for the ClamAV project." Publisher Cisco Systems, Inc. 50M+ pulls. Only `latest` tag listed (digest `sha256:64e30c0bf…`, 152.7 MB, updated ~4 days before fetch). Architectures not stated. Chart pins 1.5.5 (digest `64e30c0bf976…`).

## Note
The Docker Hub page (as fetched) says **Alpine-based**. The Dockerfile reviewed in github-cisco-talos-clamav-docker.md uses `debian:13-slim` for `clamav/1.5/debian`. The draft's `1.5.5` is the Debian variant from that repo; the Alpine variant is a separate build not reviewed.

## Run / env / ports / volumes
- Only `docker pull clamav/clamav` shown. No env, ports or volumes on the page. Points to docs.clamav.net Docker section (not followed; see docs-clamav-net.md).

## Licence
GPLv2 with third-party components under other licences; UnRAR loaded at run time (optional).
