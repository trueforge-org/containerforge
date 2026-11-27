# Context: redmine

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redmine/values.yaml | truecharts-redmine.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redmine/Chart.yaml | truecharts-redmine.md |
| https://hub.docker.com/v2/repositories/library/redmine/ | dockerhub-redmine.md |
| https://hub.docker.com/v2/repositories/library/redmine/tags?page_size=10 | dockerhub-redmine.md |
| https://raw.githubusercontent.com/docker-library/redmine/49a27f29f1d214a4226af75b55578e36d3474c4c/6.1/bookworm/Dockerfile | github-docker-library-redmine.md |
| https://raw.githubusercontent.com/docker-library/redmine/49a27f29f1d214a4226af75b55578e36d3474c4c/6.1/bookworm/docker-entrypoint.sh | github-docker-library-redmine.md |

Skipped: CLA, forgetool schemas, containerforge apps links, templated, binary downloads, image refs (removed from urls.txt). Also skipped as duplicates/budget: github.com blob Dockerfile variant, redmine LICENSE.txt, redmine.org homepage/wiki/releases pages (version and checksum come from the Dockerfile).

## Failures
- None.

## plan.md corrections (unverified conflicts, no edit)
- Chart pins image tag `6.1.0`; not found on Docker Hub first page (tags 6.1.6 and 6.1 families exist). Not verified against later pages, so no edit.
- Docker Hub `latest` is currently 7.0.3 (per Hub description), while the fetched Dockerfile is 6.1.6. Plan not re-read to check which version it targets.
