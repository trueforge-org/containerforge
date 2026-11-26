# pannal/kitana (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/pannal/kitana
- Fetched 2026-11-26

## Overview
"A responsive Plex plugin web frontend". Links to github.com/pannal/Kitana for setup details.

## Tags and size
- Only `latest`, last updated over 3 years ago.
- Digest `sha256:a6164e44a...` (truncated), size 75.7 MB.
- Architectures not listed. Pulls 10M+; a count of 25 shown (likely stars).

## Usage
- `docker pull pannal/kitana`. No env, volume or port instructions on the Hub page (points to GitHub).

## Consistency
- TrueCharts chart pins `docker.io/pannal/kitana:latest@sha256:a6164e44a03bca92b07216412e564e9c445487fe739d1b80848ffe4b4c6ccd3b` (see truecharts-kitana.md). Full digest not compared with Hub.
- GitHub README docker example (see github-pannal-kitana.md): `docker run --name kitana --restart unless-stopped -v kitana_data:/app/data -d -p 0.0.0.0:31337:31337 pannal/kitana:latest -B 0.0.0.0:31337`.
