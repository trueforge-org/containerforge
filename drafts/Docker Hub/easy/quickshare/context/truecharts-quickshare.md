# TrueCharts chart: quickshare

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/quickshare (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quickshare/values.yaml (fetched)

## Image
- repository `docker.io/hexxa/quickshare`, tag `latest@sha256:a47e01e8c3d25ce28b561452c9fee0bbecee4253e59846ad6430ce12ec09d26e`, pullPolicy IfNotPresent.

## Ports
- service main port 8686 tcp, targetPort 8686.

## Persistence
- `storagedata` enabled, mountPath `/quickshare/root`.

## securityContext (container)
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Env vars
- DEFAULTADMIN: `admin`
- DEFAULTADMINPWD: `"1234"`

## Probes
- None.

## Gotchas
- Chart default admin username `admin` differs from Docker Hub example `qs`.
