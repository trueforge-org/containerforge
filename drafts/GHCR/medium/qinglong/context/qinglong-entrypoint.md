# Upstream entrypoint: whyour/qinglong (docker/docker-entrypoint.sh)

Source URL: https://raw.githubusercontent.com/whyour/qinglong/develop/docker/docker-entrypoint.sh (fetched 2026-11-27, branch develop, not pinned)

## Flow
1. Sources `/ql/shell/share.sh` (not fetched; defines load_ql_envs, import_config, fix_config, reload_pm2).
2. Exports `BACK_PORT=${ql_port}`, `GRPC_PORT=${ql_grpc_port}`.
3. Alpine only: appends `options ndots:0` to /etc/resolv.conf if missing; appends localhost entries to /etc/hosts (127.0.0.1 and ::1) if missing.
4. If `$HOME` not writable: `HOME=$QL_DIR/.tmp`.
5. `ensure_ql_permissions`: if uid != 0, needs write to /ql (tries mkdir `/ql/.tmp`, else `chown -R` /ql) and write+x on /ql/data (else `chown`); exits 1 on failure with message.
6. `load_ql_envs`, `. $dir_shell/env.sh`, `import_config "$@"`, `fix_config`.
7. `pm2 l` (init, tolerant), `reload_pm2`.
8. If `$AutoStartBot == true`: `nohup ql bot` (log $dir_log/bot.log).
9. If `$EnableExtraShell == true`: `nohup ql extra` (log $dir_log/extra.log).
10. Scheduler: `QL_SCHEDULER` unset → `system` if `crond` exists else `node`. `system` → `crond -f >/dev/null`; else `tail -f /dev/null`.
11. Final: `exec "$@"` (never reached while crond/tail blocks; with no args it is a no-op).

## Env vars read
| Var | Use |
| --- | --- |
| QL_DIR | /ql base (from image) |
| HOME | fallback to $QL_DIR/.tmp if unwritable |
| AutoStartBot | `true` starts bot |
| EnableExtraShell | `true` runs `ql extra` |
| QL_SCHEDULER | `system` or `node` |
| ql_port, ql_grpc_port | set via share.sh (defaults not fetched) |
| dir_log | log dir (set in share.sh, not fetched) |

## Gotchas
- Writes /etc/resolv.conf and /etc/hosts: incompatible with read-only rootfs and non-root UID without root-owned /etc.
- Non-root: requires `/ql` and `/ql/data` owned by runtime UID, else exit 1.
- Messages are Chinese; keep behaviour, not wording.
