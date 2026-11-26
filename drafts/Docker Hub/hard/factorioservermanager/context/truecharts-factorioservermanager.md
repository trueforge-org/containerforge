# TrueCharts chart: factorioservermanager

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/factorioservermanager (directory not fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/factorioservermanager/values.yaml
- Fetched 2026-11-26

## Container image (values.yaml)
- `docker.io/ofsm/ofsm`, tag `latest@sha256:2b031bc1ec51e437a90b24266ce87f82362b4d16670e3804688610b4ac03b608`, pullPolicy IfNotPresent.

## Services
- `factorioport`: port 34197, targetPort 34197, protocol udp (enabled).
- `main`: port 8888, targetPort 80, protocol http.

## Persistence (no type)
- `config` -> `/opt/factorio/config`; `fsmmods` -> `/opt/factorio/mods`; `fsmsaves` -> `/opt/factorio/saves`. No `/opt/fsm-data` mount.

## Security context
- readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0. No podSecurityContext.

## Env vars
- None. No RCON or Factorio settings. No probes.
