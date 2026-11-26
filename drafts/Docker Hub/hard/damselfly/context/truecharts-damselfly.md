# TrueCharts chart damselfly (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/damselfly (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/damselfly/values.yaml) · fetched 2026-11-26

## Image
`docker.io/webreaper/damselfly:latest@sha256:6dedb903ee37463619495aad8652d2aaf23ccba61acf253e1ada764f4529dd13` (IfNotPresent). Chart uses the rolling `latest` digest.

## Ports
Main port 6363 (tcp).

## Env
None defined.

## Persistence
`config` -> `/config`; `pictures` -> `/pictures`; `thumbs` -> `/thumbs` (types not stated).

## Security context
readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
None defined.

## Gotchas
- Chart has no SYNO_THUMBS or ONDEMAND_THUMBS settings; they are optional env vars in the image entrypoint.
