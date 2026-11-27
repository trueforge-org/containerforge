# Context sources: GHCR/medium/booklore

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/booklore/values.yaml + Chart.yaml | truecharts-booklore.md |
| https://raw.githubusercontent.com/booklore-app/booklore/f397e98c5ab021b02e8930ce278583af11637238/Dockerfile (+ blob URL in urls.txt) + entrypoint.sh + booklore-api/src/main/resources/application.yaml | github-booklore-dockerfile.md |
| https://api.github.com/repos/booklore-app/booklore (+ /releases/latest, /contents/docker/unrar), https://github.com/booklore-app/booklore | github-booklore-repo.md |

- Skipped categories: none beyond the blob URL (served by raw equivalent).
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt.
- Failures: none.
- Not fetched: `unrar-*` binaries (binary download, skipped).

## plan.md corrections
- None made. Unverified conflicts to resolve in the build (not edited):
  - License: plan.md line 10 says GitHub reports AGPL-3.0 and Dockerfile label says GPL-3.0. Both confirmed as stated; plan line 78 uses AGPL-3.0-only (still unverified against LICENSE).
  - Database user: application.yaml (fetched) defaults `spring.datasource.username` to `${DATABASE_USERNAME:root}`, which matches plan.md. The chart sets `DATABASE_USERNAME` to `booklore` (depconfig `mariadbUsername`), so the chart overrides the default. No plan change needed.
  - Password: application.yaml uses `${DATABASE_PASSWORD:${MYSQL_ROOT_PASSWORD}}`.
