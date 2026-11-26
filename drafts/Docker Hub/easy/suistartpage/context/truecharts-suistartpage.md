# TrueCharts: suistartpage chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/suistartpage (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/suistartpage/values.yaml)
**Fetched:** 2026-11-26

## Image
- Repository `docker.io/corneliousjd/sui-startpage`, tag `latest`, pinned by sha256 digest beginning `0a4728be5ebed65e501c23444cb3b1f65f7a96e3bb36cff08450b3be0f45934e`. Pull policy IfNotPresent.

## Service and ports
- Service `main`, port `main`: port **8489**, target port **80**, protocol tcp.

## Env
None defined.

## Persistence
- One volume `appdata` enabled, mount path `/usr/share/nginx/html`, no size specified.

## Security context (container)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false. runAsNonRoot not specified. Container runs as root with writable root filesystem.

## Probes
None defined.

## Other
- Schema directive points to `./values.schema.json`.
- Plan note: the PVC at `/usr/share/nginx/html` would hide the baked-in site in a ContainerForge image; the port changes from 80 (chart target) to 8080 (ContainerForge nginx base).
