# context README: GHCR/medium/meshcentral

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshcentral/values.yaml | truecharts-meshcentral.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshcentral/Chart.yaml | truecharts-meshcentral.md |
| https://raw.githubusercontent.com/Ylianst/MeshCentral/f436143527458d56da0336ea3047c006703fb4e4/docker/Dockerfile (blob URL in urls.txt, same content) | github-meshcentral-dockerfile.md |
| https://registry.npmjs.org/meshcentral/1.3.1 | npm-meshcentral-1.3.1.md |

Skipped categories: GitHub HTML pages (repo root, blob variant), https://meshcentral.com (not fetched), https://docs.meshcentral.com (fetched; HTML site shell only, no usable content, not summarised).

Failures:
- https://api.github.com/repos/Ylianst/MeshCentral/license (403, rate limit); not retried
- https://api.github.com/repos/Ylianst/MeshCentral/releases/latest (403, rate limit); not retried. Plan's "latest 1.3.1 published 2026-10-23" therefore UNVERIFIED.

## plan.md corrections
- Line 8 (Version to build): chart pin stated as `ghcr.io/ylianst/meshcentral:1.3.1, which matches`. Fetched values.yaml pins `1.3.2` (appVersion 1.3.2). Edited to state the chart pins 1.3.2 (source: truecharts values.yaml). Whether to build 1.3.1 or 1.3.2 remains a plan decision; the "latest = 1.3.1" claim could not be re-checked (releases API 403).
- Checksum values in plan (line 14) match fetched npm registry metadata: no change.
