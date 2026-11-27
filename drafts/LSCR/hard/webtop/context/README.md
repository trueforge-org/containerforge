# Context: webtop

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/webtop/values.yaml | truecharts-webtop.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/webtop/Chart.yaml | truecharts-webtop.md |
| https://docs.linuxserver.io/images/docker-webtop | linuxserver-webtop-docs.md |
| https://raw.githubusercontent.com/linuxserver/docker-webtop/b1c6c9e22abe066d2d637377229de773dd45044f/Dockerfile | github-docker-webtop.md |
| https://raw.githubusercontent.com/linuxserver/docker-webtop/master/README.md | github-docker-webtop.md |
| https://raw.githubusercontent.com/selkies-project/selkies/main/README.md | selkies.md |
| https://docs.linuxserver.io/selkies/user-guide/configuration/ (follow-up) | selkies.md |
| https://docs.selkies.io | selkies.md (redirect to /latest/, not followed) |
| https://github.com/linuxserver/gclient | gclient.md |
| https://github.com/linuxserver/docker-webtop/blob/b1c6c9e22abe066d2d637377229de773dd45044f/Dockerfile | github-docker-webtop.md (same as raw) |

Skipped categories: none beyond the duplicates above. Image-ref URL (GHCR package page) not summarized.

## Failures
- https://raw.githubusercontent.com/linuxserver/gclient/main/README.md: 404 (alternative GitHub repo page used: gclient.md).
- https://fleet.linuxserver.io/image?name=linuxserver/webtop: JS-rendered, no usable content.
- https://github.com/orgs/linuxserver/packages/container/package/webtop: HTML package page, no build data extracted.

## plan.md corrections
- None made. Unverified: values.yaml lists openbox and icewm image tags; upstream docs say those were dropped (17.06.25). values.yaml port 33000 vs upstream 3000/3001 is a chart mapping, not a conflict.
