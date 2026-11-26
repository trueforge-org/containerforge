# pdreker.github.io/fritz_exporter (docs)

**Source URL(s) + fetch date**
- https://pdreker.github.io/fritz_exporter/ (redirects to `latest/`)
- https://pdreker.github.io/fritz_exporter/latest/ (returned the docs home page; subpages Quickstart, Configuration, Running, Docker images not fetched)
- Fetched 2026-11-26

**Facts from the landing page**
- Prometheus exporter for AVM FRITZ! devices, via the TR-064 API (`fritzconnection`). Multi-device support. Tested on Fritz!Box 7590, 5690, 5530 Fiber, 6660 Cable (FRITZ!OS 8.25), Fritz!Repeater 2400, Fritz!WLAN Repeater 1750E.
- Prometheus is separate; Grafana reads Prometheus, not the exporter. A third-party `vegasbrianc/prometheus` stack is referenced.
- Helm chart under `docs/helm` (also creates a ServiceMonitor).
- Passwords: Fritz!OS caps at 32 characters; longer gives a 401 from the exporter.
- `host_info: true` and `wifi_client_info: true` options (host info slow; scrape timeout 30 s suggested).
- Self-monitoring metrics: `fritz_device_reachable`, `fritz_scrapes_total`, `fritz_scrapes_timeouts_total`, `fritz_scrapes_failed_total`, `fritz_read_problem`. Standard `process_*`, `python_gc_*`, `python_info`.
- License Apache 2.0.
- Install commands, config example, env var defaults, port and endpoint path: on the subpages, not fetched.
