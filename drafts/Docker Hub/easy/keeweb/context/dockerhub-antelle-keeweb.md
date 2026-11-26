# antelle/keeweb (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/antelle/keeweb
- Fetched 2026-11-26

## Overview
"Free cross-platform password manager compatible with KeePass." Maintained by antelle. MIT licensed. Self-hosting needs only a static file server (one HTML file plus optional service worker).

## Tags and size
- Only `latest` shown, last updated over 5 years ago (consistent with plan's 2021-07-18). Image size 58.8 MB.
- Digest not shown on page. Architectures not listed.
- Pulls: 1M+. A count of 30 shown (likely stars).

## Usage
- `docker pull antelle/keeweb`
- `docker run --name keeweb -d -p 443:443 -p 80:80 -v $EXT_DIR:/etc/nginx/external/ antelle/keeweb`
- Put `dh.pem`, `cert.pem` and `key.pem` in `/etc/nginx/external/` (mounted volume). Ports 443 and 80. No env vars documented.
- Dropbox support in self-hosted setups requires extra configuration (wiki link).

## Build notes
- `grunt` builds HTML into `dist/`. `grunt desktop` builds desktop apps (macOS only, needs wine per page). Dev: `grunt dev` on `http://localhost:8085`.

## Consistency
- TrueCharts chart pins `docker.io/antelle/keeweb:latest@sha256:8ff5e10baa2ca50967964bf26af41461da79ef62a481094a00f75726623bcb36` (see truecharts-keeweb.md). Digest not checked against Hub.
