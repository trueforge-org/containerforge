# Docker Hub: factoriotools/factorio

Source URL(s) + fetch date:
- https://hub.docker.com/r/factoriotools/factorio
- Fetched 2026-11-26

## What it is
Dedicated Factorio server image (server only). Game is sold separately. Source: github.com/factoriotools/factorio-docker.

## Architectures
x64 and ARM64. ARM64 on 2.1+ uses native linux-arm64 headless build. Older versions use box64 emulation (experimental).

## Tags
- `latest` (page shows currently 2.1.24; the GitHub README fetch lists 2.1.25 as a tag; see Gotchas)
- `stable` (version marked stable on factorio.com)
- `stable-x.y.z`, `x.y.z`, rootless variants with `-rootless`
- `0.x`, `0.x.y`, `0.x-z` (older branch tags)

## Ports
- 34197/udp game (changeable via PORT)
- 27015/tcp RCON (optional)

## Volumes
Single `/factorio` volume with `config/`, `mods/`, `saves/`. Files owned by uid 845 unless PUID/PGID changed.

## Usage
- Quick start: create `/opt/factorio`, chown to 845, run with `-p 34197:34197/udp -p 27015:27015/tcp -v /opt/factorio:/factorio`. Edit `config/server-settings.json` then restart.
- Stop with `docker stop --timeout 120`.
- Console: `docker attach` or `docker exec factorio rcon /h` (2.0.18+).
- Health check: `rcon /players count`, 30s interval, 3 retries, 5-minute start grace period.
- Saves: newest loads by default. For specific map: `SAVE_NAME`, `LOAD_LATEST_SAVE=false`, `GENERATE_NEW_SAVE=true`, `PRESET` (e.g. death-world).
- Mods: place in mods folder; `UPDATE_MODS_ON_START` needs username and token; `UPDATE_IGNORE` skips mods.
- Scenarios: `/scenario.sh` entrypoint; `/scenario2map.sh` deprecated.
- Upgrade: back up saves, remove container, pull, rerun with same volume.
- Env var list matches the GitHub README summary (see github-factoriotools-factorio-docker.md).

## Gotchas
- Page shows `latest` as 2.1.24 while the GitHub README fetch lists 2.1.25 as a tag. Not resolved by these fetches; plan.md section 1 says Docker Hub has 2.1.25.
