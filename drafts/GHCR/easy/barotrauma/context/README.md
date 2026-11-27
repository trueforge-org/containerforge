# Sources for barotrauma (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/barotrauma/values.yaml | truecharts-barotrauma.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/barotrauma/Chart.yaml | truecharts-barotrauma.md |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cached copy) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md (cached copy) |
| https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide | valve-dedicated-server-guide.md (cached 403 record) |

Skipped: https://barotraumagame.com (homepage, no build data); https://www.steampowered.com (store homepage); no Docker Hub URL (GHCR image).

Failures:
- https://barotraumagame.com/wiki/Serversettings.xml: 403 (Cloudflare challenge). One alternative https://barotraumagame.com/wiki/Serversettings also 403. Not retried. Serversettings content (config file, ports) is NOT covered.
- Valve Dedicated Server Guide: 403 (cached record).

## plan.md corrections
- None made. Chart shows GAME_ID 1026340 (Barotrauma Steam app ID) and service ports 27015/udp (main) and 27016/udp (steamqueryport). Plan's 27015/tcp is not in the chart (plan still lists it as inferred; left as is, unverified, since the chart does not confirm TCP either way).
