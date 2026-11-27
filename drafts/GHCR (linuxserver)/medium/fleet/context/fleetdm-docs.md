# fleetdm.com (unrelated product)

Source URL (fetched 2026-11-27):
- https://fleetdm.com/docs (returned the "Why Fleet" page, not server install docs)
- Also listed: https://fleetdm.com (not fetched, same product)

## What it is
- Fleet (fleetdm): open-source device management, patching and governance platform (macOS, Windows, Linux, ChromeOS, iOS, Android). Built around osquery.
- Install docs are on `/docs/deploy/deploy-fleet` (not fetched). Not the same product as linuxserver/fleet.

## Gotchas
- Do not use fleetdm docs to build the linuxserver/fleet image. Its config is JDBC/MariaDB, `fleet_*` env vars, and the source is `linuxserver/fleet` jar on GitHub.
- No install/config facts (env vars, ports, DB) were found on the page fetched.
