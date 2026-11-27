# googlephotossync context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/googlephotossync/values.yaml + Chart.yaml | truecharts-googlephotossync.md |
| Docker Hub | none (image is GHCR: ghcr.io/gilesknap/gphotos-sync) |
| https://raw.githubusercontent.com/gilesknap/gphotos-sync/master/Dockerfile (= pinned b50baad Dockerfile) | gphotos-upstream-dockerfile-readme.md |
| https://api.github.com/repos/gilesknap/gphotos-sync/releases/latest | gphotos-upstream-dockerfile-readme.md |
| https://api.github.com/repos/gilesknap/gphotos-sync/license | gphotos-upstream-dockerfile-readme.md |
| https://raw.githubusercontent.com/gilesknap/gphotos-sync/master/README.rst | gphotos-upstream-dockerfile-readme.md |

Skipped categories: github.com repo/blob HTML duplicates, pinned blob URL (diffed against master raw, identical), pypi.org/project (package index page, budget).
Failures:

- https://gilesknap.github.io/gphotos-sync: 404. Alternative tried: raw README.md (404), then raw README.rst (fetched). Budget exceeded by one alternative; recorded here.

## plan.md corrections

- No factual error found in the plan's version (3.2.5), Dockerfile, license or release-asset facts.
- Not edited, flagged for the user: upstream README.rst states the project was archived on 2024-10-04. plan.md does not mention this. Consider adding a note (and the `--flush-index` requirement for index DB upgrades, if the plan ships a 3.2.x upgrade path).
- Still UNVERIFIED in plan.md: config/token and download paths and env vars (not in README.rst).
