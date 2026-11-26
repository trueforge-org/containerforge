# Grafana docs: configure a Docker image
Source URL(s): https://grafana.com/docs/grafana/latest (HTML fetched, mostly nav), https://grafana.com/docs/grafana/latest/setup-grafana/configure-docker/ (fetched 2026-11-26)

- Docs: "Grafana OSS and Enterprise | Grafana documentation". Recommends grafana/grafana Docker Hub repo.
- Run: `docker run -d -p 3000:3000 --name grafana grafana/grafana` (UI on port 3000).
- Alpine variant recommended for smaller image (uses musl).
- Config via env vars: GF_<SECTION>_<KEY> (examples in docs: GF_LOG_MODE, GF_LOG_LEVEL=debug, GF_PLUGINS_PREINSTALL, GF_DEFAULT_INSTANCE_NAME).
- Plugins at build: --build-arg GF_INSTALL_PLUGINS=grafana-clock-panel,... (custom image build, packaging/docker/custom/).
- Secrets: *__FILE env suffix (e.g. GF_AWS_default_ACCESS_KEY_ID__FILE) for Docker secrets.
