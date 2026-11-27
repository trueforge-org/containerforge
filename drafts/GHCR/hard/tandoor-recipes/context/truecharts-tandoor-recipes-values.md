# TrueCharts tandoor-recipes values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tandoor-recipes/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/tandoorrecipes/recipes`, tag `2.7.8@sha256:93dbc69a4a6843ea8637cb0e827835687a5b4b79b652074e8eb207efedc9c5a0`, pullPolicy IfNotPresent

## Security
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Ports
- service main port 10029 (TANDOOR_PORT)

## Init
- init-mkdir (type init, imageSelector image): `/bin/sh -c "mkdir -p /run/nginx"`

## Env (container main)
| env | value |
| --- | --- |
| DB_ENGINE | django.db.backends.postgresql |
| POSTGRES_HOST | secretKeyRef `<release>-postgresqlcreds` key plainhost |
| POSTGRES_PORT | 5432 |
| POSTGRES_USER | dependencies.postgresql.depconfig.postgresqlUsername (`recipes`) |
| POSTGRES_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key postgresql-password |
| POSTGRES_DB | depconfig.postgresqlDatabase (`recipes`) |
| TANDOOR_PORT | service main port (10029) |
| ALLOWED_HOSTS | "*" |
| COMMENT_PREF_DEFAULT | 1 |
| CSRF_TRUSTED_ORIGINS | "" |
| DEBUG | 0 |
| FRACTION_PREF_DEFAULT | 0 |
| GUNICORN_MEDIA | 0 |
| SECRET_KEY | secretKeyRef `recipes-secrets` key SECRET_KEY |
| SHOPPING_MIN_AUTOSYNC_INTERVAL | 5 |

## Persistence
| name | mountPath | type |
| --- | --- | --- |
| media | /opt/recipes/mediafiles | PVC (enabled) |
| static | /opt/recipes/staticfiles | emptyDir |

## Dependencies / ingress / other
- dependencies.postgresql enabled, user/db `recipes`
- ingress main integration homepage widget type tandoor
- values `tandoor.secretKey`: placeholder "PLACEHOLDERSECRETKEYCHANGEME..." (must be changed)
