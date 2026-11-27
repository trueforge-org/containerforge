# TrueCharts chart: actualserver

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/actualserver/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `actualserver` v18.0.0, `appVersion: 26.11.0`, category `finance`, train `stable`.
- Description: "Actual is a super fast privacy-focused app for managing your finances."
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Sources listed by chart: `ghcr.io/actualbudget/actual`, Kippenhof/docker-templates, trueforge chart path.
- kubeVersion `>=1.33.0-0`; max k8s 1.35.0; helm min 3.14.

## Image (values.yaml)
- Repository: `ghcr.io/actualbudget/actual`
- Tag: `26.11.0@sha256:06cf186569cf58d93e12659ff1a517b65b5b0ebee7050a3991d4bd8a1d398da6`
- pullPolicy: IfNotPresent

## Security context (chart defaults)
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0` (chart runs as root).

## Ports
| Name | Service port | Protocol | Target port |
| --- | --- | --- | --- |
| main | 10293 | http | 5006 |

## Probes (all HTTP, path `/`)
- liveness, readiness, startup: `type: http`, `path: /`

## Env
- `env: {}` (none set by chart).

## Persistence
- `data`: enabled, mountPath `/data`.

## Gotchas
- Chart mounts `/data` (upstream image data dir), not `/config`.
- Chart runs as root with non-read-only rootfs; not the ContainerForge model.
