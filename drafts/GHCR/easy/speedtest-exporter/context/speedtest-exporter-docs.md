# speedtest-exporter docs site

## Source URL(s) + date
- https://docs.miguelndecarvalho.pt/projects/speedtest-exporter
- Fetched 2026-11-27

## Run facts
- Default port `9798`; `SPEEDTEST_PORT` changes it (example 9800). Publish it too: `-p <port>:<port>`.
- `/` welcome page; `/metrics` runs a test per request, ~30 s response.
- Manual-install section shows localhost:9800 only because the example sets 9800.

## Env vars
| Name | Default | Notes |
| --- | --- | --- |
| SPEEDTEST_PORT | 9798 | listen port |
| SPEEDTEST_SERVER | auto | server id, e.g. 31309; docs discourage pinning |

- No interval or log-level variable; interval is Prometheus `scrape_interval`.

## Docker
- Images: `ghcr.io/miguelndecarvalho/speedtest-exporter` (recommended), `miguelndecarvalho/speedtest-exporter` (Docker Hub). Pinned tags example `v3.1`.
- Run: `docker run -d --name=speedtest-exporter -p 9798:9798 --restart unless-stopped ...`
- No volumes, no user settings mentioned.

## Backend
- Python; runs Ookla Speedtest CLI. Metrics: download, upload, ping, jitter.
- Manual install needs git, python3, pip3, speedtest CLI.

## Prometheus
- job `speedtest-exporter`, target `speedtest-exporter:9798`, example scrape_interval 1h, scrape_timeout 1m.

## Other
- Grafana dashboard ID 13665 and JSON in repo `Dashboard` folder.
