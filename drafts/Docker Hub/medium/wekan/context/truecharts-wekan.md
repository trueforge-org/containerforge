# truecharts: wekan (chart 28.6.0, appVersion 13.35.0; fetched 2026-11-27)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wekan/values.yaml , .../Chart.yaml

## Image
- repository `docker.io/wekanteam/wekan`, tag `v13.35@sha256:0eb9648d50651082799dda0e132c5ed80add606ff30084a43424c78d8676d940`, pullPolicy IfNotPresent.
- Chart pins v13.35 (the draft and plan use v13.20).

## Service / ports
| Service | Port | targetPort |
| --- | --- | --- |
| main | 10192 | 8080 |

## Persistence
| Name | enabled | mountPath |
| --- | --- | --- |
| data | true | `/data` |

## Dependencies
- `mongodb` enabled, depconfig: `mongodbUsername: wekan`, `mongodbDatabase: wekan`.

## Env (set in values)
| Env | Value |
| --- | --- |
| WRITABLE_PATH | `/data` |
| ROOT_URL | `http://localhost:8080` (user-defined default) |
| MONGO_URL | secretKeyRef, name `<release>-mongodbcreds`, key `url` |

All other env vars in values are commented out (defaults only). Full list in dockerhub/Dockerfile summary.

## Security
- No securityContext set in values (chart default applies).

## Gotchas
- Chart's `ROOT_URL` default is `localhost:8080` while the external service port is 10192.
- Chart uses MongoDB as the DB by default (not FerretDB).
