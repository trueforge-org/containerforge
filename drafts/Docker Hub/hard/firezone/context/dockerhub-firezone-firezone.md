# Docker Hub: firezone/firezone

Source URL(s) + fetch date:
- https://hub.docker.com/r/firezone/firezone (fetched 2026-11-26)

## What it is

Image for Firezone 0.7 (VPN server on WireGuard with egress firewall). Published by firezone. 100K+ pulls, 8 stars. Page says the repo holds the older 0.7 release, past its support lifetime.

## Support status (from the page)

- Maintainers said they would push updates only through 2024-01-31.
- Users are pointed to the GitHub README FAQ about moving to Firezone 1.0 and to Docker deployment docs (https://docs.firezone.dev/deploy/docker/).

## Tags and arch

- Only `latest` shown, last updated about 3 years before fetch. Digest begins `sha256:6e65ebab...`, 39.9 MB.
- No version-numbered tags shown. Architectures not listed.
- Chart pins `0.7.36@sha256:6e65ebab1ddbdc8dfe8c6aa10defda1ea9b2b48e0f2b54772338f3e735be8a6f`.

## Ports, volumes, env

- Not mentioned on the page.

## Gotchas

- The image is end of life. Plan's BLOCKED recommendation rests on this and on the root and NET_ADMIN requirement (see `github-firezone-firezone.md`).
