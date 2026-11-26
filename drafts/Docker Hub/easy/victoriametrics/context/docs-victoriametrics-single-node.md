# VictoriaMetrics docs: single-node

Source URL(s) + fetch date: https://docs.victoriametrics.com/ · https://docs.victoriametrics.com/victoriametrics/single-server-victoriametrics/ · fetched 2026-11-26

## What it is
- Landing page describes VictoriaMetrics as "The fast, cost-effective, scalable monitoring solution and time series database". Single-node and cluster versions are documented separately. Landing page content moved to /victoriametrics/ anchors (install, command-line flags, data import, vmui).

## Install/build steps
- Single-node docs cover installation and flags; quick start at /victoriametrics/quick-start/.
- Docker images on Docker Hub and Quay. Build example: `ROOT_IMAGE=scratch make package-victoria-metrics`.
- Docker run example is not on the single-node page; see the Docker Hub summary.

## Env vars
- Env var naming (`-envflag.enable`): `.` in flag names becomes `_`; `-envflag.prefix` sets a required prefix (e.g. `VM_`). Flags and YAML configs also support `%{ENV_VAR}` expansion.

## Ports
- Default HTTP port `8428` for the Prometheus querying API.

## Endpoints
- `/vmui` web UI (documented at `http://victoriametrics:8428/vmui`).
- `/metrics` exposes internal metrics (e.g. `vm_snapshots`).
- `/health`: referenced by the chart; response not shown in fetched content.

## Volumes/paths and persistent data
- `-storageDataPath`: all data stored here; default `victoria-metrics-data` in the working directory.

## Config files and formats
- Retention: `-retentionPeriod` default 1 month (31 days); minimum 24h / 1d. Unit semantics for bare numbers not shown in the visible text (see Gotchas).

## Auth
- Not stated as a default. Optional keys protect specific endpoints: `-deleteAuthKey`, `-forceMergeAuthKey`, `-forceFlushAuthKey`, `-metricsAuthKey`. This implies no auth on the main API by default. `vmauth` is a separate component.

## Graceful shutdown
- Docs say send `SIGINT` to stop gracefully and wait a few seconds. `SIGTERM` is not mentioned.

## Gotchas
- Fetch truncated at ~100k characters of a very long page. Not confirmed from fetched text: the `/health` response body, `-httpListenAddr` default text, bare-number retention semantics, `-storage.minFreeDiskSpaceBytes` and its default, `docker run` example.
- plan.md section 7 says VictoriaMetrics "flushes in-memory parts on SIGTERM". The docs name `SIGINT`. Contradiction flagged, not edited (see README).
