# prometheus/graphite_exporter (upstream exporter, Dockerfile, checksums, README)

**Source URL(s) + fetch date**
- https://github.com/prometheus/graphite_exporter (repo root)
- https://raw.githubusercontent.com/prometheus/graphite_exporter/v0.17.0/Dockerfile (fetched 2026-11-26)
- https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/sha256sums.txt (fetched 2026-11-26 via its signed redirect to GitHub release storage; the raw-path variant returned 404)
- https://raw.githubusercontent.com/prometheus/graphite_exporter/v0.17.0/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/prometheus/graphite_exporter/v0.17.0/main.go and `.../graphite_exporter.go`: both 404 at the tag (not fetched)
- Binary assets `https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.linux-amd64.tar.gz` (and `linux-arm64`, `dragonfly-amd64`): direct archive downloads, not fetched (names recorded below).

**What it is**
Prometheus exporter that accepts metrics in Graphite plaintext protocol over TCP and UDP and exposes them to Prometheus. Written in Go. Apache-2.0.

**Install/build steps and build deps (upstream Dockerfile at v0.17.0)**
- `ARG ARCH="amd64"`, `ARG OS="linux"`, `FROM quay.io/prometheus/busybox-${OS}-${ARCH}:latest`
- `COPY .build/${OS}-${ARCH}/graphite_exporter /bin/graphite_exporter`
- `USER nobody`, `EXPOSE 9108 9109 9109/udp`, `ENTRYPOINT [ "/bin/graphite_exporter" ]`
- No ENV, RUN, WORKDIR, VOLUME or CMD.
- Build from source is via `make` (README).

**Runtime deps**
None (static Go binary; upstream uses busybox base).

**Binaries/entrypoint/CLI flags**
- Binary: `graphite_exporter` (tarball also contains `getool`, used for an experimental Whisper import; not needed for the exporter).
- Flags named in the README (v0.17.0):
  - `--graphite.mapping-config=<file>`: YAML mapping file (same format as statsd_exporter; breaking change after v0.2.0; `timer_type` options do not work).
  - `--graphite.mapping-strict-match`: keep only metrics that match a mapping.
  - `--graphite.sample-expiry`: garbage-collect idle metrics; default five minutes after the last push.
  - `--web.config.file`: TLS and basic-auth config (exporter-toolkit format).
- README names no flag for the web listen address or the Graphite listen address (plan.md uses `--web.listen-address` and `--graphite.listen-address`; UNVERIFIED because `main.go` and `graphite_exporter.go` were not available at the tag).
- No env vars mentioned.

**Env vars**
None documented.

**Ports**
- 9108/tcp: HTTP and metrics at `/metrics`.
- 9109/tcp and 9109/udp: Graphite plaintext ingest (Dockerfile `EXPOSE 9108 9109 9109/udp`).

**Volumes/paths and persistent data**
None declared upstream. The mapping file is read from the path passed in `--graphite.mapping-config`. Metrics are in memory only (per README gc behaviour).

**User/UID & permissions**
`USER nobody` in the upstream image (busybox base). Ports 9108/9109 are above 1024.

**Config files and formats**
Mapping file: YAML, statsd_exporter format. Unmapped metrics become label-less Prometheus metrics; characters other than `[A-Za-z0-9_:]` are replaced with `_`. Tagged carbon format accepted; invalid tags dropped and counted in `graphite_tag_parse_failures`. Mapping labels win over metric labels unless `honor_labels` is used. TLS/basic auth via `--web.config.file`.

**Healthcheck/readiness endpoints**
`/metrics` on 9108 (no separate health endpoint documented).

**Version/release info and asset naming**
- Tag `v0.17.0`. Release date and "latest" status per plan.md (2026-07-10; not confirmed on the fetched pages).
- Tarball naming: `graphite_exporter-<version>.<os>-<arch>.tar.gz` with `<os>` e.g. `linux`, `darwin`, `dragonfly`, `freebsd`, `netbsd`, `openbsd`, `windows`, `aix`, `illumos`, and `<arch>` e.g. `amd64`, `arm64`, `386`, `armv5/6/7`, `mips*`, `ppc64*`, `riscv64`, `s390x`. Windows also has `.zip`.
- `sha256sums.txt` for v0.17.0 (verified 2026-11-26, values match plan.md):
  - `109c1f946b1798fe1c9c697d1c6f5d939f5b3c21f43408c14be54b9f3e60c469  graphite_exporter-0.17.0.linux-amd64.tar.gz`
  - `95d49e7fa0117eb6a87d2e55409aa57e82ee6161154a6c63a9a3cfc603c3f435  graphite_exporter-0.17.0.linux-arm64.tar.gz`
  - Also present (not used): `753fc6b0...` darwin-amd64, `7a58845167...` dragonfly-amd64 (BSD, not for Linux), linux-386, linux-armv5/6/7, mips*, ppc64*, riscv64, s390x, freebsd/netbsd/openbsd, windows (tar.gz and zip).
- Asset file is a plain `sha256sum` list (hash, two spaces, filename).

**Arch support**
linux amd64 and arm64 both published with checksums (plus many others).

**Licence**
Apache-2.0 (plan.md; repo LICENSE and NOTICE not fetched).

**Gotchas**
- Use `linux-amd64`, not `dragonfly-amd64` (the draft's link is the BSD build; plan.md correction holds: the checksum list confirms `dragonfly-amd64` is a separate asset).
- Metrics expire 5 minutes after the last push by default.
- Graphite ingest needs both TCP and UDP on 9109 if the sender uses UDP.
- Upstream README warns the exporter is incompatible with the Java and Python client Graphite bridges.
- The raw-path `sha256sums.txt` URL returns 404; the `releases/download/` URL works.
