# Docker Hub: corneliousjd/sui-startpage

**Source URL(s):** https://hub.docker.com/r/corneliousjd/sui-startpage
**Fetched:** 2026-11-26

## What it is
- Image description: "Server/Statpage UI", a startpage for a server and/or new-tab page (SUI).
- Maintained by corneliousjd. The repo was forked so Docker Hub builds could be triggered for an unRAID container template, with small modifications made at user request.
- Roughly 100K+ pulls, 0 stars shown. Last updated over 6 years ago.

## Tags and architectures
- Only tag listed: `latest` (compressed size 8.2 MB).
- Architectures: not stated on the page.
- Digest shown as a field but no value appears on the page itself (TrueCharts values pin `sha256:0a4728be5ebed65e501c23444cb3b1f65f7a96e3bb36cff08450b3be0f45934e`).

## Ports / env / volumes / user
- Exposed port: not stated.
- Environment variables: none documented.
- Volumes: none documented. Configuration is by editing `apps.json`, `links.json`, `providers.json`, `assets/js/search.js` and `themer.js`. The page does not say where these live in the container.
- User: not stated.

## Run example
- Only `docker pull corneliousjd/sui-startpage`. No `docker run` example.

## Source links
- No GitHub or Dockerfile link on the page; it notes only that this is a fork of the original SUI project.
- Screenshots: https://i.imgur.com/J4d7Q3D.png and https://imgur.com/a/FDVRIyw (not relevant to the build).
