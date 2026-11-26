# Context: fotosho

| Source URL | File |
| --- | --- |
| https://github.com/advplyr/fotosho (+ raw Dockerfile, package.json, README) | advplyr-fotosho.md |
| https://github.com/advplyr/fotosho/releases | advplyr-fotosho.md (no releases) |
| https://api.github.com/repos/advplyr/fotosho/releases/latest | advplyr-fotosho.md (404) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fotosho (+ raw Chart.yaml, values.yaml) | truecharts-fotosho.md |
| https://hub.docker.com/r/advplyr/fotosho (+ v2 API repo and tags) | dockerhub-fotosho.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated, binary or image-ref URLs.

Failures: https://api.github.com/repos/advplyr/fotosho/releases/latest returned 404; one alternative (github releases page) used: no releases, repo archived. hub.docker.com HTML not fetched; v2 JSON API used.

## plan.md corrections
- No edits. Consistent with fetched sources: Dockerfile (node:12-alpine both stages, EXPOSE 80, NODE_ENV/LOG_LEVEL, CMD node index.js, root), no releases, Docker Hub single tag `latest` amd64 (2021-07-30), package.json version 1.0.42.
- Not verified: plan line 13 says repo API returns 403 (not re-checked; releases page fetched instead). Chart port 13377 (chart, targetPort 80) is not mentioned in plan.md; no conflict.
