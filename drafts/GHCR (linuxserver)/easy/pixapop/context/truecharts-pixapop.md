# TrueCharts chart: pixapop

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pixapop/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart name `pixapop`, chart version 16.0.0, appVersion 1.2.0, train `stable`, category `media`.
- Description: "An open-source single page application to view your photos in the easiest way possible."
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.
- Sources listed in Chart.yaml: ghcr.io/linuxserver/pixapop, github.com/bierdok/pixapop, github.com/linuxserver/docker-pixapop.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/linuxserver/pixapop` |
| tag | `v1.2-ls15@sha256:605ebc091fa14b4ba82ceadda7f35c186d514e649c97913605384027c2750f4f` |
| pullPolicy | IfNotPresent |

## Ports
| Name | port (svc) | targetPort |
| --- | --- | --- |
| main | 10028 | 80 |

## Persistence
- `config` enabled, mountPath `/config`.
- `varrun` enabled (no mountPath set in values).

## Security context (chart)
- readOnlyRootFilesystem: false
- runAsNonRoot: false
- runAsUser: 0, runAsGroup: 0

## Gotchas
- Chart pins the linuxserver image as root (UID 0). Chart does not declare probes or env in values.yaml.
- No `/photos` persistence declared, although the upstream image has `VOLUME /photos`.
