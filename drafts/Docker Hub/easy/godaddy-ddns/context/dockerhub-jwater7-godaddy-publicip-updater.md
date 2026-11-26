# jwater7/godaddy-publicip-updater (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/jwater7/godaddy-publicip-updater
- Fetched 2026-11-26

**What it is**
Image that periodically updates GoDaddy A records to the machine's public IP (uses godaddypy and pif). Default check interval 15 minutes. 100K+ pulls.

**Tags and size**
- Only `latest` (digest `sha256:fd454790cf...`, image 337.8 MB). Last pushed over 6 years before fetch (page relative date; the exact date in plan.md, 2020-04-28, is not shown on the page).

**Architectures**
Not listed on the page. Plan.md says amd64 only; unverified here.

**Source link**
None on the page.

**Run examples**
- Test: `docker run --rm -it -e GODADDY_API_KEY=... -e GODADDY_API_SECRET=... -e GODADDY_DOMAINS=... jwater7/godaddy-publicip-updater`
- Daemon: same `-e` values with `-d --name=... --restart=always`.
- Compose sample mounts `./config.json` to `/config.json` and sets `UPDATER_CONFIG_FILE`.

**Env vars**
Required: `GODADDY_API_KEY`, `GODADDY_API_SECRET`, `GODADDY_DOMAINS`. Optional: `GODADDY_A_NAMES` (default `@`), `UPDATE_INTERVAL_SEC` (900), `GET_IP_WAIT_SEC` (10), `UPDATER_CONFIG_FILE`.

**Volumes and ports**
None required. No ports.

**Contradictions with plan.md**
- None found on the page. The page does not give architectures or the 2020-04-28 date that plan.md section 1 states (not verifiable from this page; left unverified).
