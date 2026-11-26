# EdwardChamberlain/namecheap_ddns

**Source URL(s) + fetch date**
- https://github.com/EdwardChamberlain/namecheap_ddns (README via raw `main` branch)
- https://raw.githubusercontent.com/EdwardChamberlain/namecheap_ddns/main/src/main.py
- https://raw.githubusercontent.com/EdwardChamberlain/namecheap_ddns/main/src/dockerfile
- https://raw.githubusercontent.com/EdwardChamberlain/namecheap_ddns/421a554e5267e6405850f0fe302ff95600dc8539/src/main.py
- https://raw.githubusercontent.com/EdwardChamberlain/namecheap_ddns/421a554e5267e6405850f0fe302ff95600dc8539/src/config.py
- https://github.com/EdwardChamberlain/namecheap_ddns/releases
- Fetched 2026-11-26. Note: the Dockerfile was read from `main`, not the pinned commit; the pinned `main.py` and `config.py` were read at `421a554e...` (the plan's pinned SHA).

**What it is**
- A small Python 3 script that performs Namecheap dynamic DNS updates by HTTPS GET. Licensed AGPL (per plan; the README fetch did not state a license).
- Repository layout: `src/main.py`, `src/config.py`, `src/dockerfile`, `README.md`, `LICENSE`.

**Install/build steps and build deps**
- Upstream Dockerfile (`src/dockerfile`, on `main`):
  ```
  FROM python:3.11-slim
  COPY src/ /app/
  RUN pip install requests
  RUN export PYTHONUNBUFFERED=0
  CMD ["python", "-u", "/app/main.py"]
  ```
- The `RUN export` line has no effect on the final image. No `ENV`, no `USER` (upstream image runs as root). No `EXPOSE`, no `ENTRYPOINT`.
- Build deps: none beyond `requests` (pip, unpinned upstream).

**Runtime deps**
- Python 3 with `requests` (the `os`, `time`, `re`, `logging` modules are stdlib).

**Binaries/entrypoint/CLI flags**
- Entry point: `python -u /app/main.py` (upstream CMD). The script has no CLI flags; all configuration is via env vars.
- `main.py` is `if __name__ == '__main__': main()`.

**Env vars**
| Name | Required | Default | Notes |
| --- | --- | --- | --- |
| `APP_HOST` | yes | none | `;`-separated list |
| `APP_DOMAIN` | yes | none | `;`-separated list |
| `APP_PASSWORD` | yes | none | Namecheap Dynamic DNS password (not the account password); `;`-separated list |
| `APP_UPDATE_TIME` | no | `60` | seconds between update rounds; read with `os.getenv(...) or 60`, converted with `float()` |
| `APP_LOG_LEVEL` | no | `INFO` | read in `config.py` via `logging.basicConfig(level=os.getenv('APP_LOG_LEVEL') or 'INFO', ...)` |

- The three required names are also in `config.required_vars` (a set). `main()` subtracts `os.environ` keys from it to find missing vars.
- The README does not mention accepted log-level values; `basicConfig` accepts standard level names (DEBUG, INFO, WARNING, ERROR, CRITICAL).

**Behavior (from `main.py`, pinned commit)**
- `main()`: logs `Starting Script` (info). Checks missing vars; on missing, logs `Missing enviroment variable: <A, B>` (sic) and calls `exit()`.
- `get_targets()` splits `APP_HOST`, `APP_DOMAIN`, `APP_PASSWORD` on `;` and zips them by position. Unequal lengths log `Mismatched inputs. You must supply the same number of hosts, domains, and passwords.` and call `exit()`.
- Infinite `while True` loop: for each target, `update_ip` issues one request, then `time.sleep(float(os.getenv('APP_UPDATE_TIME') or 60))`. Per-target errors are caught and logged as `Error updating: {host}.{domain}: {e}`; the loop continues.
- Request: `requests.get` to `https://dynamicdns.park-your-domain.com/update?host={host}&domain={domain}&password={password}` (built as an f-string, not `params=`). `raise_for_status()` is called. The response text is searched for `<ResponseString>...</ResponseString>`; if found, its text is raised as an exception. Otherwise logs `IP for {host}.{domain} updated successfully`.
- No IP-change detection: every target is updated every interval.
- Writes no files.

**Ports**
- None. No listening socket.

**Volumes/paths and persistent data**
- None mentioned upstream. The script keeps no state.

**User/UID & permissions**
- No `USER` in the upstream Dockerfile (root by default). Nothing in the code requires root.

**Config files and formats**
- None. Configuration is env-only.

**Healthcheck/readiness endpoints**
- None.

**Version/release info and asset naming**
- The releases page states "There aren't any releases here." No tags were shown on the releases page. No release assets exist; pin by commit SHA.

**Arch support**
- Pure Python; no arch-specific binary. The README does not state arch support.

**Gotchas**
- README says it "checks the public IP every 3 seconds and sends an update when the IP changes". The code does neither: it sends every target every `APP_UPDATE_TIME` seconds (default 60). Source wins.
- README's example `APP_UPDATE_TIME='time between updates, e.g: '60''` is malformed quoting; use a plain number.
- Password is embedded in the request URL unencoded; `requests` HTTP/connection error messages normally include the URL, and `main.py` logs `{e}` at ERROR, so the password can reach logs.
- `exit()` on validation failure exits with status 0, so a restart policy will not distinguish config errors from clean exit.
- Upstream sets no `logging` format beyond `config.py`'s `%(asctime)s::%(levelname)s::%(filename)s::%(message)s`.
- Plan.md check: the Dockerfile, env var names/defaults, endpoint and the no-IP-detection finding all match the source. The plan's claim that `APP_LOG_LEVEL` is default `INFO` is confirmed (via `config.py`). No contradictions found.
