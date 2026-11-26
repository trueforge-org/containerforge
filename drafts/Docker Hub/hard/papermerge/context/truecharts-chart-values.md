# TrueCharts papermerge chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/papermerge/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/papermerge (not fetched)

- Image: docker.io/papermerge/papermerge:3.5.3, sha256 pinned, pullPolicy IfNotPresent
- Service main: port 12000 -> targetPort 80
- Admin user "admin"; password from secret env-secrets (default "admin"); PAPERMERGE__AUTH__PASSWORD in env-secrets
- Secret key: secret papermerge-secrets; placeholder 32 chars, must change (>=32 random)
- DB URL from <release>-postgresqlcreds key url; Redis URL from <release>-valkeycreds key url
- Persistence: config -> /core_app/index_db; media -> /core_app/media; varrun disabled
- Probes: none defined
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
- Deps: Valkey enabled; PostgreSQL enabled (user/db papermerge)
- Schema: values.schema.json referenced
