# Context index: uptime-kuma

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/uptime-kuma/values.yaml + Chart.yaml | truecharts-uptime-kuma.md |
| https://hub.docker.com/v2/repositories/louislam/uptime-kuma/ + tags?page_size=10 | dockerhub-uptime-kuma.md |
| https://raw.githubusercontent.com/louislam/uptime-kuma/1.23.17/docker/dockerfile (also blob URL) | uptime-kuma-dockerfile-1.23.17.md |
| https://raw.githubusercontent.com/louislam/uptime-kuma/2.5.12/docker/dockerfile | uptime-kuma-dockerfile-2.5.12.md |
| https://api.github.com/repos/louislam/uptime-kuma/license (403) -> https://raw.githubusercontent.com/louislam/uptime-kuma/1.23.17/LICENSE | uptime-kuma-license.md |

Skipped (one line): GitHub repo root HTML and wiki (https://github.com/louislam/uptime-kuma/wiki, not build input). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in this list.
Failures: https://api.github.com/repos/louislam/uptime-kuma/license returned 403 (rate limit). The one alternative (raw LICENSE at tag 1.23.17) succeeded. The license is MIT for 1.23.17; not re-checked for 2.5.12.

## plan.md corrections
- No in-place edits.
- Checked and matching fetched sources: Dockerfile stages and EXPOSE 3001 for 1.23.17 and 2.5.12, no VOLUME in 2.5.12, `dumb-init` entrypoint, `CMD node server/server.js`, MIT license (1.23.17 LICENSE), chart `/app/data` mount and PUID 0.
- Unverified: plan.md's claim that Docker Hub `louislam/uptime-kuma:1.23.17-debian` is published with amd64/arm64/arm and last_updated 2025-10-20 was not checked (that tag is not on the first tags page fetched).
- Unverified: plan.md's "2.5.12 published 2026-11-17" was not checked against the GitHub release API (not in urls.txt).
