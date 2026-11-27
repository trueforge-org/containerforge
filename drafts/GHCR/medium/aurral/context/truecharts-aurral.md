# TrueCharts chart: aurral

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/aurral/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `aurral` v4.0.0, `appVersion: 3.1.0`, category `media`, train `stable`.
- Description: "Aurral is a self-hosted music discovery companion for Lidarr, with recommendations, playlists and download integrations."
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: `ghcr.io/lklynet/aurral`, github lklynet/aurral, GHCR package page, trueforge chart path.
- kubeVersion `>=1.33.0-0`; helm min 3.14; max k8s 1.35.0.

## Image (values.yaml)
- Repository: `ghcr.io/lklynet/aurral`
- Tag: `3.1.0@sha256:17d1f8ff2aaa3907d846c38b47eebdd44b10fbe00b2c993373a6da940ac2504f`
- pullPolicy: IfNotPresent

## Ports
| Name | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 3001 | http | 3001 |

## Probes (HTTP `/api/health`)
- liveness, readiness, startup: `path: /api/health`.

## Env
- None set by chart values.

## Persistence
| Name | Mount | Note |
| --- | --- | --- |
| config | /config | PVC |
| varcache | /var/cache | emptyDir; comment: image ships fontconfig and rootfs is read-only so fontconfig cache needs a writable mount |

## Security context
- Chart does not set securityContext in values.yaml (chart defaults apply).

## Gotchas
- Chart comment states the container runs with a read-only root filesystem and needs `/var/cache` writable (fontconfig).
- Chart tag is 3.1.0 on TrueCharts master (plan.md describes the draft as 3.0.0).
