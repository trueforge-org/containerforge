# TrueCharts chart: pinry

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pinry/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pinry/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `pinry`, chart version 15.0.1, appVersion 2.1.15.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/getpinry/pinry |
| tag | 2.1.15@sha256:7914a84adeb7875479b8bd2b7aba73bb99e5662bf06637209859793039d35569 |
| pullPolicy | IfNotPresent |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 10213 | 80 |

## Env vars
| Name | Source |
| --- | --- |
| SECRET_KEY | secretKeyRef `secrets`, key `SECRET_KEY` (main and init container) |

- `pinry.secretKey` value: placeholder `PLACEHOLDERSECRETKEYXXXXXXXXXXXX` (comment: replace with random 32+ chars).

## Init container
- `1-create-key-file` (type install): `sh -c` script writes `/data/production_secret_key.txt` from SECRET_KEY, only if it does not exist.

## Volumes/paths
| Persistence | Mount |
| --- | --- |
| data | /data (targetSelectAll true) |

## User/UID
- Container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- None defined.

## Gotchas
- Chart runs as root; secret key is a placeholder that must be overridden.
- Chart targetPort 80 matches upstream nginx EXPOSE 80.
