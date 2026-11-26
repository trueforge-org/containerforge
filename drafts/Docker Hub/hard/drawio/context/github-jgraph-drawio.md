# jgraph/drawio (repo and release v32.7.4)

Source URL(s) + fetch date:
- https://github.com/jgraph/drawio (repo page)
- https://github.com/jgraph/drawio/releases/tag/v32.7.4
- Fetched 2026-11-26

## What it is
- draw.io: client-side diagram editor (JavaScript). Source Apache-2.0 (icon sets and templates carry an extra restriction; exported output exempt). Default branch `dev`.
- Repo top level: `.github`, `docs`, `etc`, `src/main`, `LICENSE`, `VERSION`, `ChangeLog`, `README.md`, `SECURITY.md`, `teams.html`, `CITATION.cff`, `CODE_OF_CONDUCT.md`, `.travis.yml`.
- README: Running options include publishing a fork to GitHub Pages, the Docker image, or packaged .war files on the releases page. Desktop app separate. Repo does not accept pull requests; README calls it a test version.

## Build instructions
- Repo page shows no ant or war build instructions in the captured content. Docker build uses `ant war` in `etc/build/` (see github-docker-drawio.md).
- No reference to an export server or draw-image-export in the repo README.

## Release v32.7.4
- Tag v32.7.4, published 17 Nov (year not shown) by github-actions, commit f411a11f4f6b8994d869bdbc45f4d4d9e2284f34. No release notes. Page says "Assets 3" but names did not load.
- A draw.war asset was not visible in the fetch; the plan's `releases/download/v32.7.4/draw.war` URL is from the draft and was not confirmed by this fetch.
- The dev branch had one commit more than this release at fetch time.

## Asset naming
- draw.war at `https://github.com/jgraph/drawio/releases/download/<tag>/draw.war` (direct download, not fetched, recorded here).

## Gotchas
- Releases page did not show the latest version. Docker Hub and TrueCharts use 32.7.7 (see dockerhub-jgraph-drawio.md).
