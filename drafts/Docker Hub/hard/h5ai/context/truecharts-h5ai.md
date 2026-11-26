# TrueCharts: h5ai chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/h5ai (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/h5ai/values.yaml)
**Fetched:** 2026-11-26

## Image
- `docker.io/awesometic/h5ai`, tag `latest` pinned by digest `sha256:f45fc5a8ec89a3b7045fe83dcddb44eade4a143eb490bd9bcefa69c0d13476e5`, pull policy IfNotPresent. (The chart still uses the deprecated awesometic image.)

## Service and ports
- Service `main`, port `main`: port 80, target 80, tcp.

## Env
None defined.

## Persistence
- `config`: enabled, mounted at `/config`, no readOnly setting.
- `directorystorage`: enabled, mounted at `/h5ai`, **readOnly: true**.

## Security context
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false. Container runs as root with writable rootfs.

## Probes
None defined.

## Other
- Schema reference `./values.schema.json`.
- Plan note: the `/h5ai` mount is the browse root; mounting read-only fits our read-only rootfs design.
