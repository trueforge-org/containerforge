# danielperna84/hass-configurator (GitHub, the application)

**Source URL(s) + fetch date**
- https://github.com/danielperna84/hass-configurator (repo, draft source link)
- https://raw.githubusercontent.com/danielperna84/hass-configurator/master/README.md
- https://raw.githubusercontent.com/danielperna84/hass-configurator/master/hass_configurator/configurator.py
- Fetched 2026-11-26. Branch `master` used (no tag was pinned for these reads; `v0.7.0` corresponds to the PyPI release).

**What it is**
Small web app (file browser and text editor with Ace editor and YAML linting) for editing files on the machine it runs on, built for Home Assistant config. Upload/download, shell command execution, Git operations, SSL, standalone mode.

**Install/build steps and build deps**
Installed from PyPI (`pip install hass-configurator`). README says install methods are on the project's Wiki (not fetched). Python 3 only.

**Binaries/entrypoint/CLI flags**
- Entry point `hass-configurator` (plan.md section 1). Optional positional argument: path to a JSON settings file.
- Flags named in the README: `-s` / `--standalone` (don't fetch data from `HASS_API`; sets `HASS_API = None`). Plan.md's other flags (`--listen`, `--port`, `--basepath`, `--enforce`, `--git`) were not re-verified here.

**Env vars (table; prefix `HC_`)**

| Name | Default | Notes |
| --- | --- | --- |
| `HC_LISTENIP` | `0.0.0.0` | |
| `HC_PORT` | `3218` | `PORT` is applied after `args.port` (overrides the CLI). |
| `HC_BASEPATH` | `None` | Also sets where the prefs file goes. |
| `HC_ENFORCE_BASEPATH` | `False` | |
| `HC_HASS_API` | `http://127.0.0.1:8123/api/` | `None` means standalone. |
| `HC_LOGLEVEL` | `info` | Mapped via `LOGLEVEL_MAPPING`. |
| `HC_GIT` | `False` | |
| `HC_USERNAME` | `None` | Auth only when set. |
| `HC_PASSWORD` | `None` | Auth only when set. |
| `HC_ALLOWED_NETWORKS`, `HC_BANNED_IPS`, `HC_IGNORE_PATTERN` | unset | Comma-separated lists. |
| `HC_SSL_CERTIFICATE`, `HC_SSL_KEY` | unset | Switch the listener scheme to `https` when set. |

Merge rule (`load_settings`): the settings file is read first; then every env var with the prefix `HC_` overwrites the matching key. The prefix itself can be changed by `ENV_PREFIX` in the settings file. Values: `true`/`false` become booleans, `none`/`None`/`null` become `None`, numeric strings become `int`.

**Ports**
Listens on `HC_PORT` (3218 by default) on `HC_LISTENIP`.

**Volumes/paths and persistent data**
- Prefs file `.hass_configurator_prefs.json` in `BASEPATH` (else the current directory). Default prefs `{"ui_theme": "auto"}`.
- Edits go to whatever files are under the base path.

**User/UID & permissions**
Nothing upstream. Runs as whoever starts it.

**Config files and formats**
Optional JSON settings file (path given as the first argument). Keys match the `HC_` names without the prefix.

**Healthcheck/readiness endpoints**
None documented. Startup log line: `Listening on: <http|https>://<address>:<port>` (`LOG.info`).

**Version/release info and asset naming**
PyPI `hass-configurator` 0.7.0 (see pypi summary). Source tags were not read.

**Arch support**
Pure Python; not stated per arch.

**Gotchas**
- Auth is off unless `HC_USERNAME`/`HC_PASSWORD` (or `CREDENTIALS`) are set. The README warns that forwarding a port without authentication or IP restrictions exposes the configuration to the web.
- The UI fetches JavaScript libraries, CSS and fonts from CDNs; it does not work offline for the client (README).
- The API endpoints `/api/restart`, `/api/check_config`, `/api/reload_*` build URLs from `HASS_API` without a check; with `None` they fail inside the `try` (reported in JSON).
- README says it is "only available for Python 3".

**Contradictions with plan.md**
- plan.md section 1 says the defaults listed (LISTENIP, PORT, BASEPATH, ENFORCE_BASEPATH, HASS_API, LOGLEVEL, GIT, USERNAME, PASSWORD) match. Confirmed.
- plan.md section 1 says env vars override the settings file. Confirmed.
- plan.md section 1 says `HC_LOGLEVEL` default `info`. Confirmed.
- plan.md section 1 says standalone mode when `HASS_API` is `None`. Confirmed.
- plan.md section 1 says the prefs file is in `BASEPATH` or the current directory. Confirmed.
- plan.md section 10 says the UI loads CDN assets and does not work offline. Confirmed by README.
- plan.md section 1 lists `setup.py` dependencies `pyotp`, `gitpython`, `legacy-cgi`. setup.py was not fetched; PyPI metadata (see pypi summary) reports no `requires_dist`. Conflict left unverified.
