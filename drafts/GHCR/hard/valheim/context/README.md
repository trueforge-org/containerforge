# Context: valheim

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/valheim/values.yaml + Chart.yaml | truecharts-valheim.md |
| https://raw.githubusercontent.com/community-valheim-tools/valheim-server-docker/main/Dockerfile | community-valheim-tools-valheim-server-docker.md |
| https://api.github.com/repos/lloesche/valheim-server-docker/releases/latest (403), HTML fallback | lloesche-valheim-server-docker-release.md |

Skipped: api.github.com repo metadata and contents/README.md (not fetched; README not needed for build), github repo roots and blob variant (duplicate of raw Dockerfile), `store.steampowered.com/app/896660` (store page), `www.valheimgame.com` (homepage), image refs (`debian:trixie-slim`, `debian:buster-slim`, `ghcr.io/lloesche/valheim-server`), binary download (steamcmd_linux.tar.gz, noted in Dockerfile file).

Failures:
- https://api.github.com/repos/lloesche/valheim-server-docker/releases/latest: 403 rate limit; one HTML fallback used, which redirected (301) to community-valheim-tools.

## plan.md corrections
- None verified. Note: the plan's Dockerfile URL points to community-valheim-tools (repo moved from lloesche); not an error, flagged only.
