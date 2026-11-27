# TrueCharts: gpodder (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gpodder/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart `gpodder` version 11.0.0, appVersion `latest`. Category Downloaders. gPodder podcast client (GTK).
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.
- Chart sources: ghcr.io/xthursdayx/gpodder-docker, https://gpodder.github.io/.

## Image (values.yaml)
- repository: ghcr.io/xthursdayx/gpodder-docker
- tag: `latest@sha256:76cb41a1cca8de985f42d43a4b98f7a0a9129e415399b445cf787bd375e04d61`
- pullPolicy IfNotPresent.

## Env
| Name | Source |
| --- | --- |
| PASSWORD | secretKeyRef env-secrets/PASSWORD (chart secret `env-secrets`, data PASSWORD "") |

## Ports
- service main: 3000 tcp -> target 3000. (Dockerfile also EXPOSEs 3001; not in chart.)

## Persistence
| Name | mountPath | Notes |
| --- | --- | --- |
| config | /config | enabled |
| downloadspath | /downloads | enabled |
| varrun | (none) | disabled |

## Security
- readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart runs as root; secret-based PASSWORD expected by image.
- Image is selkies (web desktop) based; port 3000 is the web UI.
