# Context index: synctube

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/synctube/values.yaml | truecharts-synctube.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/synctube/Chart.yaml | truecharts-synctube.md |
| https://hub.docker.com/v2/repositories/littlestache/synctube/ | dockerhub-synctube.md |
| https://hub.docker.com/v2/repositories/littlestache/synctube/tags?page_size=10 | dockerhub-synctube.md |
| https://raw.githubusercontent.com/RblSb/SyncTube/d22d837/Dockerfile | github-synctube-dockerfile.md |

Skipped categories: GitHub HTML pages (`github.com/RblSb/SyncTube`, `blob/d22d837/Dockerfile`) covered by the raw Dockerfile.

Failures: none.

## plan.md corrections
None edited. Checked and consistent: upstream Dockerfile content (haxe:4.3-alpine3.22, apk nodejs npm git, UID/GID 1000 `app`, `/app`, ENTRYPOINT node build/server.js); Docker Hub `latest` only, last 2021-12-04, amd64.
Unverified (not edited): plan line 16 port 4200 from `default-config.json` (file copied by the Dockerfile but not fetched here); plan line 11 MIT license (GitHub API not fetched in this pass).
