# truecharts snippet-box (chart version 13.0.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/snippet-box/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/snippet-box/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: snippet-box`, `appVersion: latest`, `version: 13.0.0`, `type: application`
- Description: "Snippet Box is a simple self-hosted app for organizing your code snippets."
- Sources: https://github.com/pawelmalak/snippet-box, chart dir, https://hub.docker.com/r/pawelmalak/snippet-box
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`
- kubeVersion `>=1.33.0-0`

## Image (values.yaml)
- repository: `docker.io/pawelmalak/snippet-box`
- tag: `latest@sha256:4aac6fe8818dbb78a60e09d1556949e28f85cff8d50bdc6356b898806ea5f4f7`
- pullPolicy: IfNotPresent

## Ports
| name | service port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 5039 | 5000 | http |

The chart maps service 5039 to container targetPort 5000.

## Persistence
- `data`: enabled, mountPath `/app/data`

## Probes
- liveness, readiness, startup: all `type: http` (no path/port set in values; chart defaults apply)

## Env / security
- No env set in values.yaml.
- securityContext: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0 (root)

## Gotchas
- Chart pins `latest` by digest, so the tag is not a version pin.
