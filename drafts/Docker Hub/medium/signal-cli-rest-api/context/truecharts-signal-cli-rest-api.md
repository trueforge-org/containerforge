# TrueCharts chart: signal-cli-rest-api

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/signal-cli-rest-api/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `signal-cli-rest-api`, category media. Chart version 4.0.0, appVersion 0.102.0.
- Description: dockerized Signal Messenger REST API.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`.
- Chart `sources:` list: github bbernhard/signal-cli-rest-api, truecharts chart path, hub.docker.com/r/bbernhard/signal-cli-rest-api.

## Image (values.yaml)
- repository `docker.io/bbernhard/signal-cli-rest-api`, tag `0.102@sha256:6b35b3527459aec9c459398de33f4f229239b3f17b0989d4bceb5191ad71fca9`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 8080 (no protocol set).

## Env (workload.main.podSpec.containers.main.env)
| Name | Value | Note |
| --- | --- | --- |
| MODE | normal | comment: normal, native or json-rpc; json-rpc noted as not working (start-stop-daemon pidfile error) |
| SIGNAL_CLI_UID | 568 | |
| SIGNAL_CLI_GID | 568 | |
| PORT | `{{ service.main.ports.main.port }}` (8080) | |
- Commented-out optional vars: AUTO_RECEIVE_SCHEDULE (cron), DEFAULT_SIGNAL_TEXT_MODE (normal|styled), LOG_LEVEL (debug|info|warn|error), SWAGGER_HOST, SWAGGER_IP, SWAGGER_USE_HTTPS_AS_PREFERRED_SCHEME.

## Probes
- liveness, readiness, startup: HTTP path `/v1/health`.

## Persistence
- persistence.config: enabled, mounted at `/home/.local/share/signal-cli` on container `main`.

## Security / resources
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- resources: requests cpu 25m, limits cpu 250m.

## Gotchas
- Chart runs as root with UID/GID 568 env, while upstream image defaults to user signal-api (1000).
- `json-rpc` mode noted as broken in chart comment (not verified in this run).
- Chart pins `0.102` by digest; upstream `0.102` is the latest release (see github file).
