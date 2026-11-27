# Context: redm

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redm/values.yaml + Chart.yaml | truecharts-redm.md |
| https://raw.githubusercontent.com/ich777/docker-redm-server/master/Dockerfile | ich777-docker-redm-server.md |
| http://docs.fivem.net/docs (+ 1 follow-up not needed, index only) | fivem-docs-index.md |

Skipped (not fetched): Docker Hub (image is on GHCR); github.com Dockerfile blob URL (raw used); https://github.com/citizenfx/fivem (HTML only as fallback, no file); runtime.fivem.net artifact `build_proot_linux/master` (binary download, not fetched); gotty release tarball (binary download); redm.gg and redm.net (marketing/home, not build source); CLA; forgetool schemas; containerforge app links; image refs.

Failures:
- https://api.github.com/repos/citizenfx/fivem: 403. Alternative https://github.com/citizenfx/fivem (HTML) fetched; no license or push date extracted from it, so the plan's API-based values remain unverified.

## plan.md corrections
- None applied.
- Unverified conflict: plan lines 15 and 121-127 list ports 30120 (udp/tcp) and 40120 (http, txAdmin). The TrueCharts chart (fetched) declares 9016->8080 http, plus 30110 and 30120 on both tcp and udp. Plan's "40120" is not in the chart. Not edited: the plan labels these as draft inference and the upstream Dockerfile declares none.
- Unverified: plan line 10 (license NOASSERTION, last push 2026-11-17) rests on the API call that failed.
