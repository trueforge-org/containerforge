# TrueCharts chart: baikal

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/baikal/values.yaml (chart page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/baikal) · fetched 2026-11-26

## Container image
- repository `docker.io/ckulka/baikal`
- tag `0.10.1-nginx@sha256:434bdd162247cc6aa6f878c9b4dce6216e39e79526b980453b13812d5f8ebf4b`
- pullPolicy `IfNotPresent`

## Ports
Service main: port 10293, protocol http, targetPort 80.

## Env vars
`BAIKAL_SKIP_CHOWN: false` on the main container.

## User/UID & permissions
`runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`. `privileged` not set.

## Volumes/paths
- `config` at `/var/www/baikal/config`.
- `specific` at `/var/www/baikal/Specific`.

## Healthcheck/readiness
No probes defined.

## Contradictions with plan.md
- None. Port 80 target, BAIKAL_SKIP_CHOWN, and both volume paths match plan.md section 1 and the wrapper.
