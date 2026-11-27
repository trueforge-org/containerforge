# truecharts multi-scrobbler (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/multi-scrobbler/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## Chart
- name multi-scrobbler, chart version 12.0.1, appVersion `latest` (unpinned)
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- kubeVersion >=1.33.0-0; max helm 4.1, min 3.14; max k8s 1.35.0
- category: Network-Web; keywords include MediaServer-Music

## Image (values.yaml)
- repository: docker.io/foxxmd/multi-scrobbler
- tag: latest@sha256:73f8aa6cf475f841e0d21ffc191f66e74ac8e6d652c68b9dd187b65aedbb5395
- pullPolicy: IfNotPresent

## Security context (chart default)
- runAsNonRoot: false, runAsUser: 0, runAsGroup: 0, readOnlyRootFilesystem: false

## Ports
- service main port 9078, targetPort 9078

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |

## Env / probes
- no env or probes set in values.yaml
