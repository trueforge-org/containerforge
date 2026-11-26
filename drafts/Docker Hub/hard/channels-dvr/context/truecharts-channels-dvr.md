# TrueCharts chart channels-dvr (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/channels-dvr (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/channels-dvr/values.yaml) · fetched 2026-11-26

## Images
- `image`: `docker.io/fancybits/channels-dvr`, tag `latest` pinned by digest (`8b430c58…0f0abf`), pullPolicy Always.
- `tveImage`: same repo, tag `tve` pinned by digest (`4d491658…15169c`), pullPolicy Always. Main container uses `imageSelector: image`.

## Ports
Service main, port 8089 (http), targetPort 8089.

## Env
None.

## Persistence
- `config` -> `/channels-dvr`; `recordings` -> `/shares/DVR`.

## Probes
Liveness, readiness and startup: http on port 8089.

## Not specified
hostNetwork, devices, securityContext, readOnlyRootFilesystem, runAsUser.

## Gotchas
- Chart runs `latest` and `tve`; the plan's single-image scope covers only `latest`.
