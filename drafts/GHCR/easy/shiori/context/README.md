# shiori context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shiori/values.yaml | truecharts-shiori-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shiori/Chart.yaml | truecharts-shiori-chart.md |
| https://github.com/go-shiori/shiori/blob/v1.8.0/Dockerfile (raw v1.8.0) | shiori-dockerfile-v1.8.0.md |
| https://github.com/go-shiori/shiori/blob/master/docs/index.md (raw) | shiori-docs-index.md (intro only) |
| https://github.com/go-shiori/shiori/blob/master/LICENSE (raw) | shiori-license.md |
| https://github.com/go-shiori/shiori (README, raw) | shiori-readme.md (partial, no Docker/env facts) |
| https://github.com/go-shiori/shiori/pkgs/container/shiori | ghcr-shiori-package.md |
| https://api.github.com/repos/go-shiori/shiori/releases/latest | failed (403) |
| https://github.com/go-shiori/shiori/releases/latest (alternative) | github-html-shiori-releases-latest.md (asset list not loaded) |

Skipped: https://github.com/go-shiori/shiori HTML repo page (covered by raw README). No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. No Docker Hub source (GHCR app).

Gaps: docs/Configuration.md (v1.8.0), which the plan cites for env vars, was not in urls.txt and not fetched. Follow-up budget used on README.

Failures: 1 (API releases/latest 403; one alternative used, asset names still unavailable).

## plan.md corrections
- No edits made. Verified: Alpine 3.19 builder, scratch final, `ENV PORT=8080`, `SHIORI_DIR=/shiori`, `ENTRYPOINT ["/usr/bin/shiori"]`, `CMD ["server"]`, no USER/VOLUME (plan line 15); MIT license (line 10); tag v1.8.0.
- Unverified: plan lines 12-14 asset names and checksums (`shiori_Linux_x86_64_1.8.0.tar.gz`, `checksums.txt`). Release HTML asset list did not load and API returned 403. Not edited.
- Unverified conflict: plan line 8 date 2025-09-26; fetched page shows "26 Sep" with no year. Not edited.
