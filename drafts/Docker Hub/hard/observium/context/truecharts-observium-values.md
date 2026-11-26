# TrueCharts observium chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/observium (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/pvrmza/docker-observium`, tag `20250519`, digest sha256:7270b080…; pullPolicy IfNotPresent.
- Ports: main service 8668 -> container 80 (http); udpport1 8514/udp -> 514 (syslog, enabled).
- Env: OBSERVIUM_ADMIN_USER "please-change"; OBSERVIUM_ADMIN_PASS from secret env-secrets; OBSERVIUM_base_url ""; OBSERVIUM_auth_mechanism mysql; OBSERVIUM_db_extension mysqli; OBSERVIUM_db_host from secret `<release>-mariadbcreds` key plainhost; OBSERVIUM_db_name observium; OBSERVIUM_db_pass from mariadbcreds key mariadb-password; OBSERVIUM_db_user observium; OBSERVIUM_cache__enable true; OBSERVIUM_cache__driver auto.
- Deps: MariaDB (user/db observium).
- Persistence: config at /config; varrun disabled.
- securityContext: runs as uid 0 / gid 0; readOnlyRootFilesystem false.
- Probes: chart defaults. Command/args: none (image entrypoint).
