# calibre: context index

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/calibre/values.yaml | truecharts-calibre.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/calibre/Chart.yaml | truecharts-calibre.md |
| https://hub.docker.com/v2/repositories/linuxserver/calibre/ (+ /tags?page_size=10) | dockerhub-calibre.md |
| https://raw.githubusercontent.com/linuxserver/docker-calibre/master/Dockerfile | github-linuxserver-docker-calibre-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-calibre/8aa349b17edf2d4bed988982d71803684399f01a/Dockerfile (= blob URL; identical) | github-linuxserver-docker-calibre-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-calibre/master/README.md (= repo URL) | github-linuxserver-docker-calibre-readme.md |
| https://api.github.com/repos/kovidgoyal/calibre/releases/latest | github-kovidgoyal-calibre-release.md |
| https://api.github.com/repos/kovidgoyal/calibre (repo API; license not captured) | github-kovidgoyal-calibre-release.md |
| https://github.com/kovidgoyal/calibre (repo HTML) | github-kovidgoyal-calibre-release.md (via raw README) |
| https://calibre-ebook.com, https://manual.calibre-ebook.com | calibre-sites.md |

## Skipped
- Base image ghcr.io/linuxserver/baseimage-selkies:ubunturesolute (image ref).
- Icon PNG (binary) and calibre .txz binary downloads (not fetched).
- Docker Hub repo API: fetched (see dockerhub file).
- Pinned-commit Dockerfile blob (duplicate; identical to master).

## Failures
- None.

## plan.md corrections
- Edit 1 (line 8, section 1 table): "The chart pins linuxserver `9.18.0`, which is stale." -> "The draft pins linuxserver `9.18.0`, which is stale (the TrueCharts chart already pins `9.19.0`, appVersion 9.19.0)." Source: truecharts-calibre.md (values.yaml tag `9.19.0@sha256:...`, Chart.yaml appVersion 9.19.0); draft.md line 81 pins 9.18.0.
- Unverified, not changed: plan line 127 says arm64 image is unproven. Hub lists arm64 images for 9.19.0 (dockerhub-calibre.md), but the upstream Dockerfile fetches only x86_64.
- Unverified, not changed: license GPL-3.0 (plan cites repo API; not captured in this fetch).
