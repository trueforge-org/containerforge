# trueforge truecharts tasmobackup values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tasmobackup/values.yaml (fetched 2026-11-26)

## Image
- Repository: `docker.io/danmed/tasmobackupv1`
- Tag: `1.08.01@sha256:edd9bad4b1744f000ef43b9096740258901c8b0c6e3540d1945641bdec40b0da`
- PullPolicy: IfNotPresent

## Service
- Key `main`: port 8259 (protocol http) -> targetPort 80

## Persistence
- `data` volume enabled, mount `/var/www/html/data`

## Env (container main)
| Var | Value |
| --- | --- |
| DBNAME | data/tasmobackup |
| DBTYPE | sqlite |

## Security context
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
