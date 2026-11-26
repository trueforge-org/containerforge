# influxdata/chronograf (upstream source)

Source URL(s) + fetch date:
- https://github.com/influxdata/chronograf (repo; README read via raw master, fetched 2026-11-26)
- https://raw.githubusercontent.com/influxdata/chronograf/1.11.7/LICENSE (fetched 2026-11-26)

## What it is
Open-source web app (Go backend and React UI) for visualizing monitoring data and creating alerting and automation rules. It is the UI and admin component for InfluxDB. Features include host list, dashboard templates for Telegraf plugins, data explorer, dashboards, Kapacitor alert UI, user and query management, TLS/HTTPS, OAuth login, and root path routing. The REST API docs (swagger) are served at `/docs`.

## Install/build steps and build deps
- Recommended: pre-built packages (Debian/RPM). Docker: `docker pull chronograf:latest`.
- Source build (README): Go 1.18+, Node 24 LTS, Yarn 1.7+, a configured GOPATH, Kapacitor 1.5.x+ (for alerts). Commands: `go get github.com/influxdata/chronograf`, `cd $GOPATH/src/github.com/influxdata/chronograf`, `make`, `go install github.com/influxdata/chronograf/cmd/chronograf`. Not used by ContainerForge (we ship the vendor deb).

## Runtime deps
None beyond the binary for basic use. An InfluxDB (1.x, 2.x or 3.x) server is needed to be useful; Kapacitor is optional.

## Binaries/entrypoint/CLI flags
- Binary: `chronograf` (deb installs `/usr/bin/chronograf`, `/usr/bin/chronoctl`).
- Start: `chronograf`. Key flags: `--host` (default 0.0.0.0), `--port` (8888), `--bolt-path`/`-b`, `--canned-path`/`-c`, `--resources-path`, `--basepath`/`-p`, `--log-level`/`-l`, `--reporting-disabled`/`-r`, `--cert`, `--key`.
- CLI flags take precedence over env vars.

## Env vars
See docs-influxdata-chronograf-config-options.md for the full table (HOST, PORT, BOLT_PATH, CANNED_PATH, RESOURCES_PATH, BASE_PATH, LOG_LEVEL, REPORTING_DISABLED, TLS_CERTIFICATE, TLS_PRIVATE_KEY, INFLUXDB_URL, KAPACITOR_URL, and auth variables).

## Ports
- 8888/tcp (HTTP UI, default `PORT`).

## Volumes/paths and persistent data
- BoltDB file `chronograf-v1.db` (`BOLT_PATH`). The docs say to keep this file outside the launch directory so dashboards persist across upgrades.
- Canned dashboards and resources are read from `/usr/share/chronograf/canned` and `/usr/share/chronograf/resources` by default (installed by the deb).

## Version/release info and asset naming
- Latest version on the downloads page at capture: 1.11.8. Git tags use no `v` prefix (e.g. `1.11.7`), per plan.md.
- Debian asset naming: `chronograf_<version>_<arch>.deb` with `.deb.asc` (detached GPG sig). Arch is `amd64` or `arm64`. Download host `https://dl.influxdata.com/chronograf/releases/`. See influxdata-downloads.md.
- Upgrade note: upgrading from 1.3.10 or older to 1.8+ requires first going to a 1.4.0 to 1.7.x release.

## Arch support
amd64, arm64 (deb). Upstream Docker images also list arm32v7 (armhf) and armel in the Dockerfile arch check.

## License
GNU AGPL v3 (or any later version at the licensee's option). LICENSE file at repo root (version tag 1.11.7 fetched). The deb does not ship a LICENSE file (per plan.md); upstream image copies `LICENSE` and `agpl-3.0.md` into `/usr/share/chronograf/`.

## Gotchas
- README says no env vars are documented in its content; the full list is on the InfluxData config-options page (see that summary). Source: README paraphrase, the config-options page is authoritative.
- README says "The latest version is listed on the InfluxData downloads page"; no release number in the README itself.
- Known issue from README: Telegraf CPU and system plugins must run for all apps to appear on the host list page.
- Draft/plan claim of "maintenance mode" is NOT stated in the README or the product page (see influxdata-downloads.md, product page section).
