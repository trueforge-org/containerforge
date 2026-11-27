# context README: GHCR/medium/mindustry

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mindustry/values.yaml | truecharts-mindustry.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mindustry/Chart.yaml | truecharts-mindustry.md |
| https://raw.githubusercontent.com/ich777/docker-mindustry/master/Dockerfile | github-ich777-docker-mindustry.md |
| https://raw.githubusercontent.com/ich777/docker-mindustry/master/scripts/start.sh | github-ich777-docker-mindustry.md |
| https://raw.githubusercontent.com/ich777/docker-mindustry/master/scripts/start-server.sh | github-ich777-docker-mindustry.md |
| https://raw.githubusercontent.com/Anuken/Mindustry/master/README.md | github-anuken-mindustry.md |
| https://raw.githubusercontent.com/Anuken/Mindustry/master/build.gradle | github-anuken-mindustry.md |

Skipped categories: GitHub HTML pages (repo root, blob Dockerfile variant), itch.io page, mindustrygame.github.io docs and wiki (HTML, not fetched), ich777 raw `start-gotty.sh`/`start-watchdog.sh` (referenced, not in urls.txt, not fetched).

Failures:
- https://api.github.com/repos/Anuken/Mindustry/releases/latest (403, rate limit); not retried
- https://api.github.com/repos/Anuken/Mindustry (403, rate limit); not retried

## plan.md corrections
- Line 8 (Version to build): stated TrueCharts runs `GAME_V=latest` (floating). Fetched values.yaml sets `GAME_V: latest@sha256:f0065aa44fb1c38b7fc30d34e220138dc0a0c6477b78eb7f59015622c2052030`. Edited to the digest-suffixed value (source: truecharts values.yaml). Not the plain `latest` that start-server.sh special-cases, so the upstream download logic would not match it.
- Unverified: `160.8` as latest Mindustry release (releases API 403). Not changed.
