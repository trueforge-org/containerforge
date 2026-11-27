# Context README: photoprism

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoprism/values.yaml | truecharts-photoprism.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoprism/Chart.yaml | truecharts-photoprism.md |
| https://hub.docker.com/v2/repositories/photoprism/photoprism/ | dockerhub-photoprism.md |
| https://hub.docker.com/v2/repositories/photoprism/photoprism/tags?page_size=10 | dockerhub-photoprism.md |
| https://api.github.com/repos/photoprism/photoprism/releases/latest | github-photoprism.md |
| https://raw.githubusercontent.com/photoprism/photoprism/master/docker/photoprism/questing/Dockerfile | github-photoprism.md |
| https://docs.photoprism.app | photoprism-docs.md |
| https://docs.photoprism.app/getting-started/config-options/ | photoprism-docs.md |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads (release tarballs, not fetched); image refs/none; GitHub repo HTML and blob view; photoprism.app and developer pages (duplicates or budget); Docker Compose / setup pages (budget).

Failures: none.

## plan.md corrections
- None. Verified against fetched sources: release 261029-963b58c50 and both tarball names, EXPOSE 2342/2443, WORKDIR /photoprism, questing base images, SQLite default driver.
- Confirmed but still marked UNVERIFIED in plan (not edited): `PHOTOPRISM_ADMIN_PASSWORD` exists (config-options page, default none, 8-72 chars).
- Unclear in fetched Dockerfile summary: whether ENV names use `PHOTOPRISM_` prefix for the DISABLE_* / path vars. Not proven wrong; left as is.
