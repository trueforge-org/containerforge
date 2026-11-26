# TrueCharts chart: chowdown (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/chowdown (repo path)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chowdown/values.yaml (fetched 2026-11-26)

## Image
- Repository `docker.io/gregyankovoy/chowdown`, tag `latest@sha256:7941ebe37bab142a05f7b241e2490fa2c60f3644b4327d4dbac82c7b0f73243c`, pullPolicy IfNotPresent.

## Ports
- Service `main`: port 4000/tcp (targetPort 4000).

## Security context
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false (matches plan.md "non-root: no").

## Persistence
- `config` volume enabled, mounted at `/config`.

## Env / probes
- No env vars and no probes defined in values.yaml.

## Gotchas
- Chart port is 4000, which differs from draft.md's "ports: 80/http". ContainerForge build uses 8080 (plan.md).
- Chart's values.yaml points to `./values.schema.json` (not fetched).
