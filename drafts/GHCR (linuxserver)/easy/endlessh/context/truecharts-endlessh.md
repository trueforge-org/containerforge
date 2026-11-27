# TrueCharts endlessh (chart page)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/endlessh/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/endlessh/Chart.yaml
- Fetched 2026-11-27 (master)

## What it is
- Chart `endlessh` v15.0.0, appVersion 2021.11.21. "Endlessh is an SSH tarpit that very slowly sends an endless, random SSH banner."
- Dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. kubeVersion `>=1.33.0-0`.
- Sources: ghcr.io/linuxserver/endlessh.

## Image
- `ghcr.io/linuxserver/endlessh`, tag `2021.11.21@sha256:d1f67963c18ccfc995338c96276ec7563ff5661ddd3cd2ecd554b0c8526ea1a9`, pullPolicy IfNotPresent.

## Ports
| Service | Port name | Port | targetPort | Proto |
| --- | --- | --- | --- | --- |
| main | main | 10128 | 2222 | tcp |

## Env
- None (empty env block).

## Volumes
- `config`: enabled, mountPath `/config`.

## Probes
- liveness, readiness, startup all disabled.

## User/UID
- Container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem not set.

## Host access
- No hostNetwork or privileged settings.

## Gotchas
- Chart maps host 10128 to container 2222. Container's default port is 2222.
