# airdcpp-webclient upstream: README, install docs, project pages, release API

## Source URL(s) + date
- https://raw.githubusercontent.com/airdcpp-web/airdcpp-webclient/master/README.md (fetched 2026-11-26)
- http://airdcpp.net/docs/installation/installation.html (fetched 2026-11-26)
- http://airdcpp.net (fetched 2026-11-26; same content as the GitHub Pages site)
- https://airdcpp-web.github.io (fetched 2026-11-26; same content as airdcpp.net)
- https://api.github.com/repos/airdcpp-web/airdcpp-webclient/releases/latest (fetched 2026-11-26)

## What it is (upstream README)
- AirDC++ Web Client: locally installed Direct Connect / ADC file-sharing daemon with React web UI and HTTP REST/WebSocket API.
- Extensions use Node.js.
- Wraps: airdcpp-core, airdcpp-webapi, airdcpp-webui.

## Install (installation docs)
- Linux: "Portable binaries for Linux" (precompiled); "no installation package available"; source compile possible.
- Binaries are not compatible with FreeBSD or other non-Linux platforms.
- Docker: "No official Docker image is provided"; third-party images exist.
- Docs topics: Configuration directory location (Web Client), External HTTP proxy server configuration.

## Latest release (releases/latest API)
- tag `2.14.0`, published `2025-09-07T16:14:08Z`.

## Download
- Home page links to download info (airdcpp-web.github.io); binary host per Dockerfile: `https://web-builds.airdcpp.net/stable/...`.

## Support
- Issue tracker for questions and feature requests.
- Hub: adcs://web-dev.airdcpp.net:1511 (dev/support, not needed for build).

## Gotchas
- Upstream does not publish a Docker image; containers are third-party (gangefors).
- Release API gives only tag and date; the tarball is from web-builds, not GitHub release assets.
