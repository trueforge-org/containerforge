# Context sources: GHCR/medium/audiobookshelf

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/audiobookshelf/values.yaml + Chart.yaml | truecharts-audiobookshelf.md |
| https://raw.githubusercontent.com/advplyr/audiobookshelf/1430c9fc642d586ff91c8d4cbed20aab2c47e473/Dockerfile (blob URL in urls.txt) | github-audiobookshelf-dockerfile.md |
| https://api.github.com/repos/advplyr/audiobookshelf (+ /releases/latest) | github-audiobookshelf-repo.md |
| https://github.com/advplyr/audiobookshelf (repo root) | covered by github-audiobookshelf-repo.md (README failed) |
| https://github.com/advplyr/audiobookshelf/releases/tag/v2.38.0 | replaced by api releases/latest (budget rule) |
| https://www.audiobookshelf.org, /docs, /docs/installation | audiobookshelf-site.md |

- Skipped categories: none beyond HTML release-tag page replaced by API.
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt.
- Failures: README raw on `master` (404) and `main` (404), not retried further. `/docs/installation` JS-rendered (no content).
- Binary download in Dockerfile (nunicode-sqlite zips) is recorded from the Dockerfile; not fetched (binary).

## plan.md corrections
- None. Verified against fetched sources: v2.38.0 tag/GPL-3.0/no release assets, Node 24 alpine stages, EXPOSE 80, env set, tini entrypoint.
