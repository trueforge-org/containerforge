# Docker Hub: 601096721/mosdns

**Source URL(s) + fetch date:** https://hub.docker.com/r/601096721/mosdns · fetched 2026-11-26

## What it is
Community image of mosdns, built from Sagit-chu/mosdns-container. Based on `alpine:latest`. Bundles mosdns, CA roots, a ready-made config and geoip.dat / geosite.dat.

## Arch support
linux/amd64, linux/arm/v7, linux/arm64.

## Tags
Only `latest` listed (about 5 months old at fetch; ~12.9 MB compressed; 50K+ pulls).

## Ports
Container 53/udp and 53/tcp (example run maps host 5454).

## Volumes/paths
`/etc/mosdns` optional; mount only to customise config. Data files refreshed on every image update even if the config folder is mounted.

## Env vars
None mentioned.

## Usage notes
Resolution flow described on page: cn-category domains go to domestic DoT/DoH upstreams; non-cn domains go to uncontaminated DoT/DoH upstreams; otherwise prefer uncontaminated result with domestic fallback.

## Gotchas
- Not an official upstream image. Plan.md uses the upstream zip instead (consistent with draft.md's "Go binary from release zip").
- Contradiction with plan: the community image bundles geo data and is alpine; ContainerForge plan uses ubuntu base and seeds config into `/config` only when missing.
