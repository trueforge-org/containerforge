# TrueCharts: maloja (stable)

Source URL(s), fetched 2026-11-27:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/maloja/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/maloja/Chart.yaml

## What it is
- Chart `maloja`, chart version 11.0.1, appVersion `latest`, type application, not deprecated
- Description: self-hosted scrobble database for music (personal listening stats/charts); alternative to Last.fm, Libre.fm, GNU FM
- Keywords: maloja, MediaServer-Music; category MediaServer-Music; train stable
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts
- kubeVersion >=1.33.0-0; min helm 3.14, max helm 4.1; max kubernetes 1.35.0
- Sources: truecharts chart tree, hub.docker.com krateng/maloja, maloja.krateng.ch
- Artifacthub support link YAML is malformed (url key not indented under name).

## Image (values.yaml)
- Repository: `docker.io/krateng/maloja`
- Tag: `latest`
- Digest: `sha256:806df62b16d36e207ee66b037ebbad6d4910254e6735ac0224208e2c7ae18873`
- pullPolicy: IfNotPresent

## Ports (values.yaml)
| Name | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main (service main) | 42010 | tcp | 42010 |

## Env vars (values.yaml, container main)
| Name | Value |
| --- | --- |
| MALOJA_DATA_DIRECTORY | `/config` |
| MALOJA_HOST | `0.0.0.0` |

## Volumes (values.yaml)
| Name | Enabled | Mount path |
| --- | --- | --- |
| config | true | `/config` |

## Probes
- None specified.

## securityContext (container, values.yaml)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, fsGroup not specified.

## Command / args overrides
- None.

## Gotchas
- Chart sets MALOJA_DATA_DIRECTORY=/config and mounts config at /config. This matches the upstream variable name (see dockerhub-maloja.md).
- Chart pins `latest` with digest; Docker Hub `latest` currently points at 3.2.11, not 3.2.10.
