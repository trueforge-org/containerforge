# context: slink

| Source URL | File |
| --- | --- |
| https://github.com/andrii-kryvoviaz/slink/blob/aefc970.../docker/Dockerfile.prod | slink-dockerfile-prod.md |
| https://github.com/andrii-kryvoviaz/slink/releases/tag/v1.14.6 | slink-release-v1.14.6.md |
| https://github.com/andrii-kryvoviaz/slink (README) | slink-readme-upstream.md |
| https://hub.docker.com/r/anirdev/slink | dockerhub-anirdev-slink.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/slink | truecharts-slink.md |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (copied from shared cache docs/context) |

Skipped categories: none present in urls.txt.

## Failures
- docker/Dockerfile (the `common` base stage used by Dockerfile.prod `FROM common`): 404 at commit aefc970 (`.../aefc97065c20c543299d23b7315551c979705378/docker/Dockerfile`); alternative `.../main/docker/Dockerfile`: 404. Common-stage packages/user/base are UNVERIFIED.

## plan.md corrections
- none applied (no proven factual error).
- Notes: TrueCharts pins v1.14.6 matching the release; healthcheck port 8080 vs EXPOSE 3000 (fact from Dockerfile.prod).
