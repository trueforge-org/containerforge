# Context README: pgadmin

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pgadmin/values.yaml | truecharts-pgadmin.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pgadmin/Chart.yaml | truecharts-pgadmin.md |
| https://hub.docker.com/v2/repositories/dpage/pgadmin4/ | dockerhub-pgadmin.md |
| https://hub.docker.com/v2/repositories/dpage/pgadmin4/tags?page_size=10 | dockerhub-pgadmin.md |
| https://raw.githubusercontent.com/pgadmin-org/pgadmin4/REL-9_19/Dockerfile | github-pgadmin.md |
| https://pypi.org/pypi/pgadmin4/json | pypi-pgadmin.md |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads/none; image refs/none; GitHub API repo, GitHub HTML pages (blob, repo root), releases; www.pgadmin.org and /docs (budget, duplicates of PyPI home page).

Failures: none.

## plan.md corrections
- None. Plan's Dockerfile summary, version 9.19, port 5050 and `USER 5050` match fetched sources.
- Not confirmed by fetch (left as UNVERIFIED in plan): `run_pgadmin.py`/`gunicorn_config.py` contents, `/misc/ping` health path. Chart uses `/misc/ping` for its probes.
