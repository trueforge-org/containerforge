# TrueCharts chart: domoticz

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/domoticz (directory; content read from raw `values.yaml`) · 2026-11-26

## Values (as of fetch)
- Image: `docker.io/domoticz/domoticz` tag `2026.4@sha256:ece392300d055395cac0b4edea4451b31f765ff5339e5597ca77371be8d7e93a`, pullPolicy `IfNotPresent`. (Same version as the draft and plan.)
- Env: `WWW_PORT` templated from the service port (resolves to 10144); `EXTRA_CMD_ARG` = `-userdata /opt/domoticz/userdata`.
- Services: `main` port 10144 (no targetPort); `comm1` port 6144 (targetPort 6144), enabled.
- Persistence: `config` at `/opt/domoticz/userdata`.
- securityContext: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
- Probes: none. Args: none (command input via `EXTRA_CMD_ARG`).

## Notes vs plan.md
- Chart listens on 10144 via its service and `WWW_PORT`. plan.md uses 8080 (matching upstream image default), which is consistent with the chart's probe-less setup as long as the service mapping is changed.
- Chart's `comm1` 6144 port is not in plan.md (not listed in settings.yaml).
