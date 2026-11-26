# GitHub: mattermost/docker (repo + env.example)

Source URL(s): https://github.com/mattermost/docker ; https://raw.githubusercontent.com/mattermost/docker/master/env.example (fetched 2026-11-26)

## What it is
- "Official Docker deployment solution for Mattermost". Replaces deprecated mattermost-docker. License Apache-2.0.
- Compose-based deployment (docker-compose.yml, docker-compose.nginx.yml, docker-compose.without-nginx.yml). Install docs are external (docs.mattermost.com deploy-containers).
- Repo landing page did not expose Dockerfile or entrypoint details.

## env.example variables
| Var | Default |
| --- | --- |
| DOMAIN | mm.example.com |
| TZ | UTC |
| POSTGRES_IMAGE_TAG | 18-alpine |
| POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB | mmuser / mmuser_password / mattermost |
| MATTERMOST_IMAGE | mattermost-enterprise-edition |
| MATTERMOST_IMAGE_TAG | 11.7.0 |
| MATTERMOST_CONTAINER_READONLY | false |
| APP_PORT | 8065 |
| MM_SQLSETTINGS_DRIVERNAME | postgres |
| MM_SQLSETTINGS_DATASOURCE | postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable&connect_timeout=10 |
| MM_SERVICESETTINGS_SITEURL | https://${DOMAIN} |
| MATTERMOST_CONFIG_PATH / _DATA_PATH / _LOGS_PATH / _PLUGINS_PATH / _CLIENT_PLUGINS_PATH | ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins} |
| HTTPS_PORT / HTTP_PORT / CALLS_PORT | 443 / 80 / 8443 |

## Gotchas
- env.example pins MATTERMOST_IMAGE_TAG 11.7.0, while the chart pins release-9.6 and Hub latest is 12.x.
