# TrueCharts chart: charts/stable/gaseous-server

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gaseous-server ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gaseous-server/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Chart.yaml: name `gaseous-server`, version `10.0.0`, appVersion `1.7.14`.
- Image: `gaseousgames/gaseousserver`, tag `v1.7.14@sha256:5e506593ff09533f23e742470da2ef37ffe4051f3559dad3b038e81444df75a6`, pullPolicy IfNotPresent.
- Env: dbhost, dbuser, dbname, dbpass (mariadb secret/values), dbport 3306, igdbclientid, igdbclientsecret (env-secrets). See build notes above.
- Ports: service main http 5198 -> targetPort 80.
- Persistence: `/root/.gaseous-server`, `/root/.gaseous-server/Logs`, `/root/.gaseous-server/Data` (all enabled).
- Dependency: mariadb enabled (user/db `gaseous`).
- Probes: none defined.
- Security: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
