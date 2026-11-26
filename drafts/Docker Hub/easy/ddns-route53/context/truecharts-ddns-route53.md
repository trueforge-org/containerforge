# TrueCharts chart: ddns-route53

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ddns-route53 (directory; content read from raw `charts/stable/ddns-route53/values.yaml`) · 2026-11-26

## Values (as of fetch)
- Image: `docker.io/crazymax/ddns-route53`, tag `latest@sha256:8bb44744ea8b9656df08cf3ddfa9975943ec74e986e384a88bee22c2c3f4f80e`, pullPolicy `IfNotPresent`.
- Env (main container): `DDNSR53_CREDENTIALS_ACCESSKEYID` and `DDNSR53_CREDENTIALS_SECRETACCESSKEY` from secret `env-secrets`; `DDNSR53_ROUTE53_HOSTEDZONEID` = `ABCEEFG123456789` (placeholder); `DDNSR53_ROUTE53_RECORDSSET_0_NAME` = `ddns.example.com.` (placeholder); `DDNSR53_ROUTE53_RECORDSSET_0_TTL` = `"300"`; `DDNSR53_ROUTE53_RECORDSSET_0_TYPE` = `A`; `LOG_JSON` = `"false"`; `LOG_LEVEL` = `info`; `MAX_RETRIES` = `"3"`; `SCHEDULE` = `"*/30 * * * *"`.
- Secret `env-secrets` enabled (placeholder values, not recorded here).
- Service main and port disabled. Persistence: none.
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
- Probes: liveness, readiness, startup disabled.

## Contradictions / notes vs plan.md
- Chart uses rolling `latest`, as plan.md says. Chart sets `SCHEDULE` to `*/30 * * * *`, matching plan.md's chosen default. Chart runs as root with writable rootfs (plan.md's draft expectations match).
