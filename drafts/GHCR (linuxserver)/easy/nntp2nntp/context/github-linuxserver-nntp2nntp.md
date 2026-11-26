# linuxserver/nntp2nntp (upstream source, tag 0.3 = commit e21c735)

**Source URL(s):** https://github.com/linuxserver/nntp2nntp (repo page); https://github.com/linuxserver/nntp2nntp/releases/tag/0.3; https://raw.githubusercontent.com/linuxserver/nntp2nntp/master/LICENSE; https://raw.githubusercontent.com/linuxserver/nntp2nntp/master/setup.py; https://raw.githubusercontent.com/linuxserver/nntp2nntp/master/nntp2nntp.py
**Fetched:** 2026-11-26

## What it is
NNTP proxy: one upstream NNTP account can be shared across several clients, each with its own credentials. Supports SSL, and proxy access can be restricted with SSL client certificates. Repo describes itself as a fork of the SourceForge project nntp2nntp. Files: `LICENSE`, `README.md`, `nntp2nntp.py`, `nntppost.py`, `setup.py`. 5 stars, 26 commits, default branch `master`.

## Release
- Tag `0.3`, marked Latest, "Fork from original SourceForge repository", published 28 April (year not shown; plan.md says 2019-04-28). Tagged commit `e21c735` (per release page; plan.md says `e21c7352f9d615924f707973991a2cd42a9e9d4a`).
- Four commits on master since the tag.
- Release page says 2 assets; the names did not load. Plan.md says no release assets. Source archive is the only install artifact.
- Source archive URL pattern (not fetched, binary-like): `https://github.com/linuxserver/nntp2nntp/archive/0.3.tar.gz`.

## Install
- `setup.py` (name `nntp2nntp`, version `0.3`): `install_requires` = `Twisted`, `pyOpenSSL`. `scripts` = `nntp2nntp.py`, `nntppost.py` (installed as scripts named with `.py`).
- README gives no install or usage commands on the page.
- Upstream image adds `service_identity` and `typing` (see github-linuxserver-docker-nntp2nntp.md).

## PYTHON VERSION: PYTHON 2 ONLY (blocker)
- `setup.py` classifiers: Python 2, 2.6, 2.7 only. No `python_requires`.
- `setup.py` description keyword is misspelled `jescription` (harmless).
- `nntp2nntp.py` shebang: `#!/usr/pkg/bin/python2.6 -O`.
- Python 2-only constructs in `nntp2nntp.py`:
  - `print sha256(pwd).hexdigest()` (print statement).
  - `has_key()` dictionary checks.
  - `file(PROXY_LOGFILE, 'a')` builtin.
  - `from hashlib import sha256` style plus Python 2 `SafeConfigParser` import with a fallback to `configparser`. The fallback hints at Python 3 awareness, but the script as a whole is Python 2.
  - Mixed tabs and spaces in `connectionLost`, which Python 3 rejects.
- Conclusion: `pip install` on Python 3 (the plan's python base is 3.15) will not produce a working program. Matches plan.md section 10.

## Binaries / CLI
- `nntp2nntp.py <config_file>`: runs the proxy.
- `nntp2nntp.py pass`: prompts for a password (`getpass`) and prints its unsalted SHA-256 hex digest for the `[users]` section.
- Usage message when arg count is wrong: prints an example config to stdout, exits 1.
- Exactly one argument required (`sys.argv` length must be 2).

## Config file (parsed by the script)
- `[server]`: `host` (required), `port` (default 119), `login` (required), `password` (required), `use ssl` (default false), `max connections` (default 5). Upstream example uses `host = nntp.example.com`, `port = 563`, `use ssl = true`, `max connections = 50`.
- `[proxy]`: `use ssl` (default false), `cert file`, `cert key`, `ca verification` (default false), `ca file` (read only if verification on), `port` (default 1563), `logfile` (default `/var/log/nntp2nntp.log`), `pidfile` (default `/var/run/nntp2nntp.pid`). Upstream example: `port = 1563`, `cert file = /config/keys/certificate.pem`, `cert key = /config/keys/private-key.pem`, `logfile = /config/logs/nntp2nntp.log`, `pidfile = /config/logs/nntp2nntp.pid`.
- `[users]`: `username = <sha256 hex of password>` (via `pass` mode). Upstream example leaves values empty.
- `[connections]`: `username = <int>` per-user connection limit (optional).
- Quirk: `x and y or z` idiom means a value that evaluates false (e.g. port 0) falls back to the default.

## Ports and bind
- Proxy listens on `PROXY_PORT` (default 1563) via `reactor.listenSSL` / `listenTCP` with no interface argument: Twisted default (all interfaces). No bind-address option exists.
- Upstream server: `SERVER_HOST`/`SERVER_PORT` via `connectSSL` / `connectTCP`.
- Forks: the parent writes the child PID to the pidfile and exits. Plan's `exec` approach would avoid this in the container; check the behaviour during the run (plan.md step 7 points to `exec` on the script).

## Env vars
None read by the program. Config file only.

## Volumes / paths
- Config, certs (`/config/keys`), logs and pid (`/config/logs`): all supplied by the config file.
- Default paths in code (`/var/log`, `/var/run`) are not writable under read-only rootfs; the config must point to `/config`.

## User / permissions
Upstream linuxserver image is s6-based (root, then drops). This app runs as `apps` in the plan.

## Healthcheck
None. Readiness is the TCP port (the chart uses tcp probes).

## Arch
Pure Python; no arch-specific artifact. Blocked by Python 2 rather than architecture.

## License
WTFPL (see the LICENSE section in the repo; the WTFPL v2 text, copyright Sam Hocevar 2004, is the file's content).

## Gotchas
- Python 2 blocker: do not build the draft as Python 3. Options in plan.md section 10 (Python 3 port, fork, hold).
- `setup.py` says Python 2.6 and 2.7 only.
- No upstream release in 7 years; renovate will find nothing new.
