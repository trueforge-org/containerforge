# Supporterino/truenas-graphite-to-prometheus (TrueNAS mapping file project)

**Source URL(s) + fetch date**
- https://github.com/Supporterino/truenas-graphite-to-prometheus (repo root, fetched 2026-11-26)
- https://github.com/Supporterino/truenas-graphite-to-prometheus/tree/main (same content)
- Not followed: `TRUENAS.md` (run-inside-TrueNAS guide, linked from the README but not fetched; not a listed URL)

**What it is**
"A graphite exporter mapping file for truenas scale >23.10.1 metrics and some example grafana dashboards." TrueNAS sends Netdata metrics in Graphite format; a `graphite_exporter` with this mapping turns them into Prometheus metrics for Grafana. Tested on TrueNAS 23.10.x through 25.04.x (config v1.x.x for older releases, v2.x.x for 25.04).

**Install/build steps**
- Replace the existing config of your `graphite_exporter` with `graphite_mapping.conf` (repo root) and restart.
- TrueNAS side: the metric prefix must be `truenas`.
- From exporter configuration version 2.1 onward, copy the repo's `netdata.conf` to `/etc/netdata/netdata.conf` on the TrueNAS host, and reapply it after TrueNAS updates.
- The repo tree lists a `Dockerfile`, but its content was not shown in the fetch. Base image, tag, entrypoint and any env vars are UNVERIFIED from this source (plan.md says `FROM prom/graphite-exporter:v0.16.0`, and the copy of `graphite_mapping.conf` to `/config/graphite_mapping.conf`).

**Runtime deps**
The `graphite_exporter` binary (see the upstream summary). Nothing else is documented.

**Env vars**
None documented.

**Config files and formats**
- `graphite_mapping.conf` at the repo root (YAML, statsd_exporter-style mapping; about 19.7 KB per plan.md, not verified here).
- `netdata.conf` at the repo root (copied to the TrueNAS host).

**Ports**
None documented here (the exporter listens on 9108 and 9109; see upstream summary).

**Volumes/paths**
Mapping file is passed to the exporter as `--graphite.mapping-config=<path>` (TrueCharts uses `/config/graphite_mapping.conf`; see TrueCharts file).

**Version/release info**
Config versions: v1.x.x (older TrueNAS), v2.x.x (TrueNAS 25.04). No tag or release info was fetched.

**Licence**
GPL-3.0 (the fetched page).

**Gotchas**
- The mapping file is GPL-3.0, while `prometheus/graphite_exporter` is Apache-2.0. Bundling it would mix licences (plan.md section 10 open question).
- Metric prefix `truenas` must be set on the TrueNAS side for the mapping to match.
- `netdata.conf` must be re-applied after TrueNAS updates.
