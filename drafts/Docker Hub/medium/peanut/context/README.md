# Context: peanut

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/peanut/values.yaml | truecharts-peanut.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/peanut/Chart.yaml | truecharts-peanut.md |
| https://hub.docker.com/v2/repositories/brandawg93/peanut/ | dockerhub-peanut.md (full_description empty) |
| https://hub.docker.com/v2/repositories/brandawg93/peanut/tags?page_size=10 | dockerhub-peanut.md |
| https://github.com/Brandawg93/PeaNUT/blob/7ad39fd50525a3c7e5f0979fef7defbcc7f65229/Dockerfile | github-peanut-dockerfile.md (raw variant) |
| https://raw.githubusercontent.com/Brandawg93/PeaNUT/7ad39fd50525a3c7e5f0979fef7defbcc7f65229/package.json | github-peanut-dockerfile.md |
| https://api.github.com/repos/Brandawg93/PeaNUT/releases/latest | github-peanut-release.md |
| https://api.github.com/repos/Brandawg93/PeaNUT | not fetched; release API and Dockerfile cover the build |
| https://github.com/Brandawg93/PeaNUT | not fetched; covered above |
| https://github.com/Brandawg93/PeaNUT/releases/tag/v6.1.2 | not fetched; covered by releases/latest and package.json |

Skipped categories: none (no CLA, templated, binary or image-ref URLs in list).
Failures: none.

## plan.md corrections
- Edited (chart claims only; the chart pins 6.2.0, fetched 2026-11-27):
  - line 9: "Draft and chart use `docker.io/brandawg93/peanut:6.1.2`. Same version." -> "Draft uses `docker.io/brandawg93/peanut:6.1.2`. The TrueCharts chart (fetched 2026-11-27) pins `docker.io/brandawg93/peanut:6.2.0`, not 6.1.2." Source: truecharts-peanut.md
  - line 240: "The chart uses `brandawg93/peanut:6.1.2` (no `v`)." -> "The chart uses `brandawg93/peanut:6.2.0` (no `v`; fetched 2026-11-27)." Source: truecharts-peanut.md
  - line 273: "chart tag (`6.1.2`)" -> "chart tag (`6.2.0`)". Source: truecharts-peanut.md
- UNVERIFIED conflict, not edited (version choice is the author's call): line 8 says `v6.1.2` is the version to build, and Docker Hub `latest` last_updated 2026-10-28. The releases/latest API now returns v6.2.0 (published 2026-11-27T01:46:46Z), and Docker Hub `latest` was last updated 2026-11-27T01:45:58Z. Plan should be reviewed against v6.2.0.
