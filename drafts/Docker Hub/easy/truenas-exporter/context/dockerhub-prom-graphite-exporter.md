# prom/graphite-exporter (Docker Hub image)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/prom/graphite-exporter (fetched 2026-11-26)
- Also published on Quay: `quay.io/repository/prometheus/graphite-exporter` (not fetched)

**What it is**
Docker Hub image of the Prometheus Graphite Exporter. Takes Graphite plaintext over TCP or UDP and exposes Prometheus metrics. 100M+ pulls. Updated 6 days before fetch.

**Tags**
- `latest`: updated 5 months ago, size 10.3 MB, digest `sha256:c1a266f63...`.
- No other tags shown.
- TrueCharts pins `v0.17.0@sha256:c1a266f63a84fd11048ab6ad1552a4c497b14522d02823925247698e41eeac2b`, the same digest as `latest`.

**Arch support**
Not listed on the page.

**Usage**
```
docker pull prom/graphite-exporter

docker run -d -p 9108:9108 -p 9109:9109 -p 9109:9109/udp \
  -v ${PWD}/graphite_mapping.conf:/tmp/graphite_mapping.conf \
  prom/graphite-exporter --graphite.mapping-config=/tmp/graphite_mapping.conf
```

**Ports**
- 9108: metrics at `/metrics`.
- 9109: Graphite plaintext over TCP and UDP.

**Volumes**
Mapping config mounted at `/tmp/graphite_mapping.conf` in the example (the path is arbitrary; passed via the flag).

**Flags shown**
`--graphite.mapping-config`, `--graphite.sample-expiry` (default five minutes), `--graphite.mapping-strict-match`, `--web.config.file` (TLS and basic auth).

**Gotchas**
- Mapping format is YAML, shared with statsd_exporter; `timer_type` options do not work. Legacy configs need `statsd-exporter-convert`.
- Experimental `getool` (Whisper import) is bundled in the binary tarball, not the image's default use.
- Incompatible with the Java and Python client Graphite bridges.
