# hkalexling/mango (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/hkalexling/mango
- Fetched 2026-11-26

## Overview
"Self-hosted manga server and web reader", official Docker image for the Mango project. Last updated over 4 years ago. 40 stars (listed); 1M+ pulls.

## Tags and size
- Only `latest` shown. Digest `sha256:14b5e1dd4...` (truncated), size 15.5 MB, image. Architectures not listed.
- `v0.27.0` tag not visible on the page (plan says it exists and is the same image).

## Usage (from the page)
- Create a `docker-compose.yml` (version '3'): service `mango`, image `hkalexling/mango`, container name `mango`, port `9000:9000`, volumes `~/mango:/root/mango` and `~/.config/mango:/root/.config/mango`.
- `docker-compose up`.
- No environment variables mentioned.

## Consistency
- TrueCharts chart pins `docker.io/hkalexling/mango:latest@sha256:14b5e1dd467f5a2736cf6847f3be193a522c5fdd36d61b797652a2d513776911` (see truecharts-mango.md). Digest prefix matches the Hub page.
