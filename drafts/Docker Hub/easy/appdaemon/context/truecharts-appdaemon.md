# TrueCharts chart: appdaemon

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/appdaemon (listed in draft)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/appdaemon/values.yaml (fetched 2026-11-26)

**Config (values.yaml)**
- Image `docker.io/acockburn/appdaemon` tag `4.5.16@sha256:e221331ca98c19558b9e7838e2187e63d5c900eebfd0804a6cba4b1596782420`, pullPolicy `IfNotPresent`.
- Service `main`, port `main`: 5050 (http) -> 5050.
- Persistence `conf` at `/conf`, enabled, no size.
- securityContext (container): runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false; privileged not set.
- Env: `DASH_URL` "http://0.0.0.0:5050", `HA_URL` "ha-url" (placeholder), `LATITUDE` 46, `LONGITUDE` -94, `ELEVATION` 1217, `TIMEZONE` from `.Values.TZ`, `TOKEN` from secret `env-secrets` key `TOKEN` (placeholder `REPLACETHIS`).
- Probes: liveness, readiness and startup, all http `/`. No timing values set.

**Gotchas**
- Chart sample values (LATITUDE 46, LONGITUDE -94, ELEVATION 1217) are example data, not defaults for ContainerForge.
- Chart sets `DASH_URL` to `0.0.0.0:5050`, which upstream start.sh writes into `http.url`.
