# yacy.net: download and installation

**Source URL(s):** https://yacy.net/download_installation/
**Fetched:** 2026-11-26

## Java
- Java 17 minimum; a more recent JDK is recommended. Git installs also need `ant` and `git`. Docker users need no Java on the host.

## Start (Linux tarball)
- Extract the tarball, `cd` into it, run `./startYACY.sh`.
- Git: `git clone --depth 1 https://github.com/yacy/yacy_search_server.git`, then `ant clean all dist`, then `./startYACY.sh`.
- macOS and Windows: app bundle and installer (not relevant here).
- The page does not mention a `-f` flag (see the startYACY.sh facts in github-yacy-yacy-search-server.md).

## Ports
- Web interface at `http://localhost:8090`.
- Docker maps 8090 and 8443. The page does not say what 8443 is for.
- Windows: allow Java private-network access to listen on `localhost:8090`.

## Admin account and password
- Local access needs no password. From another host: `admin` / `yacy` (the Docker default is the same).
- Change the password before exposing YaCy: `/ConfigAccounts_p.html` in the UI, or headless `bin/passwd.sh <password>`.

## Data location
- macOS app: `~/Library/Application Support/net.yacy.YaCy/DATA/`.
- Docker: volume mounted at `/opt/yacy_search_server/DATA`.

## Docker
- Image `yacy/yacy_search_server:latest` (amd64). ARM tags: `aarch64-latest` (arm64v8) and `armv7-latest` (arm32v7).
- Run: `docker run -d --name yacy_search_server -p 8090:8090 -p 8443:8443 -v yacy_search_server_data:/opt/yacy_search_server/DATA --restart unless-stopped --log-opt max-size=200m --log-opt max-file=2 yacy/yacy_search_server:latest`.
- Upgrade: stop and remove the container, pull, rerun (the data volume is reused).
- Configuration: any `yacy.init` setting can be overridden with an env var: uppercase the name, replace dots with underscores, prefix `YACY_` (e.g. `network.unit.agent` -> `YACY_NETWORK_UNIT_AGENT`). This is a documented override mechanism and was not verified in the script.
- Backup: stop the container; temporary `openjdk:17-jre-slim` container tars the DATA volume to `/tmp/DATA.tar.xz`; restart.
