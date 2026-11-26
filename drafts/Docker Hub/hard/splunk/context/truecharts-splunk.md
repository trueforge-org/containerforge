# TrueCharts splunk chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/splunk (values.yaml raw, fetched 2026-11-26).

## values.yaml facts
- Image: `docker.io/splunk/splunk`, tag `10.6.2@sha256:e26840dfe69ec9ff305c10681664900168849c3ff346a9cf49322b5351841f3f`
- `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`
- Service ports (targetPort = port): 8000 (http), 8088 (http, enabled), 8089 (http, enabled), 9997 (enabled)
- env: `SPLUNK_START_ARGS=--accept-license`; `SPLUNK_PASSWORD` from secret `env-secrets` (default placeholder "changeme" in chart values)
- Persistence: `/opt/splunk/etc/`, `/opt/splunk/var`, `/splunkdata`
