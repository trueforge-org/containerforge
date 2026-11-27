# Context sources: headphones

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headphones/values.yaml | truecharts-headphones.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headphones/Chart.yaml | truecharts-headphones.md |
| https://hub.docker.com/v2/repositories/linuxserver/headphones/ | dockerhub-headphones.md |
| https://raw.githubusercontent.com/linuxserver/docker-headphones/2eda0d5edcbb/Dockerfile | linuxserver-dockerfile.md |
| https://api.github.com/repos/rembo10/headphones/releases/latest | upstream-release.md |
| https://raw.githubusercontent.com/rembo10/headphones/v0.6.4/LICENSE | upstream-license.md |
| https://github.com/rembo10/headphones/wiki | upstream-wiki.md |
| https://github.com/rembo10/headphones/wiki/Installation | upstream-wiki.md |
| https://github.com/rembo10/headphones/wiki/Usage-guide | upstream-wiki.md |

Skipped categories:
- Duplicates: github.com blob/repo-root URLs for linuxserver/docker-headphones and rembo10/headphones (covered by raw files, Dockerhub, and wiki), releases/tag/v0.6.4 (covered by API), raw.githubusercontent.com ... Dockerfile blob variant.
- Binary: source tarball archive (not fetched; no release assets).
- Templated/other: none in list.

Failures: none. Wiki sub-pages not fetched (budget): Troubleshooting, Install as a daemon, Musicbrainz mirrors, VIP server, XLD.

## plan.md corrections
- None. Verified against fetched sources: Alpine 3.17, port 8181, chart image `version-a78f38c1`, GPL v3 LICENSE, deprecation.
- Unverified in plan, not changed: linuxserver builds master (plan pins v0.6.4). Fetched wiki has no Docker/config-file details, so the plan's `--datadir` and `HTTP_PORT` lines are not checked here.
