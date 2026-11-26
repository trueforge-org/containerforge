# trueforge truecharts tar1090 values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tar1090/values.yaml (fetched 2026-11-26)

## Image
- Repository: `docker.io/mikenye/tar1090`
- Tag: `latest@sha256:b67db478db2f95d00c23cca59a9557bb6785b78a07b00611f6fef436840fa212`
- PullPolicy: IfNotPresent

## Service
- Key `main`, port `main`: 8078/tcp -> targetPort 80

## Persistence
- Declared as `{}`, no mount paths defined.

## Env (container main)
- BEASTHOST: `<BEASTHOST>` (placeholder)
- MLATHOST: `<MLATHOST>` (placeholder)
- LAT: `xx.xxxxx`, LONG: `xx.xxxxx` (placeholders)

## Security context
- readOnlyRootFilesystem: false; runAsUser: 0; runAsGroup: 0
