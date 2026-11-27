# truecharts myspeed (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/myspeed/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## Chart
- name myspeed, chart version 4.0.0, appVersion 1.0.9
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- kubeVersion >=1.33.0-0; max helm 4.1, min 3.14; max k8s 1.35.0
- category: system; keywords myspeed, speedtest
- sources: github gnmyt/myspeed, hub germannewsmaker/myspeed, myspeed.dev

## Image (values.yaml)
- repository: docker.io/germannewsmaker/myspeed
- tag: 1.0.9@sha256:3a3e774b3f78d930a5a962d625b99bcb3d71730bfeb4a6b93e04fd38cfe7d9a9
- pullPolicy: IfNotPresent

## Security context (chart default)
- runAsNonRoot: false, runAsUser: 0, runAsGroup: 0, readOnlyRootFilesystem: false, allowPrivilegeEscalation: true

## Ports
- service main port 5216 (container port per upstream Dockerfile EXPOSE 5216)

## Persistence
| name | mountPath |
| --- | --- |
| data | /myspeed/data |

## Metrics (chart)
- metrics.main enabled, type servicemonitor, endpoint port main, path /api/prometheus, prometheusRule disabled

## Env / probes
- no env or probes set in values.yaml
