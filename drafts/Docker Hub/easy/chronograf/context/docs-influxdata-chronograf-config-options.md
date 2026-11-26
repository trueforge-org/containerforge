# docs.influxdata.com: Chronograf configuration options

Source URL(s) + fetch date:
- https://docs.influxdata.com/chronograf/v1/administration/config-options/ (fetched 2026-11-26)

## Service options
| CLI flag | Env variable | Default | Description |
|---|---|---|---|
| `--host=` | `HOST` | `0.0.0.0` | Bind IP |
| `--port=` | `PORT` | `8888` | Port for insecure connections |
| `--bolt-path=` / `-b` | `BOLT_PATH` | `./chronograf-v1.db` | BoltDB file location |
| `--canned-path=` / `-c` | `CANNED_PATH` | `/usr/share/chronograf/canned` | Non-editable prebuilt dashboards |
| `--resources-path=` | `RESOURCES_PATH` | `/usr/share/chronograf/resources` | .src, .kap, .org, .dashboard files |
| `--basepath=` / `-p` | `BASE_PATH` | (none) | URL prefix for routes |
| `--status-feed-url=` | `STATUS_FEED_URL` | `https://www.influxdata.com/feed/json` | Status page feed |
| `--log-level=` / `-l` | `LOG_LEVEL` | `info` | `debug`, `info`, `error` |
| `--reporting-disabled` / `-r` | `REPORTING_DISABLED` | (none) | Disable usage reporting |
| `--host-page-disabled` / `-H` | `HOST_PAGE_DISABLED` | (none) | Disable Hosts List page |
| `--custom-auto-refresh` | `CUSTOM_AUTO_REFRESH` | (none) | name=ms pairs, semicolon-separated |
| `--custom-link` | (none) | (none) | User menu link `name:URL`, repeatable |
| `--develop` / `-d` | (none) | (none) | Developer mode |

## TLS
| `--cert=` | `TLS_CERTIFICATE` | (none) | PEM public cert path |
| `--key=` | `TLS_PRIVATE_KEY` | (none) | Private key path |

## InfluxDB v1/v2 connection
`--influxdb-url` / `INFLUXDB_URL`; `--influxdb-username` / `INFLUXDB_USERNAME`; `--influxdb-password` / `INFLUXDB_PASSWORD`; `--influxdb-org` / `INFLUXDB_ORG`; `--influxdb-token` / `INFLUXDB_TOKEN` (no defaults).

## InfluxDB 3 connection
`INFLUXDB_V3_SUPPORT_ENABLED` (required for any InfluxDB 3 product), `INFLUXDB_TYPE`, `INFLUXDB_CLUSTER_ID`, `INFLUXDB_ACCOUNT_ID`, `INFLUXDB_MGMT_TOKEN`, `INFLUXDB_DEFAULT_DB`, `TAGS_CSV_PATH`, `INFLUXDB_V3_TIME_CONDITION` (default `time > now() - 7d`).

## Kapacitor
`KAPACITOR_URL`, `KAPACITOR_USERNAME`, `KAPACITOR_PASSWORD`.

## etcd
`ETCD_ENDPOINTS`, `ETCD_USERNAME`, `ETCD_PASSWORD`, `ETCD_DIAL_TIMEOUT` (1s), `ETCD_REQUEST_TIMEOUT` (1s), `ETCD_CERTIFICATE`, `ETCD_PRIVATE_KEY`, `ETCD_ROOT_CA`.

## Authentication
`AUTH_DURATION` (720h), `INACTIVITY_DURATION` (5m), `PUBLIC_URL`, `TOKEN_SECRET`. OAuth providers: GitHub (`GH_URL` default https://github.com, `GH_CLIENT_ID`, `GH_CLIENT_SECRET`, `GH_ORGS`), Google (`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_DOMAINS`), Auth0 (`AUTH0_*`), Heroku (`HEROKU_*`), Generic OAuth 2.0 (`GENERIC_*`, `OAUTH_NO_PKCE`).

## Precedence
Command-line options take precedence over environment variables.

## Gotchas
- The plan's `BOLT_PATH` default `/config/chronograf-v1.db` is a ContainerForge choice; the upstream docs default is `./chronograf-v1.db`, and the upstream image entrypoint defaults it to `/var/lib/chronograf/chronograf-v1.db` (see github-influxdata-influxdata-docker-chronograf.md).
- Full list is long; only the subset in plan.md section 6 is needed for settings.yaml.
