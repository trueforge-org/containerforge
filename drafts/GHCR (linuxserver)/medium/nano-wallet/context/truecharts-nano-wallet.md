# TrueCharts chart: nano-wallet

Source URLs (fetched 2026-11-27):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nano-wallet/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nano-wallet/Chart.yaml

## What it is
- Chart `nano-wallet` v15.0.0, appVersion 2021.12.16, apiVersion v2, not deprecated.
- Description: lightweight, accessible digital payment protocol wallet (Nano).
- Sources: ghcr.io/linuxserver/nano-wallet, TrueCharts chart dir.
- Category `incubator`, train `stable`. Helm min 3.14, max 4.1; Kubernetes max 1.35.0; kubeVersion >=1.33.0-0.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | `ghcr.io/linuxserver/nano-wallet` |
| Tag | `2021.12.16` |
| Digest | `sha256:fdac02e669290b9cec33f2610ba9c8159ebfc59c9996222231b0deed26e701ee` |
| Pull policy | IfNotPresent |

## Ports
| Scope | Value |
| --- | --- |
| Container targetPort | 80 |
| Service `main` | 10126 |
| Protocol | not set (TCP default) |

## Env vars
- None set in values.yaml.

## Persistence
| Name | Enabled | Mount |
| --- | --- | --- |
| `varrun` | true | not specified (chart default, probably `/var/run` emptyDir) |
- No config or data volume declared.

## Healthcheck (probes)
- None defined (chart defaults). Only port hint: container 80.

## User
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, fsGroup unset.

## Command/args
- None; image default entrypoint used.

## Gotchas
- Chart runs as root with writable rootfs (LSIO-style image).
