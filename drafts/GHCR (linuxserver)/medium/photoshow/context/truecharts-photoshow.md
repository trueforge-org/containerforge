# TrueCharts chart: photoshow

Source URLs (fetched 2026-11-27):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoshow/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoshow/Chart.yaml

## What it is
- Chart `photoshow` v16.0.0, appVersion `48aabb98`, apiVersion v2, not deprecated.
- Description: gallery software that needs no database.
- Sources: ghcr.io/linuxserver/photoshow, github.com/linuxserver/docker-photoshow, github.com/thibaud-rohmer/PhotoShow.
- Category `media`, train `stable`. Helm min 3.14, max 4.1; Kubernetes max 1.35.0; kubeVersion >=1.33.0-0.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | `ghcr.io/linuxserver/photoshow` |
| Tag | `version-48aabb98` |
| Digest | `sha256:999c8760561b08a640378c19dd27ac4ab5aecee4aa964c195ee01de4e8845078` |
| Pull policy | IfNotPresent |

## Ports
| Scope | Value |
| --- | --- |
| Service `main` | 10025 |
| Container targetPort | 80 |

## Env vars
- None set in values.yaml.

## Persistence
| Name | Enabled | Mount |
| --- | --- | --- |
| `config` | true | `/config` |
| `varrun` | true | not specified (chart default) |

## Healthcheck (probes)
- None defined (chart defaults).

## User
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, fsGroup unset.

## Command/args
- None defined.

## Gotchas
- Chart runs as root with writable rootfs (LSIO-style s6 image).
- Chart does not mount `/Pictures` or `/Thumbs`; only `/config` is declared.
