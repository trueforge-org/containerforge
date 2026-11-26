# Context index: factorio

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/factoriotools/factorio-docker | github-factoriotools-factorio-docker.md |
| https://raw.githubusercontent.com/factoriotools/factorio-docker/master/README.md | github-factoriotools-factorio-docker.md |
| https://github.com/factoriotools/factorio-docker/blob/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile | github-factoriotools-factorio-docker.md |
| https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile | github-factoriotools-factorio-docker.md |
| https://factorio.com/ | docs-factorio-com.md |
| https://factorio.com/api/latest-releases | docs-factorio-com.md |
| https://factorio.com/download/sha256sums/ | docs-factorio-com.md |
| https://wiki.factorio.com/ | docs-wiki-factorio-com.md |
| https://hub.docker.com/r/factoriotools/factorio | dockerhub-factoriotools-factorio.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/factorio | truecharts-factorio.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://factorio.com/get-download/${VERSION}/headless/${platform} | template URL (contains ${) and direct binary download |
| https://factorio.com/get-download/2.1.25/headless/linux64 | direct binary download (302 to dl.factorio.com tarball); pattern recorded in docs-factorio-com.md |
| https://factorio.com/get-download/2.1.25/headless/linux-arm64 | direct binary download; pattern recorded in docs-factorio-com.md |
| https://factorio.com/get-download/stable/headless/linux64 | direct binary download |

## Fetch failures

None.

## Notes
- Version conflict: the Docker Hub page shows `latest` = 2.1.24 while the GitHub README fetch and factorio.com API show 2.1.25. Plan.md uses 2.1.25.
- Chart.yaml and values.yaml of the TrueCharts chart were not returned.
