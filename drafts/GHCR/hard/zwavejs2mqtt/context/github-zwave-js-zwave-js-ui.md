# zwave-js/zwave-js-ui (repo page + env-vars doc)

## Source URL(s) + date
- https://github.com/zwave-js/zwave-js-ui (HTML alt for api repo, fetched 2026-11-27)
- https://raw.githubusercontent.com/zwave-js/zwave-js-ui/6aba3da40be776f8ee845de144477098978d3b74/docs/guide/env-vars.md (follow-up, read via fetch tool, paraphrased)
- https://api.github.com/repos/zwave-js/zwave-js-ui: 403 (not retried; HTML page used)

## What it is
- Z-Wave Control Panel UI and MQTT gateway. NodeJS, Express, socket.io, MQTTjs, zwavejs, Vue/Vuetify.
- License MIT. Docs at zwave-js.github.io/zwave-js-ui. Docker Hub image `zwavejs/zwave-js-ui`.

## Env vars (docs/guide/env-vars.md @ 6aba3da)
| Var | Default | Note |
| --- | --- | --- |
| PORT | 8091 | HTTP port |
| HOST | empty (all interfaces) | bind address |
| STORE_DIR | `<zui dir>/store` | absolute; ContainerForge sets `/config/store` |
| BACKUPS_DIR | `<store_dir>/backups` | |
| ZWAVEJS_EXTERNAL_CONFIG | `<store_dir>/.config-db` | |
| ZWAVEJS_LOGS_DIR | store folder | |
| ZWAVE_PORT | none | forces serial port, enables Z-Wave |
| ZWAVE_EXTERNAL_SETTINGS | none | JSON overrides path |
| SSL_CERTIFICATE / SSL_KEY | self-signed in store | must be set together |
| HTTPS | none | enables HTTPS |
| DEFAULT_USERNAME / DEFAULT_PASSWORD | none | auth |
| SESSION_SECRET | built-in default | |
| BASE_PATH | `/` | |
| TZ | browser tz | |
| LOCALE | browser locale | |
| ZUI_LOG_MAXFILES | `7d` | |
| ZUI_LOG_MAXSIZE | `50m` | |
| TRUST_PROXY | none | Express trust proxy |
| TRUSTED_API_LISTEN / TRUSTED_API_ALLOWED_IPS | disabled | unauthenticated listener |

Other keys (NETWORK_KEY, KEY_S0_Legacy, KEY_S2_*, MQTT_NAME, UID_DISCOVERY_PREFIX, DISCOVERY_DISABLE_CC_CONFIGURATION, NO_LOG_COLORS, ZUI_NO_CONSOLE, DISABLE_LOG_ROTATION, FORCE_DISABLE_SSL, USE_SECURE_COOKIE) omitted; see source.

## Gotchas
- Docs fetch paraphrased by tool; PORT/STORE_DIR/HOST match the plan.
- Port 3000 is not documented here (chart targetPort 3000 is the only evidence).
- Release assets for v11.27.0 names not loaded (see release file).
