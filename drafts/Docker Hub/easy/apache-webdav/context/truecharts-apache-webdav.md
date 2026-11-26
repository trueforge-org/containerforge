# TrueCharts chart: apache-webdav

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/apache-webdav (listed in draft; values fetched raw)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/apache-webdav/values.yaml (fetched 2026-11-26)

**Config (values.yaml)**
- Image `docker.io/apachewebdav/apachewebdav:latest`, pinned digest starting `0d4aea1eefbc...`, pullPolicy `IfNotPresent`.
- Service `main`: port 8384 (tcp) -> targetPort 80. (plan.md does not mention 8384; draft lists 8080.)
- Persistence: `config` at `/var/lib/dav` (enabled); `data` at `/var/lib/dav/data` (enabled). No sizes.
- securityContext (container): runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false; runAsNonRoot and privileged not set.
- Env: `ANONYMOUS_METHODS` "", `AUTH_TYPE` Basic, `LOCATION` "/", `PASSWORD` from secret `env-secrets` key `PASSWORD` (value ""), `PUMASK` "0000", `REALM` "WebDAV-Login", `SERVER_NAMES` "localhost", `SSL_CERT` "", `USERNAME` "". `PUID` and `PGID` not set.
- Probes: none.
- Secret `env-secrets` enabled.

**Gotchas**
- Chart's realm default is `WebDAV-Login` (plan.md does not note this).
- Chart data volumes are `/var/lib/dav` (config) and `/var/lib/dav/data` (data), matching the upstream image layout; plan.md's `/config` and `/data` are ContainerForge remaps.
