# Context: pasta

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pasta/values.yaml | truecharts-pasta.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pasta/Chart.yaml | truecharts-pasta.md |
| https://hub.docker.com/v2/repositories/cglatot/pasta/ | dockerhub-pasta.md |
| https://hub.docker.com/v2/repositories/cglatot/pasta/tags?page_size=10 | dockerhub-pasta.md |
| https://github.com/cglatot/pasta/blob/1030b05cdef24d8ea382223496af0c050d45ad46/Dockerfile | github-pasta-dockerfile.md (raw variant) |
| https://raw.githubusercontent.com/cglatot/pasta/1030b05cdef24d8ea382223496af0c050d45ad46/package.json | github-pasta-dockerfile.md |
| https://api.github.com/repos/cglatot/pasta/releases/latest | github-pasta-release.md |
| https://api.github.com/repos/cglatot/pasta | not fetched; release API and Dockerfile cover what the build needs |
| https://github.com/cglatot/pasta | not fetched separately; readme text is in dockerhub-pasta.md |
| https://github.com/cglatot/pasta/releases/tag/3.0.0 | not fetched; covered by releases/latest |

Skipped categories: none (no CLA, templated, binary or image-ref URLs in list).
Failures: none.

## plan.md corrections
- No edits made.
- Info (confirmed, not a conflict): plan section 3 step 7 says upstream's runtime stage omits node_modules (marked UNVERIFIED). Fetched Dockerfile confirms: runtime stage has no npm ci and copies no node_modules. package.json deps are frontend-only (react, bootstrap, react-query, fontawesome); server-side imports were not checked.
