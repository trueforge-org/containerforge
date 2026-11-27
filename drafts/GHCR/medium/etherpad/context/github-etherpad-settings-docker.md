# ether/etherpad settings.json.docker (env-substituted config)

Source URL(s): https://raw.githubusercontent.com/ether/etherpad/844729c6b9e68d593da9928141e6e2daced53ec9/settings.json.docker (fetched 2026-11-27)

## What it is
JSON with `${VAR:default}` substitution, copied into the image as `settings.json` (`SETTINGS` build arg). Values must be quoted in JSON; `${VAR:undefined}` removes the key.

## Env vars (name: default)
| Env | Default | Setting |
| --- | --- | --- |
| TITLE | Etherpad | title |
| FAVICON | null | favicon |
| PUBLIC_URL | null | publicURL |
| SKIN_NAME | colibris | skinName |
| IP | 0.0.0.0 | ip |
| PORT | 9001 | port |
| TRUST_PROXY | false | trustProxy |
| SHOW_RECENT_PADS | true | showRecentPads |
| SHOW_SETTINGS_IN_ADMIN_PAGE | true | showSettingsInAdminPage |
| ENABLE_METRICS | true | enableMetrics |
| DB_TYPE | dirty | dbType |
| DB_HOST / DB_PORT / DB_NAME / DB_USER / DB_PASS | undefined | dbSettings |
| DB_CHARSET / DB_COLLECTION / DB_URL | undefined | dbSettings |
| DB_FILENAME | var/dirty.db | dbSettings.filename |
| ADMIN_PASSWORD | null | admin user password (`ep_hash_auth` can replace with `hash`) |
| USER_PASSWORD | null | user password |
| UPDATES_TIER | notify | update checker |
| UPDATES_SOURCE | github | update checker |
| UPDATES_CHANNEL | stable | update checker |
| UPDATES_CHECK_INTERVAL_HOURS | 6 | update checker |
| UPDATES_GITHUB_REPO | ether/etherpad | update checker |
| UPDATES_REQUIRE_ADMIN_FOR_STATUS | false | update checker |
| MAIL_HOST / MAIL_PORT / MAIL_SECURE / MAIL_FROM | null / 587 / false / null | mail |
| SOFFICE | (unset) | libreoffice path; set without value to enable |

## Gotchas
- Chart values use `DB_TYPE: postgres`; the image default is `dirty`.
- Docs in file: `"${PASSW}"` gives null, `"${PASSW:}"` gives empty string.
