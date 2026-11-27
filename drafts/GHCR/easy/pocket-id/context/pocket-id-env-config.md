# pocket-id backend env config (backend/internal/common/env_config.go, v2.19.3)

## Source URL(s) + date
- https://raw.githubusercontent.com/pocket-id/pocket-id/v2.19.3/backend/internal/common/env_config.go (fetched 2026-11-27)
- API contents URL in list not fetched separately (same file)

## Defaults (defaultConfig)
| Env | Default |
| --- | --- |
| APP_ENV | production |
| LOG_LEVEL | info |
| DB_PROVIDER (no env tag shown) | sqlite |
| FILE_BACKEND | filesystem |
| AUDIT_LOG_RETENTION_DAYS | 90 |
| ALLOW_INSECURE_CALLBACK_URLS | true |
| APP_URL | AppUrl constant |
| PORT | 1411 |
| HOST | 0.0.0.0 |
| ACTORS_PORT | 1414 |
| ACTORS_HOST | 0.0.0.0 |
| EXPERIMENTAL_FRANCIS_HOST | embedded |
| GEOLITE_DB_PATH | data/GeoLite2-City.mmdb |
| GEOLITE_DB_URL | MaxMindGeoLiteCityUrl constant |
| ICON_LIBRARY_URL | DefaultIconLibraryURL constant |
| OUTBOUND_ALLOWED_HOSTS_SCIM / _BACKCHANNEL_LOGOUT / _FEDERATED_JWKS | private,loopback |
| DB_CONNECTION_STRING | default `data/pocket-id.db` (sqlite) |
| UPLOAD_PATH | default `data/uploads` (fs backend) |

## Env var names (struct tags)
- Core: APP_ENV, APP_URL, ENCRYPTION_KEY (file option), DB_CONNECTION_STRING (file option), TRUST_PROXY, PROXY_PROTOCOL, TRUSTED_PLATFORM, AUDIT_LOG_RETENTION_DAYS, ANALYTICS_DISABLED, ALLOW_DOWNGRADE, ALLOW_INSECURE_CALLBACK_URLS, INTERNAL_APP_URL, UI_CONFIG_DISABLED, DISABLE_RATE_LIMITING, VERSION_CHECK_DISABLED, STATIC_API_KEY (file option)
- Files/S3: FILE_BACKEND, UPLOAD_PATH, S3_BUCKET, S3_REGION, S3_ENDPOINT, S3_ACCESS_KEY_ID, S3_SECRET_ACCESS_KEY (file), S3_FORCE_PATH_STYLE, S3_DISABLE_DEFAULT_INTEGRITY_CHECKS
- Listen: PORT, HOST, UNIX_SOCKET, UNIX_SOCKET_MODE, SYSTEMD_SOCKET, LOCAL_IPV6_RANGES
- Outbound: OUTBOUND_ALLOWED_HOSTS_CLIENT_LOGO, _CLIENT_METADATA, _SCIM, _BACKCHANNEL_LOGOUT, _FEDERATED_JWKS, _LDAP_PICTURE
- TLS: TLS_CERT, TLS_KEY, TLS_CERT_FILE, TLS_KEY_FILE
- GeoIP: MAXMIND_LICENSE_KEY (file option), GEOLITE_DB_PATH, GEOLITE_DB_URL, CLOUDFLARE_LOCATION_HEADERS
- Misc: ICON_LIBRARY_URL, ACTORS_PORT, ACTORS_HOST, EXPERIMENTAL_FRANCIS_HOST, EXPERIMENTAL_FRANCIS_HOST_PSK (file), EXPERIMENTAL_FRANCIS_HOST_JWT_FILE, EXPERIMENTAL_FRANCIS_CA (file), LOG_LEVEL, LOG_JSON, LOG_QUERY_ARGS, DISMISS_SQLITE_STORAGE_WARNING

## Gotchas
- "file" option: value read from a file path given in the env var.
- ENCRYPTION_KEY and DB_CONNECTION_STRING support file-based secrets.
