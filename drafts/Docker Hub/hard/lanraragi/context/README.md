# Context: lanraragi

| Source URL | File |
| --- | --- |
| https://github.com/Difegue/LANraragi | lanraragi-readme-dev.md (README from dev branch) |
| https://github.com/Difegue/LANraragi/blob/add16039b89726afa1cdd92b6dab548191bac987/tools/build/docker/Dockerfile | dockerfile-add16039.md |
| https://github.com/Difegue/LANraragi/blob/dev/tools/build/docker/Dockerfile | dockerfile-dev.md |
| https://github.com/Difegue/LANraragi/releases/tag/v.0.9.41 | github-releases-latest-api.md (API latest used: v.0.9.82; tag v.0.9.41 not fetched) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/lanraragi | truecharts-lanraragi-chart.md |
| https://hub.docker.com/r/difegue/lanraragi | hub-docker-difegue-lanraragi.md |
| https://sugoi.gitbook.io/lanraragi | gitbook-lanraragi-stable.md |
| https://sugoi.gitbook.io/lanraragi/v/dev | gitbook-lanraragi-dev.md |
| (follow-up) https://sugoi.gitbook.io/lanraragi/installing-lanraragi/methods.md | gitbook-installing-methods.md |
| (follow-up) https://sugoi.gitbook.io/lanraragi/installing-lanraragi/docker.md | gitbook-docker-install.md |

Skipped (filter miss, templated): `http://*:3000` (placeholder, not fetched).

## Failures
- None.

## plan.md corrections
- No edits made. Plan's version 0.9.82 matches the GitHub release API.
- Unverified: plan cites the dev-branch Dockerfile (alpine:3.24, valkey) as the upstream reference for release 0.9.82. The only pinned Dockerfile fetched (add16039) uses alpine:3.20. The release tag's own Dockerfile was not fetched.
- Unverified: plan's `LICENSE` value `MIT` is not stated in the fetched README.
