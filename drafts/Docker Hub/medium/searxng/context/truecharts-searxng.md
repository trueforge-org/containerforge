# TrueCharts chart: searxng

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/searxng/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `searxng`, train stable. Chart version 13.0.1, appVersion `latest`.
- Description: metasearch engine aggregating 70+ search services.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. No other dependencies listed.
- kubeVersion `>=1.33.0-0`.
- Chart `sources:` list: github searxng/searxng, truecharts chart path, hub.docker.com/r/searxng/searxng.

## Image (values.yaml)
- repository `docker.io/searxng/searxng`, tag `latest@sha256:462d8dbeadd7c7c304be08d47084f5caba70f47a9145a01fd25990a7944e61b7`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 8080, protocol http.

## Env (workload.main.podSpec.containers.main.env)
| Name | Value | Note |
| --- | --- | --- |
| BIND_ADDRESS | `0.0.0.0:<port>` (templated) | chart-side name; not an upstream image var (upstream uses GRANIAN_HOST/GRANIAN_PORT, see github file) |
| INSTANCE_NAME | SearXng | chart-side |
| BASE_URL | "" | chart-side |

## Probes
- liveness and readiness: HTTP path `/healthz` on the main port.
- startup: TCP on the main port.

## Persistence
- persistence.config: enabled, mountPath `/etc/searxng` (settings.yml lives here).

## Security
- securityContext.container: runAsUser 0, runAsGroup 0; capabilities.disableS6Caps true; capabilities.add SETUID, SETGID.

## Gotchas
- Chart runs as root with s6 caps disabled, adding only SETUID/SETGID. Upstream image runs as uid/gid 977 (searxng), with its entrypoint chowning volumes when root.
- Chart's env names (BIND_ADDRESS/INSTANCE_NAME/BASE_URL) are not the upstream env names.
