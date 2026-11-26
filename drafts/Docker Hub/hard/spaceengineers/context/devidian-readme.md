# Devidian/docker-spaceengineers README (upstream project)

Source URL(s): https://github.com/Devidian/docker-spaceengineers ; https://raw.githubusercontent.com/Devidian/docker-spaceengineers/master/README.md (fetched 2026-11-26)

## Facts
- Tags: `:latest` (Debian 12, Wine 9.0~bookworm-1) and `:winestaging` (Wine 9.9~bookworm-1). ~1.82 GB compressed, build ~19 min (per README).
- Setup: world created with SE Dedicated Server tool; instance dir uploaded to host `/appdata/space-engineers/instances/`.
- Example compose volumes (container paths must not change): `/appdata/space-engineers/plugins`, `/appdata/space-engineers/instances`, `/appdata/space-engineers/SpaceEngineersDedicated`, `/root/.steam` (steamcmd).
- Example port: `27016/udp` (host mode).
- Example env: `WINEDEBUG=-all`, `INSTANCE_NAME=TestInstance`, `PUBLIC_IP=1.2.3.4` (healthcheck needs public IP).
- Plugins: copy into plugins dir; entrypoint adds/removes them. Mods downloaded by server on first start from world.
- Extend via `FROM devidian/spaceengineers:latest`.
- Known issue: VRage Remote Client connection failed for maintainer.
