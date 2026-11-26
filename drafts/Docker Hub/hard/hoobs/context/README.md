# hoobs context

| Source URL | File |
| --- | --- |
| https://api.github.com/repos/hoobs-org/HOOBS/releases/latest | github-hoobs-releases.md |
| https://raw.githubusercontent.com/hoobs-org/HOOBS/master/README.md (repo root) | github-hoobs-readme.md |
| https://hub.docker.com/r/hoobs/hoobs | dockerhub-hoobs-hoobs.md |
| https://hoobs.org | FAILED (301 to https://hoobs.com/, which returned 403); no file |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hoobs | truecharts-hoobs.md (via raw values.yaml; tree page not fetched) |

Skipped: none of the listed categories applied.

Failures: 1. hoobs.org redirected to hoobs.com, which returned 403. Not retried.

## plan.md corrections
None edited. Unverified notes:
- plan.md says web port 8581 (draft, inferred). The TrueCharts chart maps main service to targetPort 80 and HAP to 51826. This is chart data, not upstream proof; plan keeps 8581 as UNVERIFIED.
- plan.md version 3.3.12 (npm). GitHub latest release is `v4.1` (2021-10-19). Source not reconciled.
- plan.md says GPL-3.0 from GitHub. The README does not state a license (only copyright and trademark notice).
