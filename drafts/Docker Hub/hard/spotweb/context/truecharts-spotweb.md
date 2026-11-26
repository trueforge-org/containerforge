# TrueCharts spotweb chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/spotweb (values.yaml raw, fetched 2026-11-26).

## values.yaml facts
- Image: `docker.io/jbaten/spotweb`, tag `1.5.4@sha256:2255a7483ecd4ec2ea573a3d4c7e3f8513b44cc4319d3a4f596f6c35e55399cb`
- Service port 10050 -> targetPort 80
- PostgreSQL dependency enabled; postgresqlUsername/Database `spotweb`
- `readOnlyRootFilesystem: false`; `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`
- env: SPOTWEB_SYSTEMTYPE single, SPOTWEB_FIRSTNAME demo, SPOTWEB_LASTNAME spotweb, SPOTWEB_MAIL demo@spotweb.com, SPOTWEB_RETRIEVE 15min, DB_ENGINE pdo_pgsql, DB_PORT 5432, DB_SCHEMA public, DB_DATABASE/DB_USER from postgres dependency, DB_PASSWORD from secret, SPOTWEB_USERNAME myawesomeuser, SPOTWEB_PASSWORD from env-secrets (placeholder "changeme")
