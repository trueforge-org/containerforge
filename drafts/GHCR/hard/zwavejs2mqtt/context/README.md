# Context: zwavejs2mqtt

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zwavejs2mqtt/values.yaml + Chart.yaml | truecharts-zwavejs2mqtt.md |
| https://hub.docker.com/v2/repositories/zwavejs/zwave-js-ui/ | dockerhub-zwavejs-zwave-js-ui.md |
| https://raw.githubusercontent.com/zwave-js/zwave-js-ui/6aba3da40be776f8ee845de144477098978d3b74/docker/Dockerfile (+ github blob duplicate) | github-zwave-js-zwave-js-ui-dockerfile.md |
| https://api.github.com/repos/zwave-js/zwave-js-ui/releases/tags/v11.27.0 (alt: github.com release HTML) | github-zwave-js-zwave-js-ui-release.md |
| https://api.github.com/repos/zwave-js/zwave-js-ui (alt: github.com repo HTML) + raw docs/guide/env-vars.md | github-zwave-js-zwave-js-ui.md |

Skipped: none of the listed categories present in urls.txt (already filtered). Duplicates: github blob Dockerfile URL.

## Failures
- None unrecovered. api.github.com repo and releases endpoints returned 403; HTML alternatives used.

## plan.md corrections
- None made. PORT 8091, STORE_DIR, BACKUPS_DIR, HOST and ZWAVEJS_EXTERNAL_CONFIG match env-vars doc. Dockerfile facts (alpine base stages, EXPOSE 8091, CMD, no USER) match.
- Not corrections, for reference: TrueCharts ws service targets container port 3000 (chart evidence for plan's port 3000, still unverified upstream). Chart mounts `/usr/src/app/store`.
