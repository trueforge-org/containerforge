# TrueCharts node-red (chart 26.0.0, appVersion 5.0.10)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/node-red/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "Node-RED is low-code programming for event-driven applications"
- Chart sources: ghcr.io/node-red/node-red, github.com/node-red/node-red-docker, truecharts node-red tree.
- Category tools, train stable, not deprecated. Keywords: node-red, nodered.
- Kubernetes >=1.33.0-0 (max 1.35.0); Helm min 3.14, max 4.1.
- Dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | ghcr.io/node-red/node-red |
| Tag | 5.0.10 (digest pinned) |
| Pull policy | IfNotPresent |

## Ports
| Scope | Port |
| --- | --- |
| Service main | 1880 -> target 1880 |
| Container | not specified |

## Env vars
- None set in values.yaml (empty map).

## Persistence
| Name | Enabled | Mount |
| --- | --- | --- |
| data | true | /data |

## Probes / securityContext / args
- No probes defined. No securityContext (runAsUser/runAsGroup/readOnlyRootFilesystem absent). No command/args.

## Gotchas
- Chart does not set a user; image default is UID 1000 (see upstream-node-red-dockerfile.md).
- Chart image is GHCR; upstream docs reference Docker Hub nodered/node-red (see upstream-node-red-docs.md).
