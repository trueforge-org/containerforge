# TrueCharts ser2sock chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ser2sock (WebFetch 2026-11-26); values.yaml raw (2026-11-26).

## values.yaml facts
- Image: `docker.io/tenstartups/ser2sock`, tag `latest@sha256:379d9338c720da30b63dc4cf2ecea07eb89dac7d62d5c79047294fffe97ae559`
- Service port 10000 (`LISTENER_PORT` = service port)
- Persistence mountPath `/config`
- env: `LISTENER_PORT`, `SERIAL_DEVICE` (empty default), `BAUD_RATE` 115200 (differs from Dockerfile default 9600)

## Chart files
- Chart.yaml, values.yaml, values.schema.json, CHANGELOG.md, README.md, ci/, templates/
- Install: `oci://oci.trueforge.org/truecharts/ser2sock`; docs truecharts.org/charts/stable/ser2sock.
