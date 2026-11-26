# wolveix/satisfactory-server (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/wolveix/satisfactory-server (fetched 2026-11-26)

## What it is
Docker Hub page for the Satisfactory dedicated server wrapper. Maintainer renamed to `robtme`; page recommends `robtme/satisfactory-server`. The `wolveix` image keeps getting updates.

## Env vars (table)
Defaults as listed on the page: AUTOSAVENUM 5, BACKUPLIMIT 10, DEBUG false, DISABLESEASONALEVENTS false, LOG false, MAXOBJECTS 2162688, MAXPLAYERS 4, MAXTICKRATE 30, MULTIHOME `::`, PGID 1000, PUID 1000, SERVERADMINPASSWORD empty, SERVERGAMEPORT 7777, SERVERMESSAGINGPORT 8888, SERVERNAME "Satisfactory Server", SERVERPASSWORD empty, SERVERSTREAMING true, SKIPUPDATE false, STEAMBETA false, STEAMBETAID empty, STEAMBETAKEY empty, TIMEOUT 30, VMOVERRIDE false.

## Ports
7777 tcp and udp (game); 8888 tcp (messaging).

## Volumes/paths and persistent data
Bind a local directory to `/config` (subfolders backups, gamefiles, logs, saved).

## Version/release info and asset naming
- Only tag listed under recent tags: `latest`. No version tags shown. Image 255.5 MB.
- Last updated "2 days ago" relative to capture (no exact date).

## Arch support
Not stated.

## Other notes
- Page recommends 8 to 16 GB RAM.
- Covers Docker Compose, Kubernetes, optional Certbot SSL, mod support, non-root running.
- 1M+ pulls, 171 stars.

## Contradictions with plan.md
- Docker Hub shows only `latest`; plan.md and the draft pin `wolveix/satisfactory-server:v1.9.11`, and the TrueCharts values use `v1.10.0`. The tag only exists in GitHub releases, not on this page.
