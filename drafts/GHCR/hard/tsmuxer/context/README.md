# Context: tsmuxer

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tsmuxer/values.yaml + Chart.yaml | truecharts-tsmuxer.md |
| https://raw.githubusercontent.com/jlesage/docker-tsmuxer/v26.09.1/Dockerfile (github blob variant same) | truecharts-tsmuxer.md (section "Upstream Dockerfile") |
| https://api.github.com/repos/justdan96/tsMuxer/releases/latest; https://github.com/justdan96/tsMuxer/releases/latest | justdan96-tsmuxer-release.md |

Skipped: github repo roots (justdan96/tsMuxer, jlesage/docker-tsmuxer) and api.github.com/repos/justdan96/tsMuxer (repo metadata, not needed), image refs (`tonistiigi/xx`, `alpine:3.20`, `jlesage/baseimage-gui`, `ghcr.io/jlesage/tsmuxer`), templated/icon URL (docker-templates tsmuxer-icon.png).

Failures:
- https://api.github.com/repos/justdan96/tsMuxer/releases/latest: 403 rate limit; fallback to HTML releases redirect succeeded.

## plan.md corrections
- None verified. Note: upstream Dockerfile URL uses tag v26.09.1 while chart appVersion is 26.11.2 (not a plan error, flagged only).
