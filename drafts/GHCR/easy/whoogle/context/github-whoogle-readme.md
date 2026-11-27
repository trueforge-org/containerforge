# Upstream README: benbusby/whoogle-search (master, env vars and run options)

Source URL(s) + date: https://raw.githubusercontent.com/benbusby/whoogle-search/master/README.md (fetched 2026-11-27)

## What it is
- Self-hosted, ad-free, privacy-respecting metasearch engine. Tor and HTTP/SOCKS proxy support. Light/dark/system themes and custom CSS.

## Run
- `docker run --publish 5000:5000 --detach --name whoogle-search benbusby/whoogle-search:latest`
- CLI: `whoogle-search [--port <n>] [--host <ip>] [--debug] [--https-only] [--userpass <u:p>] [--proxyauth] [--proxytype <socks4|socks5|http>] [--proxyloc <loc:port>]` (default port 5000).
- Local runs: set WHOOGLE_DOTENV=1 and use whoogle.env.

## Env vars (core, from README table)
| Env | Description |
| --- | --- |
| WHOOGLE_URL_PREFIX | URL prefix (e.g. /whoogle) |
| WHOOGLE_DOTENV / WHOOGLE_DOTENV_PATH | load whoogle.env |
| WHOOGLE_USER / WHOOGLE_PASS | basic auth (both required) |
| WHOOGLE_PROXY_USER / _PASS / _TYPE / _LOC | proxy (type: socks5, socks4, http) |
| EXPOSE_PORT | exposed port (default 5000) |
| HTTPS_ONLY | enforce HTTPS |
| WHOOGLE_ALT_TW/YT/RD/TL/MD/IMG/WIKI/IMDB/QUORA/SO | alternative frontends; "" disables |
| WHOOGLE_AUTOCOMPLETE | '0' disables suggestions (default on) |
| WHOOGLE_MINIMAL | minimal result cards |
| WHOOGLE_CSP | default CSP headers |
| WHOOGLE_TOR_SERVICE | '0' disables Tor on startup (default on) |
| WHOOGLE_TOR_USE_PASS / WHOOGLE_TOR_CONF | tor control password (default conf ./misc/tor/control.conf) |
| WHOOGLE_SHOW_FAVICONS | default on |
| WHOOGLE_UPDATE_CHECK | daily update check, default on |
| WHOOGLE_FALLBACK_ENGINE_URL | fallback search URL on error/rate limit |
| WHOOGLE_BUNDLE_STATIC | serve bundled CSS/JS (default off) |
| WHOOGLE_HTTP2 | upstream HTTP/2 (default on) |
| WHOOGLE_UA_* / WHOOGLE_USE_CLIENT_USER_AGENT / WHOOGLE_REDIRECTS | user-agent cache and redirects |

## WHOOGLE_CONFIG_* (defaults set in user config; README table)
- Named: WHOOGLE_CONFIG_DISABLE, _COUNTRY, _LANGUAGE, _SEARCH_LANGUAGE, _BLOCK, _BLOCK_TITLE, _BLOCK_URL, _THEME (light|dark|system), _SAFE, _ALTS, _NEAR, _TOR, _NEW_TAB, _VIEW_IMAGE, _GET_ONLY, _URL (root URL), _STYLE (single-line CSS), _PREFERENCES_ENCRYPTED, _PREFERENCES_KEY, _ANON_VIEW, _SHOW_USER_AGENT.

## Tor
- Tor config referenced via WHOOGLE_CONFIG_TOR=1 and WHOOGLE_TOR_USE_PASS=1 for control password.

## Gotchas
- Dropped ARMv7 in v1.2.0 (Alpine security libs).
- Wiki (github.com/benbusby/whoogle-search/wiki) exists (raw Home.md returned 200) but was not summarized (budget).
