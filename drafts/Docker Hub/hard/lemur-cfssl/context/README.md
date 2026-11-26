# Context: lemur-cfssl

| Source URL | File |
| --- | --- |
| https://github.com/Netflix/lemur (raw README https://raw.githubusercontent.com/Netflix/lemur/master/README.md returned 404; alternative used) | github-netflix-lemur.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/lemur-cfssl | truecharts-lemur-cfssl-chart.md |
| https://hub.docker.com/r/halianelf/lemur | hub-docker-halianelf-lemur.md |
| https://lemur.readthedocs.io | readthedocs-root.md |
| https://lemur.readthedocs.io/en/latest | readthedocs-latest.md |
| (follow-up) https://lemur.readthedocs.io/en/latest/quickstart/index.html | readthedocs-quickstart.md |
| (follow-up) https://lemur.readthedocs.io/en/latest/administration.html | readthedocs-administration.md |

Skipped categories: none in urls.txt.

## Failures
- None counted. Raw GitHub README returned 404 (one alternative, the repo page, was used successfully).

## plan.md corrections
- No edits made. No clear factual error proven by the fetched sources.
- Material, not in plan: upstream repo github.com/Netflix/lemur is ARCHIVED and read-only since 2026-07-06 (no new PRs/issues). Plan's SOURCE and renovate references point to it.
- Resolved as confirmed (plan marks UNVERIFIED): `LEMUR_CONF` env var is read by Lemur (quickstart); `lemur start -b <addr>` is the web start command (quickstart); `SQLALCHEMY_DATABASE_URI`, `LEMUR_TOKEN_SECRET`, `LEMUR_ENCRYPTION_KEYS` exist as config keys (administration). `SECRET_KEY` is NOT documented in the fetched page (still unverified).
- Partly resolved: plan says Netflix/lemur docker files are UNVERIFIED. The repo root lists `Dockerfile`, `docker-compose.yml` and `docker/` (not reviewed).
- Unverified: CFSSL_URL / CFSSL_ROOT / CFSSL_INTERMEDIATE are the Lemur CFSSL plugin keys (new info for the plan; not contradicted).
