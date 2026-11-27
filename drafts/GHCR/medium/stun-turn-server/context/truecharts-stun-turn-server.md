# TrueCharts chart: stun-turn-server (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/stun-turn-server/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `stun-turn-server` v12.0.0, library `common` 32.8.5, appVersion `latest`, category Network.
- Basic STUN & TURN server, created for Nextcloud Talk.

## Image (values.yaml)
- repository: `ghcr.io/ich777/stun-turn-server`
- tag: `latest@sha256:6828444f801698ede45ed86ec19cf92dc2e783c4ec7b7386090be36881d4649f`
- pullPolicy: IfNotPresent

## Ports
| service | name | port | targetPort | proto |
| --- | --- | --- | --- | --- |
| main | main | 5349 | 5349 | tcp |
| udpports | udpports | 5349 | 5349 | udp |

## Persistence
| name | mountPath |
| --- | --- |
| config | /stun-turn |

## Env (set by chart)
| var | value |
| --- | --- |
| CA_COUNTRY | "" |
| CA_LOCALITY | "" |
| CA_ORGANIZATION | "" |
| CA_STATE_PROV | "" |
| CERT_FILE | cert.pem |
| CERT_LENGTH | "2048" |
| CERT_VALID_DAYS | "3650" |
| CIPHER_LIST | ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384 |
| CLI_PASSWORD | secret `env-secrets` key CLI_PASSWORD |
| DATA_PERM | "770" |
| DH_FILE | dhparam.pem |
| DH_LENGTH | "2048" |
| DISPLAY_SECRETS | "true" |
| EXTRA_PARAMS | "" |
| LISTENING_IP | 0.0.0.0 |
| MAX_BPS | "0" |
| PORT | service.main port (5349) |
| PRIVKEY_FILE | privkey.pem |
| REALM | "" |
| SECRET | secret `env-secrets` key SECRET |
| TOTAL_QUOTA | "100" |

Secret `env-secrets` (chart default): CLI_PASSWORD "", SECRET "".

## Security context (chart values)
- readOnlyRootFilesystem: false, runAsNonRoot: false, runAsUser 0, runAsGroup 0.

## Probes
- None set in values.
