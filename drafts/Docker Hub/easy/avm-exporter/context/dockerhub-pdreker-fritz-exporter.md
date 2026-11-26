# Docker Hub: pdreker/fritz_exporter

**Source URL(s) + fetch date**
- https://hub.docker.com/r/pdreker/fritz_exporter (fetched 2026-11-26)

**Facts**
- Description: Prometheus exporter for AVM FRITZ! home network devices (TR-064, fritzconnection). Metric groups: base info, software update, LAN, WAN, DSL, PPP, WiFi, WAN Layer1. Host info exists but is disabled by default.
- Tags: only `latest` shown (digest `sha256:abe49b0f6...`, 24 MB, updated 20 days before capture). Tag `4.0.3` not on this view.
- Architectures: not stated. Ports, volumes, env vars: not stated. Pull command only: `docker pull pdreker/fritz_exporter`.
- Notes on the page: `FRITZ_EXPORTER_CONFIG` removed in v2.0.0; env config supports a single device; passwords over 32 characters give 401; old libseccomp issue on Raspberry Pi.
