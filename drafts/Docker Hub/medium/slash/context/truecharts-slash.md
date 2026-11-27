# truecharts slash (chart version 10.0.0, appVersion 1.0.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slash/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slash/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: slash`, `appVersion: 1.0.0`, `version: 10.0.0`, `type: application`, category `bookmarks`
- Description: "A bookmarking and link shortening service that enables easy saving and sharing of links."
- Sources: https://github.com/boojack/slash, chart dir, https://hub.docker.com/r/yourselfhosted/slash
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`
- kubeVersion `>=1.33.0-0`

## Image (values.yaml)
- repository: `docker.io/yourselfhosted/slash`
- tag: `1.0.0-rc.3@sha256:c34a45a0197f1822cf7bd1796ead899efb77b7ff8b926f825ad82362fdc3d093`
- pullPolicy: IfNotPresent

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 5231 | http |

## Env
| key | value |
| --- | --- |
| SLASH_PORT | `{{ .Values.service.main.ports.main.port }}` (5231) |

## Persistence
- `config`: enabled, mountPath `/var/opt/slash`

## Probes / security
- No probes, securityContext or user set in values.yaml (chart defaults apply).

## Gotchas
- Chart pins the 1.0.0-rc.3 tag by digest (digest not compared against Docker Hub; see dockerhub-slash.md for the tag list).
- Persistence mount is `/var/opt/slash`, the upstream default data dir.
