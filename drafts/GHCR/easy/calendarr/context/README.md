# Sources for calendarr (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/calendarr/values.yaml | truecharts-calendarr.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/calendarr/Chart.yaml | truecharts-calendarr.md |
| https://api.github.com/repos/jordanlambrecht/calendarr/license | github-calendarr.md |
| https://api.github.com/repos/jordanlambrecht/calendarr/releases/tags/v1.5.2 (for https://github.com/jordanlambrecht/calendarr/releases/tag/v1.5.2) | github-calendarr.md |
| https://raw.githubusercontent.com/jordanlambrecht/calendarr/4da458fb9d59a787c6ae1819eb063ba91cfe83d1/Dockerfile (for https://github.com/jordanlambrecht/calendarr/blob/4da458.../Dockerfile) | github-calendarr-dockerfile.md |
| https://raw.githubusercontent.com/jordanlambrecht/calendarr/main/Dockerfile (for https://github.com/jordanlambrecht/calendarr/blob/main/Dockerfile) | github-calendarr-dockerfile.md |
| https://raw.githubusercontent.com/jordanlambrecht/calendarr/main/requirements.txt (for .../blob/HEAD/requirements.txt) | github-calendarr.md |

Skipped: https://github.com/jordanlambrecht/calendarr (repo root, covered by license and release API calls). No Docker Hub URL (GHCR image). Chart "sources" entries (ghcr.io, github path) are the same as above.

Failures: none.

## plan.md corrections
- None. Version v1.5.2 (published 2026-11-04), GPL-3.0, no release assets, Python pins, EXPOSE 5000 and main-branch base `python:3.15.2-slim` match fetched sources.
- Not checked (out of fetched scope): plan's config.py env defaults (for example USE_DISCORD default) were not re-fetched; left as is.
