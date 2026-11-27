# Context index: tasmoadmin

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tasmoadmin/values.yaml | truecharts-tasmoadmin-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tasmoadmin/Chart.yaml | truecharts-tasmoadmin-chart.md |
| https://raw.githubusercontent.com/TasmoAdmin/TasmoAdmin/81271a076cacecb1e8d4e8723af35e61510276de/.docker/Dockerfile.alpine-tmpl (also blob URL) | tasmoadmin-dockerfile-alpine-tmpl-81271a0.md |
| https://raw.githubusercontent.com/TasmoAdmin/TasmoAdmin/master/README.md (repo root) | tasmoadmin-github-readme.md |
| https://api.github.com/repos/TasmoAdmin/TasmoAdmin/releases/tags/v5.0.0 (403) + releases/latest redirect | tasmoadmin-github-release.md |

Not fetched: https://github.com/TasmoAdmin/TasmoAdmin/releases/tag/... (covered by latest redirect).

Skipped: CLA/templated/binary/image-ref lines already filtered from urls.txt; no Docker Hub source listed.

Failures:
- https://api.github.com/repos/TasmoAdmin/TasmoAdmin/releases/tags/v5.0.0: 403 (alternative redirect used, shows v5.1.0 latest)
- https://api.github.com/repos/TasmoAdmin/TasmoAdmin: 403

## plan.md corrections
- No edit made. Unverified conflict: plan.md line 8 states v5.0.0 is the latest release (published 2026-03-09). Fetched today, GitHub's latest-release redirect points to v5.1.0 and TrueCharts chart uses v5.1.0. Plan pinning choice may be deliberate; left unchanged.
