# distribution/distribution-library-image config-example.yml (commit 775973b)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/distribution/distribution-library-image/775973b655bb4b11561db92a1cf50113148ce530/config-example.yml · 2026-11-26

## Contents (as given)
- `version: "0.1"`
- `log`: `level: debug`, `fields.service: registry`, `fields.environment: development`
- `storage`: `delete.enabled: true`, `cache.blobdescriptor: inmemory`, `filesystem.rootdirectory: /var/lib/registry`, `tag.concurrencylimit: 5`
- `http`: `addr: ":5000"`; `debug.addr: ":5001"`; `debug.prometheus.enabled: true`, `path: "/metrics"`
- `health.storagedriver`: `enabled: true`, `interval: 10s`, `threshold: 3`

## Notes vs plan.md
- plan.md's `defaults/config.yml` deliberately differs: `log.level` info, no debug server, no `delete.enabled`, no `environment` field, root `/config/data`. Matches plan's description ("reduced and with the path changed", info logging, deletes off).
