# TrueCharts chart browserless-chrome (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/browserless-chrome (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/browserless-chrome/values.yaml) · fetched 2026-11-26

## What the chart runs
- Main image `docker.io/browserless/chrome:1.61.1-chrome-stable` (digest pinned) and a `puppeteer` variant `1.61.1-puppeteer-13.1.3`. These are the **v1** images; plan.md's v2 switch is needed.
- Service main port 10194 (http), targetPort 3000.

## Env (main container)
WORKSPACE_DIR=/downloads, METRICS_JSON_PATH=/metrics/metrics.json, HOST="" (empty), WORKSPACE_DELETE_EXPIRED=false, WORKSPACE_EXPIRE_DAYS=30, CHROME_REFRESH_TIME=3600000, MAX_CONCURRENT_SESSIONS=5, MAX_QUEUE_LENGTH=5, CONNECTION_TIMEOUT=30000, DEFAULT_BLOCK_ADS=true, DEFAULT_HEADLESS=true, DEFAULT_IGNORE_HTTPS_ERRORS=true, DEFAULT_IGNORE_DEFAULT_ARGS=true, ENABLE_API_GET=true, FUNCTION_ENABLE_INCOGNITO_MODE=true, EXIT_ON_HEALTH_FAILURE=true, DISABLE_AUTO_SET_DOWNLOAD_BEHAVIOR=false, ENABLE_DEBUGGER=true, ENABLE_CORS=false, ENABLE_XVBF=true, TOKEN from secret `env-secrets` (empty default).
Chart comment: enabling KEEP_ALIVE and PREBOOT_CHROME causes probe/app failure.

## Persistence
`downloads` -> `/downloads`; `metrics` -> `/metrics`. Probes (liveness, readiness, startup) use `/metrics`.

## Not in values
securityContext, readOnlyRootFilesystem, runAsUser are not set in values (the draft's "runAsUser 568 default" is inferred from the common library).

## Gotchas
- Chart env names (`WORKSPACE_DIR`, `MAX_CONCURRENT_SESSIONS`, `ENABLE_XVBF`, ...) are v1-era and do not match the v2 docs names (`DOWNLOAD_DIR`, `CONCURRENT`, ...). The v2 names are in docs-browserless-docker.md (enterprise) and must be verified against the OSS build before use.
- Chart probes use `/metrics`; v2 documents `/pressure` for health.
