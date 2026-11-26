# Docker Hub: chronograf (Docker Official Image)

Source URL(s) + fetch date:
- https://hub.docker.com/_/chronograf (fetched 2026-11-26)

## What it is
Visualization tool for time series data in InfluxDB, InfluxData's open-source web app for the TICK stack. Docker Official Image, maintained by InfluxData, category Monitoring and observability. Not marked deprecated.

## Architectures
amd64, arm32v7, arm64v8.

## Tags
1.10, 1.10.9, 1.10-alpine, 1.10.9-alpine, 1.11, 1.11.8, latest, 1.11-alpine, 1.11.8-alpine, alpine. Latest is about 92.5 MB. About 100M+ pulls.

## Ports
8888.

## Volumes
`/var/lib/chronograf` (host dir or named volume).

## Env vars
`CHRONOGRAF_AS_ROOT=true` restores running as root. Since v1.10.5 the image does not run as root by default.

## Run examples
- `docker run -p 8888:8888 chronograf`
- `docker run -p 8888:8888 -v chronograf:/var/lib/chronograf chronograf`
- With InfluxDB on a shared network: `docker run -p 8888:8888 --net=influxdb chronograf --influxdb-url=http://influxdb:8086`

## Gotchas
- Alpine variants use musl, not glibc (not relevant for ContainerForge's ubuntu base).
- Shows `latest` as 1.11.8 at capture, while the ContainerForge draft pins 1.11.7.
