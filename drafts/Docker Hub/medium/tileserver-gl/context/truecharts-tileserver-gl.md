# truecharts tileserver-gl (chart version 3.0.0, appVersion 5.7.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tileserver-gl/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tileserver-gl/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: tileserver-gl`, `appVersion: 5.7.0`, `version: 3.0.0`, `type: application`
- Description: "TileServer GL is a server for raster and vector map tiles, supporting MBTiles, PBF vector tiles and GL styles."

## Image (values.yaml)
- repository: `maptiler/tileserver-gl` (official MapTiler image)
- tag: `v5.7.0@sha256:24d0364e1d40da0ae3fb3269f617c26e36a883ad4b7454e5c4064a8795bfc807`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 8080 | 8080 | http |

## Persistence
- `data`: enabled, mountPath `/data`

## Env / probes / security
- No env set in values.yaml. No probes set. No securityContext set (chart defaults).

## Gotchas
- Chart maps container port 8080 (matches Dockerfile EXPOSE 8080 and the docs default port 8080).
- Chart mounts `/data` (matches upstream `WORKDIR /data` and `VOLUME /data`).
