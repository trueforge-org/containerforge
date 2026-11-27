# audacity: context index

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/audacity/values.yaml | truecharts-audacity.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/audacity/Chart.yaml | truecharts-audacity.md |
| https://hub.docker.com/v2/repositories/linuxserver/audacity/ (+ /tags?page_size=10) | dockerhub-audacity.md |
| https://raw.githubusercontent.com/linuxserver/docker-audacity/master/Dockerfile | github-linuxserver-docker-audacity-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-audacity/b0c6f0d2e0d8650f40ef6e5a8661baa2230a5812/Dockerfile (= blob URL) | github-linuxserver-docker-audacity-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-audacity/master/README.md (= repo URL) | github-linuxserver-docker-audacity-readme.md |
| https://api.github.com/repos/audacity/audacity/releases/latest | github-audacity-audacity-release.md |
| https://raw.githubusercontent.com/audacity/audacity/master/README.md (= repo URL) | github-audacity-audacity-release.md |
| https://www.audacityteam.org, https://manual.audacityteam.org | audacity-sites.md |

## Skipped
- Release tag page https://github.com/audacity/audacity/releases/tag/Audacity-4.0.2 not fetched; the releases/latest API result covers it.
- Repo HTML https://github.com/audacity/audacity and https://github.com/linuxserver/docker-audacity (covered by raw README).
- Base images ghcr.io/linuxserver/baseimage-selkies:ubunturesolute and baseimage-rdesktop-web:focal (image refs).
- Icon URL audacity-logo.png (binary asset).
- Binary download URLs (AppImage) not downloaded.

## Failures
- None.

## plan.md corrections
- None. Verified against fetched data: version 4.0.2 (2026-11-02), master Dockerfile base/EXPOSE 3001/apt list/ENV, the x86_64-only AppImage download.
- Unverified in plan, not changed: license. Upstream README states GPLv3 (mixed GPLv2+ and third-party exceptions), while GitHub API shows NOASSERTION. Plan keeps the NOASSERTION placeholder and says verify SPDX in LICENSE.txt.
