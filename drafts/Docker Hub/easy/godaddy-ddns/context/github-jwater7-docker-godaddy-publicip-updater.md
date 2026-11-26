# jwater7/docker-godaddy-publicip-updater (GitHub)

**Source URL(s) + fetch date**
- https://github.com/jwater7/docker-godaddy-publicip-updater (repo, draft source link)
- https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048d7a369d816990ad624f58baf8a4c5b480/Dockerfile
- https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048d7a369d816990ad624f58baf8a4c5b480/godaddy-publicip-updater.py
- https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/master/README.md
- https://github.com/jwater7/docker-godaddy-publicip-updater/releases/tag/releases/1.0.4
- https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/ab3b048d7a369d816990ad624f58baf8a4c5b480/LICENSE (HTTP 404)
- Fetched 2026-11-26

**What it is**
Dynamic DNS updater for GoDaddy. Gets the machine's public IP with `pif` and sets GoDaddy A records with `godaddypy`. Runs in a loop, checking every `UPDATE_INTERVAL_SEC` seconds.

**Install/build steps and build deps (Dockerfile at ab3b048)**
- `FROM python`
- `RUN pip install requests` (unpinned)
- `RUN pip install pif` (unpinned)
- `RUN pip install -I godaddypy==2.2.6` (pinned)
- `COPY godaddy-publicip-updater.py /`
- `CMD [ "python", "-u", "/godaddy-publicip-updater.py" ]`
- No ENTRYPOINT, ENV, USER, VOLUME, EXPOSE. Runs as root.

**Runtime deps**
Python 3, `requests`, `pif` 0.8.2 (PyPI), `godaddypy` 2.2.6.

**Binaries/entrypoint/CLI flags**
- Single script `godaddy-publicip-updater.py`; `-v`/`--verbose` sets DEBUG logging (default off).
- Runs `loop_forever()` at module level.

**Env vars (table)**

| Name | Default | Notes |
| --- | --- | --- |
| `GODADDY_API_KEY` | none (required) | Production key. Read via `get_config_value`, which falls back to `os.environ[key]` and raises if missing. |
| `GODADDY_API_SECRET` | none (required) | Matching secret. |
| `GODADDY_DOMAINS` | none (required) | Comma-separated domains. |
| `GODADDY_A_NAMES` | `@` | Comma-separated A record names. |
| `UPDATE_INTERVAL_SEC` | `900` | Sleep between cycles. |
| `GET_IP_WAIT_SEC` | `10` | Retry delay after failed IP lookup. |
| `UPDATER_CONFIG_FILE` | none | Path to flat JSON object keyed by the same names; env overrides file. Load errors are logged and the script continues. |

**Ports**
None.

**Volumes/paths and persistent data**
None written. The README's compose sample mounts `./config.json` to `/config.json` (optional).

**User/UID & permissions**
Runs as root (no USER).

**Config files and formats**
Optional single-level JSON object, keys = the env var names above. Example from README: `{"GODADDY_API_SECRET": "secret", "GODADDY_A_NAMES": "@,anothername"}`.

**Behaviour (script)**
- Public IP: `pif.get_public_ip()`, validated with `ipaddress.ip_address`. On exception or invalid address it logs, sleeps `GET_IP_WAIT_SEC`, retries.
- `update_godaddy_records(ip)`: for each domain and A name, `g_client.get_records(domain, name=..., record_type='A')`. No records: warns and marks failure (TODO: adding records is not implemented). Same IP: skip. Else `g_client.update_record_ip(ip, domain, name=..., record_type='A')`.
- `loop_forever()`: cache starts `False`; updates GoDaddy only when the IP changes; cycles end with `time.sleep(update_interval_sec)`; exceptions are logged and do not stop the loop.
- Logging format `%(asctime)s : %(levelname)s : %(name)s - %(message)s`, INFO.
- `urllib3.disable_warnings(InsecureRequestWarning)` (silences the unverified-HTTPS warning from `pif`).

**Healthcheck/readiness endpoints**
None.

**Version/release info and asset naming**
- Tag `releases/1.0.4` (marked latest, published 28 Apr, year not shown; body "See README"; points to commit 9bf288d, and master has one newer commit). Release shows "Assets 2" but the names did not load.
- Plan's master HEAD `ab3b048` is the commit the Dockerfile link used.

**Arch support**
Not stated. Script is pure Python.

**License**
No LICENSE file at `ab3b048` (HTTP 404). README makes no license mention.

**Gotchas**
- README: create a production key and secret in the GoDaddy developer portal (the first-time wizard creates only test keys).
- README's daemon example lacks line-continuation backslashes.
- `pif` falls back to unverified HTTPS (see the `disable_warnings` line).

**Contradictions with plan.md**
- plan.md says the Dockerfile pins godaddypy 2.2.6 and does not pin pif. Confirmed; plan.md's `pif==0.8.2` pin is the plan's choice, not upstream's.
- plan.md says env var names, defaults (`@`, 900, 10), UPDATER_CONFIG_FILE behaviour and the KeyError path match the script. Confirmed.
- plan.md says master HEAD is `ab3b048` and that the tag `releases/1.0.4` lacks `int()` on the two numeric values. The 1.0.4 script was not fetched, so the int() claim is unverified here.
- plan.md says the LICENSE returns 404 and the repo lists no license. Confirmed (404 at ab3b048; no license mention in README).
