# Docker Hub: gotenberg/gotenberg
Source URL(s): https://hub.docker.com/v2/repositories/gotenberg/gotenberg/ , .../tags?page_size=10 (fetched 2026-11-27)

- "A developer-friendly API for converting many document formats into PDF files, and more!"
- Pulls 111,140,299; stars 53; status active; last_updated 2026-11-26
- Tags: 841 total. Recent (all 2026-11-26): 9.10.2 / 9.10 / 9 / latest with -aws-lambda, -chromium-aws-lambda, -libreoffice-aws-lambda suffixes
- Chart pins 9.10 (digest 2ce6fcd3...). Plain `9.10` tag not in the top-10 list; variant names in readme:
  - full (no suffix): Chromium + LibreOffice
  - -chromium: drops LibreOffice, python3, hyphenation (~30% smaller)
  - -libreoffice: drops Chromium (~38% smaller)
  - -cloudrun, -aws-lambda: cloud variants
  - edge, edge-*: development
- Arch (readme): amd64, arm64v8, arm32v7, i386, ppc64le. Tag data shows amd64, arm64 for recent tags.

## Run
- `docker run --rm -p 3000:3000 gotenberg/gotenberg:9`
- API: multipart/form-data; POST /forms/chromium/convert/url, returns PDF

## Ports
- 3000 (HTTP API)

## Health
- GET /health (chart probe path)

## Gotchas
- Gotenberg 9 is current; 8 stays available as gotenberg/gotenberg:8
- Chart runs chromium with --chromium-disable-javascript=true and --chromium-allow-list=file:///tmp/.*
