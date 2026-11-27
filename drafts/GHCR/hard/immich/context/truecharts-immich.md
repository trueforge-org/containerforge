# TrueCharts immich (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/immich/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `immich` v36.0.0, appVersion 3.4.2, description "High performance self-hosted photo and video backup solution."
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Sources listed: ghcr.io/immich-app/immich-machine-learning, ghcr.io/immich-app/immich-server, github.com/immich-app/immich
- kubeVersion >=1.33.0-0

## Images (values.yaml)
| Key | Repository | Tag |
| --- | --- | --- |
| image | ghcr.io/immich-app/immich-server | v3.4.2 (digest pinned) |
| mlImage | ghcr.io/immich-app/immich-machine-learning | v3.4.2 |
| mlCudaImage | same ML repo | v3.4.2-cuda |
| mlOpenvinoImage | same ML repo | v3.4.1-openvino (differs from 3.4.2) |
| mlRocmImage | same ML repo | v3.4.2-rocm |

## Runtime deps
- PostgreSQL (`dependencies.postgresql`, DB_HOSTNAME/DB_PORT 5432)
- Valkey (`dependencies.valkey`, REDIS_HOSTNAME, REDIS_PORT 6379, REDIS_DBINDEX 0)
- ML service reachable at `http://<fullname>-machinelearning:10003`

## Workloads
| Workload | Image | Notes |
| --- | --- | --- |
| main | image (server) | IMMICH_WORKERS_INCLUDE=api |
| machinelearning | mlImage/variant | enabled by immich.enable_ml (true); wait-server init (ubuntuImage) |
| microservices | image (server) | IMMICH_WORKERS_EXCLUDE=api; probe exec `immich-healthcheck` |

## Env vars (main, microservices, ML)
| Var | Value |
| --- | --- |
| IMMICH_PORT | main 10323 / microservices 10004 / ML 10003 |
| NODE_ENV | production |
| IMMICH_MACHINE_LEARNING_ENABLED | `{{ immich.enable_ml }}` |
| IMMICH_MACHINE_LEARNING_URL | http://<fullname>-machinelearning:10003 or `false` |
| DB_USERNAME / DB_DATABASE_NAME / DB_HOSTNAME | from postgresql depconfig |
| DB_PASSWORD | secret `<release>-postgresqlcreds` key postgresql-password |
| REDIS_PASSWORD | secret `<release>-valkeycreds` key valkey-password |
| REVERSE_GEOCODING_DUMP_DIRECTORY | /microcache (microservices) |
| MACHINE_LEARNING_CACHE_FOLDER, TRANSFORMERS_CACHE | /mlcache (ML) |

## Ports
| Service | Port | Protocol |
| --- | --- | --- |
| main | 10323 | http |
| microservices | 10004 | http (ClusterIP) |
| machinelearning | 10003 | http (ClusterIP) |

## Probes
- main: http `/api/server/ping` on 10323 (readiness, liveness, startup)
- ML: http `/ping` on 10003 (all three)
- microservices: exec `immich-healthcheck` (all three)

## Volumes/paths
| Name | Type | Mount |
| --- | --- | --- |
| library | persistent | /usr/src/app/upload/library (main, microservices) |
| uploads | persistent | /usr/src/app/upload/upload |
| mlcache | emptyDir | /mlcache (ML) |
| microcache | emptyDir | /microcache (microservices) |

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
- capabilities.disableS6Caps: true on all containers

## Gotchas
- Chart runs the image as root (UID 0), not rootless.
- openvino ML tag (v3.4.1-openvino) is one minor patch behind appVersion 3.4.2.
- ML and microservices depend on the server image tag v3.4.2 with digest pins.
