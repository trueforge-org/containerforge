# TrueCharts chart: fleet

Source URLs (fetched 2026-11-27):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fleet/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fleet/Chart.yaml

## What it is
- Chart `fleet` v21.0.0, appVersion 2.3.3, apiVersion v2 (application).
- Description: web interface listing maintained images from one or more owned repos.
- Sources listed: ghcr.io/linuxserver/fleet, TrueCharts chart dir.
- Category `incubator`, train `stable`. kubeVersion >=1.33.0-0.
- Helm: min 3.14, max 4.1; max Kubernetes 1.35.0.

## Image
| Field | Value |
| --- | --- |
| Repository | `ghcr.io/linuxserver/fleet` |
| Tag | `2.3.3` |
| Pull policy | IfNotPresent |

## Ports
| Scope | Value |
| --- | --- |
| Container targetPort | 8080 |
| Service `main` port | 10145 |

## Env vars (chart defaults)
| Name | Value / source |
| --- | --- |
| `fleet_admin_authentication_type` | `DATABASE` |
| `fleet_database_username` | `fleet` |
| `fleet_database_url` | secretKeyRef `jdbc-mariadb` from secret `<Release.Name>-mariadbcreds` |
| `fleet_database_password` | secretKeyRef `mariadb-password` from same secret |

## Persistence
| Name | Enabled | Mount |
| --- | --- | --- |
| `config` | true | `/config` |
| `varrun` | true | chart default (not set) |

## Dependencies
- `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- MariaDB enabled: `mariadbUsername: fleet`, `mariadbDatabase: fleet`.

## Healthcheck (probes)
- liveness, readiness, startup: HTTP GET `/`, port not set (defaults to service/container port).

## User
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- The chart runs the container as root with a writable rootfs.

## Command/args
- None defined.

## Gotchas
- The DB URL and password come from the MariaDB dependency secret; the app needs a JDBC URL.
- Annotation `artifacthub.io/links` in Chart.yaml is malformed YAML (url not indented under name). Not a build issue.
