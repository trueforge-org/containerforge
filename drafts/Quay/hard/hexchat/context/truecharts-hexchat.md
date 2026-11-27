# TrueCharts hexchat (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hexchat/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- HexChat IRC client (XChat-based), served via browser (noVNC-style) through binhex base image.
- Chart version 11.0.0, appVersion `latest`. Depends on common 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.
- Chart sources: github binhex/documentation, hexchat.github.io, quay.io/binhex/arch-hexchat.

## Image
- repository: quay.io/binhex/arch-hexchat
- tag: latest@sha256:c99d7cea48789657fb30de2194646e23631ee2249f59113d1cadf40689b72d34
- pullPolicy: IfNotPresent

## Ports
| Name | Chart port | Target | Proto |
| --- | --- | --- | --- |
| main | 10307 | 6080 | http |

## Env vars
| Var | Source |
| --- | --- |
| VNC_PASSWORD | secretKeyRef env-secrets/VNC_PASSWORD (empty default) |
| WEBPAGE_TITLE | HexChat |

## Persistence
| Name | Mount | Notes |
| --- | --- | --- |
| config | /config | enabled |

## Security context
- readOnlyRootFilesystem: false ; runAsUser: 0 ; runAsGroup: 0 (root in chart).

## Gotchas
- VNC_PASSWORD default empty; chart secret env-secrets with empty value.
