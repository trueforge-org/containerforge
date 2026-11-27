# TrueCharts corekeeper chart

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/corekeeper/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/corekeeper/Chart.yaml
- Fetched 2026-11-27

## What it is
- Chart `corekeeper` v11.0.0, appVersion `corekeeper`, type application.
- Description: installs SteamCMD and runs Core Keeper dedicated server.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; min helm 3.14; max helm 4.1; max k8s 1.35.0.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` |
| tag | `corekeeper@sha256:70ccef6f1423c7e0ab5754f333db822d118e5c91ccea8b352b8e488360bada08` |
| pullPolicy | IfNotPresent |

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | `"1963720"` (Steam app id, Core Keeper dedicated server) |
| GAME_PARAMS | `""` |
| PASSWRD | secretKeyRef `env-secrets/PASSWRD` |
| USERNAME | `""` |
| VALIDATE | `"false"` |
| WORLD_INDEX | `"0"` |
| WORLD_NAME | `Core Keeper Docker` |

## Persistence
| Name | Mount path |
| --- | --- |
| serverfiles | `/serverdata/serverfiles` |
| steamcmd | `/serverdata/steamcmd` |

## Ports
- `service.main.enabled: false` and port `main` disabled. No network port declared by the chart.

## Security context
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- liveness, readiness, startup all disabled.

## Secret
- `env-secrets` enabled, key `PASSWRD` empty by default.

## Gotchas
- Chart runs as root with writable rootfs (not read-only compatible as shipped).
- Image is pinned by digest, no version tag.
