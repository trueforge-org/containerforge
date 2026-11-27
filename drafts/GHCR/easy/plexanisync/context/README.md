# Context index: plexanisync

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plexanisync/values.yaml | truecharts-plexanisync.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plexanisync/Chart.yaml | truecharts-plexanisync.md |
| https://raw.githubusercontent.com/RickDB/PlexAniSync/v1.4.4/Docker/PlexAniSync/Dockerfile (+ blob URL) | plexanisync-dockerfile.md |
| https://api.github.com/repos/RickDB/PlexAniSync/contents/Docker/PlexAniSync/run/runsync.sh?ref=v1.4.4 (fetched via raw URL) | plexanisync-runsync.md |
| https://api.github.com/repos/RickDB/PlexAniSync/contents/PlexAniSync.py?ref=v1.4.4 | not fetched (budget; behaviour covered by runsync.sh + docker README) |
| https://api.github.com/repos/RickDB/PlexAniSync | github-api-plexanisync.md |
| https://api.github.com/repos/RickDB/PlexAniSync/releases/latest | github-api-plexanisync.md |
| https://github.com/RickDB/PlexAniSync | github-api-plexanisync.md (API equivalent) |
| https://github.com/RickDB/PlexAniSync/releases/tag/v1.4.4 | github-api-plexanisync.md (API equivalent) |
| https://github.com/RickDB/PlexAniSync/wiki | plexanisync-wiki-and-package-pages.md |
| https://github.com/RickDB/PlexAniSync/pkgs/container/plexanisync | plexanisync-wiki-and-package-pages.md |
| (added, not in list) raw Docker/PlexAniSync/README.md | plexanisync-docker-readme.md |
| (added, not in list) raw run/settingsupdater.py | plexanisync-settingsupdater.md |

Extra fetches: `settingsupdater.py` at repo root returned 404; one alternative (Docker/PlexAniSync/run/) was used.

Skipped: none by category. No Docker Hub source (image is ghcr.io/rickdb/plexanisync). No CLA, forgetool, containerforge or templated URLs in the list.

Failures: none (one 404 on root settingsupdater.py recovered with the alternative path above).

## plan.md corrections
- None checked against plan.md. Note for maintainer: settingsupdater.py writes /plexanisync/settings.ini unconditionally when SETTINGS_FILE is unset, and the chart mounts that path readOnly.
