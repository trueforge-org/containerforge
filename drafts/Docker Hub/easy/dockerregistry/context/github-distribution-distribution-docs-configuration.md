# distribution docs: configuration (distribution.github.io/distribution/about/configuration/)

Source URL(s) + fetch date:
- https://distribution.github.io/distribution/about/configuration/ · 2026-11-26

## Env overrides
- `REGISTRY_` prefix, underscore per nesting level. Example: `REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/somewhere`.
- List items use index: `REGISTRY_HTTP_TLS_LETSENCRYPT_HOSTS_0=...`.
- Docs advise a base config file plus env tweaks; overriding whole sections by env is "not recommended".
- `OTEL_TRACES_EXPORTER` (`none` or collector) controls tracing; default endpoint `https://localhost:4318/v1/traces`.

## Defaults
- `storage.filesystem.rootdirectory`: examples use `/var/lib/registry`; not stated as a default.
- `storage.delete.enabled`: defaults to false. `true` allows deleting blobs and manifests by digest.
- `log.level`: `error`, `warn`, `info`, `debug`; default `info`. `log.formatter`: `text` (default), `json`, `logstash`. `accesslog.disabled` turns off access log. Top-level `loglevel` is deprecated.
- `health.storagedriver`: `enabled` required (check runs only when true); `interval` default `10s` (bare number is nanoseconds); `threshold` optional, unset means one failure is unhealthy. Results at `/debug/health` on the debug server.
- `http.debug.addr` (`HOST:PORT`, e.g. `localhost:5001`): optional debug server, exposes metrics/health/profiling; may leak sensitive info. `prometheus.path` default `/metrics`. `/debug/vars` JSON stats when debug is set.

## Notes vs plan.md
- plan.md says `storage.delete.enabled` default is false: confirmed.
- plan.md's `/config/data` root is our choice (docs give `/var/lib/registry` as example only).
