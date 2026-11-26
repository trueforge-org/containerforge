# Context: llalon-github-backup

| Source URL | File |
| --- | --- |
| https://github.com/abusesa/github-backup | github-abusesa-github-backup.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/llalon-github-backup | truecharts-llalon-github-backup-chart.md |
| https://hub.docker.com/r/llalon/github-backup | hub-docker-llalon-github-backup.md (FAILED: 404) |
| (alternative) https://hub.docker.com/v2/repositories/llalon/github-backup | FAILED: 404 |

Skipped categories: none in urls.txt.

## Failures
- https://hub.docker.com/r/llalon/github-backup: 404. Alternative (Docker Hub v2 API): 404. Not retried.

## plan.md corrections
- No edits made. Plan's config keys (`token`, `directory`, `owners`), pip install, run command and token scopes match the upstream README.
- Unverified: plan's "master, 15 commits" and the pinned-SHA plan were not re-checked (no SHA fetched).
- Unverified: the `llalon/github-backup` wrapper's env names and entrypoint remain unknown (Docker Hub 404), so the plan's ContainerForge env names are the plan's own design.
- Unverified: plan says `git` is needed at runtime. The upstream README does not name git; it is inferred from clone behaviour.
