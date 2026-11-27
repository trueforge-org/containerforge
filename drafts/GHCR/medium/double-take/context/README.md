# Context index: double-take

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/double-take/values.yaml | truecharts-double-take.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/double-take/Chart.yaml | truecharts-double-take.md |
| https://github.com/jakowenko/double-take (repo root, HTML) | upstream-jakowenko-double-take-release.md |
| https://github.com/jakowenko/double-take/releases/tag/v1.13.2 | upstream-jakowenko-double-take-release.md |
| https://github.com/skrashevich/double-take (repo root, HTML) | upstream-double-take-fork-build.md |
| https://github.com/skrashevich/double-take/blob/60c957d/.build/Dockerfile | upstream-double-take-fork-build.md (same commit as raw; blob not fetched separately) |
| https://raw.githubusercontent.com/skrashevich/double-take/60c957d/.build/Dockerfile | upstream-double-take-fork-build.md |
| https://raw.githubusercontent.com/skrashevich/double-take/60c957d/.build/entrypoint.sh | upstream-double-take-fork-build.md |

Skipped categories: none beyond the filtered list.

Failures: none among the listed URLs.

Extra probes (not in urls.txt): https://api.github.com/repos/jakowenko/double-take and .../releases/tags/v1.13.2 both returned HTTP 403 (API rate limit). Not retried; the listed HTML pages were used instead.

Cache: no hits for this app.

## plan.md corrections
None. Plan facts checked against the fetched fork Dockerfile and entrypoint (stages, node:16-slim final, EXPOSE 3000, ENTRYPOINT entrypoint.sh, no USER, recognizer on 8888, `/.storage` paths, CONFIG_PATH) and the chart values (port 10200 to 3000, `/.storage` data mount, HTTP probes on `/`) all match.

Unverified conflicts (not edited):
- Plan start.sh (section 7) always runs `recognizer -cnn`. Upstream entrypoint adds `-cnn` only when a CUDA library is detected (`ldconfig -p | grep cuffda`); otherwise it runs without `-cnn`.
- Fork latest release `v1.13.11.8` (2023-11-20) and the fork's own LICENSE were not confirmed (API rate-limited). The fork repo page shows "MIT license", identical to the upstream page, so the fork's own file is unconfirmed.
- Upstream v1.13.2 release date 2025-08-18 is consistent with the plan.
