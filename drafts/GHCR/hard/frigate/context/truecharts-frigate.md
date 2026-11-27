# TrueCharts: frigate (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/frigate/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart `frigate` version 21.0.0, appVersion 0.18.3. Category nvr. "NVR With Realtime Object Detection for IP Cameras".
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; min helm 3.14; max k8s 1.35.0.

## Image (values.yaml)
- image: ghcr.io/blakeblackshear/frigate, tag `0.18.3@sha256:d1a3e0008557bb3f3314d442ecd4ba68e9b16ab7872d64612649f7a6e5156635`, pullPolicy IfNotPresent.
- tensorrtImage: ghcr.io/blakeblackshear/frigate, tag `0.18.3-tensorrt@sha256:e1576bbc...3fd9b` (optional variant).

## Config
- `frigateConfig` (values): when set, rendered to ConfigMap mounted at /config/config.yml.
- init container `init-config` (enabled only when frigateConfig empty): mkdir /config; copies /dummy-config/config.yml to /config/config.yml if missing.
- Image's own dummy config path used: /dummy-config/config.yml.

## Ports (service)
| Name | Port | Target | Proto |
| --- | --- | --- | --- |
| main (http) | 10500 | 5000 | http |
| rtmp | 1935 | 1935 | tcp |
| rtsp | 8554 | 8554 | tcp |
| webrtc-tcp | 8555 | 8555 | tcp |
| webrtc-udp | 8555 | 8555 | udp |

## Persistence
- media -> /media (enabled).
- config -> /config (targetSelector: main and init-config).

## Security
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart runs as root; no rootless/read-only support in values.
- Chart's main service maps external 10500 to container 5000 (Frigate API/UI).
