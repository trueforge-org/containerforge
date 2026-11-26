# TrueCharts chart: rcon-webadmin

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rcon-webadmin (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rcon-webadmin/values.yaml (fetched)

## Image
- repository `docker.io/itzg/rcon`, tag `latest@sha256:c9521f333bf9eaedf2db0acd750e67be88eaaa9c5e9026385bd875dc18a49110`, pullPolicy IfNotPresent. Chart uses the itzg wrapper, not the rcon-web-admin upstream image.

## Ports
- `main` 4326 http (targetPort 4326); `websocketaccess` 4327 tcp (enabled).

## Persistence
- `db` mountPath `/opt/rcon-web-admin/db`.

## securityContext (container)
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Env vars
- Templated from chart values: RWA_ADMIN, RWA_ENV, RWA_WEB_RCON, RWA_READ_ONLY_WIDGET_OPTIONS (TRUE/FALSE), RWA_GAME, RWA_SERVER_NAME, RWA_RCON_HOST, RWA_RCON_PORT, RWA_RESTRICT_COMMANDS, RWA_RESTRICT_WIDGETS, RWA_WEBSOCKET_URL_SSL, RWA_WEBSOCKET_URL.
- RWA_USERNAME: admin.
- RWA_PASSWORD and RWA_RCON_PASSWORD from secret `env-secrets`.
- Chart secret placeholder values: RWA_PASSWORD and RWA_RCON_PASSWORD both 'pass' (chart placeholder).

## Probes
- None.
