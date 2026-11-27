# Context README: plaxt

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plaxt/values.yaml | truecharts-plaxt.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plaxt/Chart.yaml | truecharts-plaxt.md |
| https://hub.docker.com/v2/repositories/xanderstrike/goplaxt/ | dockerhub-plaxt.md |
| https://hub.docker.com/v2/repositories/xanderstrike/goplaxt/tags?page_size=10 | dockerhub-plaxt.md |
| https://raw.githubusercontent.com/XanderStrike/goplaxt/1607349dea8ce7fb3b8e7ccfb0370d8103d31d61/Dockerfile-amd64 | github-plaxt.md |
| https://api.github.com/repos/XanderStrike/goplaxt/license | github-plaxt.md |

Skipped: CLA/none; forgetool schemas/none; containerforge apps links/none; templated URLs/none; binary downloads/none (source tarball by commit, not fetched); image refs/none; GitHub repo HTML, blob view, releases (404 per plan, not re-fetched); plaxt.astandke.com hosted instance (not a build source).

Failures: none.

## plan.md corrections
- None. Verified: commit 1607349 Dockerfile-amd64 (`golang:1.12.7-alpine`, `FROM scratch`, `EXPOSE 8000`, `VOLUME /app/keystore/`, ENTRYPOINT, no USER/ENV); MIT licence; Docker Hub `latest` amd64 only.
- Not in plan, noted only: Docker Hub also has tag `latest-arm7` (2024-11-13, listed amd64). Plan does not mention it. Not edited.
- Still UNVERIFIED in plan (not resolved by these sources): Trakt env var names, keystore path in the binary, bind address.
