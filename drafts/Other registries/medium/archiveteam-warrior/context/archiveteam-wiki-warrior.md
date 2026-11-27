# ArchiveTeam wiki: ArchiveTeam Warrior

## Source URL(s) + date
- https://wiki.archiveteam.org/index.php/ArchiveTeam_Warrior (fetched 2026-11-27, text extracted)
- Follow-up tried: https://wiki.archiveteam.org/index.php/Docker_environment_variables (404, page does not exist)

## Docker usage (from page)
- Image: `atdr.meo.ws/archiveteam/warrior-dockerfile`.
- Run command (documented):
  `docker run --detach --name archiveteam-warrior --label=com.centurylinklabs.watchtower.enable=true --log-driver json-file --log-opt max-size=50m --restart=on-failure --publish 8001:8001 atdr.meo.ws/archiveteam/warrior-dockerfile`
- Web UI: http://localhost:8001/ (port 8001).
- Restart: `docker start archiveteam-warrior`; stop: `docker kill --signal=SIGINT archiveteam-warrior`.
- Headless by default (no GUI).
- Config via env (per page): `SELECTED_PROJECT` (e.g. `auto`), `DOWNLOADER` (nickname), item concurrency. Also can set a username/password for web interface and firewall it.
- Restart policy `--restart=on-failure` used for boot start.
- Optional Watchtower label used for auto-updates.

## Warrior appliance (VM) facts (not used by container)
- Appliance versions: 4.2 (165 MiB), 3.2 (127 MiB).

## Gotchas
- Docker run command in the wiki publishes 8001 only; no volume documented.
- Docker environment variable reference page does not exist (404), so env var names come only from the wiki prose above.
