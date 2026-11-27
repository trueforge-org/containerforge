# Context index: gatus

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/values.yaml | truecharts-gatus.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/Chart.yaml | truecharts-gatus.md | fetched |
| https://raw.githubusercontent.com/home-operations/gatus-sidecar/1aefae52150e/Dockerfile | gatus-sidecar-dockerfile.md | fetched |
| https://github.com/home-operations/gatus-sidecar/blob/1aefae52150e/Dockerfile | gatus-sidecar-dockerfile.md | same as raw Dockerfile |
| https://github.com/home-operations/gatus-sidecar | gatus-sidecar-dockerfile.md | covered by raw README (main) |
| https://github.com/home-operations/gatus-sidecar.git | gatus-sidecar-dockerfile.md | git clone URL, same repo |
| https://raw.githubusercontent.com/home-operations/gatus-sidecar/main/README.md | gatus-sidecar-dockerfile.md | fetched (first ~40 lines, deployment notes) |
| https://github.com/TwiN/gatus | gatus-upstream-readme.md | covered by raw README (master) |
| https://raw.githubusercontent.com/TwiN/gatus/master/README.md | gatus-upstream-readme.md | fetched (grep of Docker and config lines) |
| https://gatus.io | none | not fetched: marketing site, HTTP 200, no build input beyond README |
| https://gatus.io/docs | none | not fetched: HTTP 200, the README covers the config path and port |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not applicable to the chart images (GHCR: `ghcr.io/twin/gatus`, `ghcr.io/home-operations/gatus-sidecar`); the README mentions `twinproduction/gatus` on Docker Hub, noted only.

## Failures
- None.

## plan.md corrections
- plan.md line 106 (`volumes`): `The app is stateless; /config is not required by it.` -> `The sidecar writes its output file to /config (the chart passes --output=/config/gatus-sidecar.yaml, see truecharts-gatus.md), so /config is required when the sidecar is enabled.` Source: truecharts-gatus.md (chart args, values.yaml), gatus-sidecar-dockerfile.md (README deployment section).
- Verified, no edit: sidecar version 0.6.1 and the upstream Dockerfile (pinned commit 1aefae52150e) match plan lines 8 and 14.
