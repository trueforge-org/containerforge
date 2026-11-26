# linuxserver/docker-kodi-headless README

Source URL(s): https://raw.githubusercontent.com/linuxserver/docker-kodi-headless/master/README.md (repo: https://github.com/linuxserver/docker-kodi-headless). Fetched 2026-11-26. Note: the README fetch is the master branch; the Dockerfile is pinned at 8962e35.

## Status
- Image: linuxserver/kodi-headless. README says project is DEPRECATED, "no longer maintained".
- Base: Ubuntu Bionic + s6 overlay. Patched headless Kodi (credits Celedhrim, sinopsysHK, wernerb).
- Purpose: MySQL-backed Kodi, library updates without a player machine.

## Run
- `docker create --name=kodi-headless -v <data>:/config/.kodi -e PGID=<gid> -e PUID=<uid> -e TZ=<tz> -p 8080:8080 -p 9090:9090 -p 9777:9777/udp linuxserver/kodi-headless`
- No compose example.

## Ports
- 8080 web UI; 9090 websockets; 9777/udp eventserver-style interface.

## Volumes / paths
- `/config/.kodi` = Kodi config. `userdata/advancedsettings.xml` for MySQL/MariaDB settings. `userdata/sources.xml` copy from original host needed for library cleaning.

## Env
| Var | Default | Notes |
| --- | --- | --- |
| PUID | none stated | user ID |
| PGID | none stated | group ID |
| TZ | - | e.g. Europe/London |
- UMASK not documented. No Kodi-specific env vars.

## Credentials
- Default web UI login kodi/kodi (changed 22.02.17).

## Tags
- Named after Kodi releases: Helix, Isengard, Jarvis, Krypton, Leia (current default). Usage `linuxserver/kodi-headless:Krypton`.

## Ops
- Shell: `docker exec -it kodi-headless /bin/bash`; logs: `docker logs -f kodi-headless`.
- Arch: CI x86-64 job only mentioned. Health checks: none stated.
