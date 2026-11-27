# TrueCharts novnc (chart 16.0.0, appVersion 1.2.0)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/novnc/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "The open source VNC client" (noVNC), web-based.
- Chart sources: ghcr.io/nicholaswilde/novnc, github.com/trueforge-org/truecharts, novnc.com.
- Category media, train stable, not deprecated. Keywords: novnc, vnc, remote, desktop.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/nicholaswilde/novnc |
| Tag | version-1.2.0 (digest pinned) |
| Pull policy | IfNotPresent |

## Ports
| Scope | Port | targetPort |
| --- | --- | --- |
| service main / port main | 6080 | 6080 |

## Env vars
| Name | Default |
| --- | --- |
| REMOTE_HOST | localhost |
| REMOTE_PORT | 5900 |

## Persistence / paths
- varrun: enabled; mount path not specified in values (chart default).

## Probes / securityContext / args
- No probes defined.
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- No args/command set.

## Gotchas
- Chart runs as root; image sets no USER (see upstream-novnc-dockerfile.md).
