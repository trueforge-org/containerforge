# TrueCharts chart: shapeshifter-obfuscator

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shapeshifter-obfuscator/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `shapeshifter-obfuscator`, category Security. Chart version 11.0.0, appVersion `latest`.
- Description: chartized shapeshifter-dispatcher (Operator Foundation) proxy/obfuscation tool.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`.
- Chart `sources:` list: github juchong/shapeshifter-docker, truecharts chart path, hub.docker.com/r/juchong/shapeshifter-docker.

## Image (values.yaml)
- repository `docker.io/juchong/shapeshifter-docker`, tag `latest@sha256:2063b82d7af6b43f9f175e9fc213ba2c1558278a9e12ac2e6620a3b4a5250a60`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 2222, protocol tcp, targetPort 2222.

## Persistence
- persistence.config: enabled, mountPath `/state` (not `/config`).

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| ARGS | `-transparent -server -state state -orport 127.0.0.1:3333 -transports obfs4 -bindaddr obfs4-0.0.0.0:2222 -logLevel DEBUG -enableLogging` (folded YAML scalar) |

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Gotchas
- Chart stores state in `/state` and passes `-state state` (relative path; resolves against working dir, not `/state`, unless the wrapper script changes it; run.sh not fetched).
- ORPort `127.0.0.1:3333` is internal; only 2222 is exposed.
- Chart pins `latest` by digest; upstream Docker Hub `latest` was last pushed 2022-03-03.
