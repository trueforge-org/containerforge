# trueforge truecharts trango values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/trango/values.yaml (fetched 2026-11-26)

## Image
- Repository: `docker.io/tak786/trango-self-hosted`
- Tag: `latest@sha256:ba9ffeb9152ccf7afe68d404f44fab1fdc7d461801f0504a52f33c7c3e818648`
- PullPolicy: IfNotPresent

## Service
- `main`: TCP 7755 -> container 80
- `hostport2` (enabled): TCP 5533 -> container 443

## Persistence
- `config` volume enabled, mount `/config`

## Env
- None defined.

## Security context
- readOnlyRootFilesystem: false; runAsUser 0; runAsGroup 0.
