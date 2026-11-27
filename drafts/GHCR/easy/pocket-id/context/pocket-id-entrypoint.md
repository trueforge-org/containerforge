# pocket-id scripts/docker/entrypoint.sh (v2.19.3)

## Source URL(s) + date
- https://raw.githubusercontent.com/pocket-id/pocket-id/v2.19.3/scripts/docker/entrypoint.sh (fetched 2026-11-27)
- API contents URL in list not fetched separately (same file)

## Behaviour (sh)
1. `cd /app`
2. If `id -u` != 0: `exec "$@"` (no user handling)
3. PUID default 1000, PGID default 1000
4. If group `pocket-id-group` missing: `addgroup -g $PGID pocket-id-group`
5. If user `pocket-id` missing: if no passwd entry for $PUID, `adduser -uD $PUID -G pocket-id-group pocket-id`; else reuses existing user name (`existing_user`, not used further)
6. `mkdir -p /app/data`; chown `${PUID}:${PGID}` any entries under /app/data not owned by them
7. `exec su-exec "$PUID:$PGID" "$@"`

## Env vars
| Name | Default | Use |
| --- | --- | --- |
| PUID | 1000 | uid to run as |
| PGID | 1000 | gid to run as |

## Gotchas
- Container must start as root for PUID/PGID switching; non-root start just execs CMD.
- Script uses alpine tools (addgroup/adduser/su-exec).
