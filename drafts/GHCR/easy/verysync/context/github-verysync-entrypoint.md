# Upstream entrypoint: Jonnyan404/verysync master docker-entrypoint.sh (fetched 2026-11-27)

Source URL(s) + date: https://raw.githubusercontent.com/Jonnyan404/verysync/master/docker-entrypoint.sh

## Behaviour
- Prints banner (Chinese/English), project URL.
- Requires uid 0: if `id -u` != 0 prints error and exits 1 (no --user support; use VUID).
- If `${VUID}` non-empty AND /usr/local/bin/gosu exists: `chown -R ${VUID} /data`, then `exec gosu ${VUID} /usr/bin/verysync -no-browser -home /data/.config -gui-address :${PORT}`.
- If VUID non-empty but no gosu: exec verysync as current user (root) with same flags.
- If VUID empty: exec verysync directly (root).
- Trailing `exec "$@"` is unreachable after exec.

## Runtime flags
- `-no-browser`, `-home /data/.config`, `-gui-address :${PORT}`.

## Env vars
| Env | Use |
| --- | --- |
| PORT | GUI port (default 8886 in Dockerfile) |
| VUID | UID to run as via gosu (must exist in Linux system per README) |

## Gotchas
- Test is unquoted: with empty VUID it becomes `[ != "" ]`, a malformed test (unary operator expected). Expected result: else branch, verysync runs as root. Not run-verified.
- chown -R on /data every start.
