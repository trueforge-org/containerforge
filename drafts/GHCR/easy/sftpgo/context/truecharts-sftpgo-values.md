# TrueCharts sftpgo values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sftpgo/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/drakkan/sftpgo`
- tag: `v2.7.6-plugins@sha256:c2f59aab0e6de518e839b3a77e9aae62b290cbd3dc2f0fbdc1ee38a64c8a46e7` (plugins variant)
- pullPolicy: IfNotPresent

## Ports (port → targetPort / proto)
- main: 2221 → 8080 (http)
- ftpport: 2121 → 2121 (http)
- passiveports: 50000 → 50000 (http)
- sftpport: 2022 → 2022 (tcp)
- webdavport: 10080 → 10080 (tcp)

## Env vars (main container, selected)
- SFTPGO_COMMON__DEFENDER__ENABLED: `"true"`
- SFTPGO_FTPD__BINDINGS__0__PORT: `"2121"`, DEBUG `"0"`, FORCE_PASSIVE_IP `10.0.0.10` (example)
- SFTPGO_FTPD__PASSIVE_PORT_RANGE__START `"50000"`, __END `"50100"`
- SFTPGO_WEBDAVD__BINDINGS__0__PORT: `"10080"`
- SFTPGO_PLUGIN_AUTH_LDAP_* (URL, BASE_DN, BIND_DN, SEARCH_QUERY, GROUP_ATTRIBUTES, STARTTLS, SKIP_TLS_VERIFY, CA_CERTIFICATES, USERS_BASE_DIR `"/mnt/home"`, CACHE_TIME `0`); example values, LDAP password from secret
- SFTPGO_PLUGIN_EVENTSEARCH_DRIVER / _DSN, SFTPGO_PLUGIN_EVENTSTORE_DRIVER / _DSN / _INSTANCE_ID / _RETENTION (`"0"`)
- SFTPGO_PLUGIN_GEOIPFILTER_DB_FILE `"/mnt/database/geolite.db"`, ALLOWED_COUNTRIES `"JP"`, DENIED_COUNTRIES `"KP"`

## Volumes/paths (persistence, all enabled)
- backupdirectory → `/srv/sftpgo/backups`
- configpath → `/var/lib/sftpgo`
- data → `/srv/sftpgo/data`
- shareaccess → `/shareaccess`

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Healthcheck
- No probes defined.

## Gotchas
- Chart puts WebDAV on 10080 (not 8080).
- Secret `env-secrets` holds a plaintext example LDAP password in the file.
