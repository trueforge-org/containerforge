# Context sources: GHCR/medium/aurral

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/aurral/values.yaml + Chart.yaml | truecharts-aurral.md |
| https://raw.githubusercontent.com/lklynet/aurral/84535c99df51/Dockerfile (blob URL in urls.txt) + backend/docker-entrypoint.sh | github-aurral-dockerfile.md |
| https://api.github.com/repos/lklynet/aurral (+ /releases/latest), README raw (main), https://github.com/lklynet/aurral | github-aurral-repo.md |
| https://github.com/lklynet/aurral/pkgs/container/aurral | covered by github-aurral-repo.md (nav page only) |
| https://github.com/lklynet/aurral/releases/tag/v3.0.0 | replaced by api releases/latest (budget rule) |

- Skipped categories: none beyond the release-tag HTML page (replaced by API).
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt.
- Failures: none.
- Note: the listed Dockerfile is commit 84535c99df51 (3.0.0 era), not v3.1.0. Its base pins (cloudflared 2026.11.0) differ from plan.md's v3.1.0 values (cloudflared 2026.11.1). Not verified against v3.1.0.

## plan.md corrections
- None made. Unverified conflict: plan.md line 8 says the draft's chart tag is 3.0.0, but TrueCharts master `values.yaml` already uses `3.1.0` (appVersion 3.1.0, chart 4.0.0). Plan's decision to build v3.1.0 is unaffected.
