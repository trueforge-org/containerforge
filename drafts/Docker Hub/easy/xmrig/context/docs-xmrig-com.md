# xmrig.com docs

Source URL(s) + fetch date: https://xmrig.com/docs · https://xmrig.com/docs/miner/command-line-options (followed link) · fetched 2026-11-26

## Landing page (https://xmrig.com/docs)
- Navigation only: XMRig (unified CPU/GPU miner) at /docs/miner; XMRig Proxy at /docs/proxy; Cloud API at /docs/api. Also Benchmark, Wizard, Download pages.
- No install, config or CLI detail on the landing page.

## Command-line options (https://xmrig.com/docs/miner/command-line-options)
- Full option list with versions and defaults. Key defaults stated: `--donate-level` "1% (1 minute in 100 minutes)"; `--http-host` default `127.0.0.1` (5.0.0+); `--dns-ttl` default 30; `--daemon-poll-interval` default 1000 ms; `--daemon-job-timeout` default 15000 ms; `-r/--retries` default 5; `-R/--retry-pause` default 5.
- Options relevant to the container plan: `--http-host`, `--http-port`, `--http-access-token`, `--http-no-restricted` (only with a token), `--no-huge-pages`, `--rig-id`, `--tls`, `--tls-fingerprint`, `-k/--keepalive`, `--user-agent`, `--no-color`, `--print-time`, `--cpu-max-threads-hint`, `--dry-run`, `-c/--config`.

## Gotchas
- The miner docs page (https://xmrig.com/docs/miner) and the config page were not fetched in full; the config page was not located.
- The API docs (/docs/api) were not fetched.
