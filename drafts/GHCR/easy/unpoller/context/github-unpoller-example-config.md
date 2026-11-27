# Upstream example config: unpoller/unpoller @ efb5e52 (examples/up.conf.example)

Source URL(s) + date: https://raw.githubusercontent.com/unpoller/unpoller/efb5e52aefb26f913cfc17f96d5d9c7ba4772ac2/examples/up.conf.example (fetched 2026-11-27)

## Format
- TOML. Sections: [poller], [prometheus], [influxdb], [loki], [datadog], [webserver], [unifi], [unifi.defaults], [[unifi.controller]].

## Key settings (defaults in example)
| Section.key | Example value | Notes |
| --- | --- | --- |
| poller.debug | false | |
| poller.quiet | false | |
| poller.plugins | [] | dynamic plugins |
| prometheus.disable | false | |
| prometheus.http_listen | "0.0.0.0:9130" | /metrics port |
| prometheus.interval | "60s" | env UP_PROMETHEUS_INTERVAL; 0 disables cache |
| prometheus.ssl_cert_path / ssl_key_path | "" | enables https |
| influxdb.disable | false | |
| influxdb.url | "http://127.0.0.1:8086" | |
| influxdb.db | "unifi" | |
| influxdb.interval | "30s" | |
| loki.disable | true | |
| datadog.enable | false | interval "2m" |
| unifi.defaults.url | "https://127.0.0.1:8443" | |
| unifi.defaults.user / pass | "unifipoller" | pass may be `file://` path |
| unifi.defaults.sites | ["all"] | |
| unifi.defaults.verify_ssl | false | |

- Password fields accept `file://<path>` to read from a file.
- API key auth is supported (exclusive with user/pass).

## Ports
- 9130 (Prometheus http_listen).

## Volumes/paths
- Container config path: /etc/unpoller/up.conf (from Dockerfile).

## Gotchas
- Config must be provided; example defaults point to 127.0.0.1 and placeholder creds.
- Enabling the web server with many sites increases memory use.
