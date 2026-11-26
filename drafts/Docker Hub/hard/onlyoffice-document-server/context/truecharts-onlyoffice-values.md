# TrueCharts onlyoffice-document-server chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/onlyoffice-document-server (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/onlyoffice/documentserver`, tag 10.0.0, digest sha256:ca17889f…; IfNotPresent.
- Service port 10043 -> container 80.
- Dependencies: PostgreSQL (user and db `onlyoffice`), Valkey.
- Env: WOPI_ENABLED true; JWT_ENABLED true; DB_TYPE postgres; DB_PORT 5432; DB_NAME/DB_USER templated; REDIS_SERVER_PORT 6379; DB_HOST/DB_PWD from postgresql creds secret; REDIS_SERVER_HOST/PASS from valkey creds; JWT_SECRET from env-secrets (placeholder "randomgeneratedstring").
- Persistence: none. securityContext: uid/gid 0, runAsNonRoot false, readOnlyRootFilesystem false.
- Probes (all): HTTP path /healthcheck. Command/args: none.
