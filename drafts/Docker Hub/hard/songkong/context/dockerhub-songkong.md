# Docker Hub songkong/songkong

Source URL(s): https://hub.docker.com/r/songkong/songkong (WebFetch 2026-11-26)

## Facts
- Tags: `latest` only (digest sha256:e13f264df..., ~186 MB). Updated ~7 days before capture.
- Arch: not stated.
- Ports: 4567 (web interface).
- Volumes: `/music` (music files), `/songkong` (preferences, license, logs, reports, internal DB).
- Env vars: none documented.
- Example: `docker run -v /CONFIGFOLDER:/songkong -v /MUSICFOLDER:/music -p 4567:4567 songkong/songkong`
- Tested on Synology DS218+. Over 1M pulls.
