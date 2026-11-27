# Context: yacreaderlibraryserver

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yacreaderlibraryserver/values.yaml + Chart.yaml | truecharts-yacreaderlibraryserver.md |
| https://raw.githubusercontent.com/xthursdayx/yacreaderlibrary-server-docker/f1d5f1b.../Dockerfile (+ blob variant) | xthursdayx-yacreaderlibrary-server-docker-dockerfile.md |
| https://raw.githubusercontent.com/xthursdayx/yacreaderlibrary-server-docker/f1d5f1b.../README.md | xthursdayx-yacreaderlibrary-server-docker-readme.md |
| https://api.github.com/repos/YACReader/yacreader/releases/latest (403), HTML fallback; releases/tag/10.4.0 | yacreader-release.md |

Skipped: github repo roots (YACReader/yacreader, .git URL is repo clone), www.yacreader.com (homepage), image refs (`ghcr.io/linuxserver/baseimage-ubuntu:resolute`, `ghcr.io/xthursdayx/yacreaderlibrary-server-docker`), binary/source downloads (`yacreader-7z-deps/raw/main/7z2301-src.7z`, git clone of YACReader source; not fetched).

Failures:
- https://api.github.com/repos/YACReader/yacreader/releases/latest: 403 rate limit; HTML fallback succeeded.

## plan.md corrections
- None verified. Flagged only: plan references YACReader tag 10.4.0 while latest release is 10.5.1 (Dockerfile pin still 10.4.0).
