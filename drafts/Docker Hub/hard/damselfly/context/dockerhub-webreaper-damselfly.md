# hub.docker.com/r/webreaper/damselfly (draft "Container image")

Source URL(s) + fetch date:
- https://hub.docker.com/r/webreaper/damselfly · fetched 2026-11-26

## What it is
"Server-based Digital Asset Management" for very large image collections; search by IPTC keywords and folder/file names. Category Content management system. 500K+ pulls.

## Tags / size / arch
- `latest` only (digest `sha256:6dedb903e…`, 962.5 MB). Last updated "about 2 months ago" (tag summary says 11 months). Architectures not stated (the page does not list arm64; the plan's arm64 compile is a rebuild).

## Run
- Container `damselfly`, restart `unless-stopped`, port 6363 (6363:6363 tcp), volumes `<host>:/config`, `<host>:/pictures`, `<host>:/thumbs`. No env named. Compose equivalent given.

## Notes
- Config folder holds the database, thumbnails and similar data (example uses `/config`).
