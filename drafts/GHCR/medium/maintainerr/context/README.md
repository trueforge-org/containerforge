# Context: maintainerr

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/Maintainerr/Maintainerr | github-maintainerr-maintainerr.md |
| https://github.com/Maintainerr/Maintainerr/releases/tag/v3.33.0 | github-maintainerr-maintainerr.md |
| https://github.com/Maintainerr/Maintainerr/releases/tag/v3.32.0 (draft's binary link) | github-maintainerr-maintainerr.md |
| https://raw.githubusercontent.com/Maintainerr/Maintainerr/v3.33.0/LICENSE | github-maintainerr-maintainerr.md |
| https://registry.npmjs.org/maintainerr | github-maintainerr-maintainerr.md (HTTP 404: no npm package) |
| https://github.com/Maintainerr/Maintainerr/blob/e6327bbb68b9/Dockerfile | github-maintainerr-dockerfile.md |
| https://raw.githubusercontent.com/Maintainerr/Maintainerr/e6327bbb68b9/Dockerfile | github-maintainerr-dockerfile.md |
| https://raw.githubusercontent.com/Maintainerr/Maintainerr/e6327bbb68b9/docker/start.sh (followed) | github-maintainerr-dockerfile.md |
| https://raw.githubusercontent.com/Maintainerr/Maintainerr/e6327bbb68b9/docker/healthcheck.sh (followed) | github-maintainerr-dockerfile.md |
| https://docs.maintainerr.info/ | docs-maintainerr-home.md |
| https://maintainerr.info | docs-maintainerr-home.md |
| https://docs.maintainerr.info/installation/ (followed from docs home) | docs-maintainerr-installation.md |
| https://docs.maintainerr.info/configuration/ (followed from docs home) | docs-maintainerr-installation.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/maintainerr | truecharts-maintainerr.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/maintainerr/values.yaml | truecharts-maintainerr.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://github.com/Maintainerr/Maintainerr/archive/refs/tags/v${VERSION}.tar.gz | Direct archive download (and contains `${`). Pattern recorded in github-maintainerr-maintainerr.md. |
| https://ghcr.io/maintainerr/maintainerr | GHCR image reference, not a web page. Chart digest in truecharts-maintainerr.md. |
| https://hub.docker.com/r/maintainerr/maintainerr | Linked from the docs home; not referenced by the draft or plan. Covered by the docs. |
| https://api.github.com/repos/Maintainerr/Maintainerr/releases/latest, /license (plan.md) | API variants of pages covered by the release and repo pages. |
| https://discord.maintainerr.info, features.maintainerr.info, status page | Community links, not needed for the build. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu, apps/python-node, apps/changedetection | ContainerForge `apps/<base>` links. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/python-node:3.15.2@sha256:... | Image reference. |
| node:26.13.0-alpine | Upstream base image reference (Dockerfile FROM). |
| docs/project-fireball.md, apps/changedetection, apps/budge, apps/adguardhome-sync | Repo-internal files, not web sources. |

## Fetch failures and partial results

- Release pages v3.33.0 and v3.32.0: pages loaded; the asset file names did not load ("Assets 2"). Plan.md's API check found no release assets.
- https://registry.npmjs.org/maintainerr: HTTP 404. No npm package, which agrees with plan.md.
- Docs sub-pages /configuration and /installation: loaded; no data directory path (SQLite file) or log path was stated.
- The repo Node engine (`package.json` engines) was not shown on the repo page; the Node version in the python-node base remains UNVERIFIED.
