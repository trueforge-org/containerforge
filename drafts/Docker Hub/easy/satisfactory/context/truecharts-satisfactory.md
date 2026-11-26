# TrueCharts satisfactory chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/satisfactory/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `satisfactory` (charts/stable/satisfactory). One `main` workload.

## Image used by chart
`docker.io/wolveix/satisfactory-server` tag `v1.10.0@sha256:ca895e72c78a586c4b9f50774a852f53915dc7299977af5ba26978607fad9213`, pullPolicy IfNotPresent.

## Env vars set by chart
AUTOSAVENUM 5, DEBUG false, DISABLESEASONALEVENTS false, LOG false, MAXOBJECTS 2162688, MAXPLAYERS 4, MAXTICKRATE 30, ROOTLESS false, SERVERGAMEPORT from service port (7777), SERVERIP "0.0.0.0", SERVERSTREAMING true, SKIPUPDATE false, STEAMBETA false, TIMEOUT 30, VMOVERRIDE false.

## Persistence
- `config`: enabled, mountPath `/config`.
- `tmp-dumps`: emptyDir, mountPath `/tmp/dumps`.

## Service
- main: tcp 7777; mainudp: udp 7777 (port templated from main).
- No 8888 port defined in the chart values.

## Security
securityContext.container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
No probes section in values.yaml.

## Contradictions with plan.md
- Chart runs the wrapper as root (runAsUser 0), matching plan.md's "non-root: possible" expectation.
- Chart service exposes only 7777 tcp/udp; wrapper also needs 8888/tcp (messaging), which plan.md lists. Not a plan.md mistake, a gap in the chart.
- Chart uses `v1.10.0`; draft uses `v1.9.11`.
