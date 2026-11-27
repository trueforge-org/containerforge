# Context: ztcuui-aio

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ztcuui-aio/values.yaml + Chart.yaml | truecharts-ztcuui-aio.md |
| https://hub.docker.com/v2/repositories/keynetworks/ztncui/ (upstream README image name; ghcr image has no Hub listing fetched) | dockerhub-keynetworks-ztncui.md |
| https://raw.githubusercontent.com/kmahyyg/ztncui-aio/v2024.1.28-r1/Dockerfile (+ github blob duplicate) | github-kmahyyg-ztncui-aio-dockerfile.md |
| https://github.com/kmahyyg/ztncui-aio/releases/tag/v2024.1.28-r1 (alt for api releases) | github-kmahyyg-ztncui-aio-release.md |
| https://github.com/key-networks/ztncui-containerized | github-key-networks-ztncui-containerized.md |

Skipped: none of the listed categories present in urls.txt (already filtered). Duplicates: github blob Dockerfile URL.

## Failures
- https://api.github.com/repos/kmahyyg/ztncui-aio: 403, no alternative fetched (archived/license facts come from plan.md, unverified here).
- https://api.github.com/repos/kmahyyg/ztncui-aio/releases/tags/v2024.1.28-r1: 403; HTML release page used (asset names not loaded).
- https://github.com/key-networks/ztncui-containerized used as an alternative source for the upstream project, not a failure.

## plan.md corrections
- None made. Facts checked against fetched sources (stages, EXPOSE, VOLUME, ENTRYPOINT, UID/GID 2222) match.
- Not a correction, for reference: TrueCharts chart exposes planet UDP 9993 (chart evidence), while plan.md marks 9993/udp UNVERIFIED.
