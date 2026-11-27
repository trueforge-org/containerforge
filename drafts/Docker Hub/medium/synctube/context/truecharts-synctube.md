# truecharts synctube (chart version 13.0.0, appVersion latest)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/synctube/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/synctube/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: synctube`, `appVersion: latest`, `version: 13.0.0`, `type: application`
- Description: "Synchronized video viewing with chat and other features. Lightweight modern implementation and very easy way to run locally."

## Image (values.yaml)
- repository: `docker.io/littlestache/synctube`
- tag: `latest@sha256:7d1b9dbc02bbe04c0e3fdee17b729f7a115c05ccfa603fb7e75cc804dfa3a3cb`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 4200 | 4200 | http |

## Persistence
- `storageconfig`: enabled, mountPath `/usr/src/app/user`

## Env / probes
- No env set in values.yaml. No probes set.

## Security context
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Gotchas
- Chart pins `latest` by digest (the 2021 Docker Hub image, see dockerhub-synctube.md).
- Mount path `/usr/src/app/user` is the chart's path; upstream Dockerfile has `/app` and copies `user` into it (see github-synctube-dockerfile.md).
