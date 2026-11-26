# trueforge truecharts tonido values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tonido/values.yaml (fetched 2026-11-26)

## Image
- Repository: `docker.io/captinsano/tonido`
- Tag: `latest@sha256:e54a72a59edec5165184bed1f6dbc14679f00a2cd746353714468e9e263c3793`
- PullPolicy: IfNotPresent

## Service
- Key `main`: 10001/TCP -> targetPort 10001

## Persistence
- Volume `tonido` enabled, mount `/unRAID`

## Env
- None defined.

## Security context
- readOnlyRootFilesystem: false; runAsUser 0; runAsGroup 0 (runs as root).
