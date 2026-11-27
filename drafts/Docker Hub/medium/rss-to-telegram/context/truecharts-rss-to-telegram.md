# TrueCharts chart: rss-to-telegram

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rss-to-telegram/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `rss-to-telegram`, train stable, category Network-Other. Chart version 11.0.0, appVersion `latest`.
- Description: self-hosted Telegram bot that posts RSS feed items to a chat.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. No `dependencies` on valkey/redis in this chart.
- kubeVersion `>=1.33.0-0`; max helm 4.1, min helm 3.14; max k8s 1.35.0.
- Chart `sources:` list: github BoKKeR/RSS-to-Telegram-Bot, truecharts chart path, hub.docker.com/r/bokker/rss.to.telegram.

## Image (values.yaml)
- repository `docker.io/bokker/rss.to.telegram`, tag `latest@sha256:d04ece77a383f41b8207a4c30959164b6bc17b13bd35e315964e56753c62c837`, pullPolicy IfNotPresent.

## Persistence
- persistence.config: enabled, mountPath `/config`.

## Service / ports
- service.main.enabled false, ports.main.enabled false (no ports).

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| CHATID | "" (empty default) |
| DELAY | "60" |
| TOKEN | secret ref env-secrets/TOKEN |

## Probes
- liveness, readiness, startup all disabled.

## Secrets
- secret.env-secrets enabled, data TOKEN: ''.

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (chart runs as root).

## Gotchas
- Chart does not wire Redis; upstream README/.env.example requires Redis (see github-rss-to-telegram.md). Chart sets no REDIS_* env.
- Image pinned by digest with tag `latest`; Docker Hub `latest` last pushed 2024-02-15.
