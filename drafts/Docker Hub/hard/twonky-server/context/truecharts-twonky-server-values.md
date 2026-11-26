# trueforge truecharts twonky-server values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/twonky-server/values.yaml (fetched 2026-11-26)

## Image
- Repository: `docker.io/dtjs48jkt/twonkyserver`
- Tag: `latest@sha256:dca3fd8e301d723d2c40785de23613733a23094c8799281b2d9befb59b803fe6`
- PullPolicy: IfNotPresent

## Service
- `main`: TCP 9000 -> 9000

## Persistence
- `config` enabled, mount `/config`
- `data` enabled, mount `/data`

## Env
- None defined.

## Security context
- readOnlyRootFilesystem: false; runAsUser 0; runAsGroup 0.
