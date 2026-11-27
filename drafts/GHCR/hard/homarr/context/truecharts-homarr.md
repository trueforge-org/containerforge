# TrueCharts: homarr (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homarr/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart `homarr` version 18.0.0, appVersion 2.14.0. Category media. "Homarr is a simple and lightweight homepage for your server..."
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.
- Chart sources: ghcr.io/homarr-labs/homarr, github.com/ajnart/homarr (legacy name), chart path.

## Image (values.yaml)
- repository: ghcr.io/homarr-labs/homarr
- tag: `v2.14.0@sha256:742940b00ed13e8649ddfd81532ad8f4140ad413ed0591f464ff6e4f7ff3c276`
- pullPolicy IfNotPresent.

## Env
| Name | Source |
| --- | --- |
| SECRET_ENCRYPTION_KEY | secretKeyRef env-secrets/SECRET_ENCRYPTION_KEY (chart default "changemeplease") |

## Ports
- service main: 10245 -> target 7575 (http default).

## Persistence
- appdata -> /appdata (enabled). varrun disabled.

## Security
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0.

## Gotchas
- Default SECRET_ENCRYPTION_KEY "changemeplease" must be replaced.
- Chart appVersion 2.14.0; the source URLs in urls.txt pin Dockerfile v2.13.1 (see github-homarr-labs-homarr.md). Version mismatch recorded, not verified as an error.
