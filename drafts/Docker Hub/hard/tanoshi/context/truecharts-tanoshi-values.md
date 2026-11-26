# trueforge truecharts tanoshi values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tanoshi/values.yaml (fetched 2026-11-26)
Also seen: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tanoshi (directory listing only; Chart.yaml and values.yaml not rendered there)

## Image
- Repository: `docker.io/faldez/tanoshi`
- Tag: `latest@sha256:bb6ce408c3786e33092fc59ef85d2221c16dc48c7b70eaf6bf8ec4df9701f1bf`
- PullPolicy: IfNotPresent

## Service
- Key `main`, port `main`: 80/tcp

## Persistence
- `directoryconfig` enabled, mount path `/tanoshi`

## Env
- None defined in values

## Security context (container)
- readOnlyRootFilesystem: false
- runAsUser: 0, runAsGroup: 0
- fsGroup: not set

## Notes
- Chart is for the faldez image (not luigi311). Chart is not maintained by upstream (per chart README).
- Chart install: `oci://oci.trueforge.org/truecharts/tanoshi`
