# Context: kapowarr

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kapowarr/values.yaml + Chart.yaml | truecharts-kapowarr.md |
| https://hub.docker.com/v2/repositories/mrcas/kapowarr/ (+ tags?page_size=10) | dockerhub-kapowarr.md |
| https://raw.githubusercontent.com/Casvt/Kapowarr/V1.0.0-beta-4/Dockerfile | github-kapowarr-dockerfile-beta4.md |
| https://raw.githubusercontent.com/Casvt/Kapowarr/V1.3.2/requirements.txt (+ LICENSE head) | github-kapowarr-requirements-v1.3.2.md |
| https://casvt.github.io/Kapowarr/installation/docker/ | casvt-docs-docker.md |

Skipped: CLA, forgetool schemas, containerforge links, templated, binary downloads (release zip, expanded_assets), image refs: none beyond what urls.txt already removed. Not fetched, redundant: blob/V1.0.0-beta-4 Dockerfile and blob/HEAD/requirements.txt (same as raw), github.com/Casvt/Kapowarr repo root (covered by raw files), casvt.github.io/Kapowarr root and expanded_assets/tag pages (covered by API attempt and docs).
Shared cache (docs/context/INDEX.md): no hits for this app.

Failed:
- https://api.github.com/repos/Casvt/Kapowarr/releases/latest: response had no `tag_name` or assets (not retried). Release V1.3.2 published 2026-09-14 per plan.md, not re-verified here.
- https://casvt.github.io/Kapowarr/installation/installation/ and https://casvt.github.io/Kapowarr/ : fetched, only HTML shell returned in the captured output, no content extracted (not retried).
- https://github.com/Casvt/Kapowarr/releases/tag/V1.3.2 and expanded_assets: not fetched, covered by the failed API call (plan.md cites them, unverified here).

## plan.md corrections
- Line 10 (License): `AGPL-3.0 (root LICENSE, GNU AFFERO GPL v3: ...)` -> `GPL-3.0 (root LICENSE, GNU GENERAL PUBLIC LICENSE v3: ...)` (source: github-kapowarr-requirements-v1.3.2.md, V1.3.2 LICENSE raw head).
- Unverified, not edited: plan line 36-40 Python base choice and Kapowarr compatibility with Python 3.15 remain UNVERIFIED in plan.
- Unverified conflict: TrueCharts chart media mount `/comics-1` vs upstream docs `/comics` (casvt-docs-docker.md). Both recorded; plan line 156 already treats chart mounts separately.
