# TrueCharts aistor (incubator)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/incubator/aistor/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- MinIO AIStor, S3-compatible object storage server. Chart version 2.0.0, appVersion 2026.09.19.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0. Helm 3.14 to 4.1.
- Chart sources: docs.min.io/aistor/, quay.io/minio/aistor/minio.

## Image
- repository: quay.io/minio/aistor/minio
- tag: RELEASE.2026-09-19T17-05-25Z@sha256:107cf2014a9583c74c11e3cdbd6903d89c2244355886b89ce532f4ecae9c23f3
- pullPolicy: IfNotPresent

## Command
- command: minio ; args: server --certs-dir /etc/minio/certs

## Env vars (main container)
| Var | Value |
| --- | --- |
| MINIO_ROOT_USER | .Values.minio.rootUser (default `minio`) |
| MINIO_ROOT_PASSWORD | secretKeyRef env-secrets/MINIO_ROOT_PASSWORD (default placeholder CHANGE-ME-TO-A-LONG-PASSWORD) |
| MINIO_VOLUMES | /data |
| MINIO_CONSOLE_ADDRESS | ":9001" |
| MINIO_BROWSER_REDIRECT_URL | .Values.minio.browserRedirectUrl (default "") |
| MINIO_LICENSE | /minio.license |

## Ports
| Name | Port | Protocol | Notes |
| --- | --- | --- | --- |
| api | 9000 | http or https (ternary on minio.tls) | S3 API, probes use 9000 |
| main | 9001 | http or https | WebUI (console) |

## Probes (all on port 9000)
- startup, liveness: GET /minio/health/live
- readiness: /minio/health/ready when licence non-empty, else /minio/health/live
- scheme https when minio.tls true, else http

## Volumes / persistence
| Name | Mount | Notes |
| --- | --- | --- |
| data | /data | enabled |
| certs | /etc/minio/certs | enabled only when minio.tls is true (public.crt, private.key) |
| license | /minio.license (subPath minio.license) | secret object `license`, key minio.license |

## Secrets
- env-secrets: MINIO_ROOT_PASSWORD
- license: minio.license = .Values.minio.licence

## Values (minio.*)
- rootUser: minio
- rootPassword: CHANGE-ME-TO-A-LONG-PASSWORD
- licence: "" (SOPS-encrypt the license; without valid license AIStor starts in offline mode and blocks S3)
- tls: false
- browserRedirectUrl: "" (must point at WebUI route, not S3 API)

## Gotchas
- Offline mode blocks S3 operations without a license. Free license at https://www.min.io/pricing.
- Set browserRedirectUrl only when S3 API is ingress-exposed.
