# Context sources: GHCR/medium/actualserver

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/actualserver/values.yaml + Chart.yaml | truecharts-actualserver.md |
| https://raw.githubusercontent.com/actualbudget/actual/1766241e3f4b3c578e424c4fa15f1eb83c0da17d/packages/sync-server/docker/alpine.Dockerfile (blob URL in urls.txt) | github-actual-sync-server-dockerfile.md |
| https://github.com/actualbudget/actual + https://api.github.com/repos/actualbudget/actual (releases/latest) | github-actual-repo.md |
| https://registry.npmjs.org/@actual-app/sync-server/26.11.0 | npm-actual-sync-server.md |
| https://actualbudget.org, /docs, /docs/install/docker, /docs/config/ | actualbudget-site.md |
| https://github.com/Kippenhof/docker-templates | kippenhof-docker-templates.md |
| https://api.github.com/repos/actualbudget/actual | covered by github-actual-repo.md (release only) |

- Skipped (not fetched): none of the listed URLs were skipped except the repo-root and blob variants, which were served by their raw equivalents.
- Shared cache (docs/context/INDEX.md): no hits.
- No Docker Hub URL in urls.txt (image is GHCR-published; docs mention Docker Hub `actualbudget/actual-server` as a mirror).
- Failures: none.

## plan.md corrections
- None. Checked plan facts (port 5006, UID 1001, /data, Node >=22.19.0, tini, MIT, 26.11.0) against fetched sources; no clear conflicts.
