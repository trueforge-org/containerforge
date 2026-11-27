# OpenObserve docs (openobserve.ai/docs and /docs/environment-variables/)

## Source URL(s) + date
- https://openobserve.ai/docs (fetched 2026-11-27, landing page, thin)
- https://openobserve.ai/docs/environment-variables/ (fetched 2026-11-27, main env var reference)

## What it is
- Open-source, unified observability for logs, metrics, traces; built in Rust; SQL and PromQL query.

## Ports
| Env | Default | Description |
| --- | --- | --- |
| ZO_HTTP_PORT | 5080 | HTTP listen port |
| ZO_HTTP_ADDR | (IP) | listen address |

## Env vars (selected)
| Env | Default | Description |
| --- | --- | --- |
| ZO_ROOT_USER_EMAIL | - | root user email (required) |
| ZO_ROOT_USER_PASSWORD | - | root user password (required) |
| ZO_DATA_DIR | ./data/openobserve/ | data directory |
| ZO_DATA_DB_DIR | ./data/openobserve/db/ | metadata DB dir |
| ZO_LOCAL_MODE | true | true = single node, false = cluster |
| ZO_NODE_ROLE | all | ingester, querier, router, compactor, scheduler, all |
| ZO_WEB_URL | http://localhost:5080 | UI URL used for redirects and alert links |
| ZO_BASE_URI | - | base path when hosted under a sub-path |
| ZO_TELEMETRY | true | anonymous telemetry; false disables |
| ZO_TELEMETRY_URL | https://e1.zinclabs.dev | telemetry endpoint |
| ZO_INSTANCE_NAME | hostname | node instance name (cluster) |
| ZO_CLUSTER_COORDINATOR | nats | cluster coordinator |

## Docker
- Docs show: `docker run -e ZO_ROOT_USER_EMAIL=root@example.com ...` (env-based configuration).

## Gotchas
- Default ZO_DATA_DIR is relative; set explicitly for container paths.
- ZO_WEB_URL must match the external URL for correct redirects.
