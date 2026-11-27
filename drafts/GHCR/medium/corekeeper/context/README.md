# Context index: corekeeper

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/corekeeper/values.yaml | truecharts-corekeeper.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/corekeeper/Chart.yaml | truecharts-corekeeper.md |
| https://api.github.com/repos/ich777/docker-steamcmd-server | ich777-docker-steamcmd-server.md (cache, repo root row) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server | ich777-docker-steamcmd-server.md (cache) |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (cache) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md (cache) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh | ich777-docker-steamcmd-server.md (cache) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh | ich777-docker-steamcmd-server.md (cache) |
| https://github.com/ich777/docker-steamcmd-server (root) | ich777-docker-steamcmd-server.md (cache) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cache) |

Skipped categories: steampowered.com root (marketing page, no build info, not fetched).

Failures:
- https://store.steampowered.com/app/1963720: returned the JavaScript Steam shell with no game data, so the Steam app ID 1963720 could not be confirmed from it. The app ID comes from the TrueCharts values.yaml (`GAME_ID: "1963720"`).

Extra probe (not in urls.txt): https://api.github.com/repos/ich777/docker-steamcmd-server/releases/latest returned 404 (repo has no GitHub releases).

## plan.md corrections
None. Checked the plan's Dockerfile, start.sh, env and port claims against the cached ich777 summary and the TrueCharts values; no clear factual error found. The plan's UNVERIFIED items (Steam app ID, Core Keeper binary and args, query port 27016) remain open. start-server.sh is now available in the cached summary but is Source-engine (srcds_run) specific, so it does not settle the Core Keeper launch command.
