# filestash.app configuration guide

Source URL(s): https://www.filestash.app/docs/guide/configuration.html
Date: fetched 2026-11-26

- Single config file `config.json`; default location `state/config` (i.e. `/app/data/state/config/config.json` in the image).
- /admin/storage shows `connections` and `middleware`; /admin/settings shows all other keys. Plugins can add keys.
- `connections`: list of backends, each with unique `label`.
- `middleware`: `identity_provider` (openid, saml, ldap...) and `attribute_mapping` (`related_backend` references a connection label; `params` is a JSON string keyed by backend label).
- Env: `CONFIG_JSON` (base64 of config.json) used by compiled plugin `plg_config_env` (read-only config). Generate: `CONFIG_JSON=$(cat config.json | base64 -w0)`.
- Alternative: `plg_config_s3` (config in S3 bucket, for shared replicas). Both must be compiled into the binary.
- Custom adapter: Go, override `config_state.go` implementing `LoadConfig() ([]byte, error)` and `SaveConfig(v []byte) error`.
- Not covered: default port, UID, plugin folder path, healthcheck, data dirs beyond state/config.
