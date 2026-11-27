# Taxel PlexTraktSync entrypoint.sh (commit 5f951838, installed as /init)

## Source URL(s) + date
- https://raw.githubusercontent.com/Taxel/PlexTraktSync/5f951838eaea4466d078571cc548ac51d5ed2341/entrypoint.sh (fetched 2026-11-27)
- Equivalent api contents URL in plan not fetched separately (same file)

## Behaviour
- `#!/bin/sh`, `set -eu`; `TRACE` enables `set -x`
- Defaults: `APP_USER=plextraktsync`, `APP_GROUP=plextraktsync`
- `needs_switch_user`: returns false when PUID and PGID both 0 (default), so the process stays root; otherwise switches only if running as root
- When switching: `setup_user` (usermod -o -u $PUID, groupmod -o -g $PGID), `fix_permissions` (install /app/config, chown -R /app/config, chown $HOME), then `switch_user` via `setpriv --euid/--ruid/--clear-groups --egid/--rgid ... exec`
- `test` as first arg: ldd on setpriv, usermod, groupmod, then runs `info`
- `pipx` as first arg: apk add git; pip install pipx; `pipx install plextraktsync` into PIPX_BIN_DIR if missing; then `sh`
- `sh` as first arg: passthrough to shell
- Otherwise prepends `python -m plextraktsync` to args and execs

## Env vars
| Name | Use |
| --- | --- |
| TRACE | set -x when non-empty |
| APP_USER / APP_GROUP | user/group names (default plextraktsync) |
| PUID / PGID | target uid/gid; 0/0 = no switch |

## Gotchas
- Setting PUID/PGID requires starting as root (the Dockerfile default has no USER, so root is the start user).
- Default command when no args: `python -m plextraktsync` with no subcommand (README uses `sync`).
