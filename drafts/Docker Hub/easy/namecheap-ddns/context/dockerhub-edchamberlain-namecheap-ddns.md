# edchamberlain/namecheap_ddns (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/edchamberlain/namecheap_ddns (fetched 2026-11-26)

**What it is**
- Docker Hub page for the upstream-built image, described as a "Simple ddns script for namecheap ddns". Also listed in unRAID Community Applications.

**Install/build steps and build deps**
- Pull: `docker pull edchamberlain/namecheap_ddns` (tag `latest`).

**Version/release info and asset naming**
- Only one tag: `latest`. No versioned tags are listed.
- Image size shown as 52.1 MB; digest begins `sha256:fb6e8ad86...`, which matches the digest pinned in the TrueCharts chart values (`latest@sha256:fb6e8ad8647cf37b4e82a084d52e2c5b2fc0f3d4ceaa83690f7edf4a16eed19b`).
- "Last updated: about 3 years ago" (as shown on the page at fetch time).

**Arch support**
- Not stated on the page.

**Env vars**
- Required: `APP_HOST`, `APP_DOMAIN`, `APP_PASSWORD`. Optional: `APP_UPDATE_TIME` (example 60), `APP_LOG_LEVEL`.
- Multiple records: semicolon-separated lists; each variable needs the same number of entries.

**Volumes/paths and persistent data**
- None mentioned.

**Ports**
- None mentioned.

**Gotchas**
- Prerequisites on Namecheap: create an "A + Dynamic DNS" record for the host, enable Dynamic DNS on the domain's manage page, and use the Dynamic DNS password (not the account password).
- The image is stale by page date (about 3 years since last update) while the TrueCharts chart pins a digest; the plan's "latest only" note stands.
- Page's run instructions match the env var contract in the GitHub source summary.
