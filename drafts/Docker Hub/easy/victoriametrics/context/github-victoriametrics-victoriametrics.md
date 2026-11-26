# VictoriaMetrics/VictoriaMetrics

Source URL(s) + fetch date: https://github.com/VictoriaMetrics/VictoriaMetrics (and `/tree/master`) · https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/master/README.md · https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v1.156.0/app/victoria-metrics/deployment/Dockerfile · https://github.com/VictoriaMetrics/VictoriaMetrics/releases · https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v1.157.0/LICENSE · fetched 2026-11-26

## What it is
- VictoriaMetrics time-series database and monitoring solution. Single-node edition is one binary; cluster edition is a separate set of components (vminsert, vmselect, vmstorage).
- Distribution: GitHub binary releases, Docker Hub `victoriametrics/victoria-metrics`, Quay `quay.io/victoriametrics/victoria-metrics`.
- No runtime dependencies per the README.

## Install/build steps and build deps
- Upstream Docker image build (`app/victoria-metrics/deployment/Dockerfile` at v1.156.0): `ARG base_image=non-existing`, `FROM $base_image`, `EXPOSE 8428`, `ENTRYPOINT ["/victoria-metrics-prod"]`, `ARG src_binary=non-existing`, `COPY $src_binary ./victoria-metrics-prod`. No USER, CMD or ENV in the upstream Dockerfile.
- Build the image from a static binary: docs mention `ROOT_IMAGE=scratch make package-victoria-metrics`.

## Runtime deps
- None (static single binary per README).

## Binaries/entrypoint/CLI flags
- Binary name in the image: `victoria-metrics-prod` (single-node). Configuration via command-line flags.
- Flags named in the sources: `-storageDataPath` (default `victoria-metrics-data`, relative to cwd), `-retentionPeriod` (default 1 month, minimum 1d), `-httpListenAddr` (default `:8428`), `-envflag.enable`, `-envflag.prefix`, `-deleteAuthKey`, `-forceMergeAuthKey`, `-forceFlushAuthKey`, `-metricsAuthKey`.
- `--help` lists all flags (Docker Hub example: `docker run --rm victoriametrics/victoria-metrics:latest --help`).

## Env vars
- Only through `-envflag.enable`: each `.` in a flag name becomes `_` (e.g. `insert.maxQueueDuration` -> `insert_maxQueueDuration`). `-envflag.prefix=VM_` requires env names to start with `VM_`. Repeated flags may take comma-separated values in one variable.
- No documented fixed env vars.

## Ports
- `8428/tcp` (EXPOSE in upstream Dockerfile; default `-httpListenAddr` `:8428`).

## Volumes/paths and persistent data
- Data directory from `-storageDataPath`; default `victoria-metrics-data` (relative to cwd). Docker Hub example mounts a volume at `/victoria-metrics-data` and passes `-storageDataPath=/victoria-metrics-data`.

## User/UID & permissions
- Upstream image sets no USER (root by default).

## Healthcheck/readiness endpoints
- `/health` (used by the TrueCharts chart probes). `/metrics` and `/vmui` endpoints exist per docs. The response body of `/health` was not confirmed in fetched content.

## Version/release info and asset naming
- Latest release: `v1.157.0` (marked Latest on the releases page; the page lists v1.156.0, v1.155.0, v1.154.1, v1.154.0, v1.153.0 as older).
- Asset name pattern: `victoria-metrics-<os>-<arch>-v<version>[-enterprise][-cluster].tar.gz` with a matching `..._checksums.txt`. Also `vmutils-*` and Windows `.zip` archives.
- Source code archives are also attached (zip and tar.gz).

## Arch support
- Assets present for darwin amd64/arm64 and linux (amd64/arm64 per draft/plan). Linux amd64 and arm64 tarballs are named in the draft and the plan.

## Config files and formats
- None required. Optional YAML configs with `%{ENV_VAR}` expansion (per docs).

## License
- Apache License 2.0 (LICENSE at v1.157.0; "Copyright VictoriaMetrics, Inc. 2019-2026").

## Gotchas
- Enterprise and LTS releases exist on the same releases page; not relevant for the community build but Renovate can see them.
- Docs say graceful shutdown uses `SIGINT` (see the docs file); plan.md section 7 mentions `SIGTERM`.
- Cluster `-cluster.tar.gz` assets exist (see the draft); they are the cluster components, not the single-node binary (consistent with plan.md section 1).
- Auth is open by default; the `*AuthKey` flags protect only specific endpoints.
