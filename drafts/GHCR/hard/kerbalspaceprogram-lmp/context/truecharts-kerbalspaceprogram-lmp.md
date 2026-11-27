# TrueCharts kerbalspaceprogram-lmp (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kerbalspaceprogram-lmp/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `kerbalspaceprogram-lmp` v11.0.0, appVersion `latest`
- Description: runs Luna Multiplayer for Kerbal Space Program (KSP)

## Image
- repository ghcr.io/ich777/lunamultiplayer-ksp
- tag latest (digest pinned), pullPolicy IfNotPresent

## Env vars (workload main)
| Var | Value |
| --- | --- |
| DATA_PERM | "770" |
| LMP_V | latest@sha256:f0065aa44fb1c38b7fc30d34e220138dc0a0c6477b78eb7f59015622c2052030 |

## Ports
| Service | Port | Protocol |
| --- | --- | --- |
| main | 8800 | UDP |

## Volumes/paths
- serverfiles -> /lunamultiplayer (persistent)

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Healthcheck
- liveness, readiness, startup all disabled (`enabled: false`)

## Gotchas
- LMP_V is set to an image digest string, not a version. Looks odd; verify against the upstream script.
