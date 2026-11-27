# skeeto/endlessh (upstream project)

## Source URL(s) + date
- https://raw.githubusercontent.com/skeeto/endlessh/master/README.md (fetched 2026-11-27)
- https://github.com/skeeto/endlessh/blob/master/UNLICENSE: 503. Alt raw UNLICENSE used.
- https://api.github.com/repos/skeeto/endlessh/tags: 403. Alt https://github.com/skeeto/endlessh/tags used.
- Also in urls.txt, not fetched: https://github.com/skeeto/endlessh (repo root, covered by README).

## What it is
- Single-threaded C SSH tarpit. Holds clients in banner stage (before crypto), sending random banner lines very slowly. No crypto libs needed.
- License: Unlicense (public domain).

## Build (from Makefile targets)
- `make` builds `endlessh`. Targets: `endlessh`, `install`, `clean`.
- `install` -> `$(DESTDIR)$(PREFIX)/bin` (755) and man page `endlessh.1` -> `$(PREFIX)/share/man/man1` (644).
- Special builds: RHEL6 `make LDLIBS=-lrt`; Solaris variants (documented, not used here).

## Runtime flags
| Flag | Meaning | Default |
| --- | --- | --- |
| -p INT | listen port | 2222 |
| -d INT | ms between banner lines | 10000 |
| -l INT | max banner line length (3-255) | 32 |
| -m INT | max clients | 4096 |
| -f | load config file | /etc/endlessh/config |
| -4 / -6 | IPv4 or IPv6 only | |
| -v | diagnostics (repeat for more) | |
| -s | log to syslog | |

- Config file keys: Port, Delay, MaxLineLength, MaxClients, LogLevel (0/1/2), BindFamily (0/4/6). `#` comments.
- Signals: SIGTERM graceful stop; SIGHUP reloads config; SIGUSR1 prints stats.
- Logs to stdout by default.
- No `-b` flag; no pidfile/user/volume info in README.

## Version / tags (api 403, HTML alt)
- Tags: 1.1 (Jan 31 2020), 1.0 (Apr 29 2019), 0.1 (Mar 24 2019). Image pins by date tag `2021.11.21` (chart appVersion); no matching upstream tag confirmed.

## Gotchas
- Config file option order matters with `-f`.
