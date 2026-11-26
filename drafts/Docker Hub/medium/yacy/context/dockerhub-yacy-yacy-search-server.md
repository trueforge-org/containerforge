# Docker Hub: yacy/yacy_search_server

**Source URL(s):** https://hub.docker.com/r/yacy/yacy_search_server
**Fetched:** 2026-11-26

## What it is
"The YaCy Peer-to-Peer Search Engine Software". Categories: Data science; Databases & storage. 26 stars, 100K+ pulls. Updated 23 days before the snapshot. Image size 371.1 MB.

## License
GPL 2.0 or later, with some parts under LGPL.

## Tags and architectures
- Only `latest` listed (digest `sha256:4077e9d85ea13e3d2a29b63add60b109ccced191bebfc169d422dd50fca44c41`).
- No architectures listed on the page (the download/installation page lists amd64 and the ARM tags; see docs-yacy-net-download-installation.md).

## Ports, env, volumes, user
- Docker section lists no ports, env vars, volumes or user. General docs: web UI and admin on port 8090.
- Localhost access is auto-authorised. After roughly 10 minutes, a random password is generated and remote login is blocked. Set an admin account at `http://<server>:8090/ConfigAccounts_p.html` on any non-local server.

## Run example
Only `docker pull yacy/yacy_search_server`. Run command from the download/installation page: see docs-yacy-net-download-installation.md.

## Other
- Java: "1.8 or later" per this page, but the repo and the download page say Java 17 minimum (Java 17 is the supported minimum; the page is out of date). Use Java 17+.
- Default Java memory 600 MB; adjustable at `/Performance_p.html`. Disk cache at `/ConfigHTCache_p.html`.
- Docker build from source: see docker/Readme.md in the repo (404 at the pinned commit; see the README notes).
