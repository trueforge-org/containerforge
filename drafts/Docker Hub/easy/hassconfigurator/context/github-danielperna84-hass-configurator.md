# danielperna84/hass-configurator (upstream application)

Source URL(s) + fetch date:
- https://github.com/danielperna84/hass-configurator (README via https://raw.githubusercontent.com/danielperna84/hass-configurator/master/README.md, fetched 2026-11-26)
- https://raw.githubusercontent.com/danielperna84/hass-configurator/master/hass_configurator/configurator.py (fetched 2026-11-26)
- https://github.com/danielperna84/hass-configurator/releases (fetched 2026-11-26)
- Followed sub-page: https://github.com/danielperna84/hass-configurator/wiki/Configuration (fetched 2026-11-26)

## What it is
- Python 3 web-based file editor for Home Assistant configuration. Browser UI; the server is a single Python process.
- Standalone mode works without a Home Assistant instance. The README says the client needs internet access: JS libraries, CSS and fonts load from CDNs, so it does not work offline for the client.
- Optional Home Assistant panel embedding via `panel_iframe`.

## Install/build steps and build deps
- Install from PyPI: `pip install hass-configurator` (package name `hass-configurator`). Entry point `hass-configurator` (CLI).
- README does not give Docker instructions; the Wiki "Installation" page holds install methods (not followed).
- Git integration needs GitPython (`GIT: True`). Config `ALLOWED_DOMAINS` etc. need no extra deps.
- TOTP whitelisting (`SESAME_TOTP_SECRET`) requires `pyotp`.

## Runtime deps
- Python 3 (README). Optional: `gitpython` (GIT), `pyotp` (SESAME_TOTP_SECRET).
- Client side: internet access for CDN assets.

## Binaries/entrypoint/CLI flags
- `hass-configurator [settings]`: optional positional path to a JSON settings file (`nargs='?'`). Missing file logs a warning and loading continues.
- `-s` / `--standalone`: sets `HASS_API` to `None` (no Home Assistant fetch; hides the HA panel).
- Other flags per the source/README: `--listen`, `--port`, `--basepath`, `--enforce`, `--git` (plan.md lists these; the summary of configurator.py did not re-verify each flag).

## Env vars
Every environment variable starting with the prefix `HC_` (default; `ENV_PREFIX` can be set in the settings file, not via env) overrides the settings file value after the file is read. Type conversion: `true/false` (any case) become booleans, purely numeric strings become int, `none/null` become `None`; `ALLOWED_NETWORKS`, `BANNED_IPS`, `IGNORE_PATTERN` are comma-separated lists. The environment variable `HC_LOGLEVEL` is read at import time (default `info`); it is not a settings-file key.

| Key (env `HC_` + key) | Default (source) | Notes (wiki) |
| --- | --- | --- |
| LISTENIP | `0.0.0.0` | `::` covers IPv6 |
| PORT | `3218` | `0` = dynamic port |
| BASEPATH | `None` | serve files from another location |
| ENFORCE_BASEPATH | `False` | `True` locks the UI inside BASEPATH |
| SSL_CERTIFICATE / SSL_KEY | `None` | https when set |
| HASS_API | `http://127.0.0.1:8123/api/` | `None` = standalone |
| HASS_WS_API | `None` (falls back to HASS_API) | websocket URL |
| HASS_API_PASSWORD | `None` | api_password or long-lived token |
| IGNORE_SSL | `False` | disables SSL verification toward HA API |
| USERNAME / PASSWORD | `None` | basic auth only when both set; `{sha256}` hash prefix supported |
| CREDENTIALS | `None` | deprecated `user:pass` form |
| ALLOWED_NETWORKS | `[]` | comma list |
| ALLOWED_DOMAINS | `[]` | DNS-matched client IPs |
| BANNED_IPS | `[]` | comma list |
| BANLIMIT | `0` | disabled |
| GIT | `False` | needs GitPython; remotes added manually |
| IGNORE_PATTERN | `[]` | hidden files in UI |
| DIRSFIRST / HIDEHIDDEN | `False` | UI listing |
| SESAME | `None` | secret path that whitelists the caller |
| SESAME_TOTP_SECRET | `None` | needs pyotp |
| VERIFY_HOSTNAME | `None` | 403 on hostname mismatch |
| ENV_PREFIX | `HC_` | settings file only |
| NOTIFY_SERVICE | `persistent_notification.create` | `False` disables |
| LOGLEVEL | `info` | env `HC_LOGLEVEL`, read at import |

## Ports
- `3218` (code default `PORT = 3218`, `LISTENIP = "0.0.0.0"`). Log line at startup: `Listening on: http(s)://<addr>:<port>`.

## Volumes/paths and persistent data
- Settings file: optional JSON at the path passed as argument (upstream Docker convention: `/config/settings.conf`, see causticlab summary).
- Writes: `.hass_configurator_prefs.json` (content `{"ui_theme": "auto"}`) into `BASEPATH` if set, else the current directory. The editor writes whatever files the user edits under BASEPATH. Git may write under `$HOME` (`~/.gitconfig`, `~/.ssh` for git remotes).
- No install-time data paths in the package.

## User/UID & permissions
- None set by upstream; no privilege needed. Runs as whatever user starts it.

## Config files and formats
- JSON settings file (`settings.conf`). Keys as in the table above. `None` becomes `null` in JSON.
- Settings file keys can be overridden by env (see above).

## Healthcheck/readiness endpoints
- No health endpoint documented. Readiness: the log line `Listening on: ...`, then HTTP `/` on the port.

## Version/release info and asset naming
- Latest: `0.7.0` (marked Latest on the releases page; PyPI upload 2026-10-18; commit `dbc81a2`).
- Recent releases: 0.6.0 (07 Apr), 0.5.2 (08 Nov), 0.5.1 (08 Sep), 0.5.0 (19 Aug), 0.4.1 (23 Apr), 0.4.0 (24 Feb), 0.3.9, 0.3.8, 0.3.7 (years not shown on the releases page).
- Release assets: the page shows "Assets 2" per release, which is the automatic GitHub source archives (zip and tar.gz). No uploaded binary assets are visible. Use the PyPI sdist for the artifact (see the pypi summary).
- Source tarball pattern on GitHub: `https://github.com/danielperna84/hass-configurator/tarball/<version>` (from PyPI project_urls). Not used; it is a direct archive download.

## Arch support
- Pure Python; no arch-specific code in the sources read. amd64 and arm64 are the same.

## Gotchas
- Unauthenticated by default. The README warns that a forwarded port without authentication or IP blocking exposes the configuration to the web.
- Auth active only when both `USERNAME` and `PASSWORD` are set.
- `ALLOWED_NETWORKS` in standalone/container use needs care: the hass.io addon range is `172.30.0.0/16`.
- `HASS_API` default points at `127.0.0.1:8123`, which is the wrong container; set `None` for standalone.
- `LISTENPORT` is deprecated (use `PORT`).
- Plan.md agreement: `HC_*` overrides the settings file, `HC_ENFORCE_BASEPATH` default `False` upstream, port 3218, listen `0.0.0.0`, `HC_LOGLEVEL` default `info`, and the prefs file location all match the source. No contradiction found.
- Unverified: `legacy-cgi` in plan.md's setup.py claim could not be confirmed from the fetched sources (the PyPI JSON lists no `requires_dist` for 0.7.0). See the pypi summary.
