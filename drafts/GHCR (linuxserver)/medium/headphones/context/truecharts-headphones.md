# TrueCharts chart: headphones

Source URLs (fetched 2026-11-27):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headphones/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headphones/Chart.yaml

## What it is
- Chart `headphones` v17.0.0, appVersion `a78f38c1`, apiVersion v2, not deprecated.
- Description: automated music downloader in Python (SABnzbd, NZBget, Transmission, µTorrent, Blackhole; NZB and torrent).
- Sources: ghcr.io/linuxserver/headphones, github.com/linuxserver/docker-headphones, github.com/rembo10/headphones.
- Category `media`, train `stable`. Helm min 3.14, max 4.1; Kubernetes max 1.35.0; kubeVersion >=1.33.0-0.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
| Field | Value |
| --- | --- |
| Repository | `ghcr.io/linuxserver/headphones` |
| Tag | `version-a78f38c1` |
| Digest | `sha256:393b0b1abe6fd75cf58178e24638b173eb3404e38fc836aa5730ada32caf95f9` |
| Pull policy | IfNotPresent |

## Ports
| Scope | Value |
| --- | --- |
| Service `main` | 10064 |
| Container targetPort | 8181 |

## Env vars
- None set in values.yaml.

## Persistence
| Name | Enabled | Mount |
| --- | --- | --- |
| `config` | true | `/config` |
| `varrun` | true | not specified |

## Healthcheck (probes)
- None defined in values.yaml (chart defaults).

## User
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, fsGroup unset.

## Command/args
- None defined.

## Gotchas
- Chart runs as root with writable rootfs (typical LSIO image).
