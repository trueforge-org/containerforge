# Context index: universal-media-server

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/universal-media-server/values.yaml + Chart.yaml | truecharts-universal-media-server.md |
| https://hub.docker.com/v2/repositories/universalmediaserver/ums/ + tags?page_size=10 | dockerhub-ums.md |
| https://raw.githubusercontent.com/UniversalMediaServer/UniversalMediaServer/main/src/main/external-resources/docker/Dockerfile | ums-dockerfile.md |

Skipped (one line): GitHub repo root and `blob/` URL (duplicates of raw Dockerfile), https://www.universalmediaserver.com (marketing site, not a build input). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in this list.
Failures: none.

## plan.md corrections
- No in-place edits.
- Unverified: plan.md's "15.9.0 (GitHub latest)" was not checked against the GitHub releases API (not in urls.txt, not fetched). Docker Hub shows `15.10.0` (2026-11-15, amd64 and arm64), which plan.md mentions. Check the GitHub latest tag before merge.
- Plan facts that match fetched sources: Ubuntu 22.04 base in upstream Dockerfile, `openjdk-17-jre-headless`, `UMS_PROFILE=/profile`, EXPOSE list (1900/udp 5001/tcp 5353/udp 9001/tcp 9002/tcp), no `USER` upstream, Docker Hub amd64+arm64 for 15.9.0 and 15.10.0.
