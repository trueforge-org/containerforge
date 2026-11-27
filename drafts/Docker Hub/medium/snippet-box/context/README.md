# Context index: snippet-box

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/snippet-box/values.yaml | truecharts-snippet-box.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/snippet-box/Chart.yaml | truecharts-snippet-box.md |
| https://hub.docker.com/v2/repositories/pawelmalak/snippet-box/ | dockerhub-snippet-box.md |
| https://hub.docker.com/v2/repositories/pawelmalak/snippet-box/tags?page_size=10 | dockerhub-snippet-box.md |
| https://raw.githubusercontent.com/pawelmalak/snippet-box/f501941a22ead0fccd196d109098e9b065205d98/Dockerfile | github-snippet-box.md |
| https://api.github.com/repos/pawelmalak/snippet-box | github-snippet-box.md |

Skipped categories: GitHub HTML pages (`github.com/pawelmalak/snippet-box`, `/releases`, `blob/.../Dockerfile`), covered by the raw Dockerfile and API.

Failures:
- https://api.github.com/repos/pawelmalak/snippet-box/releases/latest: 404 (no releases). Recorded, not retried.
- https://api.github.com/repos/pawelmalak/snippet-box/tags: 403 rate limit (used as the single alternative). Recorded, not retried.

## plan.md corrections
- Line 8 (Version to build): "no tags used by Docker Hub (`latest`, last updated 2021-10-14)" -> Docker Hub has three tags (`latest` 2021-10-14 amd64, `dev` 2021-11-18 amd64/arm64/arm, `arm` 2021-10-14 arm64/arm). Source: dockerhub-snippet-box.md. Also noted GitHub tags are unreadable (rate limit).
- Not edited, verified by chart: plan line 15 says the chart's 5039 port value is unconfirmed. truecharts-snippet-box.md shows service port 5039 -> targetPort 5000 (container port 5000).
- Unverified (not in fetch list, not edited): `PORT` default and `data/db.sqlite3` path in `src/index.ts` / `src/db/index.ts`.
