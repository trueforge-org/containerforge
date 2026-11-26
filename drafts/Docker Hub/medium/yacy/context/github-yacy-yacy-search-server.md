# yacy/yacy_search_server (upstream source)

**Source URL(s):** https://github.com/yacy/yacy_search_server (repo page); pinned commit `eba3f94b4376180de5fbf3812c41e3c65dad4cfb`: https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/startYACY.sh, .../defaults/yacy.init
**Fetched:** 2026-11-26

## What it is
- "Distributed Peer-to-Peer Web Search Engine and Intranet Search Appliance". Includes an index server, a web front-end, a crawler with scheduler, and a network scanner (HTTP, FTP, SMB).
- Peers join a P2P network by default; users can opt out entirely or per search.
- Default branch `master`. About 4.1k stars, 14,942 commits.

## Install/build steps and build deps
- Upstream build: `git clone --depth 1 https://github.com/yacy/yacy_search_server.git`, then `ant clean all`. Build needs JDK 17+ and `ant`.
- Linux tarball path: extract, `cd` into the folder, `./startYACY.sh`. Stop with `./stopYACY.sh`.
- Windows installer: NSIS and `ant distWinInstaller`. Not relevant here.
- The Docker build (upstream Dockerfile, see github-yacy-docker-dockerfile.md) runs `ant compile` in a builder stage, then copies `/opt/yacy_search_server`.
- Prebuilt packages exist but are not regularly produced; the repo README points to release.yacy.net for developer builds.

## Runtime deps
- Java 17 or newer (repo README, `startYACY.sh` refuses to start otherwise). A more recent JDK is recommended (download page). The plan's Java 24/25 choice is not required by upstream.
- No database. Data is files on disk.
- Network: UDP and multicast for peer discovery is described in the wider docs, not in this source (see docs summary).

## Binaries/entrypoint/CLI flags (startYACY.sh)
- Launches `$JAVA $JAVA_ARGS -classpath $CLASSPATH net.yacy.yacy`.
- Classpath: `.:` followed by every `lib/*.jar`.
- Base JVM flags: `-server -Djava.awt.headless=true -Dfile.encoding=UTF-8`.
- On 64-bit: adds `-Dsolr.directoryFactory=solr.MMapDirectoryFactory`. On Linux with HugePages or SunOS: `-XX:MinHeapFreeRatio=60 -XX:MaxHeapFreeRatio=90`.
- Memory: reads `javastart_Xmx` from `DATA/SETTINGS/yacy.conf` (prefixed with `-`); `YACY_JAVASTART_XMX` env overrides it; if the config is missing, uses `-Xmx600m`.
- `javastart_priority` in config wraps the command in `nice -n <value>`.
- Flags: `-f`/`--foreground` (console output, script `exec`s java; use this for containers), `-d` (debug with JMX on port 9999, no auth, and assertions; also foreground), `-l` (background with `yacy.log` and `yacy.pid`), `-p` (print command only), `-t` (tail `DATA/LOG/yacy00.log`), `-h` (usage, exit 3), `-s`/`-g` (custom data parent path, GUI path).
- Default (no flags): background daemon that prints `http://localhost:$PORT`.
- The script `cd`s to its own directory. Relative paths: `lib/`, `DATA/SETTINGS/`, `DATA/LOG/`.
- Reads `DATA/SETTINGS/yacy.conf` for `javastart_Xmx`, `javastart_priority` and `port=` (default 8090). Reads `/proc/meminfo` on Linux.
- Env vars read by the script: `YACY_JAVASTART_XMX`, `HOME`, `PATH`. Uses `uname`, `getopt`, `id`.
- Does not reference `yacy.init` or a defaults file. `yacy.init` is read by the app itself.

## Env vars (documented overrides)
- Any `yacy.init` setting can be set by env var: uppercase the key, replace dots with underscores, prefix `YACY_`. Example `network.unit.agent` becomes `YACY_NETWORK_UNIT_AGENT` (yacy.net download/installation page). Not verified against `startYACY.sh` (the script does not handle this; the app must, per the docs).
- `YACY_JAVASTART_XMX` (script).

## Config file: defaults/yacy.init (key facts)
- Ports: `port` = 8090; `port.ssl` = 8443; `port.shutdown` = -1; `server.https` = false (Dockerfile sets true); `host` = 0.0.0.0 (binds all); `bindPort`, `publicPort`, `staticIP` empty; `upnp.enabled` = true.
- TLS keystore: `keyStore` = `defaults/freeworldKeystore`, `keyStorePassword` = `freeworld`.
- Admin: `adminAccountUserName` = `admin`; `adminAccountBase64MD5` = `MD5:8cffbc0d66567a0987a4aba1ec46d63c` (comment says password `yacy`); `adminAccountForLocalhost` = true (Dockerfile sets false); `adminAccountAllPages` = false.
- Paths (relative to install dir): `htDocsPath` = DATA/HTDOCS; `indexPrimaryPath` = DATA/INDEX; `indexArchivePath` = DATA/ARCHIVE; `listsPath` = DATA/LISTS; `workPath` = DATA/WORK; `skinPath` = DATA/SKINS; `proxyCache` = DATA/HTCACHE; `dictionaries` = DATA/DICTIONARIES; `classification` = DATA/CLASSIFICATION; `releases` = DATA/RELEASE; `locale.translated_html` = DATA/LOCALE/htroot; `packs.*` under DATA/PACKS; `ai.logreport.dir` = DATA/REPORTS/log. `htRootPath` = htroot.
- Network: `network.unit.definition` = defaults/yacy.network.freeworld.unit; `cluster.mode` = publicpeer; `allowDistributeIndex` = true; `allowReceiveIndex` = true; `crawlOrder` = true; `scan.enabled` = false; `update.process` = manual; `restart.process` = off.
- Memory/disk: `javastart_Xmx` = Xmx600m; `javastart_priority` = 10; `wordCacheMaxCount` = 20000; `proxyCacheSize` = 4096 (MB); `disk.free` = 3000; `disk.free.hardlimit` = 1000; `resource.disk.free.autoregulate` = true; `httpdMaxBusySessions` = 200.
- Federated Solr indexing: disabled, URL `http://127.0.0.1:8983/solr`.

## Ports
8090 (HTTP web UI/API, `port`), 8443 (HTTPS, `port.ssl`, used when `server.https=true`). Debug JMX 9999 only with `-d`.

## Volumes/paths and persistent data
- `/opt/yacy_search_server/DATA` (VOLUME upstream; holds SETTINGS, LOG, INDEX, HTCACHE, etc.).
- Docker docs: named volume `yacy_search_server_data` mounted there.
- Backup: stop the container, tar the DATA volume with a temporary container, restart (docs).

## User/UID and permissions
Upstream Docker image runs as `yacy` (system user, created with `adduser --system`). Our build runs as `apps` (568).

## Config files and formats
- `defaults/yacy.init`: key=value. Runtime settings are written to `DATA/SETTINGS/yacy.conf` (per startYACY.sh; the plan's assumption is consistent).
- Admin password: `ConfigAccounts_p.html` in the web UI, or headless `bin/passwd.sh <password>` (docs).

## Healthcheck/readiness endpoints
None documented. Web UI at `http://localhost:8090` (docs); localhost access needs no password.

## Version/release info
- Latest tarball: `yacy_v1.942_202608150808_f9c4b9700.tar.gz` (123 MB, 2026-08-15). Previous: `v1.941_202603291103_f0464e7fb` (104 MB, 2026-03-29). Naming: `yacy_v<VERSION>_<YYYYMMDDHHMM>_<commit>.tar.gz`.
- See docs-download-yacy-net.md for the listing and checksum facts.

## Arch support
- Docker page (download/installation): `yacy/yacy_search_server:latest` is amd64. ARM tags exist: `aarch64-latest` (arm64v8) and `armv7-latest` (arm32v7).
- Tarball is a JVM app: arch-neutral.

## Gotchas
- LICENSE at the pinned commit returned 404 (raw URL and GitHub blob URL both failed). Repo page and yacy.net say GPL-2.0-or-later with some LGPL parts. The plan's `GPL-2.0-or-later` is therefore partly confirmed; the exact LICENSE file was not read.
- `docker/Readme.md` at the pinned commit returned 404 (raw). Docker details came from the Docker Hub page and the download/installation page.
- The admin default `yacy` is a known default: change it before exposure (docs say remote login is blocked after about 10 minutes of no local login; the page's wording is per Docker Hub).
- `-f` must be used for foreground; the default runs a background daemon and exits.
