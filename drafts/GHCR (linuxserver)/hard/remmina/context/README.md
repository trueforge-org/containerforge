# Context: remmina

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/remmina/values.yaml | truecharts-remmina.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/remmina/Chart.yaml | truecharts-remmina.md |
| https://raw.githubusercontent.com/linuxserver/docker-remmina/9c34e90f8d44/Dockerfile | dockerfile-linuxserver-remmina.md |
| https://hub.docker.com/v2/repositories/linuxserver/remmina/ (+ /tags?page_size=10, /tags/1.4.43) | dockerhub-remmina.md |
| https://packages.ubuntu.com/resolute/remmina | ubuntu-package-remmina.md |

Skipped categories: binary downloads (none in list beyond apt archive), blob duplicate of the Dockerfile, boilerplate (github FreeRDP/Remmina and linuxserver repo root, remmina.org), image refs (ghcr.io/linuxserver/baseimage-selkies not fetched), remote icon URL.

Failures: none.

## plan.md corrections
- Unverified conflict (not edited): plan.md section 5/image row cites Hub 1.4.43 digests amd64 `sha256:cede2f9f...c3d51` and arm64 `sha256:bf18520f...f950`. Current API (fetched 2026-11-27, tag last_updated 2026-11-25T23:35Z) returns amd64 `sha256:f087b700...05d2` and arm64 `sha256:53dd603f...f558`. Likely a rebuild after the plan was verified. Source: dockerhub-remmina.md. Plan left unchanged; re-check digests before pinning.
- Confirmed, no edit: `remmina=1.4.43+dfsg-0ubuntu0.26.04.2` in resolute (ubuntu-package-remmina.md).
