# TrueCharts borg-server (chart 10.0.0)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/borg-server/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart `borg-server` 10.0.0, appVersion 2.8.46 (chart value; image tag 2.8.46), common 32.8.5.
- Description: a borg Backup server (SSH-accessed borg repos).
- Chart sources: ghcr.io/anotherstranger/borg-server, github AnotherStranger/docker-borg-backup.

## Image
- repository: `ghcr.io/anotherstranger/borg-server`
- tag: `2.8.46@sha256:cd91190ab3beb7e678ee372f87dfceed44fac6ade9d17f7a686c4254eb79667a`
- pullPolicy: IfNotPresent

## Security context
- readOnlyRootFilesystem: false, runAsUser 0, runAsGroup 0.
- Main container capabilities add: SYS_CHROOT, KILL.

## Ports
| Name | Protocol | Port (service) | targetPort |
| --- | --- | --- | --- |
| main | tcp | 8022 | 22 |

## Env (chart)
| Env | Value |
| --- | --- |
| BORG_UID | `{{ .Values.securityContext.container.PUID }}` (key not set in values) |
| BORG_GID | `{{ .Values.securityContext.pod.fsGroup }}` (key not set in values) |

## Persistence
| Name | mountPath |
| --- | --- |
| borg | /var/lib/docker-borg |
| backups | /home/borg/backups |
| ssh | /home/borg/.ssh |

## Gotchas
- BORG_UID/GID templates reference keys not set in values.yaml; the entrypoint only applies them when non-empty.
