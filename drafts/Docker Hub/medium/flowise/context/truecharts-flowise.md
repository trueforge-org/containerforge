# TrueCharts chart: charts/stable/flowise

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flowise ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flowise/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Install: `helm install mychart oci://oci.trueforge.org/truecharts/flowise`. Not maintained by upstream.
- Chart.yaml: name `flowise`, version `12.0.0`, appVersion `3.1.4`.
- Image: `flowiseai/flowise`, tag `3.1.4@sha256:3922767afb52a5777759fd8b28a3c9eee864daea96018a791f2429eae2a76571`, pullPolicy IfNotPresent.
- Ports: service main http port 3000.
- Env: `PORT`=3000; `APIKEY_PATH` `/config/api`; `LOG_PATH` `/config/logs`; `SECRETKEY_PATH` `/config/secrets`; `BLOB_STORAGE_PATH` `/config/storage`; `DATABASE_TYPE`=postgres; `OVERRIDE_DATABASE`=true; `DATABASE_HOST` (secret `<release>-postgresqlcreds`, key plainhost); `DATABASE_PORT`=5432; `DATABASE_USER`=flowise; `DATABASE_PASSWORD` (secret, key postgresql-password); `DATABASE_NAME`=flowise; `DATABASE_SSL`=false; `EXECUTION_MODE`=main; `LOG_LEVEL`=debug; `DEBUG`=true; `FLOWISE_USERNAME`=user; `FLOWISE_PASSWORD` (secret env-secrets, value 1234); `FLOWISE_FILE_SIZE_LIMIT`=50mb; `CORS_ORIGINS`=*; `FLOWISE_SECRETKEY_OVERWRITE` (secret flowise-secrets); `LANGCHAIN_TRACING_V2`=false.
- Persistence: `/config/api`, `/config/logs`, `/config/secrets`, `/config/storage` (all enabled).
- Dependency: postgresql enabled (user/db `flowise`).
- Probes: none defined.
- Security: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- Note: chart sets `DATABASE_TYPE=postgres`; image default is sqlite (docs).
