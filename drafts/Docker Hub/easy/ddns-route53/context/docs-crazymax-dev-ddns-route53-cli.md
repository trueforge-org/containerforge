# crazymax.dev ddns-route53 docs: command line

Source URL(s) + fetch date:
- https://crazymax.dev/ddns-route53/usage/cli/ · 2026-11-26

## Flags and env vars
See the table in github-crazy-max-ddns-route53.md, which lists the same flags. Key facts from this page:
- `--schedule` / `SCHEDULE`: CRON expression. Warning on page: "If schedule is not set, the app will run once and then exit."
- `--config` / `CONFIG`: config path.
- `--ifname` / `IFNAME`: empty selects the default interface.
- `--max-retries` / `MAX_RETRIES` (3); `--max-backoff-delay` / `MAX_BACKOFF_DELAY` (5s); `--log-level` / `LOG_LEVEL` (info); `--log-json` / `LOG_JSON` (false); `--log-caller` / `LOG_CALLER` (false); `--log-nocolor` / `LOG_NOCOLOR` (false).
- `--version` is listed without description. No env var listed for `-h`/`--version`.
- No timezone flag on this page.
