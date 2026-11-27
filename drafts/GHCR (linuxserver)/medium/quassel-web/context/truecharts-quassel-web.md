# TrueCharts chart: quassel-web

Source URLs (fetched 2026-11-27):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quassel-web/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quassel-web/Chart.yaml

## What it is
- Chart `quassel-web` v15.0.0, appVersion 2021.12.16, apiVersion v2, not deprecated.
- Description: web client for Quassel.
- Sources: ghcr.io/linuxserver/quassel-web, TrueCharts chart dir.
- Category `incubator`, train `stable`. Helm min 3.14, max 4.1; Kubernetes max 1.35.0; kubeVersion >=1.33.0-0.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | `ghcr.io/linuxserver/quassel-web` |
| Tag | `2021.12.16` |
| Digest | `sha256:873f28a42f3c928d65cc1ae5259a44ef62c2626111ce36c6dec76bfc308c7602` |
| Pull policy | IfNotPresent |

## Ports
| Scope | Value |
| --- | --- |
| Service `main` (name `main`) | 64080 |
| Container targetPort | 64080 |
- Quassel core port 4242 is only an env value, not a declared port.

## Env vars
| Name | Chart default |
| --- | --- |
| `URL_BASE` | empty string |
| `QUASSEL_CORE` | `0.0.0.0` |
| `QUASSEL_PORT` | `4242` |

## Persistence
| Name | Enabled | Mount |
| --- | --- | --- |
| `config` | true | `/config` |
| `varrun` | true | not specified (chart default) |

## Healthcheck (probes)
- None defined (chart defaults).

## User
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, fsGroup unset.

## Command/args
- None; image entrypoint used.

## Gotchas
- Chart runs as root with writable rootfs (LSIO s6 image).
- Chart's `QUASSEL_CORE=0.0.0.0` is a placeholder; real core host is normally set.
- Chart does not set the https port; upstream Dockerfile EXPOSE is 64443 (see linuxserver-dockerfile.md).
