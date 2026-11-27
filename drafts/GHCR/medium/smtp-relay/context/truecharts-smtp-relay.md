# TrueCharts chart: smtp-relay (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/smtp-relay/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `smtp-relay` v9.0.0, appVersion 0.7.7, category smtp, depends on `common` 32.8.5.
- Description: SMTP service for relaying emails.
- Sources: https://ghcr.io/ix-ai/smtp , https://github.com/ix-ai/smtp

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/ix-ai/smtp |
| tag | v0.7.7@sha256:4f5f64a386ef8e024b60a45f9cac171f6229dd65eaad1d772337a1db64ba7f3d |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | protocol |
| --- | --- | --- |
| main | 25 | http (chart label; SMTP is TCP) |

## Probes
- liveness, readiness, startup: all `type: tcp`.

## Container env (chart override)
| Name | Value |
| --- | --- |
| PORT | "{{ .Values.service.main.ports.main.port }}" (renders 25) |
| RELAY_NETWORKS | `join " : "` of smtprelay.networks (default 172.16.0.0/16) |
| RELAY_DOMAINS | `join " : "` of smtprelay.domains (default empty) |
| DISABLE_IPV6 | true |
| SMARTHOST_ADDRESS | smtprelay.generic.address (default "") |
| SMARTHOST_PORT | smtprelay.generic.port (default 587) |
| SMARTHOST_USER | smtprelay.generic.user (default "") |
| SMARTHOST_PASSWORD | secretKeyRef env-secrets/SMARTHOST_PASSWORD |
| SMARTHOST_ALIASES | `join " : "` of smtprelay.generic.aliases |

Secret `env-secrets` (enabled): `SMARTHOST_PASSWORD` from smtprelay.generic.pass.

## Security context (chart override)
- container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
