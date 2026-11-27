# Context: lyrion-music-server

Fetched 2026-11-27. Summaries of the web sources in urls.txt.

## Source -> file
| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lyrion-music-server/values.yaml | truecharts-lyrion-music-server.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lyrion-music-server/Chart.yaml | truecharts-lyrion-music-server.md |
| https://hub.docker.com/v2/repositories/lmscommunity/lyrionmusicserver/ | dockerhub-lyrionmusicserver.md |
| https://hub.docker.com/v2/repositories/lmscommunity/lyrionmusicserver/tags?page_size=10 | dockerhub-lyrionmusicserver.md |
| https://github.com/LMS-Community/slimserver | github-slimserver-readme.md |
| https://github.com/LMS-Community/slimserver-platforms | github-slimserver-platforms-repo.md |
| https://github.com/LMS-Community/slimserver-platforms/blob/d05c757/Docker/Dockerfile | github-slimserver-platforms-dockerfile.md |
| https://lyrion.org | lyrion-org-home.md |
| https://lyrion.org/downloads | lyrion-downloads.md |
| https://lyrion.org/getting-started | lyrion-getting-started.md |

Not in shared cache (docs/context/INDEX.md): no hits.

## Skipped
- Not fetched: downloads.lms-community.org .deb/.rpm/.dmg binaries (binary downloads); no CLA, forgetool, containerforge or templated URLs in list.

## Failures
- None.

## plan.md corrections
- Edit: `lyrion-music-server` version `8.0.0` -> `8.0.1` (Chart.yaml, truecharts-lyrion-music-server.md).
- Unverified conflicts (not edited):
  - plan says Docker Hub 9.1.2 last updated 2026-10-24; API reports 2026-11-27.
  - plan says Docker Hub 9.2.0 updated 2026-11-25; API reports 2026-11-26.
  - plan lists 9.1.2 as "stable"; lyrion.org/downloads labels 9.1.2 "Stable Nightly Build" and 9.1.1 "Latest Release (official)".
  - plan says 9.2.0 is only under `nightly/`; downloads page labels it "Development Build" (folder path not shown).
  - plan says start-container.sh runs as root with usermod/groupmod/chown; start-container.sh was not fetched.
  - License still not stated on lyrion.org or the GitHub README.
